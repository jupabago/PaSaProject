slices = 91;
positions = 5;
timePoints = 17;

GetHistograms('3-13-19', '62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-13-19', slices,timePoints);
GetHistograms('3-19-19', '62x_Salac_Pa14wt_SaPa14wt=1-1,1-10,100-1,10-1_co_SCFM2_tile2x2_3-19-19', slices,timePoints);
GetHistograms('4-17-19', '62x_Salac_Pa14wt_SaPa14wt1-11-10100-110-1_co_SCFM2_tile2x2_4-17-19', slices,timePoints);

function GetHistograms(date, sample, slices,timePoints)
directory= strcat('/Volumes/Seagate Backup Plus Drive/Good images/',date,'/', sample,'/',sample);
dataPoints = (slices+1)*(timePoints+1)*4*2*256;
output = zeros(dataPoints,7);
counter = 1;
for slice= 0:slices
    for timePoint = 0:timePoints
        for tile = 0:3
            name = strcat(directory,'_z',CorrectIndex(slice),'_t',CorrectIndex(timePoint),'_p3_m',num2str(tile),'.tif');
            [Ir,Ig] = ReadImage(name);
            output(counter:counter+255, 1:7) = GetImageHistogram(Ir, 1, slice, timePoint, 3, tile);
            output(counter+256:counter+511, 1:7) = GetImageHistogram(Ig, 2, slice, timePoint, 3, tile);
            counter = counter+512;
        end
    end
end
fileName = strcat('/Users/jupabago/Documents/Whiteley/PROJECTS/PaSaProject/Spatial paper Data/Microscopy Data/singleImageData/Histograms_',date,'.csv');
csvwrite(fileName,output)
end

function histogram = GetImageHistogram(image, channel, slice, timePoint, position, tile )
[imCounts,imBins ] = imhist(image);
histogram = [imCounts,imBins, ones(256,1)*channel, ones(256,1)*slice, ones(256,1)*timePoint, ones(256,1)*position, ones(256,1)*tile]; 
end

function [redImage, greenImage] = ReadImage(file)
I = imread(file);
redImage = squeeze(I(:,:,1));
greenImage = squeeze(I(:,:,2));
end

function slice = CorrectIndex(idx)
if(idx>9) 
    slice =num2str(idx);
else    
    slice = strcat('0', num2str(idx));
end
end