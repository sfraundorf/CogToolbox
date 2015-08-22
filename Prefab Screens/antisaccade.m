% [medianRT propAcc] = antisaccade(win, datafolder, subjno, diagsize, dist_to_screen, repetitions, feedback_during_crit)
%
% Presents an anti-saccade task on window WIN.  The results are saved in
% folder DATAFOLDER with a file identified by participant ID number SUBJNO.
% Optionally, the function also returns the median RT and proportion
% accurate responses (excluding practice trials).
%
% DIAGSIZE specifies the diagonal size of the monitor (upper-left to
% lower-right).  DIST_TO_SCREEN is the distance from the participant's eye
% to the center of the screen.  These parameters may be in any unit of
% measurements as long as the units are the SAME.  These parameters are
% used to control the stimulus 
%
% The task is based on Kane, Bleckley, Conway, and Engle (2001).  A
% flashing cue is displayed to either the left or right of fixation.  Then,
% a target letter is briefly displayed (100 ms) on the OPPOSITE side of the
% screen, followed by a forward mask.  Participants' task is to report the
% letter that appeared.  Accuracy and RTs are recorded.
%
% The target is either the letter B, P, or R, which participants indicate
% by pressing the keys 1, 2, or 3, respectively.
%
% The task first presents instructions followed by two practice blocks in
% which targets are presented in the center, so that participants can learn
% the mapping between the targets and response keys.  Finally, there is one
% more practice block where participants practice the antisaccade task.
%
% The actual task then consists of 36 trials repeated REPETITIONS number of
% trials (default is 2).
%
% During practice trials, the computer plays audio feedback if the
% participant makes an error.  During the critical block, parameter
% FEEDBACK_DURING_CRIT controls this behavior.  Default is FALSE (off).
%
% 06.07.11 - S.Fraundorf - first version
% 06.20.11 - S.Fraundorf - Fixed a bug where the DVs would be returned
%                             incorrectly if >1 repetition
%                          Reduced # of response mapping blocks to 1.
%                          Added feedback_during_crit parameter and
%                            defaulted this to off.
%                          Added column in results for subject #
% 06.28.11 - S.Fraundorf - Fixed a bug where the audio feedback was not
%                            being correctly controlled
% 08.22.12 - S.Fraundorf - improved stimulus timing by getting the times
%                            directly from Screen('Flip')

function [medianRT propAcc] = antisaccade(win, datafolder, subjno, ...
    diagsize, dist_to_screen, repetitions, feedback_during_crit)

%% SETTINGS

% Trial types:
targets = 'BPR';
fixationdurations = [.200 .600 1.000 1.400 1.800 2.200];
numtrialtypes = length(targets) * length(fixationdurations) * 2; % * 2 for left and right

% Number of times to do each trial type in the critical block:
if nargin < 7
    feedback_during_crit = false;
    if nargin < 6
       repetitions = 2;
    end
end

% Practice block settins:
mappingblocks = 1;
mappingtrials = length(targets) * length(fixationdurations); % # per block
practiceblocks = 1;
practicetrials = numtrialtypes/2; % # per block

% Response keys:
KbName('UnifyKeyNames');
NewTrialKey = KbName('space');
ResponseKeys = [KbName('1!') KbName('2@') KbName('3#')];

% Backward masks:
initialmask = 'H';
responsemask = '8';

% Timing (all in s):
ISI = .400; % Time between trials
cueontime = .100; % Time cue is ON
cueofftime = .050; % Time cue is OFF
targetduration = .100; % Duration of target
maskduration = .050; % Duration of first forward mask

% Visual display properties:
bgcolor = [0 0 0]; % black
readysignal = 'PRESS SPACE TO START.'; % 'READY?';
readycolor = [255 255 0]; % yellow
fixationsignal = '***';
fixationcolor = [0 255 255]; % cyan
cue = '=';
cueflashes = 2; % cue flashes twice
targetcolor = [255 255 255]; % white.  applies to cue, target, mask
TextSize = 48; % text size for targets
displaceangle = 11.33; % displacement of the cue/target in VISUAL ANGLE 
textangle = 2; % size of the cue/target in VISUAL ANGLE

% Sound properties:
freq = 44100;
feedbackduration = .5; % in s
feedbackHz = 175;

%% GET & SET SCREEN PROPERTIES
rect = Screen('Rect', win);

% calculate center:
XMid = floor(rect(3)/2);
YMid = floor(rect(4)/2);
CueLine = YMid+TextSize; % line where cue is -- one row below middle

% target displacement:
monitorrect = monitorsize(diagsize, win, 'win');
displacement = visangle2pixels(displaceangle, rect(3), monitorrect(3), dist_to_screen);
% kludge: displacement = floor(rect(3)/3);

