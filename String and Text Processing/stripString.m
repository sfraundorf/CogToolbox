% newstring = stripString(oldstring, toremove)
%
% Removes all instances of string TOREMOVE from string OLDSTRING and
% returns the modified string.
%
% 05.18.07 - S.Fraundorf
% 11.21.09 - S.Fraundorf - replaced stripCharacter with this.
%                          improved efficiency with strrep

function newstring = stripString(oldstring, toremove)

newstring = strrep(oldstring,toremove,'');