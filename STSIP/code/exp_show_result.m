function exp_show_result(video_name, frame, type)
%EXP_SHOW_RESULT Summary of this function goes here
%   Detailed explanation goes here

if(nargin < 3)
    type = 'original';
end

switch type
    case ''
        type = 'original';
    case 'rotated'
        type = 'transformation_1';
    case 'blur'
        type = 'transformation_2';
    case 'shift'
        type = 'transformation_3';
    otherwise
end

switch video_name
    case 'boxe'
        video_name = 'person04_boxing_d1_uncomp';
    case 'gesture'
        video_name = 'Sample0001_color';
    case 'mixing'
        video_name = 'mixing_cam2';
    otherwise
end


% crea la directory completa fino ai files
fulldir = ['results/' type '/' video_name '/'];

% ...carica il file con i punti selezionati in SEL
txtname = ['points/' video_name '_selected.mat'];
load(txtname);

% conta il numero di punti in questo frame
n = nnz(selected(:,3) == frame);

figure('Position', [11 611 1819 367]);

[fulldir video_name '_frame_' int2str(frame) '_points.png']

subplot(1,n+1,1);
im = imread([fulldir video_name '_frame_' int2str(frame) '_points.png']);
imshow(im);

for i=2:n+1
    subplot(1,n+1,i);
    im = imread([fulldir video_name '_frame_' int2str(frame) '_point_' int2str(i-1) '.png']);
    imshow(im);
end


end

