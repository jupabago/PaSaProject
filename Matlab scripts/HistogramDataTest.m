%{
I2 = imread('62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-13-19_z00_t01_p3_m2.tif');
I0 = imread('62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-13-19_z00_t00_p3_m2.tif');
I10 = imread('62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-13-19_z00_t10_p3_m2.tif');
I11 = imread('62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-13-19_z11_t00_p3_m2.tif');
%}
Ib = imread('62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-13-19_z25_t04_p3_m3.tif');
%{
hist0 = imhist(squeeze(I0(:,:,1)));
hist2 = imhist(squeeze(I2(:,:,1)));
hist10 = imhist(squeeze(I10(:,:,1)));
hist11 = imhist(squeeze(I11(:,:,1)));

imageData2 = GetImageData(I2);
imageData0 = GetImageData(I0);
imageData10 = GetImageData(I10);
imageData11 = GetImageData(I11);
%}

testGetImageHistogram = GetImageHistogram(Ib, 1, 1,1,3,2);
function histogram = GetImageHistogram(image, channel, slice, timePoint, position, tile )
[imCounts,imBins ] = imhist(image);
histogram = [imCounts,imBins, ones(256,1)*channel, ones(256,1)*slice, ones(256,1)*timePoint, ones(256,1)*position, ones(256,1)*tile]; 
end

function imageData = GetImageData(im)
image= squeeze(im(:,:,1));
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

imageData = [zeroInt,zeroPercent, maxInt,firstZero,totalZeroes,level,calculatedG(2),tailBins, numtailEnd,optimalG,meanIntensity,sdIntensity]; 
end

function optimalG = getOptimalG( counts,totalpixels)
seq = 0:1/255:1;
bins = seq';
bins(1)=[];
counts(1)=[];
optimalG = -sum(counts.*(log2(bins)))/totalpixels;
end