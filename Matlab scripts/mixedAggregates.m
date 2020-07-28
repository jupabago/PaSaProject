slices = 91;%these are # of slices -1, the number on the file

GetMixedAggregates('5-8-19', slices);
GetMixedAggregates('3-13-19', slices);
GetMixedAggregates('3-19-19', slices);
GetMixedAggregates('4-17-19', slices);
GetMixedAggregates('4-24-19', slices);
GetMixedAggregates('4-25-19', slices);

%PA14wt<- c('3-13-19', '3-19-19', '4-17-19')
%PA14mut<- c('4-24-19', '4-25-19', '5-8-19')

function GetMixedAggregates( date, slices)
resultsfilePath = strcat('/Volumes/Seagate Backup Plus Drive/Good images/', date,'/mixedAggregatesData/');
[~,~] = mkdir(resultsfilePath);
totalSegments=0;%object counter
results = zeros(1,5);%storing data
for slice = 0:slices
    name = strcat('/Volumes/Seagate Backup Plus Drive/Good images/', date,'/images1/','t05_p2_s', GetSlice(slice),'.tif');
    I = im2double(imread(name));
    [r, c, p] = size(I);%store size of picture
    rgbImBi = im2bw(I , 0.01);%the idea of this is to convert an rgb image into a single color
    ImR = squeeze(I(:,:,1));
    ImG = squeeze(I(:,:,2));
    [labels1,numLabels1] = bwlabel(rgbImBi);%combined image
    results = [results;zeros(numLabels1, 5)];
    for item = totalSegments+1:totalSegments+numLabels1
        labels = zeros(r,c);%zero array to imprint each combined aggregate
        zeroG = zeros(r,c);%zero array to imprint red portion of the aggregate
        zeroR = zeros(r,c);%zero array to imprint green portion of the aggregate
        labels(labels1==(item-totalSegments))=1;%pick the aggregate 
        redInt = labels+ImR;%add red and combined binary images
        greenInt = labels+ImG;%add green and combined binary images
        aggregateSize = nnz(labels);%declare meaningful variable names
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
end
fileName = strcat(resultsfilePath,date,'Original.csv');
csvwrite(fileName,results)
end

function slice = GetSlice(idx)
if(idx>=10)
    slice =num2str(idx);
else
    slice = strcat('0', num2str(idx));
end
end
