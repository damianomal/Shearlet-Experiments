
% ----------------------------------------
% CALCULATE THE WHOLE REPRESENTATION FIRST
% ----------------------------------------

% load the video sequence (contained in the sample_sequences directory)
clear VID
% VID = load_video_to_mat('Sample0001_color.mp4',160,1239, 1350, true);
VID = load_video_to_mat('person01_walking_d1_uncomp.avi',160,1, 100, true);

clear COEFFS idxs
clear -global shifted
[COEFFS,idxs] = shearlet_transform_3D(VID,46,91,[0 1 1], 3, 1, [2 3]);

%% CLUSTERING OF A SINGLE FRAME USING THE SHEARLET-BASED REPRESENTATION DEVELOPED

% calculate the representation for a specific frame (frame number 37 of the
% sequence represented in the VID structure)

TARGET_FRAME = 37; % 72 per truck.mp4
SCALE_USED = 2;
SKIP_BORDER = 5;

repr_type = '6dim';

switch repr_type
    case 'original'
        
        REPRESENTATION_USED = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, SCALE_USED, idxs, true, true, SKIP_BORDER);
        
    case '6dim'
        
        REPRESENTATION = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, SCALE_USED, idxs, true, true, SKIP_BORDER);
        
        lines = [1 9 25 49 81 121];
        
        REPR_RED = zeros(19200, 6);
        REPR_RED(:,1) = REPRESENTATION(:,1);
        
        for i=2:numel(lines)
            REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
        end
        
        REPRESENTATION_USED = REPR_RED;
        clear REPR_RED
        
    case '12dim'
        
        REPRESENTATION = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, 2, idxs, true, true, SKIP_BORDER);
        
        lines = [1 9 25 49 81 121];
        
        REPR_RED = zeros(19200, 6);
        REPR_RED(:,1) = REPRESENTATION(:,1);
        
        for i=2:numel(lines)
            REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
        end
        
        REPR_RED2 = zeros(19200, 12);
        REPR_RED2(:,1:6) = REPR_RED;
        
        REPRESENTATION = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, 3, idxs, true, true, SKIP_BORDER);
        
        REPR_RED = zeros(19200, 6);
        REPR_RED(:,1) = REPRESENTATION(:,1);
        
        for i=2:numel(lines)
            REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
        end
        
        REPR_RED2(:,7:12) = REPR_RED;
        
        REPRESENTATION_USED = REPR_RED2;
        clear REPR_RED REPR_RED2
        
    otherwise
        
end

%% CREATE THE CENTROIDS

CLUSTER_NUMBER = 8;
[CL_IND, CTRS] = shearlet_cluster_coefficients(REPRESENTATION_USED, CLUSTER_NUMBER, [size(COEFFS,1) size(COEFFS,2)]);

% sorts the clusters with respect to their size, and also rea

[SORTED_CL_IMAGE, SORT_CTRS] = shearlet_cluster_sort(CL_IND, CTRS);

% shows a colormap associated with the clusters found
[~,~,img] = shearlet_cluster_image(SORTED_CL_IMAGE, CLUSTER_NUMBER, false, false);

close all;

figure;
subplot(1,2,1); imshow(VID(:,:,TARGET_FRAME), []);
subplot(1,2,2); imshow(img);

%%

st = tic;

scales = [2 3]; % [scale_for_representation scale_for_motion]
motion_th = 0.05;

SKIP_BORDER = 5;

full_motion = zeros(size(COEFFS,1), size(COEFFS,2), size(COEFFS,3));
full_cluster_indexes = zeros(size(COEFFS,1), size(COEFFS,2), size(COEFFS,3));
color_maps = zeros(size(COEFFS,1), size(COEFFS,2), size(COEFFS,3), 3);

% dictionary
CENTROIDS = SORT_CTRS;

for t=20:30
        
    switch repr_type
        case 'original'
            
            [REPRESENTATION_USED, angle_map, ~, motion_colored] = shearlet_combined_fast(COEFFS, t, scales, idxs, true, true, SKIP_BORDER);
            
        case '6dim'
            
            [REPRESENTATION, angle_map, ~, motion_colored] = shearlet_combined_fast(COEFFS, t, scales, idxs, true, true, SKIP_BORDER);
            
            lines = [1 9 25 49 81 121];
            
            REPR_RED = zeros(19200, 6);
            REPR_RED(:,1) = REPRESENTATION(:,1);
            
            for i=2:numel(lines)
                REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
            end
            
            REPRESENTATION_USED = REPR_RED;
            clear REPR_RED
            
        case '12dim'
            
            [REPRESENTATION, angle_map, ~, motion_colored] = shearlet_combined_fast(COEFFS, t, [2 scales(2)], idxs, true, true, SKIP_BORDER);
            
            lines = [1 9 25 49 81 121];
            
            REPR_RED = zeros(19200, 6);
            REPR_RED(:,1) = REPRESENTATION(:,1);
            
            for i=2:numel(lines)
                REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
            end
            
            REPR_RED2 = zeros(19200, 12);
            REPR_RED2(:,1:6) = REPR_RED;
            
            [REPRESENTATION, angle_map, ~, motion_colored] = shearlet_descriptor_fast(COEFFS, t, [3 scales(2)], idxs, true, true, SKIP_BORDER);
            
            REPR_RED = zeros(19200, 6);
            REPR_RED(:,1) = REPRESENTATION(:,1);
            
            for i=2:numel(lines)
                REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
            end
            
            REPR_RED2(:,7:12) = REPR_RED;
            
            REPRESENTATION_USED = REPR_RED2;
            clear REPR_RED REPR_RED2
            
        otherwise
            
    end
    
    CL_IND = shearlet_cluster_by_seeds(REPRESENTATION_USED, COEFFS, CENTROIDS);
    full_cluster_indexes(:,:,t) = shearlet_cluster_image(CL_IND, size(CENTROIDS,1), false, false);
    full_motion(:,:,t) = angle_map(:,:,3);
    %         full_motion(:,:,t) = abs(atan(angle_map(:,:,3)));
    color_maps(:,:,t,:) = motion_colored;
