% numberlist = parseNumberList(inputstring)
%
% Turns a string into a vector of numbers.  The string can include ranges
% of numbers (using a hyphen) and lists (using a comma)
%
% e.g. parseNumberList('1-3,5,7-9') returns [1,2,3,5,7,8,9]
%
% Returns NaN if the string does not fit this format.
%
% For reasons I can't figure out right now , the call to textscan in this function
% sometimes fails to parse the list of numbers -- it may skip some numbers,
% return excess 0s at the end, or return only NaNs.  This varies stochastically
% even when running the code on IDENTICAL input.  A fix for this would be
% much appreciated!
%
% 07.28.08 - S.Fraundorf
% 10.15.10 - S.Fraundorf - improved efficiency of code. bugfixes.

function numberlist = parseNumberList(inputstring)
 
  numberlist = [];
  
  tokenized{1} = NaN;
  tokenized = textscan(inputstring, '%s', 'EndOfLine', ',');
  tokens = numel(tokenized{1});

  for i=1:tokens    
      % is this a single number, or a range?
      [range1 range2] = strtok(tokenized{1}(i), '-');
      
      if strcmp(range2, '') % this is a single number
          numberlist = [numberlist str2double(range1)];
      else                  % this is a range of numbers
          range2 = strtok(range2, '-'); % remove the hypoen
          fullrange = str2double(range1):str2double(range2);
          numberlist = [numberlist fullrange]; % add the whole range of #s
      end
  end