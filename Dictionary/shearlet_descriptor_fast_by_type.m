function [ REPRESENTATION_USED ] = shearlet_descriptor_fast_by_type( coeffs_mat, frame, idxs, repr_type, print_debug, profiling, skip_border)
%SHEARLET_DESCRIPTOR Calculates the shearlet descriptor for the selected
%time instant and scale on the passed coefficients matrix
%
% Example:
%   big_coeffs = shearlet_descriptor(input_coeffs, t, scale, shearletIdxs, debug, profiling)
%       Calculates the shearlet descriptor matrix c
%
% Parameters:
%   input_coeffs:
%   t:
%   scale:
%   shearletIdxs:
%   debug:
%   profiling:
%
% Output:
%   coeffs_mat:
%
%   See also ...

if(profiling)
   st = tic; 
end

switch repr_type
    case 'original'
        
        REPRESENTATION_USED = shearlet_descriptor_fast(coeffs_mat, frame, SCALE_USED, idxs, true, true, skip_border);
        
    case '6dim_sc2'
        
        REPRESENTATION = shearlet_descriptor_fast(coeffs_mat, frame, 2, idxs, true, true, skip_border);
        
        lines = [1 9 25 49 81 121];
        
        REPR_RED = zeros(19200, 6);
        REPR_RED(:,1) = REPRESENTATION(:,1);
        
        for i=2:numel(lines)
            REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
        end
        
        REPRESENTATION_USED = REPR_RED;
        clear REPR_RED
        
    case '6dim_sc3'
        
        REPRESENTATION = shearlet_descriptor_fast(coeffs_mat, frame, 3, idxs, true, true, skip_border);
        
        lines = [1 9 25 49 81 121];
        
        REPR_RED = zeros(19200, 6);
        REPR_RED(:,1) = REPRESENTATION(:,1);
        
        for i=2:numel(lines)
            REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
        end
        
        REPRESENTATION_USED = REPR_RED;
        clear REPR_RED
        
    case '12dim'
        
        REPRESENTATION = shearlet_descriptor_fast(coeffs_mat, frame, 2, idxs, true, true, skip_border);
        
        lines = [1 9 25 49 81 121];
        
        REPR_RED = zeros(19200, 6);
        REPR_RED(:,1) = REPRESENTATION(:,1);
        
        for i=2:numel(lines)
            REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
        end
        
        REPR_RED2 = zeros(19200, 12);
        REPR_RED2(:,1:6) = REPR_RED;
        
        REPRESENTATION = shearlet_descriptor_fast(coeffs_mat, frame, 3, idxs, true, true, skip_border);
        
        REPR_RED = zeros(19200, 6);
        REPR_RED(:,1) = REPRESENTATION(:,1);
        
        for i=2:numel(lines)
            REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
        end
        
        REPR_RED2(:,7:12) = REPR_RED;
        
        REPRESENTATION_USED = REPR_RED2;
        clear REPR_RED REPR_RED2
        
    otherwise
        REPRESENTATION_USED = [];
end

%
if(profiling)
    fprintf('-- Time for Representation Extraction: %.4f seconds\n', toc(st));
end

end

