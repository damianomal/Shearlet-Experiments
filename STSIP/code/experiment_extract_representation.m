

% lista di video da caricare
video_filenames = {'person04_boxing_d1_uncomp.avi',1,100};
descriptors = [];


%% ORIGINALI

% global figure handles
close all
clear -global fH1 fH2

prefix = 'results/original/';

% per ogni video da caricare...
for fname = video_filenames'
    
    % ...carica il video
    VID = load_video_to_mat(fname{1}, 160, fname{2}, fname{3}, true);
    
    % ...calcola la trasformata
    clear COEFFS idxs
    [COEFFS,idxs] = shearlet_transform_3D(VID,46,91,[0 1 1], 3, 1, [2 3]);
    
    % ...carica il file con i punti selezionati in SEL
    [~,name,~] = fileparts(fname{1});
    txtname = ['points/' name '_selected.mat'];
    load(txtname);
    
    % ...per ogni fotogramma diverso indicato dalla terza colonna in SEL...
    third_col = unique(selected(:,3));
    for j = 1:numel(third_col)
        
        t = third_col(j);
        
        % ......calcola la rappresentazione in questo fotogramma
        SCALE_USED = 2;
        SKIP_BORDER = 5;
        
        REPRESENTATION = shearlet_descriptor_fast(COEFFS, t, SCALE_USED, idxs, true, true, SKIP_BORDER);
        
        % ......per ogni punto in questo fotogramma...
        points = selected(selected(:,3) == t,:);
        for i = 1:size(points,1)
            
            x = points(i,1);
            y = points(i,2);
            
            % .........calcola il descrittore per il punto            
            index = (y-1)*size(VID,2)+x;
            repr = REPRESENTATION(index,:);
            
            % .........salva il descrittore in fondo a una matrice
            descriptors = [descriptors; repr];
            
            % .........salva la visualizzazione 3D del descrittore
            shearlet_show_descriptor(repr);
            
            outname = [prefix name '_frame_' int2str(t) '_point_' int2str(i) '.png'];
%             imagesel = getfield(getframe(), 'cdata');
%             imwrite(imagesel, outname, 'png');
            saveas(gcf, outname);
            RemoveWhiteSpace([], 'file', outname);
            
        end
        
        % ......salva il fotogramma attuale
        outname = [prefix name '_frame_' int2str(t) '.png'];
        imwrite(VID(:,:,t) ./ 255, outname, 'png');
        
        % ......salva il fotogramma attuale con sovrapposti i punti rossi
        fH = figure;
        imshow(VID(:,:,t), []);
        hold on;
        plot(points(:,1), points(:,2), 'ro', 'MarkerSize', 5, 'LineWidth', 2);
        hold off;
        outname = [prefix name '_frame_' int2str(t) '_points.png'];
        imagesel = getfield(getframe(), 'cdata');
        imwrite(imagesel, outname, 'png');
%         saveas(gcf, outname);
        
        close(fH);
    end
    
    % ...salva i descrittori su di un file .mat
    txtname = [prefix name '_descriptors.mat'];
    save(txtname, 'descriptors');

end


%% TRASFORMAZIONE 1 - ROTAZIONE

% global figure handles
close all
clear -global fH1 fH2

descriptors = [];

prefix = 'results/transformation_1/';

