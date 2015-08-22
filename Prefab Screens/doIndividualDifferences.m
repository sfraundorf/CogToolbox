% doIndividualDifferences.m
%
% Runs a variety of cognitive ability measures.
%
% This script should NOT be run by itself -- it is called by
% IndividualDifferences.m (or your version thereof).  You probably don't
% want to mess with any of the code or settings here unless you know what
% you're doing.
%
% 06.13.11 - S.Fraundorf - first version
% 06.17.11 - S.Fraundorf - added support for Operation Span
% 06.20.11 - S.Fraundorf - no need to create LetterComparison and
%                            PatternComparison files since they now save
%                            their own output.
%                          Added toggle for neutral trials in flanker.
%                          Clarified instructions to participant
% 06.21.11 - S.Fraundorf - Added support for new Reading & Listening Span tasks.
%                          Added parameter for how to time the WM tasks
%                          Hide cursor BEFORE playing test sound.
%                          Don't let keyboard input bleed into MATLAB.
% 06.22.11 - S.Fraundorf - Updated calls to Listening Span tasks.
% 06.22.11 - S.Fraundorf - Changed "blank" columns to actual blanks rather
%                            than 0.  Updated header row to distinguish
%                            old/new WM tasks
% 06.22.11 - S.Fraundorf - save % accuracy on the WM tasks
% 06.22.11 - S.Fraundorf - clarified column headers for accuracy %
% 06.29.11 - S.Fraundorf - initializes audio for PCs
% 07.03.11 - S.Fraundorf - does a check to close any existing sound channels
% 07.05.11 - S.Fraundorf - added sound latency settings

%% UPDATE FOLDERS

% Fix names:
ResultsFolder = makeValidPath(ResultsFolder);
OldListeningFolder = makeValidPath(OldListeningFolder);
NewListeningFolder = makeValidPath(NewListeningFolder);

% Move to correct folder:
cd(ResultsFolder);

% create Gupta & Stroop folders, if needed
if PseudowordRepetition > 0 && ~exist('Gupta_Recordings', 'dir')
    mkdir('Gupta_Recordings');
end
if (StroopSelfPaced > 0 || StroopExpPaced > 0) && ~exist('Stroop_Recordings', 'dir')
    mkdir('Stroop_Recordings');
end
        

%% PARSE THE LIST OF TASKS
taskordering = [LetterComparison PatternComparison ReadingWM ListeningWM ...
    OperationWM OldReadingWM OldListeningWM AlphabetSpan Subtract2Span ...
    Antisaccade StroopSelfPaced StroopExpPaced Flanker Vocab PseudowordRepetition];

% Check how many tasks we have
activetasks = taskordering(taskordering>0);
numtasks = numel(activetasks);
highestnum = max(activetasks); % highest number that has been assigned.
   % OK if they happen to skip a few numbers (e.g. 1, 2, 4)

% Check that no two tasks have been assigned the same number
if containsDuplicates(activetasks)
    error('CogToolbox:IndividualDifferences:DuplicateSerialPosition', ...
        ['Two or more individual difference measures have been assigned the same serial position.  '...
        'You can fix this by editing the top of your version of IndividualDifferences.m']);
end

% Put the tasks in order
tasknames = {'Letter Matching', 'Shape Matching', 'Reading', ...
    'Listening', 'Equations', 'Reading Memory', 'Listening Memory', ...
    'Alphabet', 'Number Memory', 'Flashing Letters', 'Colors', ...
    'Color Words', 'Arrows', 'Word Meanings', 'Imaginary Words'};
% names as shown to participants
nextslot = 1;
tasklist = cell(1,numtasks);
for i=1:highestnum
    taskindex = find(taskordering == i);
    if ~isempty(taskindex)
        tasklist(nextslot) = tasknames(taskindex);
        nextslot = nextslot + 1;
    end
end

% Clear variables no longer needed
clear taskordering activetasks tasknames highestnum nextslot taskindex ...
    LetterComparison PatternComparison ReadingWM ListeningWM OperationWM ...
    OldReadingWM OldListeningWM AlphabetSpan Subtract2Span Antisaccade ...
    StroopSelfPaced StroopExpPaced Flanker Vocab PseudowordRepetition;

