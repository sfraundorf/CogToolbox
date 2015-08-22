% newline = stripLeadingCharacter(currentline,character)
%
% Removes all instances of the specified CHARACTER from the beginning of
% string CURRENTLINE.  Does not remove instances of the character that appear
% later in the string.  If CHARACTER is not specified, it is assumed to
% be the first character of CURRENTLINE
%
% This function is useful for removing spaces or other formatting
% information from the beginning of a string.
%
% If the string contains nothing but the specified character, this
% function will leave a single instance of the character remaining.
%
% 05.25.07 - S.Fraundorf
% 11.21.09 - S.Fraundorf - assume CHARACTER is initial character if not
%                           specified.  deal with strings of length 0

function newline = stripLeadingCharacter(currentline, character)

newline = currentline;

if numel(currentline) > 0 % must have at least one character!
    
  if nargin<2
     character = currentline(1); % default to first character of currentline
  end

  if numel(currentline) > 1
    while newline(1) == character && numel(newline) > 1
      newline = newline(2:numel(newline));
    end
  end
end