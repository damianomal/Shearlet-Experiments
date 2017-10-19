function  out = shearlet_reduce_representation( REPRESENTATION )
%SHEARLET_REDUCE_REPRESENTATION Summary of this function goes here
%   Detailed explanation goes here

lines = [1 9 25 49 81 121];

REPR_RED = zeros(19200, 6);
REPR_RED(:,1) = REPRESENTATION(:,1);

for i=2:numel(lines)
    REPR_RED(:,i) = sum(REPRESENTATION(:,lines(i-1)+1:lines(i)),2);
end

out = REPR_RED;
clear REPR_RED



end

