% new = repelem(vector,X)
%
% Returns a vector with each element of vector VECTOR repeated X times
% before moving onto the next element.
%
% e.g. repelem([1 2 3], 3) returns [1 1 1 2 2 2 3 3 3]
%
% note that this is DIFFERENT from Matlab's built-in repmat function, whch
% cycles through each element (e.g. [1 2 3] -> [1 2 3 1 2 3 1 2 3])
%
% Right now, this function only works on vectors (not matrices)
%
% 06.06.11 - S.Fraundorf - first version

function new = repelem(vector,X)

vecsize = size(vector);
if numel(find(vecsize > 1)) > 1
    % more than 1 dimension
    error('CogToolbox:repelem:NotVector', 'repelem only works on vectors.');
elseif vecsize(1) == 1
    % row vector
    new = kron(vector, ones(1, X));
elseif vecsize(2) == 1
    % column vector
    new = kron(vector, ones(X, 1));
else
    error('CogToolbox:repelem:NotRowOrColumn', 'Must be row or column vector.');
    % could rewrite this to be more flexible
end