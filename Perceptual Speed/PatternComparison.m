% score = PatternComparison(win, fgcolor, bgcolor, timelimit, outputfolder, subjno)
%
% Computerized version of the pattern comparison task from Salthouse &
% Babcock, 1991.
%
% In this task, participants view 2 patterns and make speeded responses as
% to whether the 2 patterns are the same or not.  The patterns are
% comprised of invisible 4 x 4 matrices with line segments added between
% particular vertices.
%
% There are a total of 6 blocks: 2 blocks in which the patterns have 3
% lines each, 2 blocks in which they have 6 lines each, and 2 blocks in
% which they have 9 lines each.
%
% The instructions is displayed on window WIN with foreground color FGCOLOR and
% background color BGCOLOR.  The task itself is always on a black
% background, with blue & yellow patterns, for maximum visibility.
%
% The task runs for TIMELIMIT seconds per block (default is 20 s, for a total
% of 2 min across the 6 blocks).
%
% Returns SCORE, which is a 6 x 4 matrix of respones on each block:
%  Column 1 - HITS to SAME items
%  Column 2 - FALSE ALARMS (responded "same" but is actually different)
%  Column 3 - CORRECT REJECTIONS of DIFFERENT items
%  Column 4 - MISSES of SAME items
%
% 01.26.10 - S.Fraundorf - first version, for PTB-3
% 01.30.10 - S.Fraundorf - collect incorrect as well as correct responses
% 02.05.10 - S.Fraundorf - added exit key to quit early
% 02.08.10 - S.Fraundorf - changed background to black, returns 4-column
%                           matrix for maximal info.
% 02.14.10 - S.Fraundorf - clarified instructions to participant
% 06.20.11 - S.Fraundorf - Can save trial-by-trial data in a file.
%                          Changed response keys to D (yes, same) and K
%                          (no, diff) to be consistent with other tasks
%                          and exit key to F3.  Revised the instructions
%                          again to (probably unsuccessfully) ward off
%                          confusion about each block ending after a fixed
%                          amount of time.  Clarified to press a key at
%                          end.
% 06.21.11 - S.Fraundorf - changed the blue color to show up better
% 07.20.11 - S.Fraundorf - fixed typo in instructions
% 08.22.12 - S.Fraundorf - slightly improved timing by initializing RT
%                          variables before task starts

function score = PatternComparison(win, fgcolor, bgcolor, timelimit, outputfolder, subjno)

%% DEFAULT VALUES
if nargin < 4
    timelimit = 20;
end

%% INITIALIZE STUFF
score = zeros(6,4);
setsizes = [3 6 9 3 6 9];
rand('twister', sum(100*clock));

respkeys(1) = KbName('D'); % key for SAME
respkeys(2) = KbName('K'); % key for DIFFERENT
respkeys(3) = KbName('F3'); % key to EXIT TASK

patterncolors = [50 50 255;255 255 0];
patternbg = [0 0 0]; % black for best visibility
democolor = [255 255 255]; % white text on the demo screens

% response timing variables:
t1 = 0;
timeelapsed = 0;
t2 = 0;
RT = 0;
resptime = 0;

%% GET WINDOW PARAMETERS
rect = Screen('Rect', win);
XRight = rect(3);
XMid = XRight/2;
XEighth = XMid/4;
YMid = rect(4)/2;
textsize = Screen('TextSize', win);

%% OPEN OUTPUT FILE, IF DESIRED
if ~isempty(outputfolder)
    savetrials = true;
    outfile = fopen([outputfolder 'PatternComp' num2strLZ(subjno, '%d', 2) '.csv'], 'w');
    fprintf(outfile, 'SUBJNO,BLOCKNUM,SETSIZE,STIM1,STIM2,SAME,RESP,CORRECT,RT\n');
else
    savetrials = false;
end

%% SET UP PATTERNS
linelength = min(rect(3)/10, rect(4)/10);
boxwidth = linelength * 3;