% text size:
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
outfile=fopen([datafolder 'antisaccade' num2str(subjno) '.csv'], 'w');
fprintf(outfile,'SUBJNO,BLOCK,TRIALNO,TRIALINBLOCK,REPETITION,TARGET,CUEDUR,LOCATION,RT,RESPONSE,ACCURACY\n');

%% SET UP LIST OF BLOCKS, INITIALIZE TRIAL COUNTER
blocklist = {};
for i=1:mappingblocks
    blocklist = [blocklist ['Mapping' num2str(i)]];
end
for i=1:practiceblocks
    blocklist = [blocklist ['Practice' num2str(i)]];
end
blocklist = [blocklist 'Critical'];

% initialize trial number:
trialnum = 1;

%% INTRO INSTRUCTIONS
% (1)
Screen('FillRect', win, bgcolor);
blurb = ['In this task, you will try to identify letters that flash quickly on the screen.|' ...
    'On each trial, one letter will appear, and that letter will always be B, P, or R.|' ...
    'It is your job to figure out which of the 3 letters was shown.'];
WriteLine(win, blurb, targetcolor, 30, 30, 30);
Screen('TextSize', win, TextSize);
Screen('TextFont', win, monofont);
WriteCentered(win, [targets(1) ' ' targets(2) ' ' targets(3)], XMid, YMid, targetcolor);
Screen('Flip', win, [], 1);
WaitSecs(6);
Screen('TextSize', win, InstructionsSize);
Screen('TextFont', win, InstructionsFont);
WriteLine(win, 'Press a key to continue.', targetcolor, 30, 30, YMid+(TextSize*2));
Screen('Flip', win);
getKeys;

% (2) description of trial sequence
blurb = ['Each trial will start off with a set of stars (' fixationsignal ').|After a period of ' ...
    'time, the stars will disappear, and the target letter (B, P, or R) will flash at the center of the screen.|' ...
    'After we flash the target letter, we will cover it up with an ' initialmask ' followed by the number ' responsemask '.|'...
    'Pay close attention so you can tell whether the target letter is B, P, or R.|'...
    'On the next screen, we will show you a sample trial.'];
InstructionsScreen(win, targetcolor, bgcolor, blurb);

% (3) fake trials
targetlist = 'RB';
durationlist = [fixationdurations(5) fixationdurations(3)];
for trial=1:2
    Screen('TextSize', win, TextSize);
    Screen('TextFont', win, monofont);

   % fixation
   WriteCentered(win, fixationsignal, XMid, YMid, fixationcolor);
   t1 = Screen('Flip', win);
   
   % (4) Show target
   Screen('FillRect', win, bgcolor);
   WriteCentered(win, targetlist(trial), XMid, YMid, targetcolor);
   % location is either +1 or -1, so we are either moving to the right or
   % the left by the same amount
   t1 = Screen('Flip', win, t1+durationlist(trial));

   % (5) Show first mask
   Screen('FillRect', win, bgcolor);
   WriteCentered(win, initialmask, XMid, YMid, targetcolor);
   t1 = Screen('Flip', win, t1+targetduration);

   % (6) Wait for response
   Screen('FillRect', win, bgcolor);
   WriteCentered(win, responsemask, XMid, YMid, targetcolor);
   Screen('Flip', win, t1+maskduration);
   WaitSecs(2);
   
   Screen('TextSize', win, InstructionsSize);
   Screen('TextFont', win, InstructionsFont);
   if trial==1
       blurb = ['Did you get it?  That time, the letter was ' targetlist(1) '.|Let''s try one more.'];
   else
       blurb = ['That time, the letter was ' targetlist(2) '.  Did you catch it?'];
   end
   InstructionsScreen(win, targetcolor, bgcolor, blurb);
end

% (4) response instructions
blurb = ['When the ' responsemask ' comes up, you will use the keyboard to indicate which letter you think you saw.|'...
    'Press <b>1</b> if you think you saw <b>' targets(1) '</b>.|'...
    'Press <b>2</b> if you think you saw <b>' targets(2) '</b>.|'...
    'Press <b>3</b> if you think you saw <b>' targets(3) '</b>.|'...
    'You should keep your fingers on those keys so that you can respond as quickly as possible.'];
InstructionsScreen(win, targetcolor, bgcolor, blurb);

% (5) respond quickly
blurb = ['Please try to respond as quickly as you can while still being accurate.|' ...
    'If you are not sure, just make your best guess.|'...
    'If you guess incorrectly, the computer will make a sound to let you know that guess was incorrect.|'...
    'Again, please keep your fingers on the 1, 2, and 3 keys so that you can respond quickly.|' ...
    'We will start off with some practice trials so that you can get the hang of it.'];
InstructionsScreen(win, targetcolor, bgcolor, blurb);

