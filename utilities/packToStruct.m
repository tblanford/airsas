function [A] = packToStruct(folder,filename,chanSelect,cSelect)
%PACKTOSTRUCT Takes .h5 and .csv files with acoustic and non-acoustic
%AirSAS data and packs it into a Matlab structure for more convenient
%processing.  Additionally pre-processes the acoustic time series so it is
%suitable for image reconstruction
%   folder = path to folder where the data is stored
%   filename = name of .h5 file to load into structure
%   chanSelect = vector of channel numbers to load 
%   cSelect = flag for model to use 
%   A = output data structure

%pre-populate the data structure for the desired number of channels to load
A=initStruct(numel(chanSelect)); 

dPath=fullfile(folder,'scenes',filename); %path to .h5 file

%load the non-acoustic parameters
%first get the parameters stored in the .h5 file
P.temp=h5read(dPath,'/na/temperature');
P.humidity=h5read(dPath,'/na/temperature');
P.position=h5read(dPath,'/na/position');
P.soundSpeed=getAirSpeed(P,cSelect);
%next, get the data acquistion parameters
daqParams=readtable(fullfile(folder,'characterization data','acquistionParams.csv'));
P.fs=daqParams{1,2};
P.time=h5readatt(dPath,'/','collection_date');
[A.Params]=deal(P);
groupDelay=daqParams{2,2}; %group delay of the acquistion system, samples

sensorCoord=readmatrix(fullfile(folder,'characterization data','sensorCoordinates.csv'));
for n=1:numel(chanSelect)
    A(n).Hardware.rxPos=sensorCoord(chanSelect(n)+1,2:4);
    A(n).Hardware.txPos=sensorCoord(1,2:4);
    A(n).Hardware.groupDelay=groupDelay;
end

%load the waveform parameters
Wfm.pulseType='LFM';
Wfm.fStart=daqParams{8,2};
Wfm.fStop=daqParams{9,2};
Wfm.pulseLength=daqParams{10,2};
Wfm.amplitude=daqParams{11,2};
%reconstruct the transmitted waveform
pulseReplica=genLfm(Wfm.fStart,Wfm.fStop-Wfm.fStart,Wfm.pulseLength,P.fs);
win=tukeywin(Wfm.pulseLength*P.fs,daqParams{13,2});
Wfm.pulseReplica=pulseReplica.*win;
[A.Wfm]=deal(Wfm);

%pack the time series data
for n=1:numel(chanSelect)
    A(n).Data.tsRaw=h5read(dPath,['/ch',num2str(chanSelect(n)),'/ts']);
    
    % Some data conditioning
    A(n).Data.tsRC = A(n).Data.tsRaw;
    
    % Remove the DC bias
    A(n).Data.tsRC = A(n).Data.tsRC - mean(A(n).Data.tsRC);
    
    % Remove the group delay of the acquisition system
    A(n) = removeGroupDelay(A(n));

    % Remove the direct path transmission from speaker to microphone
    A(n) = txBlanker(A(n));

    %Apply a bandpass filter
    bandEdge = min([A(n).Wfm.fStart A(n).Wfm.fStop]);
    if bandEdge(1)>=5e3
        b = AirsasHpf(bandEdge-2e3,bandEdge,A(n).Params.fs);
        A(n).Data.tsRC = filter(b,1,A(n).Data.tsRC);
        A(n).Data.tsRC = circshift(A(n).Data.tsRC,-(length(b)-1)/2,1);
    end
    
    %Write the matched filter output to the structure
    A(n).Data.tsRC = mfilt(A(n).Data.tsRC,A(n).Wfm.pulseReplica);

end

end

%-----------------------------------------------------------------------


function data = mfilt(data,pulseReplica)
% This subfunction replica correlates the data with the transmitted
% waveform to perform pulse compression.  The resulting data is output as a
% complex-valued timeseries.

%use the hilbert transform to produce an analytic (complex-valued) version of the signal
data = hilbert(data); 

nPtsData = size(data,1);
nPtsMfk = length(pulseReplica);

data(1:nPtsMfk,:) = 0;

nFFT = nPtsData+nPtsMfk-1; %number of points in the FFT to prevent wrap errors
filterKernelF = fft(hilbert(pulseReplica(:)),nFFT);

dataF = fft(data,nFFT,1);
dataF = dataF.*conj(filterKernelF);
data = ifft(dataF,[],1);

data = data(1:nPtsData,:);

end

function A = removeGroupDelay(A)
% This sub-function removes the the group delay of the data acquisition
% system. It ensures that real input data results in real output data.

data = fft(A.Data.tsRC,[],1);
nT = size(data,1);

freqVec = freqVecGen(nT,A.Params.fs).';
groupDelay_s = A.Hardware.groupDelay/A.Params.fs; %group delay in seconds

% Calculate the phase ramp that will be applied to the Fourier transform of
% the recorded data.
delayRamp = exp(1i*2*pi*freqVec*groupDelay_s);

% If the input data is purely real, the phase of the -fs/2
% bin must be zero prior to the ifft. This guarantees that.
    if rem(nT,2)==0
        delayRamp(nT/2+1) = real(delayRamp(nT/2+1));
    end

A.Data.tsRC  = ifft(data.*delayRamp,[],1);

end


function A = txBlanker(A)
% This subfunction zeros out ("blanks") the portion of the received waveforms that
% correspond to when the transmitter was emitting the pulse.  
    for nDex = 1:numel(A)       
        
        pulseReplicaLength = A(1).Wfm.pulseLength .* A(1).Params.fs;
        
        if rem(pulseReplicaLength,1)~=0
            error('PP_AIRSAS: Pulse length not an integer sample length')
        end
        
        blankLength = pulseReplicaLength;
        
        blanker = ones(size(A(nDex).Data.tsRC,1),1);
        blanker(1:blankLength) = 0;
        blanker(blankLength+1 : blankLength + pulseReplicaLength) = ...
            (sin(linspace(-pi/2,pi/2,pulseReplicaLength))+1)/2;
        
        A(nDex).Data.tsRC = A(nDex).Data.tsRC .* blanker;
    end
end

function b = AirsasHpf(filterStop,filterPass,fs)
%PPAIRSASHPF Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 9.7 and Signal Processing Toolbox 8.3.
% Generated on: 01-Jun-2020 17:18:14

% Equiripple Highpass filter designed using the FIRPM function.

Dstop = 0.01;             % Stopband Attenuation
Dpass = 0.0057563991496;  % Passband Ripple
dens  = 20;               % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([filterStop, filterPass]/(fs/2), [0 1], [Dstop, Dpass]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
end