% x1x2x3x
% 4 5 6 7
% x8x9x0x
% 1 2 3 4
% x5x6x7x
% 8 9 0 1
% x2x3x4x
coords(1,:,:) = [0             YMid-(1.5*linelength)  linelength   YMid-(1.5*linelength); ... % horiz row 1
                 linelength    YMid-(1.5*linelength)  linelength*2 YMid-(1.5*linelength); ...
                 linelength*2  YMid-(1.5*linelength)  linelength*3 YMid-(1.5*linelength); ...
                 0             YMid-(1.5*linelength)  0            YMid-(0.5*linelength); ... % vert row 1
                 linelength    YMid-(1.5*linelength)  linelength   YMid-(0.5*linelength); ...
                 linelength*2  YMid-(1.5*linelength)  linelength*2 YMid-(0.5*linelength); ...
                 linelength*3  YMid-(1.5*linelength)  linelength*3 YMid-(0.5*linelength); ...
                 0             YMid-(0.5*linelength)  linelength   YMid-(0.5*linelength); ... % horiz row 2
                 linelength    YMid-(0.5*linelength)  linelength*2 YMid-(0.5*linelength); ...
                 linelength*2  YMid-(0.5*linelength)  linelength*3 YMid-(0.5*linelength); ...
                 0             YMid-(0.5*linelength)  0            YMid+(0.5*linelength); ... % vert row 2
                 linelength    YMid-(0.5*linelength)  linelength   YMid+(0.5*linelength); ...
                 linelength*2  YMid-(0.5*linelength)  linelength*2 YMid+(0.5*linelength); ...
                 linelength*3  YMid-(0.5*linelength)  linelength*3 YMid+(0.5*linelength); ...
                 0             YMid+(0.5*linelength)  linelength   YMid+(0.5*linelength); ... % horiz row 3
                 linelength    YMid+(0.5*linelength)  linelength*2 YMid+(0.5*linelength); ...
                 linelength*2  YMid+(0.5*linelength)  linelength*3 YMid+(0.5*linelength); ...
                 0             YMid+(1.5*linelength)  0            YMid+(0.5*linelength); ... % vert row 3
                 linelength    YMid+(1.5*linelength)  linelength   YMid+(0.5*linelength); ...
                 linelength*2  YMid+(1.5*linelength)  linelength*2 YMid+(0.5*linelength); ...
                 linelength*3  YMid+(1.5*linelength)  linelength*3 YMid+(0.5*linelength); ...
                 0             YMid+(1.5*linelength)  linelength   YMid+(1.5*linelength); ... % horiz row 4
                 linelength    YMid+(1.5*linelength)  linelength*2 YMid+(1.5*linelength); ...
                 linelength*2  YMid+(1.5*linelength)  linelength*3 YMid+(1.5*linelength)];   
coords(1,:,1) = coords(1,:,1) + XEighth;
coords(1,:,3) = coords(1,:,3) + XEighth;
coords(2,:,1) = coords(1,:,1) + (XRight-(XEighth*2)-boxwidth);
coords(2,:,2) = coords(1,:,2);
coords(2,:,3) = coords(1,:,3) + (XRight-(XEighth*2)-boxwidth);
coords(2,:,4) = coords(1,:,4);
demoset = [1,5,10;3,10,11;3,10,4];

%% DISPLAY INSTRUCTIONS
instructions = ['In this task, you will see 2 patterns on each screen.|One will be blue and one will be yellow.|'...
    'Your job is to judge whether the two patterns are the <b>same</b>.|' ...
    'Press the <b>D</b> key if, <b>yes</b>, the patterns <b>ARE</b> exactly the same.|'...
    'Press the <b>K</b> key if, <b>no</b>, the patterns are <b>NOT</b> exactly the same.|'...
    'We''ll show you some examples to get you started.'];
InstructionsScreen(win, fgcolor,bgcolor,instructions);