%% CYCLE THROUGH BLOCKS / SET UP TRIALS FOR THIS BLOCK
for blocknum=1:numel(blocklist)
    
    if strfind(blocklist{blocknum}, 'Mapping')
        % Response Mapping blocks
        usecue=false;
        targetlist = repmat(targets, 1, numel(fixationdurations));
        durationlist = repelem(fixationdurations, 3);
        locationlist = zeros(1,mappingtrials); % 0 = in the CENTER
        repno = ones(1,mappingtrials);
        trialordering = randperm(mappingtrials);        
        
    elseif strfind(blocklist{blocknum}, 'Practice')
        % Practice block
        usecue = true;        
        targetlist = repmat(targets, 1, numel(fixationdurations));
        durationlist = repelem(fixationdurations, 3);
        locationlist = repelem([1 -1 1 -1], ceil(numel(targets)*numel(fixationdurations)*.25)); % kludge
        repno = ones(1,practicetrials);
        trialordering = randperm(practicetrials);
        
    else
        % Critical block
        usecue = true;
        
        % create all trial types:
        targetlist = repmat(targets, 1, numel(fixationdurations)* 2); % * 2 because two locations
        durationlist = repmat(repelem(fixationdurations,3),1,2);
        locationlist = repelem([1 -1], numel(targets)*numel(fixationdurations));
        
        trialsperrep = numel(targets)*numel(fixationdurations)*2;
        trialordering = randperm(trialsperrep);

        % duplicate by number of repetitons:
        targetlist = repmat(targetlist, 1, repetitions);
        durationlist = repmat(durationlist, 1, repetitions);
        locationlist = repmat(locationlist, 1, repetitions);
        trialordering = repmat(trialordering, 1, repetitions);
        repno = repelem(1:repetitions, trialsperrep);
        
    end
    
    % reserve space for accuracy & RTs
    accuracy = zeros(1,numel(trialordering));
    RT = zeros(1,numel(trialordering));
    
%% INSTRUCTIONS FOR THIS BLOCK

Screen('TextSize', win, InstructionsSize);
Screen('TextFont', win, InstructionsFont);
soundfeedback = true;

if strcmp(blocklist{blocknum}, 'Mapping1')
    % nothing, instructions for this are above   
elseif strcmp(blocklist{blocknum}, 'Practice1')
    % describe antisaccade task
    blurb = ['In the next part of this experiment, you are still going to be identifying the flashing letters.|'...
        'The letters will still be ' targets(1) ',  ' targets(2) ' and ' targets(3) '.|' ...
        'But, they will now appear on one side of the screen or the other, instead of in the center.|' ...
        'We will show you an example on the next screen.'];
    InstructionsScreen(win, targetcolor, bgcolor, blurb);
    
    blurb = 'Sometimes the letter will be on the left.';
    WriteLine(win, blurb, targetcolor, 30, 30, 30);
    Screen('TextSize', win, TextSize);
    Screen('TextFont', win, monofont);
    WriteCentered(win, targets(1), XMid+(displacement*-1), YMid, targetcolor);        
    Screen('Flip', win, 0, 1);
    WaitSecs(1);
    Screen('TextSize', win, InstructionsSize);
    Screen('TextFont', win, InstructionsFont);    
    WriteLine(win, 'Press a key to continue.', targetcolor, 30, 30, YMid+(TextSize*2));
    Screen('Flip', win, 0);
    getKeys;
    
    blurb = 'Other times, the letter will be on the right.';
    WriteLine(win, blurb, targetcolor, 30, 30, 30);
    Screen('TextSize', win, TextSize);
    Screen('TextFont', win, monofont);
    WriteCentered(win, targets(2), XMid+(displacement*1), YMid, targetcolor);        
    Screen('Flip', win, 0, 1);
    WaitSecs(1);
    Screen('TextSize', win, InstructionsSize);
    Screen('TextFont', win, InstructionsFont);    
    WriteLine(win, 'Press a key to continue.', targetcolor, 30, 30, YMid+(TextSize*2));
    Screen('Flip', win, 0);    
    getKeys;
    
    blurb = ['Before each letter appears, you will first see a flashing cue on the OPPOSITE side of the screen.|' ...
       'If the cue flashes on the <b>LEFT</b>, the target letter will appear on the <b>RIGHT</b>.|' ...
       'If the cue flashes on the <b>RIGHT</b>, the target letter will appear on the <b>LEFT</b>.|' ...
       'You will need to look in the <b>OPPOSITE</b> direction from the flashing cue.|' ...
       'We will do a few practice trials with this new version of the task.'];
   InstructionsScreen(win, targetcolor, bgcolor, blurb);
    
elseif strcmp(blocklist{blocknum}, 'Critical')
    blurb = ['OK so far?|Now we are going to more of what you just did, except that there will be more trials in a row.|'...
        'For this set of trials, the computer will not provide any feedback if you get a trial wrong.|'...
        'But, please try to do the best you can.|' ...
        'Please ask the experimenter if you have any questions.'];
    InstructionsScreen(win, targetcolor, bgcolor, blurb);
    soundfeedback = feedback_during_crit;
