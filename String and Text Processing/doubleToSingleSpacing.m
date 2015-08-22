% newstring = doubleToSingleSpacing(oldstring)
%
% This function changes all multiple spaces ('  ') within string OLDSTRING to
% single spaces (' ') and then returns the modified string.  Works with
% double spacing, triple spacing, and more.
% 
% This function is helpful when spaces are being used to count words.
%
% 05.23.07 - S.Fraundorf
% 11.21.09 - S.Fraundorf - improved efficiency of code using strrep

function newstring = doubleToSingleSpacing(oldstring)

newstring = oldstring;

while strfind(newstring, '  ') % there are still instances remaining
    newstring = strrep(newstring, '  ', ' ');
end % repeat loop several times to deal with triple spacing, etc.