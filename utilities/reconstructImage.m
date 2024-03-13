function A = reconstructImage(A, r, img_plane,fov)
%bpLAirSAS Reconstructs a SAS image using backprojection
% Inputs:
% A = structure with preprocessed data (from pp_airsas)
% r = upsampling ratio
% img_plane = coordinate along the z-axis at which to beamform
% fov = field of view of transmitter (degrees)
% 
% Outputs:
% A = structure with backprojection data added



% Extract variables
c   = A.Params.soundSpeed; %sound speed, m/s
fs  = A.Params.fs; %sampling rate, Hz

n_pings = length(A.Params.position); %number of pings in the data


% Resample the data 
data = resample(A.Data.tsRC, r, 1); %upsample the data so it is oversampled for nearest-neighbor interpolation
recording_scope = size(data, 1); %get the dimensions in indices of the data matrix

% Define the scene extent:
x   = A.Results.Bp.xVect;
y   = A.Results.Bp.yVect;
img = zeros(length(y), length(x)); %pre-allocate the image matrix

% All pixel coordinates:
[Xs, Ys] = meshgrid(x, y);

% Backprojection (delay and sum)
% The backprojection algorithm finds the complex-valued sample from each
% ping that contributes to each pixel.  The samples corresponding to each
% pixel are summed together.

for ping = 1:n_pings
    
    m_position=A.Params.position(ping); %position of the array along the track
    %----------------------------------------------------
    % Calculate the distances from every pixel to Tx, Rx.
    % Get Rx and Tx positions
    Rx = A.Hardware.rxPos + [m_position, 0, 0]; %position of the receiver on the track
    Tx = A.Hardware.txPos + [m_position, 0, 0]; %position of the transmitter on the track
    
    % Compute distance from Tx to each pixel and back to
    %  Rx (all pixels computed in parallel):
    distMtx =  sqrt((Xs - Tx(1)).^2      ...
                 +  (Ys - Tx(2)).^2      ...
                 +  (img_plane - Tx(3)).^2)       ...
              +                          ...
               sqrt((Xs - Rx(1)).^2      ...
                 +  (Ys - Rx(2)).^2      ...
                 +  (img_plane - Rx(3)).^2);

    thetaMtx=atand((Xs - Tx(1))./(Ys - Tx(2))); %azimuthal angle from the transmitter to the pixel
    
    %The position in the time series that corresponds to the center of a
    %pixel is likely not an integer-number sample.  Nearest neighbor
    %interpolation is used to find the closest sample
    time_indices = round(distMtx/c(ping)*fs*r);
    % If the nearest sample is outside the recording scope, set it to the
    % max index.  This is done for execution speed.
    times = min(time_indices, recording_scope);

    % Isolate the ping so it can be efficiently indexed w/time_indices:
    p_data = data(:, ping);
    ping_contributions = p_data(times);
    %ping_contributions can have values that should be discarded.  The
    %first are values that from indices that were outside the scope of the
    %recording, but set to the max index.  The second are from outside the
    %prescribed field of view of transmitter.  Those values, while 
    %numerically valid, are primarily noise and could degrade the image
    ping_contributions = ping_contributions .* ...
                         (time_indices < recording_scope).*...
                         (abs(thetaMtx) < fov/2);
                     
    % Accumulate energy from n-th ping into all pixels at once
    img = img + ping_contributions;
end

% Pass the image to the data structure
A.Results.Bp.image = img;

end