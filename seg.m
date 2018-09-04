I = imread('streak.png');
mask = false(size(I)); 
mask(46,46) = true;
W = graydiffweight(I, mask, 'GrayDifferenceCutoff', 25);
thresh = 0.01;
[BW, D] = imsegfmm(W, mask, thresh);
figure
imshow(BW)
title('Segmented Image');