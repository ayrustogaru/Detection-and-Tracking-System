function Displayimg(file_path)
% This function generates the surface plots of the target at various
% instance of the traversal. The absolute file path of the folder in which
% the images are generated is to be passed to this function. The file path
% sent as an input should be a string and engulfed in quotes. The surface
% plots generated he surface diagram consists of peaks which represents the target. 
% The output is three mesh diagrams, one, which shows the complete traversal 
% of the peak i.e. target; two, which plots the position of target in every 
% fourth image when there are large number of images and the last one, 
% shows the start and end points of the target.
%% Error Handling %%
fileFolder = fullfile(file_path);
dirOutput = dir(fullfile(fileFolder,'test_*.png'));
fileNames = {dirOutput.name}';
if(isempty(fileNames))
    error('There are no images present in the current folder: \n1)Try running Image generation function first and try again.\n2)Check if the file path "%s" specified is correct',file_path);
end
global num_of_img;
global bound;
%% Surface plot of every Image combined %%
figure; hold on
[X,Y] = meshgrid(-1*bound:1:bound);
for i = 0:+1:num_of_img-1
        k = imread(fullfile(file_path,strcat('test_',int2str(i),'.png')));

surf(X,Y,k);
colormap default;
colorbar; % colorbar for the surface plot
end
L = imread(fullfile(file_path,strcat('test_',int2str(num_of_img-1),'.png')));
surf(X,Y,L);
view(17,20) % The view angle of the figure generated interms of elevation and azimuth
hold off
%% Surface plot of the start and end points %%
figure; hold on
[X,Y] = meshgrid(-1*bound:1:bound);
for i = 0
        k = imread(fullfile(file_path,strcat('test_',int2str(i),'.png')));

surf(X,Y,k);
colormap default;
colorbar;
end
L = imread(fullfile(file_path,strcat('test_',int2str(num_of_img-1),'.png')));
surf(X,Y,L);
view(17,20);
hold off
%% Surface plot of every 5th image %%
figure;
hold on
if(num_of_img>5)
    b = floor((num_of_img)/5)*5;
    for i = 0:+5:b-1
        k = imread(fullfile(file_path,strcat('test_',int2str(i),'.png')));
        surf(X,Y,k);
    end
end
L = imread(fullfile(file_path,strcat('test_',int2str(num_of_img-1),'.png')));
surf(X,Y,L);
colorbar;
view(17,20);