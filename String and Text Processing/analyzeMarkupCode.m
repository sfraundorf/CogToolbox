% [markupcode number] = analyzeMarkupCode(currentline,position)
%
% Given the beginning POSITION of a markup code (<) in string CURRENTLINE,
% finds the end of the markup code (>) and returns the markup code.
%
% If POSITION is not specified, the markup code is assumed to begin at the
% start of the line.
%
% If the markupcode ends with a number, the number is returned from the
% markup code and returned separately. (or, -1 if no number)
%
% 08.10.08 - S.Fraundorf
% 11.21.09 - S.Fraundorf - don't check for number if not requested.
%                          return -1 if no number available.
% 06.11.10 - S.Fraundorf - can avoid specifiying position if markup code
%                          is at start of text string
% 06.14.10 - S.Fraundorf - looks for numbers ANYWHERE

function [markupcode number] = analyzeMarkupCode(currentline, position)

if nargin<2 % have a line and a position
   position=1;
end

choppedline = currentline(position:numel(currentline));
endofcodepsn = find(choppedline == '>', 1);
markupcode = choppedline(1:endofcodepsn);

% see if there's a number to extract from this code, if requested
if nargout > 1
    
  [number markupcode] = extractNumbers(markupcode);
  
end