% per ogni video da caricare...
for fname = video_filenames'
    
    % ...carica il video
    VID = load_video_to_mat_rotated(fname{1}, 160, fname{2}, fname{3}, false);
    
    % ...calcola la trasformata
    clear COEFFS idxs
    [COEFFS,idxs] = shearlet_transform_3D(VID,46,91,[0 1 1], 3, 1, [2 3]);
    
    % ...carica il file con i punti selezionati in SEL
    [~,name,~] = fileparts(fname{1});
    txtname = ['points/' name '_selected.mat'];
    load(txtname);
    
    % ...per ogni fotogramma diverso indicato dalla terza colonna in SEL...
    third_col = unique(selected(:,3));
    for j = 1:numel(third_col)
        
        t = third_col(j);
        
        % ......calcola la rappresentazione in questo fotogramma
        SCALE_USED = 2;
        SKIP_BORDER = 5;
        
        REPRESENTATION = shearlet_descriptor_fast(COEFFS, t, SCALE_USED, idxs, true, true, SKIP_BORDER);
        
        % ......per ogni punto in questo fotogramma...
        points = selected(selected(:,3) == t,:);
        for i = 1:size(points,1)
            
            x = size(VID,2)-points(i,2)+1;
            y = points(i,1);
            
            % .........calcola il descrittore per il punto            
            index = (y-1)*size(VID,2)+x;
            repr = REPRESENTATION(index,:);
            
            % .........salva il descrittore in fondo a una matrice
            descriptors = [descriptors; repr];
            
            % .........salva la visualizzazione 3D del descrittore
            shearlet_show_descriptor(repr);
            
            outname = [prefix name '_frame_' int2str(t) '_point_' int2str(i) '.png'];
%             imagesel = getfield(getframe(), 'cdata');
%             imwrite(imagesel, outname, 'png');
            saveas(gcf, outname);
            RemoveWhiteSpace([], 'file', outname);
            
        end
        
        % ......salva il fotogramma attuale
        outname = [prefix name '_frame_' int2str(t) '.png'];
        imwrite(VID(:,:,t) ./ 255, outname, 'png');
        
        % ......salva il fotogramma attuale con sovrapposti i punti rossi
        fH = figure;
        imshow(VID(:,:,t), []);
        hold on;
        plot(size(VID,2)-points(:,2)+1, points(:,1), 'ro', 'MarkerSize', 5, 'LineWidth', 2);
        hold off;
        outname = [prefix name '_frame_' int2str(t) '_points.png'];
        imagesel = getfield(getframe(), 'cdata');
        imwrite(imagesel, outname, 'png');
%         saveas(gcf, outname);
        
        close(fH);
    end
    
    % ...salva i descrittori su di un file .mat
    txtname = [prefix name '_descriptors.mat'];
    save(txtname, 'descriptors');
    
end



%% TRASFORMAZIONE 2 - BLUR

% global figure handles
close all
clear -global fH1 fH2

descriptors = [];

prefix = 'results/transformation_2/';

% per ogni video da caricare...
for fname = video_filenames'
    
    % ...carica il video
    VID = load_video_to_mat(fname{1}, 160, fname{2}, fname{3}, true);
    
    % ...blurring gaussiano
    VID = smooth3(VID, 'gaussian', [9 9 9], 2);
    
    % ...calcola la trasformata
    clear COEFFS idxs
    [COEFFS,idxs] = shearlet_transform_3D(VID,46,91,[0 1 1], 3, 1, [2 3]);
    
    % ...carica il file con i punti selezionati in SEL
    [~,name,~] = fileparts(fname{1});
    txtname = ['points/' name '_selected.mat'];
    load(txtname);
    
    % ...per ogni fotogramma diverso indicato dalla terza colonna in SEL...
    third_col = unique(selected(:,3));
    for j = 1:numel(third_col)
        
        t = third_col(j);
        
        % ......calcola la rappresentazione in questo fotogramma
        SCALE_USED = 2;
        SKIP_BORDER = 5;
        
        REPRESENTATION = shearlet_descriptor_fast(COEFFS, t, SCALE_USED, idxs, true, true, SKIP_BORDER);
        
        % ......per ogni punto in questo fotogramma...
        points = selected(selected(:,3) == t,:);
        for i = 1:size(points,1)
            
            x = points(i,1);
            y = points(i,2);
            
            % .........calcola il descrittore per il punto            
            index = (y-1)*size(VID,2)+x;
            repr = REPRESENTATION(index,:);
            
            % .........salva il descrittore in fondo a una matrice
            descriptors = [descriptors; repr];
            
            % .........salva la visualizzazione 3D del descrittore
            shearlet_show_descriptor(repr);
            
            outname = [prefix name '_frame_' int2str(t) '_point_' int2str(i) '.png'];
