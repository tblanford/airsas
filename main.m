%Script to load AirSAS data from .h5 file, process it, and plot the results

clear all
close all

%% Setup the paths to the data file for processing and analysis

folder='D:\modelFidelityATR\data\experiment\dataSet'; %path to folder with the data
filename='t1e4_01.h5'; %data file to load
dPath=fullfile(folder,filename);
%% Load and Plot a SAS Image
%One of the simplest interactions with the data is to load the
%reconstructed imagery from a single channel and plot it.  

%load and plot a SAS image
loadCh=1; %data channel to load
sasImg=h5read(dPath,['/ch',num2str(loadCh),'/img_re'])...
    +1j*h5read(dPath,['/ch',num2str(loadCh),'/img_re']); %complex-valued SAS image
xVec=h5read(dPath,'/na/xVec'); %vector of pixels coordinates in the along-track direction, m
yVec=h5read(dPath,'/na/yVec'); %vector of pixels coordinates in the cross-track direction, m

%plot the magnitude of the image
figure(1)
imagesc(xVec,yVec,20*log10(abs(sasImg)'))
set(gca,'YDir','normal')
xlabel('Along-track (m)')
ylabel('Cross-track (m)')
clim([0,30])

%% Load the complete set of data and pre-process the time series
% Here the raw acoustic data, along with all of the non-acoustic parameters
% are loaded and pre-processed
chanSelect=1:4; %select which of the receiver channels to load
cSelect=0; %flag for which sound speed model to use.  0=temp only, 1=temp+humidity
A=packToStruct(folder,filename,chanSelect,cSelect); %load the data, and pre-process the time series for further processing

%% Reconstruct an image from the data using backprojection

%Define parameters for reconstructing the imagery
cross_track = [0.1, 2.4]; %bounds of the imagery in the cross-track direction, m
dy=3e-3; %pixel size in the cross-track direction, m
along_track = [0.3,   5.3]; %bounds of the imagery in the along-track direction, m
dx=3e-3; %pixel size in the along-track direction, m
img_plane = .6032; %elevation of imaging plane, m

resampling_ratio = 10; %upsampling ratio prior to nearest neighbor interpolation
fov=120; %field of view from the transmitter to the pixel to include in the integration, degrees

%Define plotting  parameters for displaying the imagery
normFlag=1; %flag to apply 30*log10(r) range normalization to the imagery 
% (1 = normalization on, 0 = normalization off)
dynamicRange=35; %dynamic range to display in the image, dB

for m=1:numel(chanSelect)
    %pass the image reconstruction parameters to the data structure
    A(m).Results.Bp.xVect=along_track(1):dx:along_track(2); 
    A(m).Results.Bp.yVect=cross_track(1):dy:cross_track(2);
    A(m).Results.Bp.zPlane=img_plane;
    A(m).Results.Bp.fov=fov;

    %reconstruct the imagery
    A(m) = reconstructImage(A(m), resampling_ratio, img_plane,fov);
    disp(['Backprojection of Channel ',num2str(chanSelect(m)),' Complete'])

    %plot the reconstructed imagery
    figure()
    plotSasImage(A(m),dynamicRange,normFlag)
    drawnow
end