else
    % generic, e.g. mapping or practice block after the first
    blurb = 'OK so far?  Please ask the experimenter if you have any questions.|Otherwise, press a key to continue to the next set of trials.';
    InstructionsScreen(win, targetcolor, bgcolor, blurb);
end

%% BLOCK START
trialinblock = 1;

% change to trial text
Screen('TextSize', win, TextSize);
Screen('TextFont', win, monofont);

% Display ready signal and wait for keypress
Screen('FillRect', win, bgcolor);
WriteCentered(win, readysignal, XMid, YMid, readycolor);
Screen('Flip', win, 0);
Wait4Key(NewTrialKey);

%% ACTUAL TASK

for trial=trialordering

   % (0) ISI
   Screen('FillRect', win, bgcolor);
   t1 = Screen('Flip', win, 0);   

   % (1) Display fixation signal
   WriteCentered(win, fixationsignal, XMid, YMid, fixationcolor);
   Screen('Flip', win, t1+ISI);
   % wait:
   WaitSecs(durationlist(trial));

   if usecue
     % (2) Flash cue
     for i=1:cueflashes
      % cue OFF:
      Screen('FillRect', win, bgcolor);
      t1 = Screen('Flip', win, 0);
      % cue ON:
      Screen('FillRect', win, bgcolor);
      WriteCentered(win, cue, XMid+(-1*displacement*locationlist(trial)), CueLine, targetcolor);
      % this is ANTISACCADE, so cue is displaced in the OPPOSITE direction
      % of where the actual target will be
      Screen('Flip', win, t1+cueofftime);
      WaitSecs(cueontime);
     end
   end
   
   % (3) Hide cue one more time
   Screen('FillRect', win, bgcolor);
   t1 = Screen('Flip', win, 0);

   % (4) Show target
   Screen('FillRect', win, bgcolor);
   WriteCentered(win, targetlist(trial), XMid+(displacement*locationlist(trial)), YMid, targetcolor);
   % location is either +1 or -1, so we are either moving to the right or
   % the left by the same amount
   t1 = Screen('Flip', win, t1+cueofftime);

   % (5) Show first mask
   Screen('FillRect', win, bgcolor);
   WriteCentered(win, initialmask, XMid+(displacement*locationlist(trial)), YMid, targetcolor);
   t1 = Screen('Flip', win, t1+targetduration);

   % (6) Wait for response
   Screen('FillRect', win, bgcolor);
   WriteCentered(win, responsemask, XMid+(displacement*locationlist(trial)), YMid, targetcolor);
   t1 = Screen('Flip', win, t1+maskduration);
   [t2 response] = Wait4Key(ResponseKeys);

   % (7) Process response:
   RT(trialinblock) = t2-t1;
   response = find(response==1);
   if numel(response) > 1 % more than key pressed
      respletter = 'x';
      accuracy(trialinblock) = 0;
   else
      response = KbName(response);
      respletter = targets(str2double(response(1)));
      accuracy(trialinblock) = (respletter == targetlist(trial));
   end
   
   % (8) Feedback for incorrect responses
   if ~accuracy(trialinblock) && soundfeedback
       PsychPortAudio('Start',audiochannel,1);
       PsychPortAudio('Stop',audiochannel,1);
   end
      
   % (9) Save trial data:
   %fprintf(outfile, 'SUBJNO,BLOCK,TRIALNO,TRIALINBLOCK,REPETITION,TARGET,FIXDUR,LOCATION,RT,RESPONSE,ACCURACY\n');
   fprintf(outfile, '%d,%s,%d,%d,%d,', subjno, blocklist{blocknum}, trialnum, trialinblock, repno(trial));
   fprintf(outfile, '%s,%1.2f,%d,', targetlist(trial), durationlist(trial), locationlist(trial));
   fprintf(outfile, '%2.4f,%s,%d\n', RT(trialinblock), respletter, accuracy(trialinblock));
   
   trialnum = trialnum + 1;
   trialinblock = trialinblock + 1;
end % next trial

end % next block

%% WRAP-UP

% close output file
fclose(outfile);

% compute statistics for critical block:
medianRT = median(RT);
propAcc = mean(accuracy);

% shut down audio channel:
PsychPortAudio('Close', audiochannel);

% display closing message
Screen('TextSize', win, InstructionsSize);
Screen('TextFont', win, InstructionsFont);
WriteCentered(win, 'Great!  You have now finished this task.  Please press a key.', XMid, YMid, targetcolor);
Screen('Flip', win);
getKeys;

% reset text properties
Screen('TextFont', win, oldFont);
Screen('TextSize', win, oldSize);