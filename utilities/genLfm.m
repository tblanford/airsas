function sig = genLfm(fStart, bw, tau, fs)
%GENLFM Generates a real-valued linear frequency modulated (LFM) chirp
%   fStart = starting frequency of chirp, Hz
%   bw = bandwidth of chirp (negative number for downchirp), Hz
%   tau = duration of chirp, s
%   fs = sampling rate, Hz
%   sig = real-valued LFM chirp

nSamp = round(tau*fs); %number of samples in the chirp
t  = (0 : nSamp-1).'/fs; %time vector, s
B  = 0.5*bw/tau; %frequency modulation factor
sig  = sin(2*pi*(fStart + B*t).*t);
