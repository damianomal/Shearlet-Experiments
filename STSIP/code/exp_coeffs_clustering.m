

%%



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
% VID = load_video_to_mat('Sample0001_color.mp4',160,1239, 1350, false);

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



%%

opts = statset('Display','final', 'MaxIter',200);

COEFFS_SHIFT = shearlet_global_coeff_shift(COEFFS, idxs, 37, 1);
COEFFS_SHIFT = COEFFS_SHIFT(:,:,idxs(:,3) == 1);

CLUSTER_NUMBER = 12;

C = reshape(COEFFS_SHIFT,[],size(COEFFS_SHIFT,3),1);
[clusterid1, clusterctrs1] = kmeans(C, CLUSTER_NUMBER, 'Distance', 'sqeuclidean', 'Replicates',3, 'Options',opts);
[clusterid2, clusterctrs2] = kmeans(C, CLUSTER_NUMBER, 'Distance', 'cityblock', 'Replicates',3, 'Options',opts);

CC1 = reshape(clusterid1,120,160);
CC2 = reshape(clusterid2,120,160);

close all;
figure;
subplot(1,2,1); imshow(CC1, []);
subplot(1,2,2); imshow(CC2, []);
colormap(cluster_map)

%% DEBUGGING

TARGET_FRAME = 37; % 72 per truck.mp4, 46 per gesture, 37 per boxing, 37 per mixing
SCALE_USED = 2;
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

% REPR_RED2 = zeros(19200, 12);
% REPR_RED2(:,1:6) = REPR_RED;
% 
% SCALE_USED = 3;
% 
% REPRESENTATION = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, SCALE_USED, idxs, true, true, SKIP_BORDER);
% 
% % lines = [1 9 25 49 81 121];
% % lines = [1:3:121];
% 
% REPR_RED = zeros(19200, 6);
% REPR_RED(:,1) = REPRESENTATION(:,1);
% 
% for i=2:numel(lines)
%     siz = lines(i) - lines(i-1);
%     REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
% end
% 
% REPR_RED2(:,7:12) = REPR_RED;

REPR_PERM = zeros(19200,21);
REPR_PERM(:,1:6) = REPR_RED;

c = 7;

for i = 1:6
    for j = i+1:6
        REPR_PERM(:,c) = (REPR_PERM(:,i) .*  REPR_PERM(:,j)) .* 3;
        
%         REPR_REM = zeros(19200, 1);
%         
%         for z = 1:6
%             if(z == i || z == j)
%                 continue
%             end
%             
%             REPR_REM = REPR_REM + REPR_PERM(:,z);
%         end
%         
%         REPR_PERM(:,c) = REPR_PERM(:,c) - REPR_REM./4;
%         
%         REPR_PERM(REPR_PERM(:,c) < 0,c) = 0;
        
        c = c + 1;
    end
end


CLUSTER_NUMBER = 10;
[CL_IND, CTRS] = shearlet_cluster_coefficients(REPR_RED, CLUSTER_NUMBER, [size(COEFFS,1) size(COEFFS,2)]);
% [CL_IND, CTRS] = shearlet_cluster_coefficients(REPR_RED2, CLUSTER_NUMBER, [size(COEFFS,1) size(COEFFS,2)]);
% [CL_IND, CTRS] = shearlet_cluster_coefficients(REPR_PERM, CLUSTER_NUMBER, [size(COEFFS,1) size(COEFFS,2)]);

% sorts the clusters with respect to their size, and also rea

[SORTED_CL_IMAGE, SORT_CTRS{CLUSTER_NUMBER}] = shearlet_cluster_sort(CL_IND, CTRS);

% shows a colormap associated with the clusters found

[~,~,img] = shearlet_cluster_image(SORTED_CL_IMAGE, CLUSTER_NUMBER, false, false);

% close all;

figure;
subplot(1,2,1); imshow(VID(:,:,TARGET_FRAME), []);
subplot(1,2,2); imshow(img);
title('Scale 2 perm prod scaled')

%%


lines = [1:1:121];

REPR_RED = zeros(19200, numel(lines));
REPR_RED(:,1) = REPRESENTATION(:,1);

for i=2:numel(lines)
    siz = lines(i) - lines(i-1);
    REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2) ./ siz;
