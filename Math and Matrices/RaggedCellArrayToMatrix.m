% xprime = RaggedCellArrayToMatrix(x,fillvalue)
%
% Converts a cell array of vectors to a matrix.
%
% If the vectors vary in length, the matrix takes on the size of the
% longest vector and the value FILLVALUE is used to "fill" the "missing"
% cells.  The default FILLVALUE is NaN.
%
% e.g. x{1} = [2 3]; x{2} = [4 5 6]; RaggedCellArrayToMatrix(x)
% returns [2 3 NaN; 4 5 6]
%
% Right now, this only converts an array of 1-dimensional vectors to a
% 2-dimensional matrix, but you could scale it up...
%
% 01.07.11 - S.Fraundorf - first version

function xprime = RaggedCellArrayToMatrix(x,fillvalue)

% default fill value is NaN
if nargin < 2
    fillvalue = nan;
end

% calculate the number of items inside the cell array
numitems = numel(x);

% calculate the LONGEST item:
maxlength = max(cellfun(@numel,x));

% create the new matrix, filled with default value
xprime = repmat(fillvalue,numitems,maxlength);

% populate it with the values from the cell array
for i=1:numitems
    xprime(i,1:numel(x{i})) = x{i};
end
