%%cript to load AirSAS data from .h5 files and analyze the power spectra

clear all
close all

addpath(genpath('C:\Users\tblanford\OneDrive - USNH\Documents\MATLAB\modelFidelityATR\airsas'))

folder='D:\modelFidelityATR\data\experiment\dataSet'; %path to folder with the data
fileList={'t0e1_01.h5','t1e1_01.h5','t1e2_01.h5','t1e4_01.h5','noise_01.h5'}; %data files to load

chanSelect=1:4; %select which of the receiver channels to load
cSelect=0; %flag for which sound speed model to use.  0=temp only, 1=temp+humidity

indStart=451; %starting index of scattering from the scene
indStop=1500; %ending index of scattering from the scene
lWin=indStop-indStart+1; %length of window that encompasses these indices
nPings=1001; %number of pings to analyze

GxxVec=NaN(lWin,numel(chanSelect),numel(fileList)); %preallocate a vector for the single sided power spectral density



for n=1:numel(fileList)
    A=packToStruct(folder,fileList{n},chanSelect,cSelect); %load the data, and pre-process the time series for further processing
    for m=1:numel(chanSelect)
        [Gxx,fVec]=pwelch(A(m).Data.tsRC(indStart:indStop,:),rectwin(lWin),[],lWin,A(m).Params.fs);
        GxxVec(:,m,n)=mean(Gxx,2);
    end

end

%% Plot
figure(1)
tiledlayout(1,numel(chanSelect))
for m=1:numel(chanSelect)
    nexttile
    plot(fVec/1e3,10*log10(squeeze(GxxVec(:,m,:))),'LineWidth',2)
    xlim([0,50])
    ylim([-120,-60])
    xlabel('Frequency (kHz)')
    ylabel('Mean Power Spectral Density (dB re: 1 V^2/Hz)')
    grid on
    title(['Channel ',num2str(m)])
end
lg=legend('Free Field Background','Solid Spheres in Free Field','Solid Spheres on Flat Interface','Partially Buried Solid Spheres','Noise');
lg.Layout.Tile='south';
lg.Orientation='Horizontal';
set(gcf,'Position',[2.85,.85,1.52,.42]*1e3)