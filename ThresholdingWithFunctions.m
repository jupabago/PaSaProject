timepoints = 17;
positions = 5;
slices = 91;%these are # of slices -1, the number on the file
path ='/Volumes/Seagate Backup Plus Drive/Good images/';

%{        
filename = stitchImage(strcat(path, date, '/',name, '/', name, '_z', GetSlice(22), '_t', GetSlice(8),'_p', num2str(0))); 
imred = squeeze(filename(:,:,1));
imred = imbinarize(imred);
[labels1,numLabels1] = bwlabel(imred);
%}

%[thR,thG] = CollectThresholds(path, date, name, 40, 1, 4);
%testThresholdImage = ThresholdImage(path, date, name, 40, 1, 4);
%[thR,thG] = CollectThresholds(path, date, name, slices,17, 4);
%testThresholdImages = ThresholdImage(path, date, name, slices, 17, 4,thR,thG);

%{
%This is how to run the script while you calculate the threshold per image:
pa14wt_1 = GetImageData(path, '3-13-19', '62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-13-19', slices, timepoints, positions);
pa14wt_2 = GetImageData(path, '3-19-19', '62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-19-19', slices, timepoints, positions);
pa14wt_3 = GetImageData(path, '4-17-19', '62x_Salac_Pa14wt_SaPa14wt1-11-10100-110-1_co_SCFM2_tile2x2_4-17-19', slices, timepoints, positions);

pa14mut_1 = GetImageData(path, '4-24-19', '62x_Salac_Pa14pqsLclean_SaPa14pqsLclean=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_4-24-19', slices, timepoints, positions);
pa14mut_2 = GetImageData(path, '4-25-19', '62x_Salac_Pa14pqsLclean_SaPa14pqsLclean=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_4-25-19', slices, timepoints, positions);
pa14mut_3 = GetImageData(path, '5-8-19', '62x_Salac_Pa14pqsLclean_SaPa14pqsLclean=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_5-8-19', slices, timepoints, positions);

pao1wt_1 = GetImageData(path, '3-26-19', '62x_Salac_Pa01wt_SaPa01wt1-11-10100-110-1_co_SCFM2_tile2x2_3-26-19', slices, timepoints, positions);
pao1wt_2 = GetImageData(path, '4-18-19', '62x_Salac_Pa01wt_SaPa01wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_4-18-19_2019', slices, timepoints, positions);
pao1mut_1 = GetImageData(path, '4-23-19', '62x_Salac_Pa01pqsL_SaPa01pqsL=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_4-23-19', slices, timepoints, positions);

extra = GetImageData(path, '3-28-19', '62x_SaLac-PA14wt-PA14pqsL-SaPa14wt-SaPa14pqsL-bkgd_co_SCFM2_18hrTimeLapse_tile2x2_3-28-18', 139, 11, positions);
%}

%This is how to do it with the thresholds calculated from analyzing the
%thresholds from previous analysis
SaThreshold = ones(18,1)*0.2143;
Pa14wtThreshold = ones(18,1)*0.081486;
Pa14mutThreshold = ones(18,1)*0.077379;
GetImageData2(path, '3-13-19', '62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-13-19', slices, timepoints, positions, SaThreshold,Pa14wtThreshold);
GetImageData2(path, '3-19-19', '62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-19-19', slices, timepoints, positions, SaThreshold,Pa14wtThreshold);                                           
GetImageData2(path, '4-17-19', '62x_Salac_Pa14wt_SaPa14wt1-11-10100-110-1_co_SCFM2_tile2x2_4-17-19', slices, timepoints, positions, SaThreshold,Pa14wtThreshold);
                                           
GetImageData2(path, '4-24-19', '62x_Salac_Pa14pqsLclean_SaPa14pqsLclean=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_4-24-19', slices, timepoints, positions, SaThreshold,Pa14mutThreshold);
GetImageData2(path, '4-25-19', '62x_Salac_Pa14pqsLclean_SaPa14pqsLclean=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_4-25-19', slices, timepoints, positions, SaThreshold,Pa14mutThreshold);
GetImageData2(path, '5-8-19', '62x_Salac_Pa14pqsLclean_SaPa14pqsLclean=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_5-8-19', slices, timepoints, positions, SaThreshold,Pa14mutThreshold);