end

fprintf('-- Time for Full Video Repr./Motion Extraction: %.4f seconds\n', toc(st));


%% PROFILES EXTRACTION

close all;

SELECTED_PROFILES = 3:8;
INTERVAL = 10:80;

PROF = shearlet_profiles_over_time(full_cluster_indexes, 1, 90, SELECTED_PROFILES);
clusters_ot_image =  shearlet_plot_profiles_over_time(PROF(:,INTERVAL), SELECTED_PROFILES, 1, false);

full_cluster_filtered = full_cluster_indexes;
full_cluster_filtered(full_motion == 0) = 0;

PROF_FILT = shearlet_profiles_over_time(full_cluster_filtered, 1, 90, SELECTED_PROFILES);
clusters_ot_image_filt =  shearlet_plot_profiles_over_time(PROF_FILT(:,INTERVAL), SELECTED_PROFILES, 1, false);

PROF_EDIT = PROF;

for i=1:size(PROF_EDIT,1)
    PROF_EDIT(i,:) = PROF_EDIT(i,:) - mean(PROF_EDIT(i,:));
end

%% VISUALIZATION OVER TIME

count = 1;
START_IND = 20;
END_LIM = 30;

cluster_map = shearlet_init_cluster_map;

cwheel = shearlet_show_color_wheel(true);

hand = figure('Position', [1 41 1920 963]);

record = false;

if(record)
    
    vidObjs = cell(1,4);
    prefix = 'carrot_cam2_scale2and2_th005';
    
    vidObjs{1} = VideoWriter([prefix '_video.avi']);
    vidObjs{1}.Quality = 100;
    vidObjs{1}.FrameRate = 25;
    
    open(vidObjs{1});
    
    vidObjs{2} = VideoWriter([prefix '_motion.avi']);
    vidObjs{2}.Quality = 100;
    vidObjs{2}.FrameRate = 25;
    
    open(vidObjs{2});
    
    vidObjs{3} = VideoWriter([prefix '_direction.avi']);
    vidObjs{3}.Quality = 100;
    vidObjs{3}.FrameRate = 25;
    
    open(vidObjs{3});
    
    vidObjs{4} = VideoWriter([prefix '_clusters.avi']);
    vidObjs{4}.Quality = 100;
    vidObjs{4}.FrameRate = 25;
    
    open(vidObjs{4});
end

while true
        
    subplot(2,3,1);
    imshow(cat(3,VID(:,:,START_IND-1+count),VID(:,:,START_IND-1+count),VID(:,:,START_IND-1+count))./255);
    title('Current frame');
    
    subplot(2,3,2);
    imshow(abs(full_motion(:,:,START_IND-1+count)), [0 1]);
    
    colormap(hot);
    title('Magnitude of motion');
    
    subplot(2,3,3);
    
    % ---------------
    cma = squeeze(color_maps(:,:,START_IND - 1 + count,:));
    CCC = full_motion(:,:,START_IND-1+count) == 0;
    CCC = cat(3, CCC,CCC,CCC);
    cma(CCC) = 255;
    imshow(cma);
    % ---------------
    
    title('Direction of motion');
    
    subplot(2,3,4);
    show_rgb = ind2rgb(full_cluster_indexes(:,:,START_IND-1+count), cluster_map);
    
    % -------------------
    show_rgb(1:5, 1:end, :) = 0;
    show_rgb(1:end, 1:5, :) = 0;
    show_rgb(end-4:end, 1:end, :) = 0;
    show_rgb(1:end, end-4:end, :) = 0;
    % -------------------
    
    imshow(show_rgb);
    
    title('Clusters color coded');
    
    subplot(2,3,5);
    count2 = count*(size(clusters_ot_image_filt,2)/(END_LIM-START_IND+1));
    
    imshow(clusters_ot_image_filt);
    hold on;
    line([count2 count2], [0 size(clusters_ot_image_filt,2)], 'linewidth',4, 'Color',[1 0 0]);
    hold off;
    
    title(['Frame ' int2str(START_IND-1+count)]);
    
    subplot(2,3,6);
    imshow(cwheel);
    
    pause(0.001);
    
    if(record)
        for i=1:4
            subplot(2,3,i);
            fg = getframe();
            writeVideo(vidObjs{i}, fg.cdata);
        end
    end
    
    %     waitforbuttonpress;
    
    
    %         if(ismember(START_IND-1+count, frames_to_save))
    %             imwrite(VID(:,:,START_IND-1+count)./255, ['frame_' savenacme '_' int2str(START_IND-1+count) '.png']);
    %             imwrite(squeeze(color_map(:,:,count, :)), ['frame_color_' savename '_' int2str(START_IND-1+count) '.png']);
    %         end
    
    %     if(ismember(START_IND-1+count, frames_to_pause))
    %         pause;
    %     end
    
    count = count + 1;
    
    % skipping last frames
    if(count > size(full_motion,3) || count > END_LIM)
        count = 1;
%                 break;
    end
    
end

if(record)
    
    imwrite(clusters_ot_image_filt, [prefix '_graph.png'], 'png');
    
    close(vidObjs{1});
    close(vidObjs{2});
    close(vidObjs{3});
    close(vidObjs{4});
    
end

close(hand);