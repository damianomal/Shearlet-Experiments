function shearlet_show_vocabulary_nointeractive( dictionary, rows, cols)
%SHEARLET_SHOW_VOCABULARY Summary of this function goes here
%   Detailed explanation goes here

if(nargin < 3)
    rows = 2;
    cols = 3;
end

dim = size(dictionary,1);

winindex = 0;
c = 0;

for i=1:dim
    
    if(c == 0 || c > rows*cols)
        winindex = winindex + 1;
        figure('Name',['Centroids Vocabulary (' int2str(winindex) ')'], 'Position', [66 312 1774 544]);
        c = 1;
    end
    
    subplot(rows,cols,c)
    bar(dictionary(i,:));
    title(['Cluster #' int2str(i)]);
    c = c + 1;
    
end


end

