% function datastruct = csvToStruct(filename, delimiter);
%
% Turns the contents of text file FILENAME into a matrix of structs, with
% one field in the struct corresponding to each column of the data in
% FILENAME.
%
% The first line of the file should be a list of COLUMN NAMES, which are
% used to determine the names of the fields in the resulting struct.
%
% Any column that consists entirely of numbers is automatically converted
% to double format.  Everything else is treated as a string.
%
% For example, if the contents of FILENAME are:
% TRIAL      PRIMING    SOA
% 1          Yes        .2
% 2          No         .2
% 3          Yes        .2
% 
% csvToStruct(FILENAME, '%d%s%f') would return a struct with 3 fields:
% TRIAL (int32), PRIMING (string), and SOA (double).
%
% DELIMITER specifies the column delimiter in the file (assumed to be a
% comma by default).
%
% 06.02.11 - S.Fraundorf - first version

function datastruct = csvToStruct(filename, delimiter)

%% ASSIGN DEFAULT VALUES

if nargin < 2
    delimiter = ',';
end

%% OPEN THE FILE
infile = fopen(filename);

if infile < 0
    error('CogToolbox:csvToStruct:UnableToOpenFile', 'Can''t open file %s.', filename);
else
    % READ THE RAW DATA
    columnnames = fgetl(infile); % 1st row is COLUMN NAMES
    
    % SEGMENT THE COLUMN NAMES
    colnames = textscan(columnnames, '%s', 'Delimiter', delimiter);
    colnames = colnames{1};
    
    % HOW MANY COLUMNS TO EXPECT?
    numcols = length(colnames);
    formatting = repmat('%s', 1, numcols);
    
    % READ THE REST OF THE DATA
    rawdata = textscan(infile, formatting, 'Delimiter', delimiter);
    fclose(infile);
    
    % CONVERT ANY NUMERIC DATA
    for i=1:numcols
        fprintf('%d\n', i)
        % try converting this to a double, see if any NaNs
        asdouble = str2double(rawdata{i});
        if ~any(isnan(asdouble));
            % no NaNs, so this is a column of numeric data
            rawdata{i} = asdouble;
        end
    end    
    
    % CREATE THE STRUCT
    datastruct = cell2struct(rawdata,colnames,2);
    
end