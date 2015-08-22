% textstring = extractStringFromLines(textblock, startpoint, endpoint)
%
% This function extracts a string of text from cell array TEXTBLOCK containing
% several lines of text.  The string to be extracted can span several
% lines of text; it will be returned as a single line.
%
% STARTPOINT is a 2 x 1 vector containing the line number and character
%  number where the target string starts.  ENDPOINT is the same thing for
%  the end of the string
%
% 05.27.07 - S.Fraundorf

function textstring = extractTextFromLines(textblock, startpoint, endpoint)

if startpoint(1) == endpoint(1); % start and end on same line
  textstring = textblock{startpoint(1)}(startpoint(2):endpoint(2));
else % start and end are on different lines
  textstring = textblock{startpoint(1)}(startpoint(2):numel(textblock{startpoint(1)})); % start with the rest of the first line
  for m = (startpoint(1)+1): (endpoint(1)-1)
    textstring = [textstring textblock{m}];
  end
  textstring = [textstring textblock{endpoint(1)}(1:endpoint(2))];
end