%% GET PARTICIPANT #
subjno = getSubjectNumber([ResultsFolder 'id'], '.txt', 1);

% create a file to note that this participant has been run
outfile = fopen([ResultsFolder 'id' num2strLZ(subjno, '%2d', 2) '.txt'], 'w');
fprintf(outfile, 'Run %s at %s', datestr(now,2), hourmin);
fclose(outfile);

%% READY DATA FILE
if ~exist([ResultsFolder ResultsFilename], 'file')
    % data file doesn't exist yet, so set it up
    outfile = fopen([ResultsFolder ResultsFilename], 'a');
    
    % create header row
    fprintf(outfile, 'SubjNo');
    for i=1:length(tasklist)
        switch tasklist{i}
            case 'Letter Matching'
                fprintf(outfile, ',LC_Cor_1,LC_Cor_2');
            case 'Shape Matching'
                fprintf(outfile, ',PC_Cor_1,PC_Cor_2');
            case 'Reading'
                fprintf(outfile, ',RSpan,RSpan_ProcAcc,RSpan_Maxtime');
            case 'Listening'
                fprintf(outfile, ',LSpan,LSpan_ProcAcc,LSpan_Maxtime');
            case 'Equations'
                fprintf(outfile, ',OSpan,OSpan_ProcAcc,OSpan_Maxtime');
            case 'Reading Memory'
                fprintf(outfile, ',ReadSpan');
            case 'Listening Memory'
                fprintf(outfile, ',ListSpan');
            case 'Alphabet'
                fprintf(outfile, ',AlphaSpan');
            case 'Number Memory'
                fprintf(outfile, ',Min2Span');
            case 'Flashing Letters'
                fprintf(outfile, ',Antisac_RT,Antisac_Acc');
            case 'Colors'
                fprintf(outfile, ',Stroop_LogInt');
            case 'Arrows'
                fprintf(outfile, ',Flank_LogInt');
            case 'Word Meanings'
                fprintf(outfile, ',Vocab1,Vocab2');
        end
    end
    fprintf(outfile, '\n');
else
    % resume this file
    outfile = fopen([ResultsFolder ResultsFilename], 'a');
end
% write the current subject number
fprintf(outfile, num2str(subjno));

%% OPEN SCREEN
[mainwindow rect] = Screen('OpenWindow', 0, bgcolor);

Screen('TextSize',mainwindow,TextSize);
Screen('TextFont',mainwindow,TextFont);

XCenter = rect(3)/2;
YBottom = rect(4);
YCenter = YBottom/2;

