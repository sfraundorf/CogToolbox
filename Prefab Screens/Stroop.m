% Stroop(window, fgcolor, bgcolor, subno, outputfolder)
%
% Performs a Stroop task with 2 components: reading colored words (easy)
% and naming the color of words (hard).  The task is displayed on window
% WINDOW with background color BGCOLOR and foreground color FGCOLOR.
% BGCOLOR and FGCOLOR only affect the instruction screens; the task itself
% always has a gray background for maximal visibility of the colors
%
% The participant's speech is recorded.  The dependent measure is the # of
% trials where the participant correctly, fluently responds.  Since this
% has to be coded (manually) from the audio, the function does not return
% anything in MATLAB.  It saves sound files.
%
% For a version that collects RT, see StroopRT
%
% Optional argument OUTPUTFOLDER specifies the folder to save the resulting
% sound files in.  Default is the current folder.
%
% Requires stroop1.txt and stroop2.txt, files with lists of stimuli
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
% Stroop.m manually
%
% 05.20.09 - S.Brown-Schmidt, A.Trude - initial version
% 01.30.10 - S.Fraundorf - cleaned up, converted to fxn
% 02.02.10 - S.Fraundorf - added practice screens
% 02.05.10 - S.Fraundorf - changed bkgnd to gray
% 02.08.10 - S.Fraundorf - optimized background drawing
% 02.15.10 - S.Fraundorf - changed bkgnd to black & changed blue color
% 06.21.11 - S.Fraundorf - changed default green color based on what looks
%                            best on our lab Macs
% 08.22.12 - S.Fraundorf - improved stimulus timing by getting the times
%                            directly from Screen('Flip').  allow more time
%                            to record the last response in each block

function Stroop(window, fgcolor, bgcolor, subno, outputfolder)

%% SETTINGS

trialduration=0.7; % 700 ms per trial
ColorWordSize = 72; % font size for the color words
textstyle = 1; % bold the color words
freq = 44100; % freq of sound recording

if nargin < 5
    outputfolder = ''; % default is to save in same folder
else
    outputfolder = makeValidPath(outputfolder);
end

%% DEFINE COLORS
white = [255 255 255];
%black = [0 0 0];
red=[255 0 0];
yellow=[255 255 0];
blue=[50 50 255];
green=[0 128 0];
purple=[200 0 255];
%brown=[156 102 31];
orange=[255 150 0];
%StroopBG = [128 128 128]; % gray
StroopBG = [0 0 0];

%% SCREEN PARAMETERS
rect = Screen('Rect', window);
YMid = rect(4) / 2;
XMid = rect(3)/ 2;

%% SET UP AUDIO RECORDING
InitializePsychSound;
pahandle = PsychPortAudio('Open', [], 2, [], freq, 1);

%% WORD NAMING - INSTRUCTIONS
instructions=['This task will involve recording sound.|'...
    'Please check with the experimenter to make sure this is ready.'];
InstructionsScreen(window, fgcolor, bgcolor, instructions);

instructions=['In this task, you will see a series of words.|'...
       'Read each word OUT LOUD, ignoring the color of the text.|'...
       'For example, you might see the following word:|'...
       'green|'...
       'In this case, you should say "GREEN" out loud.  That is what the WORD says (even though it is printed in blue).|'...
       'Remember to say the word OUT LOUD.|'...
       'We will start with a practice screen.  This one will go slowly to help you learn the task.'];
InstructionsScreen(window, fgcolor, bgcolor, instructions, {'green'}, blue);

% show demo word #1
oldfont = Screen('TextFont', window, 'Arial'); % change the font & save old
oldsize = Screen('TextSize', window, ColorWordSize);
oldstyle = Screen('TextStyle',window,textstyle);
Screen('FillRect', window, StroopBG);
WriteCentered(window, 'orange', XMid, YMid, red);
Screen('Flip', window, 0, 1); % keep word on the screen

% let them practice on this word
WaitSecs(3); % give them time to respond
% reset font and display feedback
Screen('TextFont', window, oldfont);
Screen('TextSize', window, oldsize);
Screen('TextStyle', window, oldstyle);
instructions=['Did you get it?  If you said "ORANGE," you were right.  That''s what the WORD spells out.  We''ll do one more practice screen.  Press a key to continue.'];
WriteCentered(window, instructions, XMid, YMid + (ColorWordSize*2), white);
Screen('Flip', window);
getKeys;

% show demo word #2
oldfont = Screen('TextFont', window, 'Arial'); % change the font & save old
oldsize = Screen('TextSize', window, ColorWordSize);
oldstyle = Screen('TextStyle',window,textstyle);
Screen('FillRect', window, StroopBG);
WriteCentered(window, 'purple', XMid, YMid, green);
Screen('Flip', window, 0, 1); % keep word on the screen