function GetImageData2(path, date, name, slices, timepoints, positions, thR, thG)
tic    
    for position = 0:positions
        %[thR,thG] = CollectThresholds(path, date, name, slices, timepoints, position);
        ThresholdImage(path, date, name, slices, timepoints, position,thR,thG);
        toc
    end
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
            %change range
            %ImR1 = mat2gray(ImR);%this rescales the range of intensities of the image, bioasing the results...
            %ImG1 = mat2gray(ImG);
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

function ThresholdImage(path, date, name, slices, timepoints, position, redThreshold,greenThreshold)
imagesfilepath = strcat(path, date,'/imagesSubtractRed');%declare name of directory to put images in
[~,~] = mkdir(imagesfilepath);%create directory if it hasn't been created. double wiggly thing is to prevent it from throwing warning
resultsfilePath = strcat(path, date,'/resultsSubtractRed');
[~,~] = mkdir(resultsfilePath);

for timepoint = 0:timepoints
    %totalSegments=0;%this is here for the overlapping aggregates chunk
    %results = zeros(1,5);%this is here for the overlapping aggregates chunk
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
        
        newImG = imsubtract(ImG, ImR);
            
        %combine channels
        rgbImG = cat(3,ImNeR,newImG,ImB);%Global algorithm
        
        imageName = strcat(imagesfilepath,'/t',GetSlice(timepoint),'_p',num2str(position),'_s',GetSlice(slice),'.tif');%create image name to store
        imwrite(rgbImG,imageName);%save image
        singleColorResults(slice+1,1)= nnz(ImNeR);%this puts the red pixels in the results spreadsheet
        singleColorResults(slice+1,2)= nnz(ImNeG);%this puts the green pixels in the results spreadsheet
        singleColorResults(slice+1,3)= slice;%this puts the slice number in the results spreadsheet
            
        %{ 
        The code below is in case I want the aggregate overlapping data
        %get objects
        rgbImBi = im2bw(rgbImG, 0.01);%using this "im2bw" function to binarize because imbinarize doesnt work with bwlabel...
        [labels1,numLabels1] = bwlabel(rgbImBi);%image with both green and red colors 
        
        results = [results;zeros(numLabels1, 5)];%this adds the number of
        aggregates of the current slide 
        for item = totalSegments+1:totalSegments+numLabels1
            labels = zeros(r,c);%zero array to imprint each combined aggregate
            zeroG = zeros(r,c);%zero array to imprint red portion of the aggregate
            zeroR = zeros(r,c);%zero array to imprint green portion of the aggregate
            labels(labels1==(item-totalSegments))=1;%pick the aggregate 
            redInt = labels+ImNeR;%add red and combined binary images
            greenInt = labels+ImNeG;%add green and combined binary images
            aggregateSize = nnz(labels);%declare meaningful variable names (nnz is the number of non-zero elements in X)
            zeroG(greenInt==2)=1;%store green overlaping pixels on an array
            zeroR(redInt==2)=1;%store blue overlaping pixels on an array
            greenPixels = nnz(zeroG);%store amount of green overlap
            redPixels = nnz(zeroR);%store amount of red overlap
            overlap = redPixels+greenPixels-aggregateSize;
            %add results to table
            results(item,1)= aggregateSize;
            results(item,2)= redPixels;
            results(item,3)= greenPixels;
            results(item,4)= overlap;
            results(item,5)= slice;
        end
        totalSegments= totalSegments+numLabels1;
        %}
        
    end
    resultsfilename = strcat(resultsfilePath,'/t',GetSlice(timepoint),'_p',num2str(position),'.csv');
    csvwrite(resultsfilename,singleColorResults)
    %this part is also only for the aggregate overlap code
    %{
    resultsfilename = strcat(resultsfilePath,'/t',GetSlice(timepoint),'_p',num2str(position),'.csv');
    csvwrite(resultsfilename,results)
    %}
    
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