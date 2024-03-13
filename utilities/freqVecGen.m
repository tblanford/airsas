function freqVec=freqVecGen(Nt,fs)
% FREQVECGEN Generates a vector of frequencies that correspond to the
% elements of an FFT with Nt samples at fs sampling rate.  This function
% works for both odd and even length signals.  The frequencies are arranged
% in order of positive frequencies (0 to fs/2) followed by the negative
% frequencies (-fs/2 to 0-df)
%
% Nt = Number of samples
% fs - Sampling frequency
% freqVec - Vector of frequencies
%


df=fs/Nt; %frequency step

if rem(Nt,2)==0 %for even numbers of points
    freqVec=(-Nt/2:(Nt/2-1))*df;
else %for odd numbers of points
    Nt=Nt-1;
    freqVec=(-Nt/2:Nt/2)*df;
end

freqVecSwap = freqVec;

posFreqMask = freqVecSwap>=0;

freqVec = [freqVecSwap(posFreqMask) freqVecSwap(~posFreqMask)];


end