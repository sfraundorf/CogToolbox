% newCellArray = textFileToCellArray(myfile, maxlines)
%
% This function opens MYFILE and reads it line-by-line, assigning each
% line to a cell in the cell array passed to the function.  MYFILE may
% either be the number of an open file, or a string filename of a file you
% want to open.  In the latter case, the file will be closed once it is
% done.
%
% Lines that begin with a % are considered comments and not read
%
% Optional parameter MAXLINES specifies the maximum number of lines to
% read.  If undefined, all lines will be read.
%
%  5.23.07 - S.Fraundorf - first version
% 11.21.09 - S.Fraundorf - added MAXLINES and ability to specify the number
%                           of an open file
% 11.25.09 - S.Fraundorf - fixed bug when passing numeric file handle
% 08.12.12 - S.Fraundorf - updated error messages to use Matlab's built-in
%                           error/warning functions
% 02.05.13 - S.Fraundorf - deal with empty lines

function newCellArray = textFileToCellArray(myfile, maxlines)

% default return if there is a problem with the file or maxlines == 0
newCellArray{1} = 'error';

%% FIGURE OUT WHAT KIND OF INPUT FILE WE WERE GIVEN
if ischar(myfile) % open a file based on a filename
    inputfile = fopen(myfile); % open the file
    if (inputfile == -1) % check if there's an error in opening the file
        warning('CogToolbox:textFileToCellArray:UnableToOpen', 'Unable to open file %s', myfile);
    end
    
elseif isnumeric(myfile) % use the number of an open file
    inputfile = myfile;
    
else
    inputfile = -1;    
    error('CogToolbox:textFileToCellArray:NotAnOpenFile', ...
        'Input must be a file name or the number of an open file.')
end

%% READ THE FILE
if inputfile > -1 % file opened successfully
    
  i = 1; % start at index = 1 of cell array

  while true % keep reading lines until list is exhaused or we hit MAXLINES
      
      if nargin == 2 % do we have a maximum number of lines?
          if i > maxlines
              break;
          end
      end % go ahead
      
      if ~feof(inputfile)
          currentline = fgetl(inputfile); % get a line if we can
          if isempty(currentline) || currentline(1) ~= '%' % not a comment, so save this line
              newCellArray{i} = currentline; % save the line
              i = i+1; % move to the next index
          end
          
      else % end of file!
          break
      end
  
  end % done reading the file
   
  if ischar(myfile) % we used a filename, want to close it
      fclose(inputfile); % done read the words, so close file
  end % don't close the file it was passed as a number
  
end