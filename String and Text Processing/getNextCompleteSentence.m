% [sentence leftover] = getNextCompleteSentence(filenumber, holdover)
%
% Get the next complete sentence from open text file FILENUMBER.  A sentence
% is defined as everything before and including the next period.
% getNextCompleteSentence returns the complete sentence, as well as any
% text that is leftover on the last line read after the sentence was completed. 
% e.g. given the lines:
%      Alice went to the grocery store on
%      her way home.  She bought some cereal and
% sentence will be 'Alice went to the grocery store on her
% way home' and leftover will be ' She bought some cereal and'
%
% Passing text in the HOLDOVER variable will add that text to the
% beginning of the extracted sentence.  This can be used to pass whatever
% was the LEFTOVER from the last call of the function.  (e.g. ' She bought
% some cereal and' in the above example can be passed as HOLDOVER because
% it is the beginning of the next sentence)
%
% If HOLDOVER text itself contains a period, the function will not read any more
% lines from FILENUMBER.
%
% If nothing is passed to HOLDOVER, the sentence is assumed to start at the
% beginning of the next line of the text file.
%
% The file specified by FILENUMBER must already be open for this function
% to work.
%
% 11.24.08 - S.Fraundorf

function [ sentence leftover] = getNextCompleteSentence(filenumber, holdover)

if nargin == 1
  holdover = '';
end

currentline = holdover; % start sentence with whatever was held over after the period on the last line
i=0; % line counter starts at 0
done=0; % flag indicates when sentence is done reading
leftover = ''; % no leftover to return until we hear otherwise

% READ IN THE SENTENCE
while ~done % continue going until period found (or end of file)

  i = i+1; % advance line counter
  periods = find(currentline == '.');  % look for periods in the current line

  if isempty(periods) % current line has no periods in it (no end of sentence)
     sentencelines{i} = currentline;  % assign this complete line as part of the sentence
     
     % now, get another line, or stop if end of file
     if ~feof(filenumber)
        currentline = fgetl(filenumber); % get another line if the file continues
     else
        done = 1; % if end of file, sentence has to stop here
     end

  else % current line has a period (end of sentence) in it
     periodposition = periods(1); % stop at the first period
     sentencelines{i} = currentline(1:periodposition); % everything up to the period is included in the current line
     leftover = currentline((periodposition+1):numel(currentline)); % everything else is the leftover
     done = 1; % end of sentence is found, stop reading text file

  end

end % repeat WHILE loop with next line from file

% CONCATENATE TOGETHER ALL THE SENTENCE PIECES
sentence = sentencelines{1}; % start with the first line
for i=2:numel(sentencelines) % add all the other lines
  sentence = [sentence sentencelines{i}];
end