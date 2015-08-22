% [meanRTs medianRTs] = flanker(win, datafolder, subjno, diagsize, dist_to_screen, trialspertype, includeneutral)
%
% Presents a flanker task on window WIN.  The results are saved in
% folder DATAFOLDER with a file identified by participant ID number SUBJNO.
%
% DIAGSIZE specifies the diagonal size of the monitor (upper-left to
% lower-right).  DIST_TO_SCREEN is the distance from the participant's eye
% to the center of the screen.  These parameters may be in any unit of
% measurements as long as the units are the SAME.  These parameters are
% used to control the stimulus 
%
% On each trial, the participant is to indicate the direction of the arrow
% in the middle by pressing either the F key (left) or the J key (right).
%
% The central arrow has 2 flankers on each side.  The flankers are either 
% congruent with the arrow (e.g. <<<<<), incongruent (>><>>), or neutral
% (||<||).  The neutral trials can be removed by setting parameter
% includeneutral to 0 (default is 1, on).
%
% Returns MEANRT and, optionally, MEDIANRT in each of the conditions in
% the order congruent, incongruent, neutral.
%
% TRIALSPERTYPE specifies the number of trials to do for each combination
% of flanker condition x target direction.  With the neutral trials, there
% are 6 such combinations 3 x 2) design, the total number of trials will be
% 6 * TRIALSPERTYPE.  If the neutral trials are excluded, there are 
% 4 * TRIALSTYPE (2 x 2) trials.
%
% The task first presents 6 practice trials with audio feedback on
% participants' accuracy.
%
% 06.09.11 - S.Fraundorf - first version
% 06.13.11 - S.Fraundorf - return RTs
% 06.20.11 - S.Fraundorf - parameter controls whether to include NEUTRAL
%                          condition or not.  added subject # column in
%                          output.  clarified instructions to participant
% 07.20.11 - S.Fraundorf - updated instructions: if not doing the neutral
%                           trials, "all" rather than "most" instructions
%                           have the flankers.  instructions are now
%                           properly Gricean.
% 08.29.11 - S.Fraundorf - corrected bug in instructions when you DO
%                           include the neutral trials
% 08.22.12 - S.Fraundorf - improved stimulus timing by getting the times
%                            directly from Screen('Flip')

function [meanRTs medianRTs] = flanker(win, datafolder, subjno, diagsize, dist_to_screen, trialspertype, includeneutral)

%% SETTINGS

if nargin < 7
    % default is to incude neutral
    includeneutral = 1;
end

% Target characters
targets = '<>';

% Names of conditions
condnames = {'Neut' 'Cong' 'Incong'};
if includeneutral
    numconditions = 3;
else
    numconditions = 2;
end

% Response keys:
KbName('UnifyKeyNames');
ResponseKeys = [KbName('F') KbName('J')];

% Timing (all in s):
ISI = .400; % Time between trials
fixtime = .400; % Fixation display time
maxtrialtime = 1.7; % Max time to respond

% Visual display properties:
bgcolor = [0 0 0]; % black
fixationsignal = '+';
fixationcolor = [0 255 255]; % cyan
targetcolor = [255 255 255]; % white.  applies to cue, target, mask
TextSize = 48; % text size for targets
textangle = 2; % size of the cue/target in VISUAL ANGLE

% Trials counts
numtypes = numconditions * 2;
practicepertype = 1;
numpractice = practicepertype * numtypes;
totaltrials = (trialspertype*numtypes) + numpractice;

% Sound properties:
freq = 44100;
feedbackduration = .5; % in s
feedbackHz = 175;

%% GET & SET SCREEN PROPERTIES
rect = Screen('Rect', win);

% calculate center:
XMid = floor(rect(3)/2);
YMid = floor(rect(4)/2);
TargLine = YMid-TextSize; % line where target is -- one above middle

% text size:
monitorrect = monitorsize(diagsize, win, 'win');
TextSize = ceil(visangle2pixels(textangle, rect(3), monitorrect(3), dist_to_screen));
InstructionsSize = 32;
monofont = get(0,'FixedWidthFontName');
InstructionsFont = 'Arial';

oldSize = Screen('TextSize', win, InstructionsSize);
oldFont = Screen('TextFont', win, InstructionsFont);

%% SET UP AUDIO
audiochannel = PsychPortAudio('Open', [], 1, [], freq, 1);
feedbacksound = MakeBeep(feedbackHz,feedbackduration);
PsychPortAudio('FillBuffer', audiochannel, feedbacksound);

%% OPEN UP OUTPUT FILE
datafolder = makeValidPath(datafolder);
outfile=fopen([datafolder 'flanker' num2str(subjno) '.csv'], 'w');
fprintf(outfile,'BLOCK,SUBJNO,TRIALNO,TARGETDIR,TRIALTYPE,RT,RESPONSE,ACCURACY\n');

%% SET UP LIST OF TRIALS, INITIALIZE TRIAL COUNTER