end

CLUSTER_NUMBER = 9;
[CL_IND, CTRS] = shearlet_cluster_coefficients(REPR_RED, CLUSTER_NUMBER, [size(COEFFS,1) size(COEFFS,2)]);

% sorts the clusters with respect to their size, and also rea

[SORTED_CL_IMAGE, SORT_CTRS{CLUSTER_NUMBER}] = shearlet_cluster_sort(CL_IND, CTRS);


%
lines = [1 9 25 49 81 121];
% lines = [1:2:121];

REPR_RED2 = zeros(19200, numel(lines));
REPR_RED2(:,1) = REPRESENTATION(:,1);

for i=2:numel(lines)
    siz = lines(i) - lines(i-1);
    REPR_RED2(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2) ./ siz;
end

CLUSTER_NUMBER = 9;
[CL_IND2, CTRS] = shearlet_cluster_coefficients(REPR_RED2, CLUSTER_NUMBER, [size(COEFFS,1) size(COEFFS,2)]);

% sorts the clusters with respect to their size, and also rea

[SORTED_CL_IMAGE2, SORT_CTRS{CLUSTER_NUMBER}] = shearlet_cluster_sort(CL_IND2, CTRS);
% CL_IND2 = shearlet_cluster_by_seeds(REPR_RED, COEFFS, SORT_CTRS{CLUSTER_NUMBER});
% CL_IND2 = shearlet_cluster_by_seeds(REPR_RED, COEFFS, SORT_CTRS{CLUSTER_NUMBER});
% [SORTED_CL_IMAGE2, ~, ~] = shearlet_cluster_image(CL_IND2, size(SORT_CTRS,1), false, false);


mask = SORTED_CL_IMAGE ~= SORTED_CL_IMAGE2;
fprintf('Percentage diffent repres.: %.1f (%d)\n', nnz(mask)/numel(SORTED_CL_IMAGE)*100, nnz(mask));

show_rgb = ind2rgb(SORTED_CL_IMAGE, cluster_map);

% -------------------
show_rgb(1:5, 1:end, :) = 0;
show_rgb(1:end, 1:5, :) = 0;
show_rgb(end-4:end, 1:end, :) = 0;
show_rgb(1:end, end-4:end, :) = 0;
% -------------------


show_rgb_r = ind2rgb(SORTED_CL_IMAGE2, cluster_map);

% -------------------
show_rgb_r(1:5, 1:end, :) = 0;
show_rgb_r(1:end, 1:5, :) = 0;
show_rgb_r(end-4:end, 1:end, :) = 0;
show_rgb_r(1:end, end-4:end, :) = 0;
% -------------------

figure;

subplot(1,4,1);
imshow(VID(:,:,TARGET_FRAME), []);

subplot(1,4,2);
imshow(show_rgb);

subplot(1,4,3);
imshow(show_rgb_r, []);

subplot(1,4,4);
imshow(mask, []);



%%

TARGET_FRAME = 37; % 72 per truck.mp4, 46 per gesture, 37 per boxing, 37 per mixing
SCALE_USED = 2;
SKIP_BORDER = 5;

REPRESENTATION = zeros(19200,121*2);
REPRESENTATION(:,1:121) = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, 2, idxs, true, true, SKIP_BORDER);
REPRESENTATION(:,122:end) = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, 3, idxs, true, true, SKIP_BORDER);

% REPRESENTATION = REPRESENTATION(:,1:121) .* REPRESENTATION(:,122:end);

CLUSTER_NUMBER = 12;

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

% cluster_edit_map = cluster_map;
% 
% cluster_edit_map(2,:) = [0 0 1];
% cluster_edit_map(3,:) = [0 0 1];
% cluster_edit_map(4,:) = [0 0 1];
% 
% 
% subplot(1,4,2); imshow(ind2rgb(SORTED_CL_IMAGE, cluster_edit_map)); title('Scale 2 concat Scale 3');
% subplot(1,4,3); imshow(ind2rgb(SORTED_CL_IMAGE2, cluster_edit_map)); title('Scale 2');
% subplot(1,4,4); imshow(ind2rgb(SORTED_CL_IMAGE3, cluster_edit_map)); title('Scale 3');





