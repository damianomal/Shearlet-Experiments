

% VID = load_video_to_mat('vid.avi',1000,1, 3000, false);


reader = VideoReader('vid.avi');
v = VideoWriter('mixing_cam1_scale2and2_th005_second_video.avi');
v.FrameRate = reader.FrameRate;
v.Quality = 100;

open(v);
for i=1:size(VID,3)
%    A = VID(:,:,37);
   A = readFrame(reader);
   A = A * 1.3;
   writeVideo(v,A);
end

close(v);