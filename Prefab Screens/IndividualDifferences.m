% IndividualDifferences.m
%
% Runs a battery of measures of individual differences in cognitive & 
% psycholinguistic abilities.
%
% How to use the battery:
%  1) First, use File->Save As... to save a COPY of this file and call it
%     something like YourProjectName.m .  Then, just edit this COPY so you
%     can leave the original verison in place.
%
%  2) Look through the new file that you created (YourProjectName.m) and
%     adjust the settings in the file as needed.  In particular, you will
%     want to enter information about:
%      2a) The physical size of your computer
%      2b) The folder on your computer where you want your results to go
%      2c) The tasks you want used, and the order to do them in.
%     Save the updated file.
%
%  3) To run a participant on the task, open MATLAB and go to the folder
%     where you put the YourProjectName.m file.  Type:
%       YourProjectName
%     to start the battery
%
%  4) Just enter the participant # and you should be set to go
%
% During the task, the list of tasks that you have is displayed between
% tasks, and each one is checked off once complete (so participants
% hopefully feel like they are making progress).
%
% TO SKIP A TASK, press the F3 key when the name of the next task is
% highlighted on the menu, before it starts.
%
% The individual differences battery assumes that you have the *entire*
% CogToolbox set up on your system.  Just copying this 1 file over will not
% work.
%
% Almost all tasks create their own detailed output file for each subject.
%
% In addition, the program maintains a "Master" results file (in comma-separated
% .CSV format) that attempts to summarize the key dependent variables from each
% task for each subject.  Those DVs are:
%    > Letter Comparison: # of correct trials in each of the 2 times through
%         the task
%    > Pattern Comparison: same as above
%    > All WM tasks: Memory score according to the "Partial-Credit Unit-
%         Weighted" scoring method detailed by Conway et al. 2005
%    > Newer WM tasks: Also saves the maximum processing time calibrated
%         for each participant, and the proportion accuracy on the
%         processing tasks (criterion for inclusion = 85% or above)
%    > Antisaccade: median RT and proportion accurate responses
%    > Computer-paced Stroop: no DV is saved because results must be
%         transcribed from the audio recordings
%    > Self-paced stroop: Interference -- the difference in log(mean RT)
%         between the "boxes" and "color word" conditions
%    > Flanker: Interference -- the difference in log(mean RT) between the
%         between the congruent & incongruent conditions
%    > Vocab: For each block, # of correct trials plus a penalty for
%         guessing (-0.25 for each incorrect guess)
%    > Pseudoword Repetition: no DV is saved because results must be
%        transcribed from the audio recordings
%
% The program does its best job to keep the file in order, but if you
% change which tasks are being used (or their order) partway through your
% study, or if the program crashes, it will get messed up.  This shouldn't
% be too big a deal because EVERYTHING can be reconstructed from the raw
% data (described above).
%
% 06.13.11 - S.Fraundorf - first version
% 06.20.11 - S.Fraundorf - added toggle for neutral trials in flanker task
% 06.21.11 - S.Fraundorf - added parameter for how to time the WM tasks
% 06.22.11 - S.Fraundorf - added parameters for Listening Span sound files
% 06.22.11 - S.Fraundorf - updated output saved by WM tasks
% 07.05.11 - S.Fraundorf - added sound latency settings

