

VID = load_video_to_mat('person04_boxing_d1_uncomp.avi',160,1,100, true);

close all;

for t=[28 32 37 49 53]
    
    IMG = VID(:,:,t);
%     B = IMG < 80;
%     
%     CC = bwconncomp(B);
%     numOfPixels = cellfun(@numel,CC.PixelIdxList);
%     [unused,indexOfMax] = max(numOfPixels);
%     biggest = zeros(size(B));
%     biggest(CC.PixelIdxList{indexOfMax}) = 1;
    %     imshow(~biggest);
    
    figure;
%     biggest = imerode(biggest, strel('ball',3,3));
    
%     IMG(~biggest) = 255;
    imshow(IMG./255);
    
    imwrite(IMG./255, ['frame_' int2str(t) '.png'], 'png');
    
end