%             imagesel = getfield(getframe(), 'cdata');
%             imwrite(imagesel, outname, 'png');
            saveas(gcf, outname);
            RemoveWhiteSpace([], 'file', outname);
            
        end
        
        % ......salva il fotogramma attuale
        outname = [prefix name '_frame_' int2str(t) '.png'];
        imwrite(VID(:,:,t) ./ 255, outname, 'png');
        
        % ......salva il fotogramma attuale con sovrapposti i punti rossi
        fH = figure;
        imshow(VID(:,:,t), []);
        hold on;
        plot(points(:,1), points(:,2), 'ro', 'MarkerSize', 5, 'LineWidth', 2);
        hold off;
        outname = [prefix name '_frame_' int2str(t) '_points.png'];
        imagesel = getfield(getframe(), 'cdata');
        imwrite(imagesel, outname, 'png');
%         saveas(gcf, outname);
        
        close(fH);
    end
    
    % ...salva i descrittori su di un file .mat
    txtname = [prefix name '_descriptors.mat'];
    save(txtname, 'descriptors');

end



%% TRASFORMAZIONE 3 - SHIFT

% global figure handles
close all
clear -global fH1 fH2

descriptors = [];

prefix = 'results/transformation_3/';

SHIFT_AMOUNT = 20;

% per ogni video da caricare...
for fname = video_filenames'
    
    % ...carica il video
    VID = load_video_to_mat(fname{1}, 160, fname{2}, fname{3}, true);
    VID = circshift(VID, [0 SHIFT_AMOUNT 0]);
    
    % ...calcola la trasformata
    clear COEFFS idxs
    [COEFFS,idxs] = shearlet_transform_3D(VID,46,91,[0 1 1], 3, 1, [2 3]);
    
    % ...carica il file con i punti selezionati in SEL
    [~,name,~] = fileparts(fname{1});
    txtname = ['points/' name '_selected.mat'];
    load(txtname);
    
    % ...per ogni fotogramma diverso indicato dalla terza colonna in SEL...
    third_col = unique(selected(:,3));
    for j = 1:numel(third_col)
        
        t = third_col(j);
        
        % ......calcola la rappresentazione in questo fotogramma
        SCALE_USED = 2;
        SKIP_BORDER = 5;
        
        REPRESENTATION = shearlet_descriptor_fast(COEFFS, t, SCALE_USED, idxs, true, true, SKIP_BORDER);
        
        % ......per ogni punto in questo fotogramma...
        points = selected(selected(:,3) == t,:);
        for i = 1:size(points,1)
            
            x = points(i,1) + SHIFT_AMOUNT;
            y = points(i,2);
            
            % .........calcola il descrittore per il punto            
            index = (y-1)*size(VID,2)+x;
            repr = REPRESENTATION(index,:);
            
            % .........salva il descrittore in fondo a una matrice
            descriptors = [descriptors; repr];
            
            % .........salva la visualizzazione 3D del descrittore
            shearlet_show_descriptor(repr);
            
            outname = [prefix name '_frame_' int2str(t) '_point_' int2str(i) '.png'];
%             imagesel = getfield(getframe(), 'cdata');
%             imwrite(imagesel, outname, 'png');
            saveas(gcf, outname);
            RemoveWhiteSpace([], 'file', outname);
            
        end
        
        % ......salva il fotogramma attuale
        outname = [prefix name '_frame_' int2str(t) '.png'];
        imwrite(VID(:,:,t) ./ 255, outname, 'png');
        
        % ......salva il fotogramma attuale con sovrapposti i punti rossi
        fH = figure;
        imshow(VID(:,:,t), []);
        hold on;
        plot(points(:,1)+SHIFT_AMOUNT, points(:,2), 'ro', 'MarkerSize', 5, 'LineWidth', 2);
        hold off;
        outname = [prefix name '_frame_' int2str(t) '_points.png'];
        imagesel = getfield(getframe(), 'cdata');
        imwrite(imagesel, outname, 'png');
%         saveas(gcf, outname);
        
%         close(fH);
    end
    
    % ...salva i descrittori su di un file .mat
    txtname = [prefix name '_descriptors.mat'];
    save(txtname, 'descriptors');

end

%% FINISHED




