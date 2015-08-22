function scores = wmbattery(mainwindow, fgcolor, bgcolor, highlighted, foldername, subjno,testorder,randspan)

% scores = wmbattery(mainwindow,fgcolor,bgcolor,highlighted,foldername,subjno,testorder,randspan)
%
% !!NOTE!!: These tasks are out of date.  The new working memory tasks
% (rspan.m, ospan.m, and lspan.m) are preferred.  You can run these tasks
% via IndividualDifferences.m.  But, the old tasks are still here in case
% you want to keep using them.
%
% Runs a working memory battery with 4 tests: listeningspan, readingspan,
% alphabetspan, and minus2span.  More details on each test can be found in
% their individual help files.
%
% The test is displayed on open window MAINWINDOW, in color FGCOLOR on
% background BGCOLOR.
%
% Returns SCORES, a vector of scores on the four tests.  The scores can be
% averaged together to create an aggregate WM measure, which is usually
% preferred.  See discussion of RANDSPAN for what the scores represent.
%
% Trial-by-trial data from each test is also saved in folder FOLDERNAME
% based on subject number SUBJNO.
%
% Optional parameter TESTORDER controls the presentation order of the tests:
%   0 - listening, reading, alphabetspan, minus2span   (default)
%   1 - minus2span, alphabetspan, reading, listening
% Other TESTORDERs will return an error.  Regardless of the presentation
% order, the scores are stored in the SCORES vector based on testorder 0
% (i.e., scores(1) is always the listening span score).
%
% Optional parameter RANDSPAN controls the order in which the sets WITHIN
% a task are presented.
%   0 - present the sets in order of increasing span length, and quit if
%        the participant misses both spans of a given length.  In this
%        case, the SCORE represents the highest span successfully
%        completed, plus the proportion of items answered on the last level.
%        This is the DEFAULT setting, mostly to maintain compatibility with past
%        versions.  This version takes approximately 20-25 minutes.
%   1 - present the sets in a RANDOMIZED order, and display ALL sets.  This
%        takes longer, but gives you more data points (for a more reliable
%        estimate) and deconfounds span length with the buildup of proactive
%        interference over the course of the experiment.  In this case,
%        the SCORE represents the number of SETS correctly recalled, with
%        PARTIAL CREDIT awarded to sets not fully recalled.  This is the
%        approach recommended by working memory researchers.
%
% wmbattery.m has several parameters hard-coded into it that control the
% timing of trials.  These parameters were chosen by Eun Kyung Lee and me
% based on piloting.  If you want to change them, you will have to edit
% wmbattery.m
%
% 11.17.09 - S.Fraundorf - first version
% 11.25.09 - S.Fraundorf - added TESTORDER parameter
% 01.24.09 - S.Fraundorf - added RANDSPAN parameter
% 06.21.11 - S.Fraundorf - added warning that this is now out of date
% 08.24.12 - S.Fraundorf - updated error message

%% SETTINGS FOR THE WM BATTERY

% folder with the sound files
soundfilefolder = 'listeningspan/';

% time limits
readmin = 1; % 1 second min to read each sentence in reading span
readmax = 7; % 7 seconds max to read each sentence in reading span
TFtime = 2; % 2 seconds to make true/false judgment in listening & reading span
alphatime = 1; % 1 seconds to read each word in alphabet span
minustime = 1; % 1 second to read each number in minus 2 span

%% CHECK PARAMETERS
if nargin < 8
    randspan = 0;
    if nargin < 7
       testorder = 0; % default test order is 0
    end
end

if randspan > 1 % not a valid parameter
    error('CogToolbox:wmbattery:InvalidRandSpan', 'RANDSPAN for the wmbattery must be either 0 or 1.');
end

foldername = makeValidPath(foldername); % make sure this is a valid path

%% SET UP SCORES
scores = zeros(4,1);

%% DO THE TESTS
if testorder == 0
  % Test 1: Listening Span
  scores(1) = listeningspan(mainwindow,fgcolor,bgcolor,highlighted,TFtime,foldername,subjno,randspan,soundfilefolder,'PART ONE');
  % Test 2: Loaded Reading Span
  scores(2) = readingspan(mainwindow,fgcolor,bgcolor,highlighted,readmin,readmax,TFtime,foldername,subjno,randspan,'PART TWO');
  % Test 3: Alphabet Span
  scores(3) = alphabetspan(mainwindow,fgcolor,bgcolor,alphatime,foldername,subjno,randspan,'PART THREE');
  % Test 4: Minus 2 Span
  scores(4) = minus2span(mainwindow,fgcolor,bgcolor,minustime,foldername,subjno,randspan,'PART FOUR');
elseif testorder == 1
  % Test 1: Minus 2 Span
  scores(4) = minus2span(mainwindow,fgcolor,bgcolor,minustime,foldername,subjno,randspan,'PART ONE');
  % Test 2: Alphabet Span
  scores(3) = alphabetspan(mainwindow,fgcolor,bgcolor,alphatime,foldername,subjno,randspan,'PART TWO');
  % Test 3: Loaded Reading Span
  scores(2) = readingspan(mainwindow,fgcolor,bgcolor,highlighted,readmin,readmax,TFtime,foldername,subjno,randspan,'PART THREE');
  % Test 4: Listening Span
  scores(1) = listeningspan(mainwindow,fgcolor,bgcolor,highlighted,TFtime,foldername,subjno,soundfilefolder,randspan,'PART FOUR');
else
    % not a valid test order
    Screen('CloseAll');
    error('TESTORDER for the wmbattery must be either 0 or 1.');
end

end