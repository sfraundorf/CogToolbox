% StroopRT(window, fgcolor, bgcolor, subno, outputfolder, saveRTs)
%
% Performs a Stroop task with 2 components: naming the color of color patches
% (easy) vs. naming the color of a incongruent color word (hard).  The task
% is displayed on window WINDOW with background color BGCOLOR and foreground
% color FGCOLOR.  BGCOLOR and FGCOLOR only affect the instruction screens;
% the task itself always has a gray background for maximal visibility of the colors
%
% The participant's speech is recorded.  The dependent measure is the RT to
% naming colors in the two conditions.  Returns a 2xN matrix (where N = the number of
% trials in each condition) of RTs.  Audio is also recorded and saved.
%
% For an automatically-paced Stroop task, see Stroop
%
% Optional argument OUTPUTFOLDER specifies the folder to save the resulting
% sound files in.  Default is the current folder.
%
% If optional argument SAVERTs is > 0 or not specified, the RTs will automatically
% be saved to a file named stroopRTx.csv in OUTPUTFOLDER, where x is the subject #.  If
% SAVERTs is 0, the RTs are only returned from the function and not saved
% to disk.
%
% Requires stroopRT.txt, a file with a list of stimuli
%
% CAUTION: The same RGB values can look very different on different
% monitors.  We recommend first running colordemo() on a new machine to
% make sure you have a good set of colors before you run any stroop tasks
% on it.  Things to look for when you choose colors:
%   1) The colors should be easily distinguished from each other...
%   2) The words must be readable on the background; otherwise, you cannot
%      get interference from the lexical items.
%   3) Avoid colors that might be ambiguous in terms of the lexical item to use.
%      Purple/pink distinctions are often difficult for subjects.
% Unfortunately, at present, the colors are hard-coded into the function,
% so if you want to change them, you will have to change the RGB values in
% StroopRT.m manually
%
% 06.15.09 - S.Brown-Schmidt, A.Trude - initial version
% 02.04.10 - S.Fraundorf - converted to function
% 02.05.10 - S.Fraundorf - changed bkgnd to gray
% 02.08.10 - S.Fraundorf - optimized background drawing
% 02.15.10 - S.Fraundorf - changed bkgnd to black & changed blue color
% 04.20.10 - S.Fraundorf - typo correction.
% 08.06.10 - S.Fraundorf - corrected getSecs to GetSecs, which allows for
%                            faster look-up
% 06.07.11 - S.Fraundorf - fix in reserving spaces for the RTs
% 06.21.11 - S.Fraundorf - changed default green color based on what looks
%                            best on our lab Macs
% 08.22.12 - S.Fraundorf - improved stimulus timing by getting the times
%                            directly from Screen('Flip').  changed the way
%                            we decide when to dump the audio buffer, which
%                            may prevent the last trial from getting cut
%                            off in the recording (as it often was in the
%                            past)

function rt = StroopRT(window, fgcolor, bgcolor, subno, outputfolder, saveRTs)

%% SETTINGS
ColorWordSize = 72; % font size for the color words
textstyle = 1; % bold the color words

freq = 44100; % freq of sound recording

if nargin < 6
    saveRTs = 1;
    if nargin < 5
       outputfolder = ''; % default is to save in same folder
    else
       outputfolder = makeValidPath(outputfolder);
    end
end

%% DEFINE COLORS
white = [255 255 255];
black = [0 0 0];
red=[255 0 0];
yellow=[255 255 0];
blue=[50 50 255];
green=[0 128 0];
purple=[200 0 255];
%brown=[156 102 31];
orange=[255 150 0];
StroopBG = [0 0 0 ]; % black

%% SCREEN PARAMETERS
rect = Screen('Rect', window);
oldsize = Screen('TextSize', window);
XRight = rect(3);
YBottom = rect(4);
XMid = XRight / 2;
YMid = YBottom / 2;

patchbox = [XRight * .35   YBottom * .35 ...
            XRight * .60   YBottom * .65];

%% LOAD THE TRIALS
% load the trials
fid = fopen('stroopRT.txt');
listbuffer = textscan(fid,'%s%s%s', 'Delimiter', '\t');%word,color,colorpatch
fclose(fid);

numtrials = numel(listbuffer{1});

%% SET UP MATRIX OF RTS
rt = zeros(numtrials,2);

%% SET UP AUDIO RECORDING
InitializePsychSound;
pahandle = PsychPortAudio('Open', [], 2, [], freq, 1);

%% PATCH NAMING - INSTRUCTIONS
instructions=['This task will involve recording sound.|'...
    'Please check with the experimenter to make sure this is ready.'];
InstructionsScreen(window, fgcolor, bgcolor, instructions);
instructions=['In this task, you will see a series of colored boxes, one at a time.|'...
       'For each box, say the color of the box out loud.  Then press a key on the keyboard to go on to the next box.|'...
       'For example, you might see a green box.  In that case, you should say "GREEN" out loud and then press a key.|'...
       'Please try to go as quickly as you can while still being accurate.|'...
       'Remember to say the word OUT LOUD.|'...
       'On the next screen, we will show you the box colors you may see.'];
InstructionsScreen(window, fgcolor, bgcolor, instructions);

colors = {'red','yellow','green','orange','blue','purple'};

TopRow = YBottom / 4;
LeftCol = XRight / 3;

