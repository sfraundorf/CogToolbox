% [startline startchar] = findUtteranceStart(textblock,linenum,letterindex,delimiter)
%
% This function looks for the start of an utterance somewhere within cell
% array TEXTBLOCK, containing lines of text.  Given line number LINENUM and
% position LETTERINDEX within that line, the function "rewinds" through the
% text from that point until it finds the start of the utterance.  If the
% utterance begins the block of text, [1 1] is returned.
%
% Optional parameter DELIMITER specifies the character used to delimit
% utterances.  If no delimiter is specified, the default period ('.') is
% used
%
% 05.28.07 - S.Fraundorf
% 11.21.09 - S.Fraundorf - fixed a glitch when delimiter is at end of line

function [startline startchar] = findUtteranceStart(textblock,linenum, letterindex, delimiter)

if nargin == 3
  delimiter = '.';
end

startfound = 0;

while ~startfound % continue until an utterance start is found

   if textblock{linenum}(letterindex) == delimiter   % period found!
     startfound = 1; % stop searching

     % was the delimiter at the end of a line?
     if numel(textblock{linenum})==letterindex  % yes, it was
         startline=linenum + 1; % new utterance starts on next line
         startchar=1;
     else  % no
         startline=linenum;
         startchar=letterindex+1; % new utterance starts AFTER the delimiter
     end

   else   % this character is not a period, keep searching
      letterindex = letterindex - 1; % go one character back
      if letterindex < 1 % we've moved past the end of this line
          linenum = linenum - 1; % go back one line
          if linenum < 1 % if we just finished checking the first line, no more lines to search
             startline = 1;
             startchar = 1;
             startfound = 1;
          else % still at least one more line to check
             letterindex = numel(textblock{linenum}); % start at the end of this line
          end
      end
   end
end