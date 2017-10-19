
%%

clear VID

VID = load_video_to_mat('person04_boxing_d1_uncomp.avi',160,1,100, true);
% VID = load_video_to_mat('Sample0001_color.mp4',160,1239, 1350, true);
% VID = load_video_to_mat('mixing_cam1.avi',160,1, 100, true);
% VID = load_video_to_mat('TRUCK.mp4',160,1300,1400, true);

clear COEFFS idxs
clear -global shifted
[COEFFS,idxs] = shearlet_transform_3D(VID,46,91,[0 1 1], 3, 1, [2 3]);

%% CLUSTERING coefficients of a given scale directly (75 dimensional)

cluster_map = shearlet_init_cluster_map;

TARGET_FRAME = 73;
SCALE_USED = 2;

opts = statset('Display','final', 'MaxIter',200);

clear -global shifted
COEFFS_SHIFT = shearlet_global_coeff_shift(COEFFS, idxs, TARGET_FRAME, 1);
COEFFS_SHIFT = COEFFS_SHIFT(:,:,idxs(:,2) == SCALE_USED);

CLUSTER_NUMBER = 8;

C = reshape(COEFFS_SHIFT,[],size(COEFFS_SHIFT,3),1);
[clusterid1, clusterctrs1] = kmeans(C, CLUSTER_NUMBER, 'Distance', 'sqeuclidean', 'Replicates',3, 'Options',opts);
[clusterid2, clusterctrs2] = kmeans(C, CLUSTER_NUMBER, 'Distance', 'cityblock', 'Replicates',3, 'Options',opts);

CC1 = reshape(clusterid1,120,160);
CC2 = reshape(clusterid2,120,160);

[CC1, ~] = shearlet_cluster_sort(CC1, clusterctrs1);
[CC2, ~] = shearlet_cluster_sort(CC2, clusterctrs2);

[~,~,img1] = shearlet_cluster_image(CC1, CLUSTER_NUMBER, false, false);
[~,~,img2] = shearlet_cluster_image(CC2, CLUSTER_NUMBER, false, false);

close all;
figure;
subplot(1,2,1); imshow(img1);
subplot(1,2,2); imshow(img2);
% colormap(cluster_map)

%% CLUSTERING 121/242 dimensional representation, concat scale 2 and 3

TARGET_FRAME = 73; % 72 per truck.mp4, 46 per gesture, 37 per boxing, 37 per mixing
SKIP_BORDER = 5;

REPRESENTATION = zeros(19200,121*2);
REPRESENTATION(:,1:121) = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, 2, idxs, true, true, SKIP_BORDER);
REPRESENTATION(:,122:end) = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, 3, idxs, true, true, SKIP_BORDER);

% REPRESENTATION = REPRESENTATION(:,1:121) .* REPRESENTATION(:,122:end);

CLUSTER_NUMBER = 8;

[CL_IND, CTRS] = shearlet_cluster_coefficients(REPRESENTATION, CLUSTER_NUMBER, [size(COEFFS,1) size(COEFFS,2)]);
[SORTED_CL_IMAGE, SORT_CTRS_full] = shearlet_cluster_sort(CL_IND, CTRS);
[~,~,img] = shearlet_cluster_image(SORTED_CL_IMAGE, CLUSTER_NUMBER, false, false);

[CL_IND2, CTRS2] = shearlet_cluster_coefficients(REPRESENTATION(:,1:121), CLUSTER_NUMBER, [size(COEFFS,1) size(COEFFS,2)]);
[SORTED_CL_IMAGE2, SORT_CTRS_red] = shearlet_cluster_sort(CL_IND2, CTRS2);
[~,~,img2] = shearlet_cluster_image(SORTED_CL_IMAGE2, CLUSTER_NUMBER, false, false);

[CL_IND3, CTRS3] = shearlet_cluster_coefficients(REPRESENTATION(:,122:end), CLUSTER_NUMBER, [size(COEFFS,1) size(COEFFS,2)]);
[SORTED_CL_IMAGE3, SORT_CTRS_3] = shearlet_cluster_sort(CL_IND3, CTRS3);
[~,~,img3] = shearlet_cluster_image(SORTED_CL_IMAGE3, CLUSTER_NUMBER, false, false);

close all;

figure;
subplot(1,4,1); imshow(VID(:,:,TARGET_FRAME), []);
subplot(1,4,2); imshow(img); 
subplot(1,4,3); imshow(img2); 
subplot(1,4,4); imshow(img3); 

%% setting CLUSTERS number

CLUSTER_NUMBER = 12;

%% CLUSTERING 6-dimensional representation

TARGET_FRAME = 37; % 72 per truck.mp4, 46 per gesture, 37 per boxing, 37 per mixing
SCALE_USED = 2;
SKIP_BORDER = 0;

REPRESENTATION = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, SCALE_USED, idxs, true, true, SKIP_BORDER);

lines = [1 9 25 49 81 121];

REPR_RED = zeros(19200, 6);
REPR_RED(:,1) = REPRESENTATION(:,1);

for i=2:numel(lines)
    REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
end

CLUSTER_NUMBER = 8;

[CL_IND, CTRS] = shearlet_cluster_coefficients(REPR_RED, CLUSTER_NUMBER, [size(COEFFS,1) size(COEFFS,2)]);

% sorts the clusters with respect to their size, and also rea
[SORTED_CL_IMAGE, cctrs] = shearlet_cluster_sort(CL_IND, CTRS);

% shows a colormap associated with the clusters found
[~,~,img] = shearlet_cluster_image(SORTED_CL_IMAGE, CLUSTER_NUMBER, false, false);

