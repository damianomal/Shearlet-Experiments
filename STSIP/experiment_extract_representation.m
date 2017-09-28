
% global figure handles
clear -global fH1 fH2

% lista di video da caricare
video_filenames = {'person04_boxing_d1_uncomp.avi',1,100};
descriptors = [];

% per ogni video da caricare...
for fname = video_filenames'
    
    % ...carica il video
    VID = load_video_to_mat(fname{1}, 160, fname{2}, fname{3}, true);
    
    % ...calcola la trasformata
    clear COEFFS idxs
    [COEFFS,idxs] = shearlet_transform_3D(VID,46,91,[0 1 1], 3, 1, [2 3]);
    
    % ...carica il file con i punti selezionati in SEL
    [~,name,~] = fileparts(fname{1});
    txtname = [name '_selected.mat'];
    load(txtname);
    
    % ...per ogni fotogramma diverso indicato dalla terza colonna in SEL...
    third_col = unique(selected(:,3));
    for j = numel(third_col)
        
        t = third_col(j);
        
        % ......calcola la rappresentazione in questo fotogramma
        SCALE_USED = 2;
        SKIP_BORDER = 5;
        
        REPRESENTATION = shearlet_descriptor_fast(COEFFS, t, SCALE_USED, idxs, true, true, SKIP_BORDER);
        
        % ......per ogni punto in questo fotogramma...
        points = selected(selected(:,3) == t,:);
        for i = 1:size(points,1)
            
            % .........calcola il descrittore per il punto
            %             close all;
            %             clear -global fH1 fH2
            
            index = (points(i,2)-1)*size(VID,2)+points(i,1);
            selected = REPRESENTATION(index,:);
            
            % .........salva il descrittore in fondo a una matrice
            descriptors = [descriptors; REPRESENTATION(index,:)];
            
            % .........salva la visualizzazione 3D del descrittore
            shearlet_show_descriptor(selected);
            
%             figure(fH2);
            g  = getframe();
            imagesel = g.cdata;
            outname = [name '_frame_' int2str(t) '_point_' int2str(i) '.png'];
            imwrite(imagesel, outname, 'png');
            
            %             close(fH1);
            %             close(fH2);
            
        end
        
        % ......salva il fotogramma attuale
        outname = [name '_frame_' int2str(t) '.png'];
        imwrite(VID(:,:,t) ./ 255, outname, 'png');
        
        % ......salva il fotogramma attuale con sovrapposti i punti rossi
        fH = figure;
        imshow(VID(:,:,t), []);
        hold on;
        plot(points(:,1), points(:,2), 'ro', 'MarkerSize', 5, 'LineWidth', 2);
        hold off;
        outname = [name '_frame_' int2str(t) '_points.png'];
        g  = getframe();
        imagesel = g.cdata;
        imwrite(imagesel, outname, 'png');
        
        close(fH);
    end
    
end


