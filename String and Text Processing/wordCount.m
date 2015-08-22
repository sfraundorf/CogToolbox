% [numwords spaces] = wordCount(sentence,ignoredwords)
%
% This function counts the number of words in string SENTENCE.  Words are
% defined by blocks of text with spaces after them.  (The last word in the
% string is also counted even if there is no space after it.)
%
% Optional parameter IGNOREDWORDS is a cell array of words to be ignored
% in the word count.  They are not removed from the string, just ignored.
%
% Output:
%  NUMWORDS - scalar - number of words in the sentence
%  SPACES - vector containing the spaces defining the end of each of the
%    words (excluding any ignored words and the last word if there isn't
%    a space after it)
%
% 11.30.07 - S.Fraundorf
% 11.21.09 - S.Fraundorf - cleaned up code

function [numwords spaces] = wordCount(sentence, ignoredwords)

if nargin == 1
  ignoredwords{1} = ''; % no ignored words if no cell array specified
end

sentence = stripLeadingCharacter(sentence, ' '); % remove any space at the beginning
sentence = doubleToSingleSpacing(sentence); % remove any double spaces between words

if ~isempty(sentence)  % only count words if there actually any text to work with!!!
%---THIS IF BLOCK CONTINUES BELOW---

prelimspaces = find(sentence == ' '); % preliminary list of spaces
spaces2 = zeros(1,1); % start with no actual words

%  REMOVE ALL THE IGNORED WORDS FROM OUR INDEX OF WORDS
for i=1:numel(prelimspaces) % look at each word

  % get the word from the string
  if (i > 1) % not the first word
     testword = sentence(prelimspaces(i-1)+1:prelimspaces(i)-1);
  else % first word
     testword = sentence(1:prelimspaces(1)-1);
  end

  % compare the word to all the ignored words
  isignoredword = 0; % set ignored flag to 0
  j = 1;
  while (j<=numel(ignoredwords) && isignoredword == 0) % continue searching until all words or checked or ignored word is found
    if strcmp(testword, ignoredwords{j}) % compare the test word to this ignored word
      isignoredword = 1; % if it matches, set flag to 1 and stop searching
    end
    j=j+1; % check the next word
  end
  if ~isignoredword % if this is not an ignored word...
    spaces2 = [spaces2 prelimspaces(i)]; % add to our list of actual words
  end
end

if numel(spaces2) > 1  % remove the leading 0 from spaces2 by creating spaces
   for i=1:(numel(spaces2)-1)
     spaces(i) = spaces2(i+1);
   end
else
   spaces = find('a' == ' '); % create empty spaces matrix
end

% FIND NUMBER OF WORDS

% --if at least one word--
if sentence(numel(sentence)) == ' '  % does sentence end with blank space?
  if sentence(1) ~= ' ' % if there actually was at least one word
      numwords = numel(spaces); %  yes - we've counted all the words
  else   % the sentence contained just a single blank space
      numwords = 0;
  end

else % sentence ends with text instead of a space - check to see if last word should be counted

  % if there is at least one space in the sentence, jump to the last word
  if (numel(spaces) > 0 && numel(sentence) > spaces(1))
     testword = sentence(spaces(numel(spaces))+1:numel(sentence));
  else  % otherwise, just get the single word that we have
     testword = sentence;
  end

  % test to see if the last word is an ignored word  by comparing the word to all the ignored words
  isignoredword = 0; % set ignored flag to 0
  j = 1;
  while (j<=numel(ignoredwords) && isignoredword == 0) % continue searching until all words or checked or ignored word is found
    if strcmp(testword, ignoredwords{j}) % compare the test word to this ignored word
      isignoredword = 1; % if it matches, set flag to 1 and stop searching
    end
    j=j+1; % check the next word
  end
  if ~isignoredword % if this is not an ignored word...
    numwords = numel(spaces) + 1; % need to increase word count by 1 to count last word
  else % it is an ignored word
    numwords = numel(spaces); % don't count it
  end
end

%---THE SENTENCE WAS AN EMPTY STRING-----
else
  numwords = 0;
  spaces = find('a' == ' '); % create empty spaces matrix
end