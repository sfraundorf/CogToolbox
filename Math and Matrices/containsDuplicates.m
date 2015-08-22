% duplicatefound = containsDuplicates(matrix)
%
% Tests whether any of the entries in matrix MATRIX are the same.  If so,
% returns 1; otherwise, returns 0.
% 
% Could be extended to an N-dimensional matrix but I haven't done it yet.
%
% 01.26.10 - S.Fraundorf

function duplicatefound = containsDuplicates(matrix)

matrixsize= size(matrix);
foundsofar = [];
duplicatefound = 0;

for i=1:matrixsize(1)
    for j=1:matrixsize(2)
        if find(foundsofar==matrix(i,j))
            % duplicate found
            duplicatefound = 1;
            return; % no need to look at anything else
        else
            % no duplicates yet
            foundsofar = [foundsofar matrix(i,j)];
        end  
    end    
end
        