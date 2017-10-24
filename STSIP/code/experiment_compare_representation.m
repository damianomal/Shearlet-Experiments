
close all;

% lista di video da caricare
video_filenames = {'person04_boxing_d1_uncomp.avi',1,100;
    'Sample0001_color.mp4', 1239, 1350;
    'mixing_cam2.avi', 1, 100;
    'trial_018.avi', 1, 100};

% video_filenames = {'mixing_cam2.avi', 1, 100};
descriptors = [];

%% video da caricare per selezionare punti


id = 2;
filename = video_filenames{id,1};
start_vid = video_filenames{id,2};
end_vid  = video_filenames{id,3};

VID = load_video_to_mat(filename, 160, start_vid, end_vid, true);

% clear start_vid end_vid filename

clear COEFFS idxs
[COEFFS,idxs] = shearlet_transform_3D(VID,46,91,[0 1 1], 3, 1, [2 3]);


%% CLUSTERING OF A SINGLE FRAME USING THE SHEARLET-BASED REPRESENTATION DEVELOPED

% calculate the representation for a specific frame (frame number 37 of the
% sequence represented in the VID structure)

TARGET_FRAME = 46; % 72 per truck.mp4, 46 per gesture, 37 per boxing, 37 per mixing
SCALE_USED = 2;
SKIP_BORDER = 5;

REPRESENTATION = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, SCALE_USED, idxs, true, true, SKIP_BORDER);

CLUSTER_NUMBER = 5;
[CL_IND, CTRS] = shearlet_cluster_coefficients(REPRESENTATION, CLUSTER_NUMBER, [size(COEFFS,1) size(COEFFS,2)]);

% sorts the clusters with respect to their size, and also rea

[SORTED_CL_IMAGE, SORT_CTRS] = shearlet_cluster_sort(CL_IND, CTRS);

% shows a colormap associated with the clusters found

[~,~,img] = shearlet_cluster_image(SORTED_CL_IMAGE, CLUSTER_NUMBER, false, false);

close all;

figure;
subplot(1,2,1); imshow(VID(:,:,TARGET_FRAME), []);
subplot(1,2,2); imshow(img);



%% ROTATION CASE

AMOUNT = -90;

VID_R = load_video_to_mat_rotated(filename, 160, start_vid, end_vid, false, AMOUNT);

clear COEFFS_R idxs_r
[COEFFS_R,idxs_r] = shearlet_transform_3D(VID_R,46,91,[0 1 1], 3, 1, [2 3]);


%%

close all;

c = 46;


figure;
subplot(1,4,1);
subplot(1,4,2);
subplot(1,4,3);
subplot(1,4,4);

cluster_map = shearlet_init_cluster_map;

[REPRESENTATION, ~, ~, ~] = shearlet_combined_fast(COEFFS, c, [2 2], idxs, 0.05, false, true, SKIP_BORDER);
CL_IND = shearlet_cluster_by_seeds(REPRESENTATION, COEFFS, SORT_CTRS);
[CL_IMG, ~, show_rgb] = shearlet_cluster_image(CL_IND, size(SORT_CTRS,1), false, false);
% show_rgb = ind2rgb(CL_IMG, cluster_map);

% -------------------
show_rgb(1:5, 1:end, :) = 0;
show_rgb(1:end, 1:5, :) = 0;
show_rgb(end-4:end, 1:end, :) = 0;
show_rgb(1:end, end-4:end, :) = 0;
% -------------------

[REPRESENTATION_R, ~, ~, ~] = shearlet_combined_fast(COEFFS_R, c, [2 2], idxs, 0.05, false, true, SKIP_BORDER);
CL_IND_R = shearlet_cluster_by_seeds(REPRESENTATION_R, COEFFS_R, SORT_CTRS);
[CL_IMG_R, ~, ~] = shearlet_cluster_image(CL_IND_R, size(SORT_CTRS,1), false, false);
CL_IMG_R = imrotate(CL_IMG_R, -AMOUNT);
show_rgb_r = ind2rgb(CL_IMG_R, cluster_map);

