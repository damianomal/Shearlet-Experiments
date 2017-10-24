
%%

% videos = {{'person04_boxing_d1_uncomp.avi', 1, 100, [4 8]}
%     {'person04_boxing_d1_uncomp.avi', 1, 100, [4 8]}};

videos = dict_create_video_cell('E:\Datasets_31GB\KTH');

addpath(genpath('E:\Datasets_31GB\KTH'));

%%

% --- DETECTION PARAMETERS

LOWER_THRESHOLD = 0.1;
SPT_WINDOW = 11;
SCALES = [2];
CONE_WEIGHTS = [1 1 1];

% --- REPRESENTATION PARAMETERS

lines = [1 9 25 49 81 121];

SKIP_BORDER = 5;
new_ctr_index = 0;

repr_type = '12dim';

INIT_DIM = 1000;

switch repr_type
    
    case 'original'
        ALL_CENTROIDS = zeros(INIT_DIM, 121);
    case '6dim_sc2'
        ALL_CENTROIDS = zeros(INIT_DIM, 6);
    case '6dim_sc3'
        ALL_CENTROIDS = zeros(INIT_DIM, 6);
    case '12dim'
        ALL_CENTROIDS = zeros(INIT_DIM, 12);
        
end

DISTANCE_TH = 0.1;

for id = 1:numel(videos)
       
    video_filename = videos{id}{1}; 
    video_start = videos{id}{2};
    video_end =  videos{id}{3};
    video_min_k =  videos{id}{4}(1);
    video_max_k = videos{id}{4}(2);
    
    fprintf('---- Processing video: %s\n', video_filename);

    % --- VIDEO LOADING ---
    clear VID
    VID = load_video_to_mat(video_filename, 160, video_start, video_end, false);
    
    clear COEFFS
    [COEFFS,idxs] = shearlet_transform_3D(VID,46,91,[0 1 1], 3, 1, [2 3]);
    
    % --- DETECTION ---
    close all;
    clear CHANGE_MAP
    [COORDINATES, CHANGE_MAP] = shearlet_detect_points_new( VID(:,:,1:91), COEFFS, SCALES, [], LOWER_THRESHOLD, SPT_WINDOW, CONE_WEIGHTS, false);
    
    [COUNTS] = comparison_points_over_time(VID(:,:,1:91), COORDINATES, false);
    [~, counts_ind] = sort(COUNTS,2, 'descend');
    frames = counts_ind(1:4);
    
    % --- PER-FRAME OPERATIONS ---
    for frame = frames
        
        fprintf('Processing video: %s, frame: %d\n', video_filename, frame);
        
        % --- REPRESENTATION CREATION ---
        %         REPRESENTATION2 = shearlet_descriptor_fast(COEFFS, frame, 2, idxs, true, true, SKIP_BORDER);
        %         REPRESENTATION3 = shearlet_descriptor_fast(COEFFS, frame, 3, idxs, true, true, SKIP_BORDER);
        %
        %         REPRESENTATION2_RED = zeros(19200, 6);
        %         REPRESENTATION2_RED(:,1) = REPRESENTATION2(:,1);
        %
        %         for i=2:numel(lines)
        %             siz = lines(i) - lines(i-1);
        %             REPRESENTATION2_RED(:,i) = sum(REPRESENTATION2(:,lines(i-1)+1:lines(i)),2);
        %         end
        %
        %         REPRESENTATION3_RED = zeros(19200, 6);
        %         REPRESENTATION3_RED(:,1) = REPRESENTATION3(:,1);
        %
        %         for i=2:numel(lines)
        %             siz = lines(i) - lines(i-1);
        %             REPRESENTATION3_RED(:,i) = sum(REPRESENTATION3(:,lines(i-1)+1:lines(i)),2);
        %         end
        %
        %         REPRESENTATION_CAT = [REPRESENTATION2_RED REPRESENTATION3_RED];
        
        REPRESENTATION_USED = shearlet_descriptor_fast_by_type(COEFFS, frame, idxs, repr_type, true, true, SKIP_BORDER);
        
        % --- CLUSTERING AND CENTROIDS ADDING ---
        for K = video_min_k:video_max_k
            
            [~, CTRS] = shearlet_cluster_coefficients(REPRESENTATION_USED, K, [size(COEFFS,1) size(COEFFS,2)]);
            
            for i =1:K
                
                CUR_CTR = CTRS(i, :);
                CUR_CTR_MAT = repmat(CUR_CTR, size(ALL_CENTROIDS,1),1);
                DIST = sum((double(CUR_CTR_MAT) - double(ALL_CENTROIDS)),2) .^ 2;
                
                [mn, mi] = min(DIST);
                
                % se la differenza e' sufficiente, lo considera nei
                % clusters generali
                if(mn > DISTANCE_TH)
                    
                    new_ctr_index = new_ctr_index + 1;
                    
                    if(new_ctr_index > size(ALL_CENTROIDS))
                        ALL_CENTROIDS = [ALL_CENTROIDS; zeros(20, 12)];
                    end
                    
                    ALL_CENTROIDS(new_ctr_index,:) = CUR_CTR;
                    
                    %                 else
                    %                     ALL_CENTROIDS(mi,:) = (ALL_CENTROIDS(mi,:) + CUR_CTR) ./2;
                end
            end
        end
    end
    