% set the blend fxn for smooth drawing
Screen(mainwindow,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%% INITIALIZE SOUND
InitializePsychSound; % needed for PCs
PsychPortAudio('Close'); % close any existing audio channels

%% SET UP MENU SCREEN
menuwindow = CreateOffWin(mainwindow, bgcolor, TextFont, TextSize);
for i = 1:length(tasklist)
  WriteLine(menuwindow, tasklist{i}, fgcolor, 150,150,TextSize*i*2);
end

%% HIDE KEYBOARD FROM CONSOLE
ListenChar(2);
HideCursor;

%% DISPLAY INTRODUCTION & ADJUST VOLUME

Instructions = ['Welcome to the experiment!|On the next screen, we''ll adjust the computer volume to make sure it''s '...
    'comfortable before we get started.'];
InstructionsScreen(mainwindow, fgcolor, bgcolor, Instructions);

AdjustVolume(mainwindow, fgcolor, bgcolor, 1); % use a keypress to confirm

Instructions = ['We are going to ask you to complete a set of short mini-experiments on the computer.|'...
    'There are a number of them. But, each one is fairly short.|'...
    'You are welcome to take a short break between each task if you''re getting tired.|'...
    'But, during the tasks, it is important that you not take breaks until the experiment tells you that it''s OK.|'...
    'We''ll keep track of your progress for you as you go.'];
InstructionsScreen(mainwindow, fgcolor, bgcolor, Instructions);

%% DO EACH TASK

% show the menu screen initially
Screen('CopyWindow',menuwindow,mainwindow);
Screen('Flip',mainwindow,0,1);

for i=1:length(tasklist)
        
    % show next task as active
    WriteLine(mainwindow,tasklist{i}, red,150,150,TextSize*i*2);
    Screen('Flip',mainwindow,0,1);
        
    % allow the user to start the next task
    WriteCentered(mainwindow,['Press a key to begin ' tasklist{i} '.'], ...
        XCenter, YBottom-2*TextSize, fgcolor);
    Screen('Flip',mainwindow);
    
    keypress = getKeys;
    
    if keypress ~= ExitKey   % exit key SKIPS the next task
        switch tasklist{i}
            case 'Letter Matching' % Letter Comparison
                % do the task
                scores = LetterComparison(mainwindow,fgcolor,bgcolor,ComparisonBlockTime,ResultsFolder,subjno);
                % save the TOTAL CORRECT in the master file:
                cor1 = sum(scores(1:3,1)) + sum(scores(1:3,3));
                cor2 = sum(scores(4:6,1)) + sum(scores(4:6,3));
                fprintf(outfile, ',%2.4f,%2.4f', cor1, cor2);
                clear SpeedFile scores cor1 cor2;                
                
            case 'Shape Matching' % Pattern Comparison 
                % do the task
                scores = PatternComparison(mainwindow,fgcolor,bgcolor,ComparisonBlockTime,ResultsFolder,subjno);
                % save the TOTAL CORRECT in the master file:
                cor1 = sum(scores(1:3,1)) + sum(scores(1:3,3));
                cor2 = sum(scores(4:6,1)) + sum(scores(4:6,3));
                fprintf(outfile, ',%2.4f,%2.4f', cor1, cor2);
                clear SpeedFile scores cor1 cor2;
                
            case 'Color Words' % computer-paced Stroop
                % do the task
                Stroop(mainwindow, fgcolor, bgcolor, subjno, [ResultsFolder 'Stroop_Recordings/']);
                % nothing to save because this records audio only'
                
            case 'Colors' % self-paced Stroop
                StroopRTs = StroopRT(mainwindow, fgcolor, bgcolor, subjno, [ResultsFolder 'Stroop_Recordings/'], 1);
                % saves its own output file
                % but also save it to our master file
                logInt = log(mean(StroopRTs(:,2))) - log(mean(StroopRTs(:,1)));
                fprintf(outfile, ',%2.4f', logInt);
                clear StroopRTs;
                
            case 'Equations' % Operation Span
                [score pct maxtime] = ospan(mainwindow, fgcolor, bgcolor, ResultsFolder, subjno, WMProcessingTime);
                fprintf(outfile, ',%2.4f,%2.4f,%2.4f', score, pct, maxtime);
                clear pct maxtime;

            case 'Reading' % current Reading Span
                [score pct maxtime] = rspan(mainwindow, fgcolor, bgcolor, ResultsFolder, subjno, WMProcessingTime);
                fprintf(outfile, ',%2.4f,%2.4f,%2.4f', score, pct, maxtime);
                clear pct maxtime;                                

            case 'Listening' % current Listening Span
                [score pct maxtime] = lspan(mainwindow, fgcolor, bgcolor, ResultsFolder, NewListeningFolder, subjno, WMProcessingTime, PlayingLatency);
                fprintf(outfile, ',%2.4f,%2.4f,%2.4f', score, pct, maxtime);
                clear pct maxtime;                                             
                
            case 'Number Memory' % Minus 2 Span
                score = minus2span(mainwindow, fgcolor, bgcolor, minus2time, ResultsFolder, subjno, 1, 'NUMBER MEMORY');
                % also saves its own data, but also save to master
                fprintf(outfile, ',%2.4f', score);
                
            case 'Listening Memory' % old Loaded Listening Span
                score = listeningspan(mainwindow, fgcolor, bgcolor,highlighted, TFtime, ResultsFolder, subjno, 1,  OldListeningFolder, 'LISTENING MEMORY', PlayingLatency);
                % also saves its own data, but also save to master
                fprintf(outfile, ',%2.4f', score);

            case 'Reading Memory' % old Loaded Reading Span
                score = readingspan(mainwindow, fgcolor, bgcolor,highlighted, readmin, readmax, TFtime, ResultsFolder, subjno, 1, 'READING MEMORY');
                % also saves its own data, but also save to master
                fprintf(outfile, ',%2.4f', score);
                
            case 'Alphabet' % Alphabet Span
                score = alphabetspan(mainwindow, fgcolor, bgcolor, alphatime, ResultsFolder, subjno, 1, 'ALPHABET');
                % also saves its own data, but also save to master
                fprintf(outfile, ',%2.4f', score);
                
            case 'Word Meanings' % Vocabulary Test
                scores = vocab(mainwindow, fgcolor, bgcolor, ResultsFolder, subjno, VocabTime);
                fprintf(outfile, ',%2.2f,%2.2f', scores(1), scores(2));
                clear scores;
                
            case 'Flashing Letters' % Anti-saccade 
                [medianRT propAcc] = antisaccade(mainwindow, ResultsFolder, subjno, ...
                    Diagonal_Size_of_Your_Screen, Distance_From_Participant_To_Screen, AntisaccadeRepetitions);
                fprintf(outfile, ',%2.4f,%2.4f', medianRT, propAcc);
                clear medianRT propAcc;
                
            case 'Arrows' % flanker
                scores = flanker(mainwindow, ResultsFolder, subjno, Diagonal_Size_of_Your_Screen, ...
                    Distance_From_Participant_To_Screen, FlankerTrialsPerType, NeutralTrialsInFlanker);
                logInt = log(scores(2)) - log(scores(1));
                fprintf(outfile, ',%2.4f', logInt);
                clear scores logInt;
                
            case 'Imaginary Words' % Gupta / pseudoword repetition
                % just saves recordings
                gupta(mainwindow, fgcolor, bgcolor, [ResultsFolder 'Gupta_Recordings/'], subjno, PlayingLatency, RecordingLatency);                
                
        end
    else
        % SKIPPED the task.  write the corresponding # of blank columns in
        % the master results file
        switch tasklist{i}
            case {'Equations','Reading', 'Listening'} 
                % 3 blank columns
                fprintf(outfile, ',,,');
            case {'Letter Matching', 'Shape Matching', 'Word Meanings', 'Flashing Letters'}
                % 2 blank columns
                fprintf(outfile, ',,');
            case {'Colors', 'Arrows', 'Number Memory', 'Listening Memory', 'Reading Memory', ...
                    'Alphabet'}
                % 1 blank column
                fprintf(outfile, ',');
            % others have ZERO blank columns
        end
    end
    % task done (or skipped)
    
    % show the menu screen again
    Screen('CopyWindow',menuwindow,mainwindow);
    Screen('Flip',mainwindow,0,1);
    
    % check off the task that was just completed
    DrawLineAnimated(mainwindow, green, 90, (TextSize*i*2+(TextSize/2)), ...
        100, TextSize*i*2+TextSize, 8, 25);
    DrawLineAnimated(mainwindow, green, 100, TextSize*i*2+TextSize, ...
        160,TextSize*i*2-(TextSize*.75), 8, 25);
    
    % draw this on the PERMANENT menu
    Screen('DrawLine',menuwindow, green, 90, (TextSize*i*2+(TextSize/2)), ...
        100, TextSize*i*2+TextSize, 8);
    Screen('DrawLine',menuwindow, green, 100, TextSize*i*2+TextSize, ...
        160,TextSize*i*2-(TextSize*.75), 8);
    
    % mark the last task as completed
    WriteLine(menuwindow,tasklist{i}, green,150,150,TextSize*i*2);
    Screen('CopyWindow',menuwindow,mainwindow);
    Screen('Flip',mainwindow,0,1);
    WaitSecs(0.25);

    
end

%% WRAP-UP

% display goodbye
Screen('Flip',mainwindow);
InstructionsScreen(mainwindow, fgcolor, bgcolor, 'Congratulations!  You finished the last task.');
Screen('CloseAll');

% restore control
ListenChar(0);
ShowCursor;

% close out the datafile
fprintf(outfile, '\n'); % end the line of the data
fclose all;

%
fprintf('Experiment concluded successfully.  Thank you!\n');