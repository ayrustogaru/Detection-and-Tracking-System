function n = img_gen(start_pt, end_pt, a_x, a_y, vel, img_edge,targ_int)
%Image Generator
%This function generates grayscale images based on gaussian plume model
%This function takes in the starting and ending points of the target, the
%semi-axes of the gaussian-plume, the velocity('vel') of the target and the
%edge length of the image
%The start_pt and end_pt must be matrices of size 1x2.........(1)
%The edge length of the image must be such that i could accomodate the
%traversal of the image
%% Global Declarations %%
global Sm;
Sm = targ_int;
global aE;
aE = a_x;
global aN;
aN = a_y;
global num_of_img;
global bound;
%% Input Testing %%
if numel(start_pt)~=2 %check for condition(1)
    error('Start_pt should be of the format [x,y]')
end
if numel(end_pt)~=2 %check for condition(1)
    error('Etart_pt should be of the format [x,y]')
end
if vel<0
    error('Velocity must be greater than or equal to zero');
end
if targ_int<=1
    error('Target intensity must be greater than 1');
end
if(img_edge<=10)
    error('Frame Size is very small for the traversal to be seen');
end
bound = round((img_edge-1)/2);
if(start_pt(1)<-1*bound||start_pt(1)>bound||start_pt(2)>bound||start_pt(2)<-1*bound)
    error('Start_pt is not in the frame');
end
if(end_pt(1)<-1*bound||end_pt(1)>bound||end_pt(2)>bound||end_pt(2)<-1*bound)
    error('End_pt is not in the frame');
end
%% Distance Calculations %%
A = [start_pt;end_pt];
dist = pdist(A,'euclidean'); %euclidean distance between the atart and end points
dist_x = vel.*((end_pt(1)-start_pt(1))./dist);%distance covered by the target in x-direction in one sampling period
dist_y = vel.*((end_pt(2)-start_pt(2))./dist);%distance covered by the target in y-direction in one sampling period
[X,Y] = meshgrid(-1*bound:1:bound);
iter = floor(dist/vel);
sig = 0.01;
%% Image Generation %%
for j = 0:+1:iter%image generation loop
    Z = targ_int.*exp(-1/2*(((X-start_pt(1)-j.*dist_x).^2/(a_x^2))+((Y-start_pt(2)-j.*dist_y).^2/(a_y^2))));
    Z = Z + imnoise(mat2gray(Z,[0 10]),'gaussian',0,sig);
    %sz = size(Z);
    %Z = [Z 10.*ones(sz(1),1)];
    %Z = Z + double(sig*randn(size(Z)));
    imwrite(mat2gray(Z,[0 10]), strcat('test_',int2str(j),'.png'));
end
if(iter~=(dist/vel))
    Z = 10.*exp(-1/2*(((X-end_pt(1)).^2/(a_x^2))+((Y-end_pt(2)).^2/(a_y^2))));
    Z = Z + double(sig*randn(size(Z)));
    imwrite(mat2gray(Z,[0 10]), strcat('test_',int2str(j+1),'.png'));
    extra = 1;
end
n = floor(dist/vel)+1+extra;
num_of_img =n;
%% Signal to Noise Ratio %%
[m1, m2] = size(Z);
m = m1*m2;
int_sum = sum(Z);
int_sum = sum(int_sum(:));
SNR = int_sum/(sig*sqrt(m));
disp(SNR);