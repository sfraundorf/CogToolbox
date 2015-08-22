% fixedpath=makeValidPath(oldpath)
%
% Ensures that a string is a valid path to the contents of a folder by
% adding file separator characters ('/' or '\') as needed, and returns
% that path.
%
% If OLDPATH is empty (i.e., it's THIS folder), just returns an empty string. 
%
% 07.17.08 - S.Fraundorf
% 02.05.10 - S.Fraundorf - fixed a problem when the path was THIS folder
% 07.21.10 - S.Fraundorf - create folder if needed.
%                          used platform-INDEPENDENT file separator.
% 07.27.10 - S.Fraundorf - bug fixes for folder creation.
% 07.28.10 - S.Fraundorf - removed folder creation for now because it
%                           causes bugs.  removed platform-independent
%                           separator because of bugs.

function fixedpath = makeValidPath(oldpath)

fixedpath = oldpath;

if ~isempty(oldpath)
    separator = '/';
    % supposed to be \ on Windows, but this causes problems because it
    % doubles as an escape character ... and / seems to work fine even on
    % Windows machines.
    
    fixedpath = strrep(fixedpath, '\', separator);
    fixedpath = strrep(fixedpath, '//', separator); % remove any doubles
    % that came from originally having an escape character
      
    % (2) add a file separator at the END of path if needed
    if fixedpath(numel(fixedpath)) ~= separator
        fixedpath = [fixedpath separator];
    end
    
end