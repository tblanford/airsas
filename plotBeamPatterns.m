%% Plot beam patterns
%This script plots polar plots of the transducer beam patterns

clear all
close all

dataFolder=''; %specify the path to the dataset folder before execution

dynamicRange=40; %dynamic range to plot

%% Load and plot the speaker directivity
speakerIn=readmatrix(fullfile(dataFolder,'characterization data','speakerPattern.csv'));
angSpkr=speakerIn(:,1)*pi/180; %angle, radians
speakerPat=20*log10(speakerIn(:,2:4));
speakerPat(speakerPat<-dynamicRange)=NaN;
figure(1)
polarplot(angSpkr,speakerPat,'LineWidth',2)
rlim([-40,0])
legend('10 kHz','20 kHz','30 kHz','Location','southoutside','Orientation','horizontal')
rticklabels({'','','-20 dB','-10 dB','0 dB'})
ax=gca;
ax.RAxisLocation=230;
%% Load and plot the microphone directivity
micIn=readmatrix(fullfile(dataFolder,'characterization data','micPattern.csv'));
angMic=micIn(:,1)*pi/180; %angle, radians
micPat=20*log10(micIn(:,2:4));
micPat(micPat<-dynamicRange)=NaN;
figure(2)
polarplot(angMic,micPat,'LineWidth',2)
rlim([-40,0])
legend('10 kHz','20 kHz','30 kHz','Location','southoutside','Orientation','horizontal')
rticklabels({'','','-20 dB','-10 dB','0 dB'})
ax=gca;
ax.RAxisLocation=230;