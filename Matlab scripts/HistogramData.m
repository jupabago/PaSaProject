slices = 91;
positions = 5;
timePoints = 17;

GetHistograms('3-13-19', '62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-13-19', slices,timePoints);
GetHistograms('3-19-19', '62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-19-19', slices,timePoints);
GetHistograms('4-17-19', '62x_Salac_Pa14wt_SaPa14wt1-11-10100-110-1_co_SCFM2_tile2x2_4-17-19', slices,timePoints);

function GetHistograms(date, sample, slices,timePoints)
directory= strcat('/Volumes/Seagate Backup Plus Drive/Good images/',date,'/', sample,'/',sample);
dataPoints = (slices+1)*(timePoints+1)*4*2;
output = zeros(dataPoints,17);
counter = 1;
for slice= 0:slices
    for timePoint = 0:timePoints
        for tile = 0:3
            name = strcat(directory,'_z',CorrectIndex(slice),'_t',CorrectIndex(timePoint),'_p3_m',num2str(tile),'.tif');
            [Ir,Ig] = ReadImage(name);
            output(counter, :) = GetImageData(Ir, 1, slice, timePoint, 3, tile);
            output(counter+1, :) = GetImageData(Ig, 2, slice, timePoint, 3, tile);
            counter = counter+2;
        end
    end
end
fileName = strcat('/Users/jupabago/Documents/Whiteley/PROJECTS/PaSaProject/Spatial paper Data/Microscopy Data/singleImageData/RawImgData_',date,'.csv');
csvwrite(fileName,output)
end

function [redImage, greenImage] = ReadImage(file)
I = imread(file);
redImage = squeeze(I(:,:,1));
greenImage = squeeze(I(:,:,2));
end


function imageData = GetImageData(image, channel, slice, timePoint, position, tile )
[width, height] = size(image);
numpixels = width *height;
[imCounts,~ ] = imhist(image);
zeroInt = imCounts(1);
zeroPercent = zeroInt/numpixels; 
maxInt = imCounts(256);
[~,firstZero] = min(imCounts);
tailEnd = image>=firstZero;%this thresholds the image after the first instance of zero
numtailEnd = nnz(tailEnd);%This is the amount of pixels beyond the first zero
totalZeroes = nnz(~imCounts);
tailBins = 257-firstZero-totalZeroes; %this is the number of intensity bins after the first zero freq that have non-zero freq. 
level = graythresh(image);
calculatedG = stretchlim(image);
meanIntensity = mean2(image);
sdIntensity = std2(image);
optimalG = getOptimalG(imCounts,numpixels);
imageData = [zeroInt,zeroPercent, maxInt,firstZero,totalZeroes,level,calculatedG(2),tailBins, numtailEnd,optimalG,meanIntensity,sdIntensity,channel, slice, timePoint, position, tile]; 
end

function optimalG = getOptimalG( counts,totalpixels)
seq = 0:1/255:1;
bins = seq';
bins(1)=[];
counts(1)=[];
optimalG = -sum(counts.*(log2(bins)))/totalpixels;
end
%{
IgAdj = imadjust(Ig);
IrAdj = imadjust(Ir);
matIg = mat2gray(Ig);
matIr = mat2gray(Ir);
[rawThreshG, rawEffG] = graythresh(Ig)
[adjThreshG, adjEffG] = graythresh(IgAdj)
[matThreshG, matEffG] = graythresh(matIg)
[rawThreshR, rawEffR] = graythresh(Ir)
[adjThreshR, adjEffR] = graythresh(IrAdj)
[matThreshR, matEffR] = graythresh(matIr)
lowhighR = stretchlim(Ir)
lowhighG = stretchlim(Ig)
histogram(Ir)
histogram(matIr)
histogram(IrAdj)
%}

function slice = CorrectIndex(idx)
if(idx>9) 
    slice =num2str(idx);
else    
    slice = strcat('0', num2str(idx));
end
end
        
function I = stitchImage(name) %This function stitches the tiles and returns a 2D matrix of channel specified,
IA = imread(strcat(name,'_m0.tif'));
IB = imread(strcat(name,'_m1.tif'));
top = cat(2, IA,IB);%concatenates in the x axis
IC = imread(strcat(name,'_m2.tif'));
ID = imread(strcat(name,'_m3.tif'));
bottom = cat(2, IC,ID);%concatenates in the x axis
Im = cat(1,top,bottom);%concatenates in the y axis
I = im2double(Im);
end
