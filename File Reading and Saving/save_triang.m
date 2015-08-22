% function save_triang(fullmatrix, filename, ut)
%
% Saves just the upper- or lower-triangular part of matrix FULLMATRIX in
% comma-delimited format to file FILENAME.  The other half of the matrix is
% filled in with blank columns.
%
% If UT = 1, the upper-triangular portion is saved; otherwise, the lower-
% triangular portion is saved.
%
% 04.17.11 - S.Fraundorf - first version

function save_triang(fullmatrix, filename,ut)

% default is ut = 0
if nargin < 3 || ut ~= 1
    ut = 0;
end

% open output file
outfile = fopen(filename, 'w');

% get size of matrix
matrixsize = size(fullmatrix);

% save the data
for i=1:matrixsize(1)
    for j=1:matrixsize(2)
        if (ut && i <= j) || (~ut && i >= j)
            % this is the part to save
            fprintf(outfile, '%4.4f,', fullmatrix(i,j));
        else
            % blank spot
            fprintf(outfile, ',');
        end
    end
    fprintf(outfile, '\n'); % newline at end of row
end

% close the output file
fclose(outfile);