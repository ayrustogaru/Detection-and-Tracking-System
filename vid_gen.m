function vid_gen(file_path)
fileFolder = fullfile(file_path);
dirOutput = dir(fullfile(fileFolder,'test_*.png'));
fileNames = {dirOutput.name}';
fileNames = natsort(fileNames);
outputVideo = VideoWriter(fullfile(file_path, 'target.avi'));
outputVideo.FrameRate = 25;
open(outputVideo);
for i = 1:length(fileNames)
   img = imread(fullfile(file_path,strcat('test_',int2str(i-1),'.png')));
   writeVideo(outputVideo,img)
end
close(outputVideo);