% -------------------
show_rgb_r(1:5, 1:end, :) = 0;
show_rgb_r(1:end, 1:5, :) = 0;
show_rgb_r(end-4:end, 1:end, :) = 0;
show_rgb_r(1:end, end-4:end, :) = 0;
% -------------------

while true
    
    % shows selected frame
    subplot(1,4,1);
    imshow(VID(:,:,c), []);
    
    subplot(1,4,2);
    imshow(show_rgb);
    
    subplot(1,4,3);
    imshow(show_rgb_r, []);
    
    mask = (CL_IMG ~= CL_IMG_R);
    %     mask = (CL_IMG ~= CL_IMG_R) & ...
    %         (CL_IMG ~= circshift(CL_IMG_R, [1 0])) & ...
    %         (CL_IMG ~= circshift(CL_IMG_R, [-1 0])) & ...
    %         (CL_IMG ~= circshift(CL_IMG_R, [0 1])) & ...
    %         (CL_IMG ~= circshift(CL_IMG_R, [0 -1]));
    
    subplot(1,4,4);
    %     imshow(CL_IMG ~= CL_IMG_R);
    imshow(mask);
    
    fprintf('Percentage diffent repres.: %.1f (%d)\n', nnz(mask)/numel(CL_IMG)*100, nnz(mask));
    
    % wait for user input
    waitforbuttonpress
    key = get(gcf,'CurrentKey');
    
    % process user input
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
            
            %         case 'c'
            %             [x,y] = ginput(1);
            %             fprintf('Selected Point (%d,%d)\n', floor(x), floor(y));
            %             selected = [selected; floor([x y c])];
            
        case 's'
            c = floor(input('Target frame: '));
            if(c<2)
                c=2;
            else if(c>size(VID,3)-1)
                    c = size(VID,3)-1;
                end
            end
            
        case 'q'
            break
            
        otherwise
    end
    
    [REPRESENTATION, ~, ~, ~] = shearlet_combined_fast(COEFFS, c, [2 2], idxs, 0.05, false, true, SKIP_BORDER);
    CL_IND = shearlet_cluster_by_seeds(REPRESENTATION, COEFFS, SORT_CTRS);
    [CL_IMG, ~, show_rgb] = shearlet_cluster_image(CL_IND, size(SORT_CTRS,1), false, false);
    %     show_rgb = ind2rgb(CL_IMG, cluster_map);
    
    % -------------------
    show_rgb(1:5, 1:end, :) = 0;
    show_rgb(1:end, 1:5, :) = 0;
    show_rgb(end-4:end, 1:end, :) = 0;
    show_rgb(1:end, end-4:end, :) = 0;
    % -------------------
    
    [REPRESENTATION_R, ~, ~, ~] = shearlet_combined_fast(COEFFS_R, c, [2 2], idxs, 0.05, false, true, SKIP_BORDER);
    CL_IND_R = shearlet_cluster_by_seeds(REPRESENTATION_R, COEFFS_R, SORT_CTRS);
    [CL_IMG_R, ~, ~] = shearlet_cluster_image(CL_IND_R, size(SORT_CTRS,1), false, false);
    CL_IMG_R = imrotate(CL_IMG_R, -AMOUNT);
    show_rgb_r = ind2rgb(CL_IMG_R, cluster_map);
    
    % -------------------
    show_rgb_r(1:5, 1:end, :) = 0;
    show_rgb_r(1:end, 1:5, :) = 0;
    show_rgb_r(end-4:end, 1:end, :) = 0;
    show_rgb_r(1:end, end-4:end, :) = 0;
    % -------------------
    
    
end




%% SHIFT CASE

VID_R = circshift(VID, [0 20 0]);

clear COEFFS_R idxs_r
[COEFFS_R,idxs_r] = shearlet_transform_3D(VID_R,46,91,[0 1 1], 3, 1, [2 3]);


%%

close all;

c = 37;


figure;
subplot(1,4,1);
subplot(1,4,2);
subplot(1,4,3);
subplot(1,4,4);

cluster_map = shearlet_init_cluster_map;

