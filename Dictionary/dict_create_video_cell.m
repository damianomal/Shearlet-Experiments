function video_cell = dict_create_video_cell(dataset_dir)
%DICT_CREATE_VIDEO_STRUCT Summary of this function goes here
%   Detailed explanation goes here

video_cell = {};

pth = genpath(dataset_dir);
pth = strsplit(pth, ';');

for i = 2:numel(pth)-1
   
    files = dir(pth{i});
    
    for j=3:numel(files)
        video_cell{end+1} = {files(j).name, 1, 100, [4 10]};
    end
    
end

end

