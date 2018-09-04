function streak(file_path)
%% Path Generation %%
global Sm;
fileFolder = fullfile(file_path);
dirOutput = dir(fullfile(fileFolder,'test_*.png'));
fileNames = {dirOutput.name}';
fileNames = natsort(fileNames);
num = numel(fileNames);

k = uint8(zeros(size(imread('test_0.png'))));

for i = 0:+1:num-1
    k = k + (imread(strcat('test_',int2str(i),'.png')));
end
k = k./uint8(num);
b = max(max(k));
%% Intensity Clculation %%
b = find(k==b)
size_b = size(b);
size_k = size(k);
floor(size_b(1))
if(size_b==1)
    r = floor(b(1)/size_k(1));
    c = b(r+1) - r*size_k(1);
else
    r = floor(b(floor(size_b(1)/2))/size_k(1));
    c = b(floor(size_b(1)/2)) - r*size_k(1);
end
%% Mask Calculation %%
mask = false(size(k)); 
mask(r,c) = true; % Seed is sent as an imput to create a reference
W = graydiffweight(k, mask, 'GrayDifferenceCutoff', 25);
thresh = 0.01;
[BW, ~] = imsegfmm(W, mask, thresh);% tha fast marching method of segmentation
figure
imshow(BW)
title('Segmented Image');
imwrite(BW,'streak.png');