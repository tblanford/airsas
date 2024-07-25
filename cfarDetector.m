%% CFAR detector
%This code runs a constant false alarm rate detector on SAS imagery and
%estimates the target positions and dimensions from the detections.
clear all
close all

%% Setup data path
folder=''; %specify the folder containing the dataset prior to execution


dataList=dir(fullfile(folder,'scenes','t*.h5')); %get all data corresponding to scenes (ignore noise recording)
excludeList=[dir(fullfile(folder,'scenes','t0*'))]; %don't run detections on scenes without targets

dataList(contains(string({dataList.name}),string({excludeList.name})))=[];

%% Setup Detector
p = .1e-6; %probability of false alarm 
nGuard=6; %number of guard cells per side
nTrain=10; %number of training cells per side

detector = phased.CFARDetector2D('TrainingBandSize',[nTrain,nTrain], ...
    'ThresholdFactor','Auto','GuardBandSize',[nGuard,nGuard], ...
    'ProbabilityFalseAlarm',p,'Method','SOCA','ThresholdOutputPort',true);

%% Define some parameters for analysis
chipLx=.5;  %chip dimension, along-track
chipLy=.5;  %chip dimesion, cross-track

%nominal positions of the targets (x,y,z), [m]
targPos=[-1.125,.866,0;
                -.375,.866,0;
                .375,.866,0;
                1.125,.866,0;
                -.75,1.616,0;
                0,1.616,0;
                .75,1.616,0]+[2.75,0,0];

lBox=12*.0254; %dimension of box for target placement, m
targList={'Solid Sphere','Hollow Sphere','O','Q'}; %list of target types
envList={'Free Field','Flat Interface','Rough Interface','Partially Buried'}; %list of environment/background types
targDimY=[4,4,8,8]*.0254; %nominal dimensions of each target in Y
targDimX=[4,4,8,9.8532]*.0254; %nominal dimensions of each target in X

%% Preallocate results matrices
centerX=NaN(length(dataList),7);
centerY=NaN(length(dataList),7);
dimX=NaN(length(dataList),7);
dimY=NaN(length(dataList),7);
%% Loop over all data, detect target pixels, and extract results

for m=1:length(dataList)


filename=dataList(m).name;
dPath=fullfile(folder,'scenes',filename);

loadCh=1; %data channel to load

sasImg=h5read(dPath,['/ch',num2str(loadCh),'/img_re'])...
    +1j*h5read(dPath,['/ch',num2str(loadCh),'/img_re']); %complex-valued SAS image
xVec=h5read(dPath,'/na/xVec'); %vector of pixels coordinates in the along-track direction, m
yVec=h5read(dPath,'/na/yVec'); %vector of pixels coordinates in the cross-track direction, m

%the reconstructed imagery is spatially oversampled.  The images will be
%decimated to be critically sampled prior to detection.
ratio=3;
xVec=xVec(1:ratio:end);
yVec=yVec(1:ratio:end);
sasImg=sasImg(1:ratio:end,1:ratio:end);

%Apply range normalization to the SAS image to account for the decaying
%intensity with increasing range from the sensor.
rNorm=(repmat(yVec,numel(xVec),1));
sasImg=sasImg.*rNorm;



%% Run detector
%determine the first and last columns and rows of the image that can be
%detected (accounting for training and guard cells)
colStart = nTrain + nGuard + 1; 
colEnd = size(sasImg,1) - ( nTrain + nGuard);
rowStart = nTrain + nGuard + 1;
rowEnd = size(sasImg,2) - ( nTrain + nGuard);
[X,Y]=meshgrid(colStart:colEnd,rowStart:rowEnd);
cutIdx=[X(:),Y(:)]'; %indices of cells under test.
nCutCells = size(cutIdx,2); %number of cells under test

[dets,th] = detector(abs(sasImg).^2,cutIdx); %detections and the threshold used for each cell


%% Assemble detection image
%The detections are currently a vector.  Reshape into an image that is the
%same size as the original SAS image.
detImg = zeros(size(sasImg));

for k = 1:nCutCells
    detImg(cutIdx(1,k),cutIdx(2,k)) = dets(k);
end


%% Extract size and position data from detections
%This is doen by defining a large chip around the nominal position of each
%target.  The detections within this chip, aside from false alarms, will
%correspond to the detected pixels for the particular target.  From those
%detections we can extract information about the position and dimensions.

dx=mean(diff(xVec)); %pixel spacing in the x-direction
dy=mean(diff(yVec)); %pixel spacing in the y-direction

%assemble an x- and y- vector of indices about the center of a chip chip
chipIndX=floor(-chipLx/dx/2:chipLx/dx/2); 
chipIndY=floor(-chipLy/dy/2:chipLy/dy/2);

%loop over all of the nominal target positions, extract the chip, and
%estimate the position and dimensions of the target.
for n=1:length(targPos)
    centerChipXInd=round((targPos(n,1)-min(xVec))/dx);
    centerChipYInd=round((targPos(n,2)-min(yVec))/dy);
    chipX=centerChipXInd+chipIndX; %bounding box of chip
    chipY=centerChipYInd+chipIndY;

    [detX,detY]=find(detImg(chipX,chipY)); %get all of the pixels with a detection
    
    centerX(m,n)=mean(detX);
    centerY(m,n)=mean(detY);
    dimX(m,n)=std(detX);
    dimY(m,n)=std(detY);

end
end

%% Plot the estimated positions of the centers of each target

figure(1)
tiledlayout(4,4);
for e=1:4
    for t=1:4
        ind=contains(string({dataList.name}),['t',num2str(t),'e',num2str(e)]);
        nexttile
        scatter(centerX(ind,:)*dx-chipLx/2+targPos(:,1).',centerY(ind,:)*dy-chipLy/2+targPos(:,2).','filled')
        hold on
        for n=1:length(targPos) %draw a bounding box around where the targets were placed
        rectangle('Position',[targPos(n,1)-lBox/2,targPos(n,2)-lBox/2,lBox,lBox])
        end
        hold off
        axis image
        xlim([1.25,4.25])
        ylim([0.5,2])
        xlabel('Along-track Position (m)')
        ylabel('Cross-track Position (m)')
        title({envList{e},targList{t}})
        grid on
    end
end

%% Plot the estimated dimensions of each target 
figure(2)
tiledlayout(4,4)
for e=1:4
    for t=1:4
        ind=contains(string({dataList.name}),['t',num2str(t),'e',num2str(e)]);
        nexttile
        histogram(2*dimX(ind,:)*dx,'BinEdges',linspace(0,35,50)*dx)
        hold on
        histogram(2*dimY(ind,:)*dy,'BinEdges',linspace(0,35,50)*dy)
        yMax=max(ylim);
        plot([targDimX(t),targDimX(t)],[0,yMax],'-k','LineWidth',2)
        plot([targDimY(t),targDimY(t)],[0,yMax],'--r','LineWidth',2)
        hold off
        grid on
        xlabel('Dimension (m)')
        ylabel('Counts')
        title({envList{e},targList{t}})
    end
end
lg=legend('Along-track','Cross-track','Orientation','horizontal');
lg.Layout.Tile='south';