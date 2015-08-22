% newstring= stripPunctuation(oldstring)
%
% Removes all punctuation from string OLDSTRING.
%
% Punctuation marks removed: ! ' " , ; - ? ( ) : . { }
%
% 05.18.07 - S.Fraundorf
% 11.21.09 - S.Fraundorf - rewrote to use new stripString
%
% Scott Fraundorf - sfraund2@uiuc.edu

function newstring = stripPunctuation(oldstring)

% set up cell array of punctuation marks
puncmarks = {'!' '''' '"' ',' ';' '-' '?' '(' ')' ':' '.' '{' '}'};

% remove them
newstring = strrepMany(oldstring,puncmarks,'');