%% START-UP (DON'T CHANGE)
InitExperiment; % set up random number generator & basic colors

% define other needed colors:
red = [255 0 0];
green = [0 200 0];
blue = [0 0 255];

%% IMPORTANT SETTINGS:

% This is the folder where you want your results stored:
ResultsFolder = '~/Desktop/Minotaur';
% Filename for the results file:
ResultsFilename = 'minotaur.csv';

% Physical properties of your computer setup:
Distance_From_Participant_To_Screen = 24;
Diagonal_Size_of_Your_Screen = 13; % from the upper-left corner of visible area
                                   % of the screen to the lower-right
% These measurements can be in any units you like as long as you use the
% SAME units for both.
%
% Why does this matter?  Some of the tasks use these physical distances in
% in order to calculate how big the stimuli should be relative to the screen.
% This keeps the stimuli occupying a constant VISUAL ANGLE for the participant
% no matter where they are sitting or how big the screen is.

% Latency of sound stimuli:
PlayingLatency = 0.015;
RecordingLatency = 0.015;
%
% These settings control the timing of your auditory stimuli.  That is, how
% long a delay is there between when you TELL Matlab to play a sound, and
% when it ACTUALLY starts playing?
%
% In theory, you would want this value as close to 0 as possible.  However,
% if you set the value TOO low for your particular computer system, the
% audio wil sound scratchy/static-y (Matlab is trying to go too fast and
% your system can't keep up).
%
% For these tasks, you don't need EXACT time-locking, so it's OK to
% increase the numbers if you need to.  The minimum is 0 and the maximum is
% 1.
%
% Here are some suggested values.  Or, experiment to find, for your
% particular system, the lowest value that won't make the audio sound funny.
%
% Macs:
% PlayingLatency = 0;
% RecordingLaency = 0;
% 
% PCs with good sound card:
% PlayingLatency = .015;
% RecordingLatency = .015;
%
% PCs with less able sound hardware:
% PlayingLatency = .050;
% RecordingLatency = 1;
%
% See the "Low-Latency Audio in Psychophysics Toolbox.doc" file that is part of the
% CogToolbox for more details.

% Sound file folders:
OldListeningFolder = '~/Documents/Programming/CaLLToolbox-3/WM Battery/listeningspan';
NewListeningFolder = '~/Documents/Programming/CaLLToolbox-3/WM Battery/lspan';
% If you are doing either of the listening span tasks, you need to specify
% the folder on your computer where the listening span stimuli are.  By
% default:
%  - files for the OLD task ("Listening Memory"/listeningspan.m) are in
%    'listeningspan' under the WM Battery folder
%  - files for the NEW task ("Listening"/lspan.m) are in 'lspan' under the
%    WM Battery folder
%
% But, YOU WILL NEED TO UPDATE THE ABOVE PATHS to point to the folder where
% you put the toolbox on YOUR computer
%
% If you are not sure where that is, try searching for "CogToolbox" or
% "lspan" on your computer
%
% If you are not doing the listening span tasks, you can skip this step.

%% SELECT TASKS

% Here you will select which tasks you want to do, and what order to do
% them in.  Change the number after each task name to reflect what serial
% position you want it to have.
% For example:
%  LetterComparison = 3;
% means the Letter Comparison task comes third
%
% IF YOU DON'T WANT TO DO A PARTICULAR TASK - changing the number to ZERO
% will disable the task.  Please DON'T just delete the line of code; that
% will cause the program to stop working!

% Processing Speed measures:                       % TITLE IN EXPERIMENT:
LetterComparison = 4;    % do not delete this line  "Letter Matching"
PatternComparison = 5;   % do not delete this line  "Shape Matching"
% Working Memory measures:
ReadingWM = 2;           % do not delete this line  "Reading"
ListeningWM = 3;         % do not delete this line  "Listening"
OperationWM = 1;         % do not delete this line  "Equations"
OldReadingWM = 0;        % do not delete this line  "Reading Memory"
OldListeningWM = 0;      % do not delete this line  "Listening Memory"
AlphabetSpan = 0;        % do not delete this line  "Alphabet"
Subtract2Span = 0;       % do not delete this line  "Number Memory"
% Attention/inhibitory control measures:
Antisaccade = 9;         % do not delete this line  "Flashing Letters"
StroopSelfPaced = 8;     % do not delete this line  "Colors"
StroopExpPaced = 0;      % do not delete this line  "Color Words"
Flanker = 7;             % do not delete this line  "Arrows"
% Vocab measures:
Vocab = 6;               % do not delete this line  "Word Meaning"
% Phonological ability measures:
PseudowordRepetition=10; % do not delete this line  "Imaginary Words"

%% OPTIONAL SETTINGS:
%
% You don't need to change these settings, but you can modify them if you
% want.  DO NOT DELETE any of the lines completely -- the program will stop
% working.

% Foreground and background colors
bgcolor = white;
fgcolor = black;
% Can reverse these if you want

% Text size & font for instructions:
TextSize = 32;
TextFont = 'Arial';

% Key that skips a task:
ExitKey = KbName('f3');

%% ---Don't change anything below this point unless you know what you're doing!---

%% SETTINGS FOR SPECIFIC TASKS

% Processing speed
ComparisonBlockTime = 20; % time (in s) per block on the comparison tasks

% Current Working Memory
WMProcessingTime = 0;
% How much time to allow for processing component?  Can be a particular
% number of SECONDS you want all participants to have.  Or, if you want to 
% calibrate this on a per-participant basis (see rspan.m or ospan.m for
% details), set this equal to 0.

% Old Working Memory
minus2time = 1; % # of s to display items on Minus 2 Span
alphatime = 1; % # of s to display items on Alphabet Span
readmin = 1; % minimum time for reading in Reading Span
readmax = 7; % maximum time for reading in Reading Span
TFtime = 2; % # of s for True/False judgments in Reading & Listening Span
highlighted = green; % for TOO SLOW! message

% Vocab:
VocabTime = 6; % time (in minutes) per block of the vocab test

% Inhibitory Control:
NeutralTrialsInFlanker = 0; % include neutral trials in flanker task?
FlankerTrialsPerType=25; % trials in each of the 6 conditions in the flanker task
AntisaccadeRepetitions=2; % number of times to repeat each of the 36 trial types in the antisaccade task

%% START THE INDIVIDUAL DIFFERENCES BATTERY
doIndividualDifferences;