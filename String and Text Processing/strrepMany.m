% newstring = strrepMany(s1,s2,s3)
%
% Replaces multiple strings within string S1.
%
% If S2 but not S3 is a cell array (or, S3 is a cell array with 1 element),
% any instance of *any* of the elements of S2 will be replaced with S3.
%  e.g. replacing both 'great' and 'good' in S1 with 'bad'
% 
% If both S2 and S3 are cell arrays of the same size, each instance of S2
% in S1 will be replaced with the corresponding item in S3.
%  e.g. replacing 'red' with 'blue' and 'green' with 'yellow'
%
% If neither S2 nor S3 is a cell array, this works the same as strrep.
%
% Other usages return errors.
%
% 11.21.09 - S.Fraundorf

function newstring= strrepMany(s1,s2,s3)

if ischar(s2) 
    if ischar(s3) % same as regular strrep
        newstring = strrep(s1,s2,s3);
    else % if s2 is char, s3 must be too
        error('invalid input types');
    end
elseif iscell(s2)
    if ischar(s3) % replace any of S2 with S3
        newstring = s1;
        for i=1:numel(s2)
            newstring = strrep(newstring,s2{i},s3);
        end
            
    elseif iscell(s3) % replace corresponding cells
        if numel(s3) == 1 % s3 is only 1 cell, so treat like it's a string
            newstring = s1;
            for i=1:numel(s2)
                newstring = strrep(newstring,s2{i},s3);
            end
        elseif size(s2) ~= size(s3) % otherwise, must have the same size of cell arrays!
            error('cell array sizes must match');
            
        else % OK to go ahead with corresponding replacement
            newstring = s1;
            for i=1:numel(s2)
                newstring = strrep(newstring,s2{i},s3{i});
            end
        end

    else % bad variable types
        error('s3 must be string or cell array');
    end

else
    error('s2 must be string or cell array');
end