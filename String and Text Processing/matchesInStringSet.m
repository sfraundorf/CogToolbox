% foundflag = matchesInStringSet(currentstring, stringset, casesensitivity)
%
% This function checks to see if string CURRENTSTRING matches any one of a
% set of predefined strings.  The set of strings is defined by the cell
% array STRINGSET.  The function compares the word passed to it
% against this set and returns scalar FOUNDFLAG accordingly:
%   0 - does not match anything in the set
%   i, where i>0 - matches element i in STRINGSET
% If there is more than one match, the function returns the index of the
% first match.  Note that this can only occur if there are 2 or more identical
% strings in STRINGSET
%
% This function is sensitive to differences in punctuation marks.
% Considering running the stripPunctuation function first to remove
% punctuation marks, if differences in punctuation marks are not important.
%
% This function is optionally sensitive or not sensitive to case, depending
% on the value passed as CASESENSITIVITY:
%   0 - not sensitive to case (default behavior)
%   1 - sensitive to case
%
% 11.21.09 - S.Fraundorf - currentversion

function foundflag = matchesInStringSet(currentstring, stringset, casesensitivity)

if nargin == 2
    casesensitivity = 0; % default to not case sensitive
end
% if case insensitive, change everything to lowercase
if (casesensitivity==0)
  currentstring = lower(currentstring); 
end

foundflag = 0; % return 'not found' unless found

% COMPARE TO STRINGSET
for i=1:numel(stringset) % compare against entire set of strings

   teststring = stringset{i}; % find the string to compare against
   % if case insensitive, change everything to lowercase
   if ~casesensitivity
     teststring = lower(teststring); 
   end
 
   if strcmp(currentstring, teststring) % if our string matches the string we're comparing against  ...
     foundflag=i; % set flag as index of current string
     break; % found so, don't make any further comparisons
   end
end % not a match - check against next string