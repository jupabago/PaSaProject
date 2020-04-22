I = imread('62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-13-19_z25_t17_p3_m3.tif');
%I = imread('rose.tif');
Ir = squeeze(I(:,:,1));
Ig = squeeze(I(:,:,2));
testImageDataR = GetHistogramData(Ir);
testImageDataG = GetHistogramData(Ig);

function imageData = GetHistogramData(image)
[width, height] = size(image);
numpixels = width *height;
[imBins,imCounts ] = imhist(image);
zeroInt = imCounts(1);
maxInt = imCounts(256);
[~,firstZero] = min(imCounts);
totalZeroes = nnz(~imCounts);
level = graythresh(image);
calculatedG = stretchlim(imBins,imCounts );
meanIntensity = sum(imCounts.*imBins)/(numpixels);
imageData = [zeroInt ,maxInt,firstZero,totalZeroes,level,calculatedG,meanIntensity]; 
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


