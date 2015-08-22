% score = LetterComparison(win, fgcolor, bgcolor, timelimit, outputfolder, subjno)
%
% Computerized version of the letter comparison task from Salthouse &
% Babcock, 1991.
%
% In this task, participants view 2 sets of consonants and make speeded
% responses as to whether the 2 sets are the same or not.
%
% There are a total of 6 blocks: 2 blocks in which the sets have 3 items each, 2
% blocks in which they have 6 items each, and 2 blocks in which they have 9
% items each.
%
% The task is displayed on window WIN with foreground color FGCOLOR and
% background color BGCOLOR.
%
% The task runs for TIMELIMIT seconds per block (default is 20 s, for a total
% of 2 min across the 6 blocks).
%
% Returns SCORE, which is a 6 x 4 matrix of respones on each block:
%  Column 1 - HITS to SAME items
%  Column 2 - FALSE ALARMS (said "same" but is actually different)
%  Column 3 - CORRECT REJECTIONS of DIFFERENT items
%  Column 4 - MISSES of SAME items
%
% If optional parameters OUTPUTFOLDER and SUBJNO are specified, also saves
% a separate .CSV file with trial-by-trial data
%
% 1.26.10 - S.Fraundorf - first version, for PTB-3
% 01.30.10 - S.Fraundorf - collect errors as well as correct responses
% 02.05.10 - S.Fraundorf - added exit key to quit early
% 02.08.10 - S.Fraundorf - returns 4-column matrix for maximal info.
% 02.14.10 - S.Fraundorf - clarified instructions to participant
% 10.25.10 - S.Fraundorf - manually select Courier font because the attempt
%                          to find a fixed width font doesn't seem to
%                          always work
% 06.20.11 - S.Fraundorf - Can save trial-by-trial data in a file.
%                          Changed response keys to D (yes, same) and K
%                          (no, diff) and exit key to F3, to be consistent
%                          with other tasks.  Revised the instructions
%                          again to (probably unsuccessfully) ward off
%                          confusion about each block ending after a fixed
%                          amount of time.  Clarified to press a key at
%                          end.
% 08.22.12 - S.Fraundorf - slightly improved timing by initializing RT
%                          variables before task starts

function score = LetterComparison(win, fgcolor, bgcolor, timelimit, outputfolder, subjno)

%% DEFAULT VALUES
if nargin < 5
    outputfolder = [];
    if nargin < 4
       timelimit = 20;
    end
end

%% INITIALIZE STUFF
score = zeros(6,4);
consonants = 'BCDFGHJKLMNPQRSTVWXYZ'; % use all consonants
setsizes = [3 6 9 3 6 9];
rand('twister', sum(100*clock));
%monofont = get(0,'FixedWidthFontName'); % find out what the monospaced font is on this machine
monofont = 'Courier';

respkeys(1) = KbName('D'); % key for SAME
respkeys(2) = KbName('K'); % key for DIFFERENT
respkeys(3) = KbName('F3'); % key to EXIT TASK

% response timing variables:
t1 = 0;
timeelapsed = 0;
t2 = 0;
RT = 0;
resptime=0;

%% GET WINDOW PARAMETERS
rect = Screen('Rect', win);
XMid = rect(3)/2;
YMid = rect(4)/2;
textsize = Screen('TextSize', win);

%% OPEN OUTPUT FILE, IF DESIRED
if ~isempty(outputfolder)
    savetrials = true;
    outfile = fopen([outputfolder 'LetterComp' num2strLZ(subjno, '%d', 2) '.csv'], 'w');
    fprintf(outfile, 'SUBJNO,BLOCKNUM,SETSIZE,STIM1,STIM2,SAME,RESP,CORRECT,RT\n');
else
    savetrials = false;
end

%% DISPLAY INSTRUCTIONS
instructions = ['In this task, you will see 2 sets of letters on each screen.  '...
    'Your job is to judge whether the two sets are the <b>same</b>.|' ...
    'Press the <b>D</b> key if, yes, the sets <b>ARE</b> exactly the same.|'...
    'Press the <b>K</b> key if, no, the sets are <b>NOT</b> exactly the same.|'...
    'We''ll show you some examples to get you started.'];
InstructionsScreen(win, fgcolor,bgcolor,instructions);

oldfont = Screen('TextFont', win, monofont); % switch to monospaced
oldsize = Screen('TextSize', win, 48);

% demo SAME
WriteCentered(win, 'BHQ', XMid, YMid-textsize, fgcolor);
WriteCentered(win, 'BHQ', XMid, YMid+textsize, fgcolor);
Screen('TextFont', win, oldfont); % restore existing font
Screen('TextSize', win, oldsize); % and font size
WriteCentered(win, 'These ARE exactly the same, so press D for YES.', XMid, YMid+(textsize*3), fgcolor);
Screen('Flip', win);
Wait4Key(respkeys(1));

oldfont = Screen('TextFont', win, monofont); % switch to monospaced
oldsize = Screen('TextSize', win, 48);