[REPRESENTATION, ~, ~, ~] = shearlet_combined_fast(COEFFS, c, [2 2], idxs, 0.05, false, true, SKIP_BORDER);
CL_IND = shearlet_cluster_by_seeds(REPRESENTATION, COEFFS, SORT_CTRS);
[CL_IMG, ~, show_rgb] = shearlet_cluster_image(CL_IND, size(SORT_CTRS,1), false, false);

% -------------------
show_rgb(1:5, 1:end, :) = 0;
show_rgb(1:end, 1:5, :) = 0;
show_rgb(end-4:end, 1:end, :) = 0;
show_rgb(1:end, end-4:end, :) = 0;
% -------------------

[REPRESENTATION_R, ~, ~, ~] = shearlet_combined_fast(COEFFS_R, c, [2 2], idxs, 0.05, false, true, SKIP_BORDER);
CL_IND_R = shearlet_cluster_by_seeds(REPRESENTATION_R, COEFFS_R, SORT_CTRS);
[CL_IMG_R, ~, ~] = shearlet_cluster_image(CL_IND_R, size(SORT_CTRS,1), false, false);
show_rgb_r = ind2rgb(CL_IMG_R, cluster_map);

% -------------------
show_rgb_r(1:5, 1:end, :) = 0;
show_rgb_r(1:end, 1:5, :) = 0;
show_rgb_r(end-4:end, 1:end, :) = 0;
show_rgb_r(1:end, end-4:end, :) = 0;
% -------------------

while true
    
    % shows selected frame
    subplot(1,4,1);
    imshow(VID(:,:,c), []);
    
    subplot(1,4,2);
    imshow(show_rgb);
    
    subplot(1,4,3);
    imshow(show_rgb_r, []);
    
    subplot(1,4,4);
    imshow(CL_IMG ~= circshift(CL_IMG_R, [0 -20]));
    
    fprintf('Percentage diffent repres.: %.1f (%d)\n', nnz(CL_IMG ~= circshift(CL_IMG_R, [0 -20]))/numel(CL_IMG)*100, nnz(CL_IMG ~= circshift(CL_IMG_R, [0 -20])));
    
    % wait for user input
    waitforbuttonpress
    key = get(gcf,'CurrentKey');
    
    % process user input
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
            
            %         case 'c'
            %             [x,y] = ginput(1);
            %             fprintf('Selected Point (%d,%d)\n', floor(x), floor(y));
            %             selected = [selected; floor([x y c])];
            
        case 's'
            c = floor(input('Target frame: '));
            if(c<2)
                c=2;
            else if(c>size(VID,3)-1)
                    c = size(VID,3)-1;
                end
            end
            
        case 'q'
            break
            
        otherwise
    end
    
    [REPRESENTATION, ~, ~, ~] = shearlet_combined_fast(COEFFS, c, [2 2], idxs, 0.05, false, true, SKIP_BORDER);
    CL_IND = shearlet_cluster_by_seeds(REPRESENTATION, COEFFS, SORT_CTRS);
    [CL_IMG, ~, show_rgb] = shearlet_cluster_image(CL_IND, size(SORT_CTRS,1), false, false);
    
    % -------------------
    show_rgb(1:5, 1:end, :) = 0;
    show_rgb(1:end, 1:5, :) = 0;
    show_rgb(end-4:end, 1:end, :) = 0;
    show_rgb(1:end, end-4:end, :) = 0;
    % -------------------
    
    [REPRESENTATION_R, ~, ~, ~] = shearlet_combined_fast(COEFFS_R, c, [2 2], idxs, 0.05, false, true, SKIP_BORDER);
    CL_IND_R = shearlet_cluster_by_seeds(REPRESENTATION_R, COEFFS_R, SORT_CTRS);
    [CL_IMG_R, ~, ~] = shearlet_cluster_image(CL_IND_R, size(SORT_CTRS,1), false, false);
    show_rgb_r = ind2rgb(CL_IMG_R, cluster_map);
    
    % -------------------
    show_rgb_r(1:5, 1:end, :) = 0;
    show_rgb_r(1:end, 1:5, :) = 0;
    show_rgb_r(end-4:end, 1:end, :) = 0;
    show_rgb_r(1:end, end-4:end, :) = 0;
    % -------------------
    
    
end


%%