end

ALL_CENTROIDS = ALL_CENTROIDS(1:new_ctr_index, :);

fprintf('---- Estratti %d centroidi.\n', new_ctr_index);

%%

close all;
shearlet_show_vocabulary_nointeractive(ALL_CENTROIDS, 2, 5);

%%

st = tic;

scales = [2 3]; % [scale_for_representation scale_for_motion]
motion_th = 0.05;

SKIP_BORDER = 5;

full_motion = zeros(size(COEFFS,1), size(COEFFS,2), size(COEFFS,3));
full_cluster_indexes = zeros(size(COEFFS,1), size(COEFFS,2), size(COEFFS,3));
color_maps = zeros(size(COEFFS,1), size(COEFFS,2), size(COEFFS,3), 3);

% dictionary
CENTROIDS = ALL_CENTROIDS;

for t=10:80
    
    REPRESENTATION_USED = shearlet_descriptor_fast_by_type(COEFFS, t, idxs, repr_type, true, true, SKIP_BORDER);
    CL_IND = shearlet_cluster_by_seeds(REPRESENTATION_USED, COEFFS, CENTROIDS);
    full_cluster_indexes(:,:,t) = shearlet_cluster_image(CL_IND, size(CENTROIDS,1), false, false);
%     full_motion(:,:,t) = angle_map(:,:,3);
    %         full_motion(:,:,t) = abs(atan(angle_map(:,:,3)));
%     color_maps(:,:,t,:) = motion_colored;
end

fprintf('-- Time for Full Video Repr./Motion Extraction: %.4f seconds\n', toc(st));

%% PROFILES EXTRACTION

close all;

SELECTED_PROFILES = 2:9;
INTERVAL = 10:80;

PROF = shearlet_profiles_over_time(full_cluster_indexes, 1, 90, SELECTED_PROFILES);
clusters_ot_image =  shearlet_plot_profiles_over_time(PROF(:,INTERVAL), SELECTED_PROFILES, 1, false);

%%


%% VISUALIZATION OVER TIME

count = 1;
START_IND = 10;
END_LIM = 80;

cluster_map = shearlet_init_cluster_map;

figure;

while true
        
    subplot(1,2,1);
    imshow(cat(3,VID(:,:,START_IND-1+count),VID(:,:,START_IND-1+count),VID(:,:,START_IND-1+count))./255);
    title('Current frame');
    
    subplot(1,2,2);
    show_rgb = ind2rgb(full_cluster_indexes(:,:,START_IND-1+count), cluster_map);
    
    % -------------------
    show_rgb(1:5, 1:end, :) = 0;
    show_rgb(1:end, 1:5, :) = 0;
    show_rgb(end-4:end, 1:end, :) = 0;
    show_rgb(1:end, end-4:end, :) = 0;
    % -------------------
    
    imshow(show_rgb);
    
    title('Clusters color coded');
    
    pause(0.04);
    
    count = count + 1;
    
    % skipping last frames
    if(count > size(full_motion,3) || count > END_LIM)
        count = 1;
%                 break;
    end
    
end
