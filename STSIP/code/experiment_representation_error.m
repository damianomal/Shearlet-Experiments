

close all;

% lista di video da caricare
video_filenames = {'person04_boxing_d1_uncomp.avi',1,100;
    'Sample0001_color.mp4', 1239, 1350;
    'mixing_cam2.avi', 1, 100;
    'trial_018.avi', 1, 100};

% video_filenames = {'mixing_cam2.avi', 1, 100};
descriptors = [];

%% video da caricare per selezionare punti


id = 3;
filename = video_filenames{id,1};
start_vid = video_filenames{id,2};
end_vid  = video_filenames{id,3};

VID = load_video_to_mat(filename, 160, start_vid, end_vid, true);

% clear start_vid end_vid filename

clear COEFFS idxs
[COEFFS,idxs] = shearlet_transform_3D(VID,46,91,[0 1 1], 3, 1, [2 3]);

%%

SORT_CTRS = cell(1,13);

%% CLUSTERING OF A SINGLE FRAME USING THE SHEARLET-BASED REPRESENTATION DEVELOPED

% calculate the representation for a specific frame (frame number 37 of the
% sequence represented in the VID structure)

TARGET_FRAME = 37; % 72 per truck.mp4, 46 per gesture, 37 per boxing, 37 per mixing
SCALE_USED = 2;
SKIP_BORDER = 5;

REPRESENTATION = shearlet_descriptor_fast(COEFFS, TARGET_FRAME, SCALE_USED, idxs, true, true, SKIP_BORDER);

for cl=2:13
    
    CLUSTER_NUMBER = cl;
    [CL_IND, CTRS] = shearlet_cluster_coefficients(REPRESENTATION, CLUSTER_NUMBER, [size(COEFFS,1) size(COEFFS,2)]);

    % sorts the clusters with respect to their size, and also rea

    [SORTED_CL_IMAGE, SORT_CTRS{CLUSTER_NUMBER}] = shearlet_cluster_sort(CL_IND, CTRS);

    % shows a colormap associated with the clusters found

    [~,~,img] = shearlet_cluster_image(SORTED_CL_IMAGE, CLUSTER_NUMBER, false, false);

end

% close all;
% 
% figure;
% subplot(1,2,1); imshow(VID(:,:,TARGET_FRAME), []);
% subplot(1,2,2); imshow(img);

%% DEBUG TEMPORANEO CLUSTER_BY_SEEDS

TARGET_FRAME = 37;
SCALES = [2 2];
CLUSTER_NUMBER = 12;

[REPRESENTATION, ~, ~, ~] = shearlet_combined_fast(COEFFS, TARGET_FRAME, SCALES, idxs, 0.05, false, true, SKIP_BORDER);
CL_IND = shearlet_cluster_by_seeds(REPRESENTATION, COEFFS, SORT_CTRS{CLUSTER_NUMBER});
[~, ~, img] = shearlet_cluster_image(CL_IND, size(SORT_CTRS{CLUSTER_NUMBER},1), false, false);

figure;
subplot(1,2,1); imshow(VID(:,:,TARGET_FRAME), []);
subplot(1,2,2); imshow(img);

%% ROTATION CASE

AMOUNT = -180;

VID_R = load_video_to_mat_rotated(filename, 160, start_vid, end_vid, false, AMOUNT);
% exp_select_points_sequence(VID, filename);

% VID_R = circshift(VID, [0 20 0]);

clear COEFFS_R idxs_r
[COEFFS_R,idxs_r] = shearlet_transform_3D(VID_R,46,91,[0 1 1], 3, 1, [2 3]);


%%

close all;

cluster_map = shearlet_init_cluster_map;

tot_perc = 0;
num_frames = 0;
errors = zeros(13,1);

for cl = 2:13
    
    for c = 7:30:90
        % for c = 3:3
        
        [REPRESENTATION, ~, ~, ~] = shearlet_combined_fast(COEFFS, c, [2 2], idxs, 0.05, false, true, SKIP_BORDER);
        CL_IND = shearlet_cluster_by_seeds(REPRESENTATION, COEFFS, SORT_CTRS{cl});
        [CL_IMG, ~, ~] = shearlet_cluster_image(CL_IND, size(SORT_CTRS{cl},1), false, false);
        
        [REPRESENTATION_R, ~, ~, ~] = shearlet_combined_fast(COEFFS_R, c, [2 2], idxs, 0.05, false, true, SKIP_BORDER);
        CL_IND_R = shearlet_cluster_by_seeds(REPRESENTATION_R, COEFFS_R, SORT_CTRS{cl});
        [CL_IMG_R, ~, ~] = shearlet_cluster_image(CL_IND_R, size(SORT_CTRS{cl},1), false, false);
        CL_IMG_R = imrotate(CL_IMG_R, -AMOUNT);
        
        mask = (CL_IMG ~= CL_IMG_R);
        
        perc = nnz(mask)/numel(CL_IMG)*100.0;
        tot_perc = tot_perc + perc;
        num_frames = num_frames + 1;
        
        fprintf('Percentage diffent repres.: %.1f (frame %d)\n', perc, c);
        
    end
    
    
    avg_perc = tot_perc/num_frames;
    errors(cl) = avg_perc;
    
end

fprintf('Average percentage of diffent repres.: %.1f (video %d)\n', avg_perc, 4);

%%

figure;
plot(2:12, errors(2:12), 'r-', 'LineWidth', 2);

hold on
y = 0;

for x=2:12
    % Add lines for the temperature at time = 25
    if(errors(x) - y < 0.5)
        continue
    end
    
    y = errors(x);
    line('XData', [0 x], 'YData', [y y], 'LineWidth', 1, 'LineStyle', '--', 'Color', [1 0 0])
    text(x+0.2,y-+0.2,int2str(x))
end

hold off

axis([0 13 -0.1 errors(12)+1]);

title('Error VS Number of Clusters (rotation transform 180, mixing)');
ylabel('error %');
xlabel('K clusters');

set(gca, 'XTick', 2:12)
set(gca, 'YTick', 0:100)

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
    %     subplot(1,4,4);
    imshow(CL_IMG ~= circshift(CL_IMG_R, [0 -20]));
    
    %     fprintf('Percentage diffent repres.: %.1f (%d)\n', nnz(CL_IMG ~= circshift(CL_IMG_R, [0 -20]))/numel(CL_IMG)*100, nnz(CL_IMG ~= circshift(CL_IMG_R, [0 -20])));
    
    % aggiungere altro codice..
    
end
