timepoints = 17;
positions = 5;
slices = 91;%these are # of slices -1, the number on the file
path ='/Volumes/Seagate Backup Plus Drive/Good images/';

%This is how to do it with the thresholds calculated from analyzing the
%thresholds from previous analysis
%SaThreshold = ones(18,1)*0.2143;%threshold from time 4 
%SaThreshold = .18154:0.00819:(.18154+0.00819*17);%trial 1 /resultsByTime
%SaThreshold = .1909:-0.00386:(.1909-0.00386*17);%trial 2 /resultsByTime1
SaThreshold = .1909:-0.00819:(.1909-0.00819*17);%trial 3 /resultsByTime2

SaThreshold1 = .1909:-0.00819:(.1909-0.00819*17);%trial 4 /resultsByTime3
SaThreshold2 = .1909:-0.00919:(.1909-0.00919*17);%trial 5 /resultsByTime4
SaThreshold3 = .1909:-0.01019:(.1909-0.01019*17);%trial 6 /resultsByTime5
SaThreshold4 = .1909:-0.01119:(.1909-0.01119*17);%trial 7 /resultsByTime6
SaThreshold5 = .1909:-0.01119:(.1909-0.01219*17);%trial 8 /resultsByTime7

%batchData(path, slices, timepoints, positions, SaThreshold1, 'resultsByTime3')
%batchData(path, slices, timepoints, positions, SaThreshold2, 'resultsByTime4')
%batchData(path, slices, timepoints, positions, SaThreshold3, 'resultsByTime5')
%batchData(path, slices, timepoints, positions, SaThreshold4, 'resultsByTime6')
batchData(path, slices, timepoints, positions, SaThreshold5, 'resultsByTime7')

Pa14wtThreshold = ones(18,1)*0.081486;
Pa14mutThreshold = ones(18,1)*0.077379;
function batchData(path,slices, timepoints, positions, SaThresh, outfolder) 
GetImageDataByTime(path, '3-13-19', '62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-13-19', slices, timepoints, positions, SaThresh,outfolder);
GetImageDataByTime(path, '3-19-19', '62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-19-19', slices, timepoints, positions, SaThresh,outfolder);                                           
GetImageDataByTime(path, '4-17-19', '62x_Salac_Pa14wt_SaPa14wt1-11-10100-110-1_co_SCFM2_tile2x2_4-17-19', slices, timepoints, positions, SaThresh,outfolder);
                                           
GetImageDataByTime(path, '4-24-19', '62x_Salac_Pa14pqsLclean_SaPa14pqsLclean=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_4-24-19', slices, timepoints, positions, SaThresh,outfolder);
GetImageDataByTime(path, '4-25-19', '62x_Salac_Pa14pqsLclean_SaPa14pqsLclean=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_4-25-19', slices, timepoints, positions, SaThresh,outfolder);
GetImageDataByTime(path, '5-8-19', '62x_Salac_Pa14pqsLclean_SaPa14pqsLclean=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_5-8-19', slices, timepoints, positions, SaThresh,outfolder);
end
function GetImageDataByTime(path, date, name, slices, timepoints,positions, thR, outputFolder)
tic 
%at this point I only care about the third position so I am copying line
%inside the loop and putting it out...
%{
    for position = 0:positions
        %[thR,thG] = CollectThresholds(path, date, name, slices, timepoints, position);
        ThresholdImage(path, date, name, slices, timepoints, position,thR,thG);
        toc
    end
%}
ThresholdImage(path, date, name, slices, timepoints, 2,thR,outputFolder);
toc
end

function GetImageData(path, date, name, slices, timepoints, positions)
tic    
    for position = 0:positions
        [thR,thG] = CollectThresholds(path, date, name, slices, timepoints, position);
        ThresholdImage(path, date, name, slices, timepoints, position,thR,thG);
        toc
    end
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
            filename = strcat(path, date,'/', name, '/', name, '_z', GetSlice(slice), '_t', GetSlice(timepoint),'_p', num2str(position));            
            I = stitchImage(filename);%opens image in a range of 0 to 1
            %extract individual channels
            ImR = squeeze(I(:,:,1));
            ImG = squeeze(I(:,:,2));
            %get histogram
            [countsR] = imhist(ImR);
            [countsG] = imhist(ImG);
            %add pixels of stack to total pixels
            totalCountsR= totalCountsR+countsR;
            totalCountsG= totalCountsG+countsG;
            %binarize using "global" algorithm     
        end
        ThresholdRed(timepoint+1)=otsuthresh(totalCountsR);%this correction is because matlab starts at 1 and timepoints at 0
        ThresholdGreen(timepoint+1)=otsuthresh(totalCountsG);
    end
    fileName = strcat(path, date,'/threshold_p_',num2str(position),'.csv');
    thresholdArray = cat (2,ThresholdRed,ThresholdGreen);
    csvwrite(fileName,thresholdArray)
end

function ThresholdImage(path, date, name, slices, timepoints, position, redThreshold,outfolder)
imagesfilepath = strcat(path, date,'/imagesByTime');%declare name of directory to put images in
[~,~] = mkdir(imagesfilepath);%create directory if it hasn't been created. double wiggly thing is to prevent it from throwing warning
resultsfilePath = strcat(path, date,'/',outfolder);
[~,~] = mkdir(resultsfilePath);

for timepoint = 0:timepoints
    singleColorResults = zeros(slices,3);%this is here for the simple version of the code without overlapping aggregate data
    for slice = 0:slices
        filename = strcat(path, date,'/', name, '/', name, '_z', GetSlice(slice), '_t', GetSlice(timepoint),'_p', num2str(position));            
        I = stitchImage(filename);%collects tile of 4 images and opens in a range of 0 to 1
        %extract individual channels...
        %single channel
        ImR = squeeze(I(:,:,1));
        %ImG = squeeze(I(:,:,2));
        %ImB = squeeze(I(:,:,3));
        %binarize using "global" algorithm and global threshold
        ImRiB = imbinarize(ImR,redThreshold(timepoint+1));
        %ImGiB = imbinarize(ImG,greenThreshold(timepoint+1));
        %clean up image using maximum object size
        ImNeR = (bwareaopen(ImRiB,10));
        %ImNeG = (bwareaopen(ImGiB,10));
        singleColorResults(slice+1,1)= nnz(ImNeR);%this puts the red pixels in the results spreadsheet
        %singleColorResults(slice+1,2)= nnz(ImNeG);%this puts the green pixels in the results spreadsheet
        singleColorResults(slice+1,3)= slice;%this puts the slice number in the results spreadsheet
        %{ 
        %this part is to save the images, but I don't want to do this at this point
        %combine channels
        rgbImG = cat(3,ImNeR,ImNeG,ImB);
        imageName = strcat(imagesfilepath,'/t',GetSlice(timepoint),'_p',num2str(position),'_s',GetSlice(slice),'.tif');%create image name to store
        imwrite(rgbImG,imageName);%save image
        %}   
    end
    resultsfilename = strcat(resultsfilePath,'/t',GetSlice(timepoint),'_p',num2str(position),'.csv');
    csvwrite(resultsfilename,singleColorResults)
end
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