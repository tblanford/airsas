function [] = plotSasImage(A,dynamicRange,normFlag)
%PLOTSASIMAGE Makes plot of linear AirSAS image
%   A = Single-channel AirSAS data structure
%   dynamicRange = dynamic range of the image to display
%   normFlag = range-dependent normalization flag (1=apply range
%   normalizaiton, 0=no normalization)

if ~exist("normFlag")
    normFlag=1;
end

if normFlag
    rNorm=20*log10(repmat(A.Results.Bp.yVect,numel(A.Results.Bp.xVect),1)).';
else
    rNorm=0;
end

img=20*log10(abs(A.Results.Bp.image))+rNorm;

imagesc(A.Results.Bp.xVect, A.Results.Bp.yVect, img)
set(gca,'YDir','reverse') 
set(gca,'XDir','reverse') 
clim([-dynamicRange,0]+max(img(:)));
xlabel('Along Track (m)')
ylabel('Cross Track (m)')
colormap(sasColormap)
axis image

h=colorbar;
if normFlag
    ylabel(h,'Amplitude (dB re: 1V @ 1m)')
else
    ylabel(h,'Amplitude (dB re: 1V)')
end
end