Screen('FillRect', window, StroopBG);
i=1;
for row=[TopRow YMid]
    for col=[LeftCol XMid LeftCol*2]
        Screen('FillRect', window, eval(colors{i}), [col-50 row-50 col+50 row+50]);
        WriteCentered(window, colors{i}, col, row+75, eval(colors{i}));
        i=i+1;
    end
end
WriteCentered(window, 'These are the six colors you''ll see.', XMid, TopRow*3, white);
Screen('Flip',window,0,1);
WaitSecs(3);
WriteCentered(window, 'Press a key to continue.', XMid, (TopRow*3)+(oldsize*2), white);
Screen('Flip',window);
getKeys;
clear colors TopRow LeftCol;

instructions=['On the next screen, the task will start.  The task is a little bit long, so please be prepared.|'...
       'Remember, say the color of each box OUT LOUD as quickly as possible, and then press a key.|'...
       'Please try to go as fast as you can while still being accurate.'];
InstructionsScreen(window, fgcolor, bgcolor, instructions);

%% PATCH NAMING
% draw background
Screen('FillRect', window, StroopBG);

% start recording
PsychPortAudio('GetAudioData', pahandle, 60); % buffer 60 seconds
dumptime = PsychPortAudio('Start', pahandle);

% do each trial
audiodata = [];
for trialnum=1:numtrials
    
    % retrieve the color and convert to RGB value
    wordcolor = eval(listbuffer{3}{trialnum});
    
    % draw the box
    Screen('FillRect', window, wordcolor, patchbox);
    
    % show screen & start timing
    t1 = Screen('Flip', window, 0);
    [key t2] = getKeys;
    rt(trialnum,1) = t2-t1; % calculate RT
    
    % dump the buffer if needed
    if t2 > (dumptime + 45) % buffer holds 60 seconds but let's play it safe
        audiodata = [audiodata PsychPortAudio('GetAudioData', pahandle)]; % dump the buffer
        dumptime = GetSecs;
    end
           
end
Screen('Flip', window, 0); % clear the last screen

% end recording & save file
WaitSecs(2);
audiodata = [audiodata PsychPortAudio('GetAudioData', pahandle)];  % dump the last of the buffer
PsychPortAudio('Stop', pahandle); % stop recording
filename = [outputfolder 'StroopRT_Patch_' num2str(subno) '.wav'];
wavwrite(audiodata, freq, filename)

%% COLOR NAMING - INSTRUCTIONS
instructions=['Good work!  Now for the second part of this task.|'...
       'Now, you will see words instead of boxes.  But, you should keep saying the COLORS of the word, regardless of what the word says.|'...
       'For example, you might see the following word:|'...
       'green|'...
       'then, you should say "BLUE" out loud.  That is the COLOR of the word (regardless of what it spells out).|'...
       'After you say the name of the color OUT LOUD, press a key on the keyboard to go on to the next word.  Please try to go as quickly as you can while still being accurate.|'...
       'The task will start on the next screen.  It will be the same length as the last one.'];
InstructionsScreen(window, fgcolor, bgcolor, instructions, {'green'}, blue);

%% COLOR NAMING
oldfont = Screen('TextFont', window, 'Arial'); % change the font & save old
oldsize = Screen('TextSize', window, ColorWordSize);
oldstyle = Screen('TextStyle', window, textstyle);

% draw background
Screen('FillRect', window, StroopBG);

% start recording
dumptime = PsychPortAudio('Start', pahandle);

% do each trial
audiodata = [];
for trialnum=1:numtrials
    
    % retrieve the color and convert to RGB value
    wordcolor = eval(listbuffer{2}{trialnum});
    
    % display the word
    WriteCentered(window, listbuffer{1}{trialnum}, XMid, YMid, wordcolor);
   
    % start timing and show screen
    t1 = Screen('Flip', window, 0);
    [key t2] = getKeys;
    rt(trialnum,2) = t2-t1; % calculate RT
    
    % dump the buffer if needed
    if t2 > (dumptime + 45) % buffer holds 60 seconds but let's play it safe
        audiodata = [audiodata PsychPortAudio('GetAudioData', pahandle)]; % dump the buffer
        dumptime = GetSecs;
    end
        
end
Screen('Flip', window, 0); % clear the last screen

% end recording & save file
WaitSecs(2);
audiodata = [audiodata PsychPortAudio('GetAudioData', pahandle)];  % dump the last of the buffer
PsychPortAudio('Stop', pahandle); % stop recording
filename = [outputfolder 'StroopRT_Color_' num2str(subno) '.wav'];
wavwrite(audiodata, freq, filename)

%% SAVE RT DATA
if saveRTs % save RTs to a file
    outfile = fopen([outputfolder 'StroopRT_' num2str(subno) '.csv'], 'w');
    % print header row
    fprintf(outfile, 'WORD NAME,WORD COLOR,PATCH COLOR,WORD_RT,PATCH_RT\n');
    for trialnum=1:numtrials
        fprintf(outfile,'%s,%s,%s,%2.4f,%2.4f\n', ...
            listbuffer{1}{trialnum}, listbuffer{2}{trialnum}, listbuffer{3}{trialnum}, ...
            rt(trialnum,2), rt(trialnum,1));        
    end
    fclose(outfile);
end

%% WRAP-UP
% restore font size
Screen('TextFont', window, oldfont);
Screen('TextSize', window, oldsize);
Screen('TextStyle', window, oldstyle);

% close audio port
PsychPortAudio('Close');

Screen('FillRect', window, bgcolor);
WriteCentered(window, 'Great!  You are all done with this task!', XMid, YMid, fgcolor);
Screen('Flip', window);
getKeys;