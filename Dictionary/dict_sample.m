
%%

videos = {'person04_boxing_d1_uncomp.avi', 1, 100, [5 6];};

%%

SKIP_BORDER = 5;

LOWER_THRESHOLD = 0.1;
SPT_WINDOW = 11;
SCALES = [2];
CONE_WEIGHTS = [1 1 1];

lines = [1 9 25 49 81 121];

ALL_CENTROIDS_2 = zeros(1000,6);
ALL_CENTROIDS_3 = zeros(1000,6);
ALL_CENTROIDS_23 = zeros(1000,12);

new_ctr_index = 1;

DISTANCE_TH = 0.5;

for id = size(videos,1)
        
    fprintf('---- Processing video: %s\n', videos{id,1});
    
    % --- VIDEO LOADING ---
    clear VID
    VID = load_video_to_mat(videos{id,1}, 160, videos{id,2}, videos{id,3}, true);
    
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
    
        fprintf('Processing video: %s, frame: %d\n', videos{id,1}, frame);    
        
        % --- REPRESENTATION CREATION ---
        REPRESENTATION2 = shearlet_descriptor_fast(COEFFS, frame, 2, idxs, true, true, SKIP_BORDER);
        REPRESENTATION3 = shearlet_descriptor_fast(COEFFS, frame, 3, idxs, true, true, SKIP_BORDER);
        
        REPRESENTATION2_RED = zeros(19200, 6);
        REPRESENTATION2_RED(:,1) = REPRESENTATION2(:,1);
        
        for i=2:numel(lines)
            siz = lines(i) - lines(i-1);
            REPRESENTATION2_RED(:,i) = sum(REPRESENTATION2(:,lines(i-1)+1:lines(i)),2);
        end
        
        REPRESENTATION3_RED = zeros(19200, 6);
        REPRESENTATION3_RED(:,1) = REPRESENTATION3(:,1);
        
        for i=2:numel(lines)
            siz = lines(i) - lines(i-1);
            REPRESENTATION3_RED(:,i) = sum(REPRESENTATION3(:,lines(i-1)+1:lines(i)),2);
        end
        
        REPRESENTATION_CAT = [REPRESENTATION2_RED REPRESENTATION3_RED];
        
        % --- CLUSTERING AND CENTROIDS ADDING ---
        for K = videos{id,4}(1):videos{id,4}(2)
            
            [~, CTRS] = shearlet_cluster_coefficients(REPRESENTATION_CAT, K, [size(COEFFS,1) size(COEFFS,2)]);

            for i =1:K
                
                CUR_CTR = CTRS(i, :);
                CUR_CTR_MAT = repmat(CUR_CTR, size(ALL_CENTROIDS_23,1),1);
                DIST = sum((double(CUR_CTR_MAT) - double(ALL_CENTROIDS_23)),2) .^ 2;
                [~,mi] = max(DIST);
                
                % se la differenza e' sufficiente, lo considera nei
                % clusters generali
                if(mi > DISTANCE_TH)
                    
                    new_ctr_index = new_ctr_index + 1;
                    
                    if(new_ctr_index > size(ALL_CENTROIDS_23))
                        ALL_CENTROIDS_23 = [ALL_CENTROIDS_23; zeros(20, 12)];
                    end
                    
                    ALL_CENTROIDS_23(new_ctr_index,:) = CUR_CTR;
                    
                end
            end        
        end
    end
    
end

ALL_CENTROIDS_23 = ALL_CENTROIDS_23(1:new_ctr_index, :);

%%




