% This file is the main script for getting the Grain Size Distribution of a sample of sediment particles.
% In order to use it, it is mandatory to have the pictures inside a folder called 'photos', located inside the
% same folder of this script. At the same time, the used functions must be also part of Matlab's path. The
% function 'filters.m' must be modified to get the best results with the specific set of photos. 
% IMPORTANT: It is required to have the Computer Vision Toolbox installed. Working with version R2020b.
% Based on the code developed by Rousseau & Pascal.

close all;
clear all;


% Useful parameters that must be changed based on the images' information
% xdim    = 2594; % Image's width
% ydim    = 1944; % Image's height

% Scale to convert between px to mm. It is recommended to get it by using Inkscape.
scale           = 79.7; % [pix/mm]
MinBlobArea     = 50;   % Minimal area for a particle to be considered as one. Not counted when is smaller. To filter possible noise.
MaxCount        = 200;  % Maximum number of particles to count per image.
sensitivity     = 0.66; % Sensitivity for binarization filter.
binsize         = 0.1;  % Bin width for grain diameter histogram.

% Entension of images files
extension = 'bmp';

% Get folder path, and creates output folder for the processed images.
mainfolder = pwd;
mkdir(fullfile(mainfolder, 'processed'));

%back=imread(fullfile(mainfolder,strcat('background.bmp'))); %

% Initialize some variables
minoraxis   = [];
majoraxis   = [];

% We get the list of photos to process
photo_list  = dir(fullfile(mainfolder, 'photos', strcat(['*.',extension])));

%% Analyzing all particles
% We go through the list of photos adding each particle to our data base 

for i = 1:length(photo_list)

    img = imread(fullfile(photo_list(i).folder, photo_list(i).name)); % Reads image
    x   = filters(img, sensitivity); % Filters image with customized filters. Modify depending of the set of images.
    imwrite(x,fullfile(mainfolder, 'processed', strcat('out_', photo_list(i).name))); % Exports images into output folder with a prefix
       
    % Using the Computer Vision Toolbox's tool Blob analyzer we get the parameters of each detected particle.
    obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
                'AreaOutputPort', true, 'CentroidOutputPort', true,'MajorAxisLengthOutputPort', true, ...
                'MinorAxisLengthOutputPort', true, 'OrientationOutputPort', true, ...
                'MinimumBlobArea', MinBlobArea,'MaximumCount', MaxCount); % Initialize blob analyzer object.

    [area, centroids, bboxes, major, minoraxis_p, orientation] = obj.blobAnalyser.step(~x); % Get parameters.
    
    % Append major and minor axis' values to their respective array.
    majoraxis   = cat(1, majoraxis, major);
    minoraxis   = cat(1, minoraxis, minoraxis_p);
end

% Convert axis values to real size [mm].
majoraxis_r = majoraxis/scale;
minoraxis_r  = minoraxis/scale;
%% Make curve
% With the particles detected, it makes finally the grain side distribution curve and export several outputs.
[D50, Volumes_mm3, ecdf, sortD] = gsd(minoraxis_r, majoraxis_r, binsize);