% target directions
targlist = [repelem([1 2], practicepertype*numconditions) ... 
           repelem([1 2], trialspertype*numconditions)]; % practice, critical

% flanker types
if includeneutral
   conditionlist = [ repmat([1 2 3], 1, practicepertype*2) ...
                     repmat([1 2 3], 1, trialspertype*2)];
else
    conditionlist = [ repmat([2 3], 1, practicepertype*2) ...
                      repmat([2 3], 1, trialspertype*2)];
end

% trial ordering ... practice trials always come first:
trialorder = [randperm(numpractice) (randperm(totaltrials-numpractice)+numpractice)];

% initialize trial number and RTs:
trialnum = 1;
RTs = zeros(totaltrials,1);
% initialize time counters:
t1 = 0;
t2 = 0;

%% INTRO INSTRUCTIONS
% (1) overview
Screen('FillRect', win, bgcolor);
blurb = ['In this task, your goal is to identify whether an arrow at the center of the screen ' ...
    'is pointing to the right or to the left.|'...
    'On each trial, a + sign will appear on the screen for a short time.  Then, the arrow will appear.|' ...
    'Press the <b>F</b> key if the arrow is pointing <b>left</b>, and the <b>J</b> key if the arrow is pointing <b>right</b>.'];
InstructionsScreen(win, targetcolor, bgcolor, blurb);

% (2) fake trial 1
Screen('TextSize', win, TextSize);
Screen('TextFont', win, monofont);
Screen('FillRect', win, bgcolor);
WriteCentered(win, fixationsignal, XMid, YMid, fixationcolor);
Screen('Flip', win);
WaitSecs(fixtime);
Screen('FillRect', win, bgcolor);
WriteCentered(win, '<', XMid, TargLine, targetcolor);
Screen('TextSize', win, InstructionsSize);
Screen('TextFont', win, InstructionsFont);
WriteCentered(win, 'This arrow is pointing left, so press F.', XMid, YMid, targetcolor);
Screen('Flip', win);
Wait4Key(ResponseKeys(1));

% (3) fake trial 2
Screen('TextSize', win, TextSize);
Screen('TextFont', win, monofont);
Screen('FillRect', win, bgcolor);
WriteCentered(win, fixationsignal, XMid, YMid, fixationcolor);
Screen('Flip', win);
WaitSecs(fixtime);
Screen('FillRect', win, bgcolor);
WriteCentered(win, '>', XMid, TargLine, targetcolor);
Screen('TextSize', win, InstructionsSize);
Screen('TextFont', win, InstructionsFont);
WriteCentered(win, 'This arrow is pointing right, so press J.', XMid, YMid, targetcolor);
Screen('Flip', win);
Wait4Key(ResponseKeys(2));

% (4) description of flankers.
Screen('TextSize', win, InstructionsSize);
Screen('TextFont', win, InstructionsFont);
if includeneutral
    blurb = ['OK so far?  To make things a little trickier, on most trials, we are going to show five arrows on each screen.|'...
    'For example: < < > < <|'...
    'You should only respond to the direction of the <b>MIDDLE</b> arrow.  (In this case, the middle arrow is pointing RIGHT.)|' ...
    'On some trials, instead of 5 arrows, you will see 1 arrow and some vertical lines.  '...
        'Again, just respond to the direction of the ARROW.|'];
else
    blurb = ['OK so far?  To make things a little trickier, we are going to show five arrows on each screen.|'...
    'For example: < < > < <|'...
    'You should only respond to the direction of the <b>MIDDLE</b> arrow.  (In this case, the middle arrow is pointing RIGHT.)|'];
end
blurb = [blurb 'We will show you some examples next.'];
InstructionsScreen(win, targetcolor, bgcolor, blurb);

% (5) fake flanker trial 1
Screen('TextSize', win, TextSize);
Screen('TextFont', win, monofont);
Screen('FillRect', win, bgcolor);
WriteCentered(win, fixationsignal, XMid, YMid, fixationcolor);
Screen('Flip', win);
WaitSecs(fixtime);
Screen('FillRect', win, bgcolor);
WriteCentered(win, '>><>>', XMid, TargLine, targetcolor);
Screen('Flip', win);
Wait4Key(ResponseKeys(1));

% (6) fake flanker trial 2  
Screen('FillRect', win, bgcolor);
WriteCentered(win, fixationsignal, XMid, YMid, fixationcolor);
Screen('Flip', win);
WaitSecs(fixtime);
Screen('FillRect', win, bgcolor);
if includeneutral
   WriteCentered(win, '||>||', XMid, TargLine, targetcolor);
else
    WriteCentered(win, '<<><<', XMid, TargLine, targetcolor);
end
Screen('Flip', win);
Wait4Key(ResponseKeys(2));

