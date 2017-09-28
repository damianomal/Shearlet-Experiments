% load the video sequence (contained in the sample_sequences directory)

clear VID

% video_filename = 'line_l.mp4';
% VID = load_video_to_mat(video_filename,160,400,500, true);

% video_filename = 'mixing_cam1.avi';
% video_filename = 'mixing_cam0.avi';
% video_filename = 'mixing_cam2.avi';
% video_filename = 'potato_cam1.avi';
% video_filename = 'eggs_cam1.avi';
% video_filename = 'eggs_cam2.avi';
% video_filename = 'front_car.mp4';
% VID = load_video_to_mat(video_filename,160,1,100, true);
% VID = load_video_to_mat(video_filename,200,1,100, true);

% video_filename = 'TRUCK.mp4';
% VID = load_video_to_mat(video_filename,160,1300,1400, true);

% --- KTH ---

% video_filename = '7-0006.mp4';
% video_filename = 'person01_walking_d1_uncomp.avi';
% video_filename = 'person04_running_d1_uncomp.avi';
video_filename = 'person04_boxing_d1_uncomp.avi';
% video_filename = 'person01_handwaving_d1_uncomp.avi';
VID = load_video_to_mat(video_filename,160,1,100, true);

% --- PER FRANCESCA
% video_filename = 'mixing_cam1.avi';
% VID = load_video_to_mat(video_filename,160,1,100, true);
% -------------

% video_filename = 'carrot_cam2.avi';
% VID = load_video_to_mat(video_filename,160,1,100, true);

% [VID, COLOR_VID] = load_video_to_mat('walk-simple.avi',160, 1,100);
% VISUALIZING THE CLUSTERING RESULTS FOR A FIXED NUMBER OF CLUSTERS

clear COEFFS idxs
[COEFFS,idxs] = shearlet_transform_3D(VID,46,91,[0 1 1], 3, 1, [2 3]);

%% --------------------------------
close all;

c = 37;
x = 69;
y = 17;

while false
    
    imshow(VID(:,:,c), []);
    
    pause(0.05);
    waitforbuttonpress
    key = get(gcf,'CurrentKey');

    
    switch key
        case 'leftarrow'
            c = c-1;
            if(c<1)
                c=1;
            end
        case 'rightarrow'
            c = c+1;
            if(c>size(VID,3))
                c = size(VID,3);
            end
        case 'c'
            [x,y] = ginput(1);
            fprintf('Selected Point (%d,%d)\n', floor(x), floor(y));
        case 's'
            
            c = floor(input('Target frame'));
            
            if(c<1)
                c=1;
            else if(c>size(VID,3))
                    c = size(VID,3);
                end
            end
        case 'q'
            break
        otherwise
            
    end
    
end

%% --------------------------------

TARGET_FRAME = c;
SCALE_USED = 2;
SKIP_BORDER = 5;

REPRESENTATION = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, SCALE_USED, idxs, true, true, SKIP_BORDER);

%% --------------------------------
close all;
clear -global fH1 fH2

index = (floor(y)-1)*size(VID,2)+floor(x);
selected = REPRESENTATION(index,:);

shearlet_show_descriptor(selected);

g  = getframe();
imagesel = g.cdata;

%% --------------------------------

VID = load_video_to_mat_rotated(video_filename,160,1,100, false);

% --- PER FRANCESCA
% video_filename = 'mixing_cam1.avi';
% VID = load_video_to_mat(video_filename,160,1,100, true);
% -------------

% video_filename = 'carrot_cam2.avi';
% VID = load_video_to_mat(video_filename,160,1,100, true);

% [VID, COLOR_VID] = load_video_to_mat('walk-simple.avi',160, 1,100);
% VISUALIZING THE CLUSTERING RESULTS FOR A FIXED NUMBER OF CLUSTERS

clear COEFFS idxs
[COEFFS,idxs] = shearlet_transform_3D(VID,46,91,[0 1 1], 3, 1, [2 3]);

%% --------------------------------


c = 37;
% x2 = 69;
% y2 = 17;

while false
    
    imshow(VID(:,:,c), []);
    
    pause(0.05);
    waitforbuttonpress
    key = get(gcf,'CurrentKey');

    
    switch key
        case 'leftarrow'
            c = c-1;
            if(c<1)
                c=1;
            end
        case 'rightarrow'
            c = c+1;
            if(c>size(VID,3))
                c = size(VID,3);
            end
        case 'c'
            [x,y] = ginput(1);
            fprintf('Selected Point (%d,%d)\n', floor(x), floor(y));
        case 's'
            
            c = floor(input('Target frame'));
            
            if(c<1)
                c=1;
            else if(c>size(VID,3))
                    c = size(VID,3);
                end
            end
        case 'q'
            break
        otherwise
            
    end
    
end

%% --------------------------------

TARGET_FRAME = c;
SCALE_USED = 2;
SKIP_BORDER = 5;

REPRESENTATION2 = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, SCALE_USED, idxs, true, true, SKIP_BORDER);

%% --------------------------------

close all;
clear -global fH1 fH2

y2 = x;
x2 = size(VID,2)-y+1;

index2 = (floor(y2)-1)*size(VID,2)+floor(x2);
selected2 = REPRESENTATION2(index2,:);

shearlet_show_descriptor(selected2);


g  = getframe();
imagesel2 = g.cdata;

figure;

subplot(1,2,1); imshow(imagesel);
subplot(1,2,2); imshow(imagesel2);
