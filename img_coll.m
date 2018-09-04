function img_coll(file_path)
%Montage of images
%This function uses the 
fileFolder = fullfile(file_path);
dirOutput = dir(fullfile(fileFolder,'test_*.png'));
fileNames = {dirOutput.name}';
fileNames = natsort(fileNames);
num = numel(fileNames);
rows = floor(num/10);
if(rows == num/10)
    col = num/rows;
else
   col = floor(num/rows) + 1; 
end
montage(fileNames,'Size',[rows col]);