% demo DIFFERENT
WriteCentered(win, 'CVN', XMid, YMid-textsize, fgcolor);
WriteCentered(win, 'CRN', XMid, YMid+textsize, fgcolor);
Screen('TextFont', win, oldfont); % restore existing font
Screen('TextSize', win, oldsize); % and font size
WriteCentered(win, 'These are NOT the same, so press K for NO.', XMid, YMid+(textsize*3), fgcolor);
Screen('Flip', win, 0);
Wait4Key(respkeys(2));

Screen('TextFont', win, oldfont); % restore existing font
Screen('TextSize', win, oldsize); % and font size

instructions = ['Please keep your fingers on the D and K keys so you can respond quickly.|'...
    'There will be six groups of trials in this experiment.  After ' num2str(timelimit) ...
    ' seconds, the program will automatically advance to the next group of trials,'...
    ' even if you hadn''t responded to the final trial in the previous set yet.|'...
    'In each group of trials, there will be a different number of letters per set.|'...
    'We know that you might make some mistakes--everyone does!  But, please try to go as fast as you can while still being accurate.|'...
    'If you have any questions, please ask the experimenter now.'];
InstructionsScreen(win, fgcolor,bgcolor,instructions);

%% DO TEST
for blocknum=1:6
    
    % retrieve set size
    setsize = setsizes(blocknum);
    
    % display instructions
    WriteCentered(win, ['In the next period, there will be ' num2str(setsize) ' letters in each set.'], XMid, YMid-textsize, fgcolor);
    Screen('Flip', win, 0, 1);
    WaitSecs(0.5);
    WriteCentered(win, 'Press a key to begin.', XMid, YMid+textsize, fgcolor);
    Screen('Flip', win, 0);
    getKeys;
    
    oldfont = Screen('TextFont', win, monofont); % switch to monospaced
    oldsize = Screen('TextSize', win, 48);
       
    % create first item
    [set same] = LetterSetCreate(consonants, setsize);
      
    % write both lines
    WriteCentered(win, set(1,:), XMid, YMid-textsize, fgcolor);
    WriteCentered(win, set(2,:), XMid, YMid+textsize, fgcolor);
 
    t1 = Screen('Flip', win, 0);
    
    % start timing
    timeelapsed = GetSecs-t1;
  
    while timeelapsed < timelimit
       % get a response
       [resptime keyCode] = Wait4KeyTimed(timelimit-timeelapsed, respkeys);
       
       % check timing
       RT = (resptime - t1) - timeelapsed;
       timeelapsed = GetSecs-t1;
       if timeelapsed >= timelimit
           % save trial-level results if needed
            if savetrials
              %fprintf(outfile, 'SUBJNO,BLOCKNUM,SETSIZE,STIM1,STIM2,SAME,RESP,CORRECT,RT')
              fprintf(outfile, '%d,%d,%d,%s,%s,%d,%d,%d,%2.4f\n', subjno, blocknum, setsize, set(1,:), set(2,:), same, -1, -1, RT);
            end
            % quit block
            break;
       end
       
       if keyCode(respkeys(3))
           % hit key to exit
           return
       elseif keyCode(respkeys(1)) && same
           % HIT (is same, said same)
           score(blocknum,1) = score(blocknum,1) + 1;
       elseif keyCode(respkeys(1)) && ~same
           % FALSE ALARM (is different, said same)
           score(blocknum,2) = score(blocknum,2) + 1;
       elseif keyCode(respkeys(2)) && ~same
           % CORRECT REJECTION (is different, said different)
           score(blocknum,3) = score(blocknum,3) + 1;
       else
           % MISSES (is same, said differnt)
           score(blocknum,4) = score(blocknum,4) + 1;
       end
       
       % save trial-level results if desired
       if savetrials
           %fprintf(outfile, 'SUBJNO,BLOCKNUM,SETSIZE,STIM1,STIM2,SAME,RESP,CORRECT,RT')
           fprintf(outfile, '%d,%d,%d,%s,%s,%d,%d,%d,%2.4f\n', subjno, blocknum, setsize, set(1,:), set(2,:), same, ...
               mod(find(keyCode(respkeys)),2), keyCode(respkeys(1)) == same, RT);
       end
       
       % create a new item
       [set same] = LetterSetCreate(consonants, setsize);
      
       % write both lines
       WriteCentered(win, set(1,:), XMid, YMid-textsize, fgcolor);
       WriteCentered(win, set(2,:), XMid, YMid+textsize, fgcolor);
 
       t2 = Screen('Flip', win, 0);
       
       timeelapsed = t2-t1;
       
    end
    
    Screen('TextFont', win, oldfont); % restore existing font
    Screen('TextSize', win, oldsize); % and font size
end

%% WRAP-UP
WriteCentered(win, 'Congratulations, you have now finished this task!  Press a key.', XMid, YMid, fgcolor);
Screen('Flip', win, 0);
getKeys;