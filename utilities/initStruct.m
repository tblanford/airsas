function A = initStruct(nChans)

for nDexChan = nChans:-1:1
    A(nDexChan) = singleEmptyStruct;
end

end


function X = singleEmptyStruct


% Sensor Data
X.Data.tsRaw = nan;             % Raw recorded time series [nSamples x nPings]
X.Data.tsRC = nan;              % Data conditioned and replica correlated

% Acquistions & Environment Parameters
X.Params.fs = nan;              % Sample rate [Hz]
                                
X.Params.time = nan;           % Time [sec]
X.Params.position = nan;        % Position on track[m]                               
                               
X.Params.nSamples = nan;        % Number of time samples recorded
X.Params.nBits = nan;           % Bit depth of ADC
X.Params.nAverages = nan;       % Number of averages taken at each position
X.Params.temp = nan;            % nPosition x 2 vector of
                                % air temperature at each measurement [C]
X.Params.humidity = nan;        % n Position x 1 vector of relative humidity
                                % at each measurement, [%]
X.Params.soundSpeed = nan;      % Calculated sound speed in chamber [m/s]

X.Params.sysUnits = 'mks';      % System of units for variables
X.Params.angleUnits = 'deg';    % Units for angle variables

% Waveform Parameters
X.Wfm.pulseReplica = nan;       % Time series of the transmitted waveform
X.Wfm.fStart = nan;             % Start frequency [Hz]
X.Wfm.fStop = nan;              % Stop frequency [Hz]
X.Wfm.pulseLength = nan;        % Length of transmitted waveform [s]
X.Wfm.amplitude = nan;          % Amplitude of the transmitted waveform
                                % at the output of the DAQ, [V]
X.Wfm.winType = nan;            % String indicating type of window applied
                                % to the transmitted waveform. This string
                                % should be the same as the MATLAB command
                                % used to produce the window function
X.Wfm.winParams = nan;          % Parameters passed to the windowing function 
                                % applied to the transmitted waveform. The
                                % parameter order should match that of the
                                % MATLAB function used to create the window

% Hardware Parameters
X.Hardware.txPos = nan;         % Transmitter position [m] [x y z]
X.Hardware.rxPos = nan;         % Receiver position [m] [x y z]
X.Hardware.groupDelay = nan;    % Delay between start of recording and 
                                % transmission [samples]

% Output Image with Backprojection (BP)
X.Results.Bp.xVect = nan;       % x coordinate of the image [m]
X.Results.Bp.yVect = nan;       % y coordinate of the image [m]
X.Results.Bp.image = nan;       % Complex image of spatial domain (x,y)


end