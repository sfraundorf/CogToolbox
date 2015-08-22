% judgment = IsInBounds(matrix,point)
%
% Tests whether N-dimensional vector of coordinates POINT is within the
% bounds of matrix MATRIX -- i.e., whether it is a valid index for the matrix.
%
% Returns 1 if POINT is a valid index for MATRIX; returns 0 if POINT is
% outside the bounds of MATRIX or if POINT is not a vector with elements
% equal to the number of MATRIX's dimensions.
%
% This is basically an expanded version of IsInRect from the PTB.
%
% 10.02.09 - S.Fraundorf
% 11.22.09 - S.Fraundorf - expanded to N-D matrices

function judgment = IsInBounds(matrix,point)

if ndims(matrix) ~= numel(point) % size mismatch
    judgment = 0;
elseif ndims(point) > 2      % too many dimensions to be a vector
    judgment = 0;
elseif ~find(size(point)==1) % not a vector
    judgment = 0;
else  % point is a vector of coordinates matching in size
    % now let's see if it's inside the matrix
    for i=1:ndims(matrix)
        if point(i) > size(matrix,i) % outside the bounds
            judgment = 0;
            return;
        end
    end
    % all the dimensions checked out
    judgment = 1;
end