% let them practice on this word
WaitSecs(3); % give them time to respond
% reset font and display feedback
Screen('TextFont', window, oldfont);
Screen('TextSize', window, oldsize);
Screen('TextStyle', window, oldstyle);
instructions=['For this trial, you should have said "PURPLE."  Press a key to continue.'];
WriteCentered(window, instructions, XMid, YMid + (ColorWordSize*2), white);
Screen('Flip', window);
getKeys;

% reset bg
% reset font and display feedback
Screen('TextFont', window, oldfont);
Screen('TextSize', window, oldsize);
Screen('TextStyle', window, oldstyle);
% final instructions before test
instructions=['OK!  Did you get it?|'...
    'Now, we will do the actual task.|'...
    'This task will go much faster.   Each word will be on the screen for LESS THAN A SECOND, so please read them quickly!|'...
    'We know that this task will be challenging.  It''s those challenges that we are researching.  Just do the best you can.|'...
    'Get ready, because the task will start on the next screen.'];
InstructionsScreen(window, fgcolor, bgcolor, instructions, {'much', 'faster', 'LESS','THAN','A','SECOND','quickly'}, red);

%% WORD NAMING

% load the trials
fid = fopen('stroop1.txt');
listbuffer = textscan(fid,'%s%s', 'Delimiter', ',');%word,color
fclose(fid);

% set font
oldfont = Screen('TextFont', window, 'Arial'); % change the font & save old
oldsize = Screen('TextSize', window, ColorWordSize);
oldstyle = Screen('TextStyle',window,textstyle);

% start recording
PsychPortAudio('GetAudioData', pahandle, 30); % buffer 30 seconds
PsychPortAudio('Start', pahandle);

% do each trial
t1=GetSecs; % initialize time tracker
for trialnum=1:size(listbuffer{1})
    
    % retrieve the color and convert to RGB value
    wordcolor = eval(listbuffer{2}{trialnum});
    
    % display the word
    Screen('FillRect', window, StroopBG);
    WriteCentered(window, listbuffer{1}{trialnum}, XMid, YMid, wordcolor);
    t1 = Screen('Flip', window, t1+trialduration);

end
Screen('Flip', window, t1+trialduration); % clear the last screen
WaitSecs(4); % wait 4 s to allow S to finish the last trial

% end recording & save file
audiodata = PsychPortAudio('GetAudioData', pahandle);  % dump what's in the buffer
PsychPortAudio('Stop', pahandle);
filename = [outputfolder 'Stroop_WordReading_' num2str(subno) '.wav'];
wavwrite(audiodata, freq, filename);

%% COLOR NAMING - INSTRUCTIONS
% restore font size
Screen('TextFont', window, oldfont);
Screen('TextSize', window, oldsize);
Screen('TextStyle', window, oldstyle);

instructions=['Good work!  Here comes the second part of this task.|'...
       'Now, you should say the COLOR that the word is printed in, ignoring what the word says.  For example, when you see:|'...
       'green|'...
       'NOW, you should say "BLUE" out loud.  That is the COLOR of the word (regardless of what it spells out).|'...
       'Again, each word will be on the screen for under 1 second, so please work quickly.|'...
       'Remember to say the word OUT LOUD.  '...
       'We know that this task is challenging, but just do your best.|'...
       'The task will start on the next screen, so please get ready.'];
InstructionsScreen(window, fgcolor, bgcolor, instructions, {'green'}, blue);

%% COLOR NAMING
oldfont = Screen('TextFont', window, 'Arial'); % change the font & save old
oldsize = Screen('TextSize', window, ColorWordSize);
oldstyle = Screen('TextStyle',window,textstyle);

% load the trials
fid = fopen('stroop2.txt');
listbuffer = textscan(fid,'%s%s', 'Delimiter', ',');%word,color
fclose(fid);

% set up background
Screen('FillRect', window, StroopBG);

% start recording
PsychPortAudio('Start', pahandle);

% do each trial
t1 = GetSecs; % initialize time tracker
for trialnum=1:size(listbuffer{1})
    
    % retrieve the color and convert to RGB value
    wordcolor = eval(listbuffer{2}{trialnum});
    
    % display the word
    WriteCentered(window, listbuffer{1}{trialnum}, XMid, YMid, wordcolor);
    t1 = Screen('Flip', window, t1+trialduration);
   
end
Screen('Flip', window, t1+trialduration); % clear the last screen
WaitSecs(4); % wait 4 s to allow S to finish the last trial

% end recording & save file
audiodata = PsychPortAudio('GetAudioData', pahandle);  % dump what's in the buffer
PsychPortAudio('Stop', pahandle);
filename = [outputfolder 'Stroop_ColorNaming_' num2str(subno) '.wav'];
wavwrite(audiodata, freq, filename)

%% DONE
% restore font size
Screen('TextFont', window, oldfont);
Screen('TextSize', window, oldsize);
Screen('TextStyle',window, oldstyle);

% close audio port
PsychPortAudio('Close');

Screen('FillRect', window, bgcolor);
WriteCentered(window, 'Great!  You are all done with this task!', XMid, YMid, fgcolor);
Screen('Flip', window);
getKeys;