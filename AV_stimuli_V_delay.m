%% Create audiovisual stimuli with a visual delay  ----- Elise Kanber April 2022 - MATLAB R2018b
%{
Requirements: 
- Put all video and audio files in the same folder 
- When listing video and audio files, ensure that they are listed in the
    same order (i.e. first item in video list should correspond to first
    item in audio list) 
%}

%% Things to set: 

% Set working directory (where your video and audio files are saved) 
% cd '/Users/e.kanber/Downloads/pilot'; 
cd '/Users/carolynmcgettigan/Documents/postdoc/for_others/ziyun'; 

% List of videos
video = {
    'Ball.mp4', ... 
    'Bill.mp4', ...
    'Boat.mp4', ...
    'Bonds.mp4', ... 
    'Box.mp4'
    };

% list of audio files
audio = {
    'Ball_c50s50.wav', ... 
    'Bill_c50s50.wav', ...
    'Boat_c50s50.wav', ...
    'Bonds_c50s50.wav', ...
    'Box_c50s50.wav'
    };

% Uncomment this if you want to test just one video & audio file
% video = {
%     'Ball.mp4'
%     }; 
% 
% audio = {
%     'Ball_c50s50.wav'
%     };

for i = 1:length(video)   % Loop through the video and audio files

v = VideoReader(video{i}); % read in the {i}th video e.g. when i = 1, read in the first video in the list above
vid = read(v);
n_frames = v.NumberOfFrames;  % Change this to v.NumFrames if using newest version of MATLAB (R2022a at time of writing)  

% Extract each frame of the video and save it out as a separate image file,
% so that we can change the timings of each frame.
% (you should see frame-1.png, frame-2.png etc. appearing in your working directory) 
for x = 1 : n_frames
    imwrite(vid(:,:,:,x),strcat('frame-',num2str(x),'.png'));
end


% Now we read in the frames one by one:
for y = 1: n_frames
    images{y} = imread(strcat('frame-', num2str(y), '.png'));
end 

 % create the video writer 
 writerObj = VideoWriter(strcat(video{i}, '_new'), 'Uncompressed AVI');  % the new video file will be called delayedVideo.avi
 % You can check the frame rate on your videos and set it here:
 writerObj.FrameRate = 30;
% set the seconds per image
secsPerImage = [];
for j = 1:n_frames % Here, I'm saying that I want the seconds per image to be 1 for every frame. Because we have 30 frames per second, I think this corresponds to 1/30 or .03 seconds per frame. 
    secsPerImage(j) = 1;
end
secsPerImage(1) = 20;  % Here, I'm saying I want frame 1 to be longer than the other frames (pause on first frame). Change this to increase or decrease the video delay. 20 = 20/30 seconds = .66s on first frame.
%  secsPerImage = [5 10 15];
 % open the video writer
 open(writerObj);
 % write the frames to the video
 for u=1:length(images)  % loop through the frames converting the images to video frames and write the video using the timings per frame specified in secsPerImage above. 
     % convert the image to a frame
     frame = im2frame(images{u});
     for v=1:secsPerImage(u) 
         writeVideo(writerObj, frame); 
%          step(writerObj,Frame,audio(val*(v-1)+1:val*v,:));
     end
 end
 % close the writer object
 close(writerObj);


%% Adding audio to the delayed video: 

video_filename = strcat(video{i}, '_new.avi'); % Name of delayed video file. 
audio_filename = audio{i}; % Name of audio to be added. 
out_filename =  strcat(video{i}, '_vid_delay.avi');  % new file name - can change this to whatever you want it to be :)
videoFReader = VideoReader(video_filename); % read in the video we created in the previous section
FR = videoFReader.FrameRate;  % read in the video's frame rate
[AUDIO,Fs] = audioread(audio_filename); % read in the audio file
SamplesPerFrame = floor(Fs/FR); % So that the audio and video are synced up
videoFWriter = vision.VideoFileWriter(out_filename, 'AudioInputPort', true, 'FrameRate', FR); % vision.VideoFileWriter allows you to write videos WITH sound
framenum = 0; % set the frame number to zero to start (so that we can write all frames from the beginning) 
while hasFrame(videoFReader) 
   videoFrame = readFrame(videoFReader);
   this_audio = AUDIO(framenum*SamplesPerFrame + 1 : min(end, (framenum+1)*SamplesPerFrame), :);
   if size(this_audio,1) < SamplesPerFrame
       this_audio(SamplesPerFrame,:) = 0; %zero pad short frames
   end
   step(videoFWriter,videoFrame, this_audio);  % Allows you to write the video including both the video frames (videoFrame) and audio samples (this_audio)
   framenum = framenum + 1; % once the frame and audio has been written for one frame, we add one to move to the next frame and do it all again, until the number of frames runs out
end
delete(videoFReader); 
release(videoFWriter);



%% delete all the separate frame files MATLAB created (e.g. frame-1.png, frame-2.png etc.) to save space on your PC
 for z = 1:n_frames
 delete(strcat('frame-', num2str(z), '.png'))
 end 
 
 % delete the video we created in line 45 - this is the delayed video
 % without sound, and we no longer need this. 
 delete(strcat(video{i}, '_new.avi')) 
 
 clear z
 clear images
 clear framenum
 
end 
 