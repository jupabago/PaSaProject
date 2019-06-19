function image = GetImageData(name,date)
slices = 91;
timepoints = 17;
positions = 5;
path = '/nv/hp10/jbarraza6/scratch/RawDataMicroscope';
    for position = 0:positions
        [thR,thG] = CollectThresholds(path, date, name, slices, timepoints, position);
        ThresholdImage(path, date, name, slices, timepoints, position,thR,thG);
    end
    image = 1;
end


function [ThresholdRed,ThresholdGreen] = CollectThresholds(path, date, name, slices, timepoints, position)
%This function gives you the red and green thresholds of each timepoint per
%position
    ThresholdRed = zeros(timepoints+1, 1);%this is a list where the threshold of each stack is stored    
    ThresholdGreen = zeros(timepoints+1, 1);
    for timepoint = 0:timepoints
        totalCountsR = zeros(256,1);%creates array to store histograms
        totalCountsG = zeros(256,1);
        for slice = 0:slices
            filename = strcat(path, '/', name, '/', name, '_z', GetSlice(slice), '_t', GetSlice(timepoint),'_p', num2str(position));
            I = stitchImage(filename);%opens image in a range of 0 to 1
            %extract individual channels
            ImR = squeeze(I(:,:,1));
            ImG = squeeze(I(:,:,2));
            %change range
            ImR1 = mat2gray(ImR);%this rescales the range of intensities of the image, bioasing the results...
            ImG1 = mat2gray(ImG);
            %get histogram
            [countsR] = imhist(ImR1);
            [countsG] = imhist(ImG1);
            %add pixels of stack to total pixels
            totalCountsR= totalCountsR+countsR;
            totalCountsG= totalCountsG+countsG;
            %binarize using "global" algorithm     
        end
        ThresholdRed(timepoint+1)=otsuthresh(totalCountsR);%this correction is because matlab starts at 1 and timepoints at 0
        ThresholdGreen(timepoint+1)=otsuthresh(totalCountsG);
    end
    fileName = strcat('/nv/hp10/jbarraza6/data/Matlab/Mat2Gray/Output/Thresholds/',date,'/threshold_p_',num2str(position),'.csv');
    thresholdArray = cat (2,ThresholdRed,ThresholdGreen);
    csvwrite(fileName,thresholdArray)
end

function thresholdedImages = ThresholdImage(path, date, name, slices, timepoints, position, redThreshold,greenThreshold)
imagesfilepath = strcat('/nv/hp10/jbarraza6/scratch/matDataMicroscope/', date,'/Images');%declare name of directory to put images in
[~,~] = mkdir(imagesfilepath);%create directory if it hasn't been created. double wiggly thing is to prevent it from throwing warning
resultsfilePath = strcat('/nv/hp10/jbarraza6/data/Matlab/Mat2Gray/Output/Results', date);
[~,~] = mkdir(resultsfilePath);

for timepoint = 0:timepoints
    totalSegments=0;%this is here for the overlapping aggregates chunk
    results = zeros(1,5);%this is here for the overlapping aggregates chunk
    singleColorResults = zeros(slices,3);%this is here for the simple version of the code without overlapping aggregate data
    for slice = 0:slices
        filename = strcat(path, date,'/', name, '/', name, '_z', GetSlice(slice), '_t', GetSlice(timepoint),'_p', num2str(position));
        I = stitchImage(filename);%collects tile of 4 images and opens in a range of 0 to 1
        [r, c, p] = size(I);%store size of picture
        %extract individual channels...
        %single channel
        ImR = squeeze(I(:,:,1));
        ImG = squeeze(I(:,:,2));
        ImB = squeeze(I(:,:,3));
        %binarize using "global" algorithm and global threshold
        ImRiB = imbinarize(ImR,redThreshold(timepoint+1));
        ImGiB = imbinarize(ImG,greenThreshold(timepoint+1));
        %clean up image using maximum object size
        ImNeR = (bwareaopen(ImRiB,10));%Global algorithm
        ImNeG = (bwareaopen(ImGiB,10));
         %combine channels
 %combine channels
        rgbImG = cat(3,ImNeR,ImNeG,ImB);%Global algorithm

        imageName = strcat(imagesfilepath,'/t',GetSlice(timepoint),'_p',num2str(position),'_s',GetSlice(slice),'.tif');%create image name to store
        imwrite(rgbImG,imageName);%save image
        singleColorResults(slice+1,1)= nnz(ImNeR);%this puts the red pixels in the results spreadsheet
        singleColorResults(slice+1,2)= nnz(ImNeG);%this puts the green pixels in the results spreadsheet
        singleColorResults(slice+1,3)= slice;%this puts the slice number in the results spreadsheet
    end
    resultsfilename = strcat(resultsfilePath,'/t',GetSlice(timepoint),'_p',num2str(position),'.csv');
    csvwrite(resultsfilename,singleColorResults)

end
       thresholdedImages = 1;
end

function slice = GetSlice(idx)
if(idx>=10)
    slice =num2str(idx);
else
    slice = strcat('0', num2str(idx));
end
end

function I = stitchImage(name) %This function stitches the tiles and returns a 2D matrix of channel specified,
IA = im2double(imread(strcat(name,'_m0.tif')));
IB = im2double(imread(strcat(name,'_m1.tif')));
top = cat(2, IA,IB);
IC = im2double(imread(strcat(name,'_m2.tif')));
ID = im2double(imread(strcat(name,'_m3.tif')));
bottom = cat(2, IC,ID);
I = cat(1,top,bottom);
end
                  
