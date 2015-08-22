% hits = findInCellMatrix(cellarray,string)
%
% Searches for string STRING in 2-dimensional cellarray CELLARRAY and
% returns a matrix with 1s for all the matching cells (0 otherwise).
%
% e.g. given cell array  'yes' 'no' 'no'
%                        'no'  'yes' 'no'
% findInCellMatrix(cellarray,'yes') returns [1,0,0;0,1,0]
%
% this is similar to Matlab's strmatch function, but it returns a MATRIX
% rather than a CELL ARRAY, so you can then use the find function
%
% Could be extended to N-dimensional cell arrays but I haven't done it yet.
%
% 01.25.10 - S.Fraundorf - first version
% 04.02.10 - S.Fraundorf - fixed a bug with non-square arrays

function hits = findInCellMatrix(cellarray,string)

arraysize = size(cellarray);

hits = zeros(arraysize);

for i=1:size(cellarray,1)
    for j=1:size(cellarray,2)
        if strcmp(string,cellarray{i,j})
            hits(i,j) = 1;
        end
    end
end