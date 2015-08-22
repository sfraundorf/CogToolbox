% textstring = initialCapsOnly(instring)
%
% Modifies string INSTRING so that it has capital letters at, and only at,
% the beginning of words.  Words are defined as beginning at the beginning
% of INSTRING and after any blank space.
%
% This assumes all spaces are single spaces; use doubleToSingleSpacing
% first if you want to eliminate any double-spaces.
%
% 04.20.08 - S.Fraundorf - first version
% 11.21.09 - S.Fraundorf - handles strings of length 1
% 08.22.12 - S.Fraundorf - fixed a crash if the string was just one letter

function textstring = initialCapsOnly(instring)

if numel(instring >= 1)
  textstring = lower(instring); % convert everything to lowercase first
                                % to eliminate unwanted caps
  textstring(1) = upper(textstring(1)); % capitalize the first letter
  
  spaces = find(instring == ' '); % capitalize letters after all other words
  for i=1:numel(spaces)
      if numel(textstring) > spaces(i)
          textstring(spaces(i)+1) = upper(textstring(spaces(i)+1));
      end
  end
  
else % just one letter, capitalize it
    textstring = upper(instring);
end