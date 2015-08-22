% filenum = openValidFile(prompt, permission)
%
% Repeatedly prompts the user for a filename using text prompt PROMPT until
% a valid file can be opened, then returns the handle of that file.
%
% PERMISSION allows you to specify the permissions to open the file with.
% See the help file for FOPEN for possible permissions, and more on opening
% files.
%
% 11.21.09 - S.Fraundorf - first version
% 08.21.12 - S.Fraundorf - rewrote string assembly & function call for speed
%                          updated try/catch syntax

function filenum = openValidFile(prompt, permission)

filenum = -1;
while filenum < 0
    % get a string filename from the user
    filename = inputstring(prompt);
    
    % figure out the string to execute
    if nargin == 2
        % INCLUDE permission
        command = ['filenum = fopen(''' filename '''' ...
            ',' '''' permission '''' ...
            ');'];
    else
        % no, permissions not included
        command = ['filenum = fopen(''' filename '''' ...
            ');'];
    end
  
    % try opening the file
    try
        eval(command);
    catch
        fprintf(['Error opening file' filename ' - see error message below.']);
        throw(lasterror)
    end
end