% demo SAME
Screen('FillRect', win, patternbg);
for i=1:3
   for j=1:2
      Screen('DrawLine', win, patterncolors(j,:), ...
          coords(j,demoset(1,i),1), coords(j,demoset(1,i),2), coords(j,demoset(1,i),3), coords(j,demoset(1,i),4),3);
   end
end 
WriteCentered(win, 'These ARE exactly the same, so press D for YES.', XMid, YMid+(textsize*3), democolor);
Screen('Flip', win, 0);
Wait4Key(respkeys(1));

% demo DIFFERENT
for i=1:3
   for j=1:2
      Screen('DrawLine', win, patterncolors(j,:), ...
          coords(j,demoset(j+1,i),1), coords(j,demoset(j+1,i),2), coords(j,demoset(j+1,i),3), coords(j,demoset(j+1,i),4),3);
   end
end 
WriteCentered(win, 'These are NOT the same, so press K for NO.', XMid, YMid+(textsize*3), democolor);
Screen('Flip', win, 0);
Wait4Key(respkeys(2));

instructions = ['Please keep your fingers on the D and K keys so you can respond quickly.|'...
    'There will be six groups of trials in this experiment.  After ' num2str(timelimit) ...
    ' seconds, the program will automatically advance to the next group of trials,'...
    ' even if you hadn''t responded to the final trial in the previous set yet.|'...
    'In each group of trials, the patterns will be more or less complex.|'...
    'We know that you might make some mistakes--everyone does!  But, please try to go as fast as you can while still being accurate.|'...
    'If you have any questions, please ask the experimenter now.'];
InstructionsScreen(win, fgcolor,bgcolor,instructions);

%% DO TEST
for blocknum=1:6
    
    % retrieve set size
    setsize = setsizes(blocknum);
    
    % display instructions
    Screen('FillRect', win, bgcolor);
    WriteCentered(win, ['In the next period, there will be ' num2str(setsize) ' lines in each pattern.'], XMid, YMid-textsize, fgcolor);
    Screen('Flip', win, 0, 1);
    WaitSecs(0.5);
    WriteCentered(win, 'Press a key to begin.', XMid, YMid+textsize, fgcolor);
    Screen('Flip', win, 0);
    getKeys;
    Screen('FillRect', win, patternbg);
           
    % create first item
    [set same] = PatternCreate(setsize);
    % draw it
    for i=1:setsize
        for j=1:2
          Screen('DrawLine', win, patterncolors(j,:), coords(j,set(j,i),1), coords(j,set(j,i),2), coords(j,set(j,i),3), coords(j,set(j,i),4),3);
        end
    end 
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
              fprintf(outfile, '%d,%d,%d,%s,%s,%d,%d,%d,%2.4f\n', subjno, blocknum, setsize, mat2str(set(1,:)), mat2str(set(2,:)), ...
                  same, -1, -1, RT);
            end
            % quit block
            break;
       end
       
       if keyCode(respkeys(3))
           % hit F10 to exit
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
           fprintf(outfile, '%d,%d,%d,%s,%s,%d,%d,%d,%2.4f\n', subjno, blocknum, setsize, mat2str(set(1,:)), ...
               mat2str(set(2,:)), same, mod(find(keyCode(respkeys)),2), keyCode(respkeys(1)) == same, RT);
       end
       
       % create next item
       [set same] = PatternCreate(setsize);
       % draw it
       for i=1:setsize
          for j=1:2
           Screen('DrawLine', win, patterncolors(j,:), coords(j,set(j,i),1), coords(j,set(j,i),2), coords(j,set(j,i),3), coords(j,set(j,i),4),3);
          end
       end 
       t2 = Screen('Flip', win);
        
       timeelapsed = t2-t1;
       
    end
    
end

%% WRAP-UP
Screen('FillRect', win, bgcolor);
WriteCentered(win, 'Congratulations, you have now finished this task!  Press a key.', XMid, YMid, fgcolor);
Screen('Flip', win);
getKeys;