close all;

figure;
subplot(1,2,1); imshow(VID(:,:,TARGET_FRAME), []);
subplot(1,2,2); imshow(img);
% title(['Scale ' int2str(SCALE_USED) ' (6-dim)']);

%% REPRESENTATION (12-dim) cat scale 2 and 3

% REPR_RED2 = zeros(19200, 12);
% REPR_RED2(:,1:6) = REPR_RED;

SCALE_USED = 2;
SKIP_BORDER = 0;

REPRESENTATION = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, SCALE_USED, idxs, true, true, SKIP_BORDER);

lines = [1 9 25 49 81 121];
% lines = [1:3:121];

REPR_RED = zeros(19200, 6);
REPR_RED(:,1) = REPRESENTATION(:,1);

for i=2:numel(lines)
%     siz = lines(i) - lines(i-1);
    REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
%     REPR_RED(:,i) = mean(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
end

REPR_RED2 = zeros(19200, 12);
REPR_RED2(:,1:6) = REPR_RED;

SCALE_USED = 3;

REPRESENTATION = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, SCALE_USED, idxs, true, true, SKIP_BORDER);

REPR_RED = zeros(19200, 6);
REPR_RED(:,1) = REPRESENTATION(:,1);

for i=2:numel(lines)
%     siz = lines(i) - lines(i-1);
    REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
%     REPR_RED(:,i) = mean(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
end

% REPR_RED2(:,7:12) = REPR_RED;
REPR_RED2(:,7:12) = REPR_RED .* 0.5;

CLUSTER_NUMBER = 4;

[CL_IND, CTRS] = shearlet_cluster_coefficients(REPR_RED2, CLUSTER_NUMBER, [size(COEFFS,1) size(COEFFS,2)]);

% sorts the clusters with respect to their size, and also rea
[SORTED_CL_IMAGE, SORT_CTRS{CLUSTER_NUMBER}] = shearlet_cluster_sort(CL_IND, CTRS);

% shows a colormap associated with the clusters found
[~,~,img] = shearlet_cluster_image(SORTED_CL_IMAGE, CLUSTER_NUMBER, false, false);

% close all;

figure;
subplot(1,2,1); imshow(VID(:,:,TARGET_FRAME), []);
subplot(1,2,2); imshow(img);
title('Scale 2 and 3 cat (12-dim)')

%% REPRESENTATION (cat permutations)

SCALE_USED = 3;
SKIP_BORDER = 5;

REPRESENTATION = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, SCALE_USED, idxs, true, true, SKIP_BORDER);

lines = [1 9 25 49 81 121];
% lines = [1:3:121];

REPR_RED = zeros(19200, 6);
REPR_RED(:,1) = REPRESENTATION(:,1);

for i=2:numel(lines)
    siz = lines(i) - lines(i-1);
    REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
end

REPR_PERM = zeros(19200,21);
REPR_PERM(:,1:6) = REPR_RED;

c = 7;

for i = 1:6
    for j = i+1:6
        REPR_PERM(:,c) = (REPR_PERM(:,i) +  REPR_PERM(:,j)) ./ 2;
        
        REPR_REM = zeros(19200, 1);
        
        for z = 1:6
            if(z == i || z == j)
                continue
            end
            
            REPR_REM = REPR_REM + REPR_PERM(:,z);
        end
        
        REPR_PERM(:,c) = REPR_PERM(:,c) - REPR_REM./4;
        
        REPR_PERM(REPR_PERM(:,c) < 0,c) = 0;
        
        c = c + 1;
    end
end


CLUSTER_NUMBER = 8;
[CL_IND, CTRS] = shearlet_cluster_coefficients(REPR_PERM, CLUSTER_NUMBER, [size(COEFFS,1) size(COEFFS,2)]);

% sorts the clusters with respect to their size, and also rea
[SORTED_CL_IMAGE, SORT_CTRS{CLUSTER_NUMBER}] = shearlet_cluster_sort(CL_IND, CTRS);

% shows a colormap associated with the clusters found
[~,~,img] = shearlet_cluster_image(SORTED_CL_IMAGE, CLUSTER_NUMBER, false, false);

% close all;

figure;
subplot(1,2,1); imshow(VID(:,:,TARGET_FRAME), []);
subplot(1,2,2); imshow(img);
title('Scale 2 perm prod scaled (21-dim)')

%% REPRESENTATION (cat permutations and scaled)

REPR_PERM = zeros(19200,21);
REPR_PERM(:,1:6) = REPR_RED;

c = 7;

for i = 1:6
    for j = i+1:6
        REPR_PERM(:,c) = (REPR_PERM(:,i) +  REPR_PERM(:,j));        
        c = c + 1;
    end
end


% CLUSTER_NUMBER = 8;
[CL_IND, CTRS] = shearlet_cluster_coefficients(REPR_PERM, CLUSTER_NUMBER, [size(COEFFS,1) size(COEFFS,2)]);

% sorts the clusters with respect to their size, and also rea
[SORTED_CL_IMAGE, SORT_CTRS{CLUSTER_NUMBER}] = shearlet_cluster_sort(CL_IND, CTRS);

% shows a colormap associated with the clusters found
[~,~,img] = shearlet_cluster_image(SORTED_CL_IMAGE, CLUSTER_NUMBER, false, false);

% close all;

figure;
subplot(1,2,1); imshow(VID(:,:,TARGET_FRAME), []);
subplot(1,2,2); imshow(img);
title('Scale 2 perm prod scaled (21-dim)')
