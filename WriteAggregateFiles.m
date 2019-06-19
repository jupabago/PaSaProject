
path ='/Volumes/Seagate Backup Plus Drive/Good images/';

testWriteAggregateFiles = WriteAggregateFiles(path,'3-13-19',2,2,10);

function writeFiles = WriteAggregateFiles(path, date, timepoints, positions, slices)
resultsfilepath = strcat(path, date,'/aggregateSizes');
[~,~] = mkdir(resultsfilepath);
for position = 0:positions
    for timepoint = 0:timepoints
        GetAggegateSizes(path, date, timepoint, position, slices)
    end
end
writeFiles = 1;
end

function aggregateSizeList = GetAggegateSizes(path, date, timepoint, position, slices) %this function has input 
imagesfilepath = strcat(path, date,'/images');
imageFile = strcat(imagesfilepath,'/t',GetSlice(timepoint),'_p',num2str(position),'_s');%create image name to store
redStucture = Get3DImage(imageFile, 1, slices);
greenStucture = Get3DImage(imageFile, 2, slices);
totalAggregates = redStucture.NumObjects+redStucture.NumObjects;
aggregateSizeList = zeros(totalAggregates,2);
count = 1;
for agg1 = 1:redStucture.NumObjects
    %aggregateSizeList{count,1}= agg1;%aggregate 1 number
    aggregateSizeList{count,1}= GetObjectSize(redStucture,agg1);%volume aggregate 1
    aggregateSizeList{count,2}= "Sa";
    count= count+1;
end

for agg2 = 1:greenStucture.NumObjects
    %aggregateSizeList{count,1}= agg2;%aggregate 1 number
    aggregateSizeList{count,1}= GetObjectSize(greenStucture,agg2);%volume ofaggregate
    aggregateSizeList{count,2}= "Pa";
    count= count+1;
end
filename = strcat(path, date,'/aggregateSizes/t_',GetSlice(timepoint),'p_',num2str(position),'.csv');
csvwrite(filename,aggregateSizeList)
end

function objectSize = GetObjectSize(threeDStructure,aggNumber)
objectSize = numel(threeDStructure.PixelIdxList{aggNumber});
objectSize = objectSize*.264*.264*.440;
end

function threeDStructure = Get3DImage(filename, channel, slices)%this function creates a 3D matrix of a single channel containing all the objects in the confocal stack
%the x increases to the right, left increases down and z starts at the
%bottom, reverse right-hand rule coordinates
threeDimage = readImage(strcat(filename, '00.tif'), channel);
for slice = 1:slices    
    name = strcat(filename,GetSlice(slice),'.tif');    
    currentImage = readImage(name, channel);
    threeDimage = cat(3,threeDimage,currentImage);
end
%this item contains all the info from the 3D objects generated from the image stack
threeDStructure = bwconncomp(threeDimage,18);%I picked connectivity of 18 because it makes more biological sense
end

function slice = GetSlice(idx)
if(idx>=10)
    slice =num2str(idx);
else
    slice = strcat('0', num2str(idx));
end
end

function I = readImage (name, channel)
Im = im2double(imread(name));
%extract individual channels
%[r, c, p] = size(Im);%store size of picture
I = squeeze(Im(:,:,channel));
end