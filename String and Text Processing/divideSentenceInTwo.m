% [firsthalf secondhalf] = divideSentenceinTwo(sentence,oddflag,ignoredwords)
%
% divides string SENTENCE into two pieces based on the number of words, so that
% the first half and second half have an equal number of words.
%
% Words are defined by blank spaces.  There should be only single
% spaces between words - use doubleToSingleSpacing.m first if necessary
% to remove any double spaces.
%
% ODDFLAG determines how to handle sentences with an odd number
% of words:
%   0 - don't return the middle word (default)
%   1 - always attach the middle word to the 1st half
%   2 - always attach the middle word to the 2nd half
%   3 - randomly assign the middle word to one half or the other
%
% IGNOREDWORDS is a cell array containing words that should not be factored
% into the word count.  This is useful for ignoring markup codes or
% other irrelevant words.
%
% 08.11.08 - S.Fraundorf
% 11.29.09 - S.Fraundorf - cleaned up the code a little
% 08.22.12 - S.Fraundorf - updated random number generator

function [firsthalf secondhalf] = divideSentenceInTwo(sentence, oddflag, ignoredwords)

if nargin == 1
   oddflag = 0; % default if not specified
end
if oddflag > 3 % error catcher if valid oddflag not specified
   oddflag = 3;
elseif oddflag < 0
   oddflag = 0;
end

if nargin < 3
  ignoredwords{1} = ''; % no ignored words if no cell array specified
end

[numwords spaces] = wordCount(sentence, ignoredwords); % find the number of words, and where they end

if (numwords>1)  % need at least one word to divide sentence

% FIGURE OUT WHERE TO DIVIDE SENTENCES
if mod(numwords,2) == 0   % even number of words
   firsthalfend = spaces(numwords./2);
   secondhalfstart = firsthalfend + 1;
else % odd number of words
    switch oddflag % ODDFLAG determines what to do
        case 0  % odd, ignore center word
          firsthalfend = spaces((numwords - 1)./2);
          secondhalfstart = spaces((numwords + 1)./2)+1;
        case 1 % odd, assign center word to first half
          firsthalfend = spaces(((numwords -1)./2)+1);
          secondhalfstart = spaces((numwords + 1)./2)+1;
        case 2 % odd, assign center word to second half
          firsthalfend = spaces((numwords - 1)./2);
          secondhalfstart = spaces(((numwords - 1)./2))+1;
        case 3 % odd, assign randomly!

          rand('twister', sum(100 * clock));  % seed random number generator
          randomoutcome = ceil(rand * 2); % get random number
          if randomoutcome == 1   % assign to first half
             firsthalfend = spaces(((numwords -1)./2)+1);
             secondhalfstart = spaces((numwords + 1)./2)+1;
          else  % assign to second half
            firsthalfend = spaces((numwords - 1)./2);
            secondhalfstart = spaces(((numwords - 1)./2))+1;
          end
    end
end

% DIVIDE SENTENCE
firsthalf = sentence(1:firsthalfend);
secondhalf = sentence(secondhalfstart:numel(sentence));

%--IF NOT AT LEAST TWO WORDS---
else  % not at least two words
  switch oddflag
    case 0 % ignore the one word
     firsthalf = '';
     secondhalf = '';
    case 1 % assign the one word to the first half
     firsthalf = sentence;
     secondhalf = '';
    case 2 % assign the one word to the second half
     firsthalf = '';
     secondhalf = sentence;
    case 3 % assign the one word randomly
     rand('twister', sum(100* clock));
     randomoutcome = ceil(rand*2); % get random number
     if randomoutcome == 1  % assign to first half
      firsthalf=sentence;
      secondhalf='';
     else
      firsthalf = '';
      secondhalf = sentence;
     end
   end % end SWITCH oddflag
end