% (5) respond quickly
Screen('TextSize', win, InstructionsSize);
Screen('TextFont', win, InstructionsFont);
blurb = ['Got it?  Try to respond as quickly as you can while still being accurate.|' ...
    'Please keep your fingers on the F and J keys so you can respond quickly.|'... 
    'If you are too slow, the computer will go on to the next trial automatically.|' ...
    'We will start off with some practice trials so you can get the hang of it.|' ...
    'During this practice phase, the computer will make a sound if your response was incorrect.'];
InstructionsScreen(win, targetcolor, bgcolor, blurb);

%% ACTUAL TASK

Screen('TextSize', win, TextSize);
Screen('TextFont', win, monofont);

for trial=trialorder   
    
   % generate target
   switch conditionlist(trial)
       case 1
           % NEUTRAL
           target = ['||' targets(targlist(trial)) '||'];
       case 2
           % CONGRUENT
           target = repmat(targets(targlist(trial)), 1, 5);
       case 3
           % INCONGRUENT
           target = [repmat(targets(mod(targlist(trial),2)+1), 1, 2) ...
               targets(targlist(trial)) repmat(targets(mod(targlist(trial),2)+1), 1, 2)];
   end

   % (0) ISI
   Screen('FillRect', win, bgcolor);
   t1 = Screen('Flip', win);

   % (1) Display fixation signal
   Screen('FillRect', win, bgcolor);
   WriteCentered(win, fixationsignal, XMid, YMid, fixationcolor);
   t1 = Screen('Flip', win, t1+ISI);

   % (2) Show target and get response
   Screen('FillRect', win, bgcolor);
   WriteCentered(win, target, XMid, TargLine, targetcolor);
   t1 = Screen('Flip', win, t1+fixtime);
   [t2 response] = Wait4KeyTimed(maxtrialtime, ResponseKeys);

   % (3) Process response:
   if isempty(response) % no key pressed in time (too slow!)
       respletter = 'x';
       accuracy = 0;
   else
      response = find(response==1);
      if numel(response) > 1 % more than key pressed
         respletter = 'b';
         accuracy = 0;
      else
         % 1 of 2 response keys pressed
         targetchosen = find(ResponseKeys == response);
         respletter = targets(targetchosen);
         accuracy = (targetchosen == targlist(trial));
      end
   end
         
   % (4) Save trial data:
   %fprintf(outfile,'BLOCK,SUBJNO,TRIALNO,TARGETDIR,TRIALTYPE,RT,RESPONSE,ACCURACY%\n');
   if trialnum <= numpractice
       fprintf(outfile, 'Prac');
   else
       fprintf(outfile, 'Crit');       
   end
   RTs(trial) = t2-t1;
   fprintf(outfile, ',%d,%d,%s,%s', subjno, trialnum, targets(targlist(trial)), condnames{conditionlist(trial)});
   fprintf(outfile, ',%2.4f,%s,%d\n', RTs(trial), respletter, accuracy);
         
   % (5) Practice phase has feedback
   if ~accuracy && trialnum <= numpractice
       PsychPortAudio('Start',audiochannel,1);
       PsychPortAudio('Stop',audiochannel,1);
   end
   
   % (5) End practice block, if needed   
   if trialnum == numpractice
       Screen('TextSize', win, InstructionsSize);
       Screen('TextFont', win, InstructionsFont);
       
       blurb = ['Did you get the hang of it?|' ...
           'Please ask the experimenter if you have any questions.|'...
           'For the real trials, the computer will not beep if you make a mistake.  But, please try to '...
           'go as quickly as you can while still being accurate.|'...
           'Remember to keep your fingers on the F and J keys so you can respond quickly.|' ...
           'We will start the real trials on the next screen.'];
       InstructionsScreen(win, targetcolor, bgcolor, blurb);      
       
       Screen('TextSize', win, TextSize);
       Screen('TextFont', win, monofont);
   end
   
   % (6) Advance trial counter
   trialnum = trialnum + 1;
end % next trial


%% WRAP-UP

% close output file
fclose(outfile);

% create summary measures
meanRTs = [mean(RTs(conditionlist(numpractice+1:totaltrials)==2)) ...
             mean(RTs(conditionlist(numpractice+1:totaltrials)==3))];
if includeneutral
    meanRTs = [meanRTs mean(RTs(conditionlist(numpractice+1:totaltrials)==1))];
end
% also get MEDIANS if requested
if nargout==2
      medianRTs = [median(RTs(conditionlist(numpractice+1:totaltrials)==2)) ...
                   median(RTs(conditionlist(numpractice+1:totaltrials)==3))];
      if includeneutral
          meanRTs = [medianRTs median(RTs(conditionlist(numpractice+1:totaltrials)==1))];
      end
end

   
% shut down audio
PsychPortAudio('Close', audiochannel);

% display closing message
Screen('TextSize', win, InstructionsSize);
Screen('TextFont', win, InstructionsFont);
WriteCentered(win, 'Congratulations!  You have now finished this task.  Press a key.', XMid, YMid, targetcolor);
Screen('Flip', win);
getKeys;

% reset text properties
Screen('TextFont', win, oldFont);
Screen('TextSize', win, oldSize);