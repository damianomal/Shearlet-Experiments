function selected = exp_select_points_sequence(video, filename)
%EXP_SELECT_POINTS_SEQUENCE Summary of this function goes here
%   Detailed explanation goes here

% initialize the variable
selected = [];
c = 1;

% keeps running
while true
    
    % shows selected frame
    imshow(video(:,:,c), []);
    
    % wait for user input
    waitforbuttonpress
    key = get(gcf,'CurrentKey');
    
    % process user input
    switch key
        case 'leftarrow'
            c = c-1;
            if(c<1)
                c=1;
            end
            
        case 'rightarrow'
            c = c+1;
            if(c>size(video,3))
                c = size(video,3);
            end
            
        case 'c'
            [x,y] = ginput(1);
            fprintf('Selected Point (%d,%d)\n', floor(x), floor(y));
            selected = [selected; floor([x y c])];
            
        case 's'
            c = floor(input('Target frame'));
            if(c<1)
                c=1;
            else if(c>size(video,3))
                    c = size(video,3);
                end
            end
            
        case 'q'
            break
            
        otherwise
    end
    
end

% ordina le righe della matrice in base alla terza colonna
selected = sortrows(selected, [3 1 2]);

% if specified, save selected points to file
if(nargin > 1)
    [~,name,~] = fileparts(filename);
    txtname = [name '_selected.mat'];
    save(txtname, 'selected');
end

end

