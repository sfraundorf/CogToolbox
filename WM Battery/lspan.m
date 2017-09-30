% [score pct maxtime] = lspan(mainwindow,fgcolor,bgcolor,datafolder,soundfilefolder,
%    subjno, maxtime, latency)
%
% Listening Span task based on Unsworth et al (2005) and Stine & Hindman
% (1994)
%
% Participants hear a recorded sentence.  As soon as the sentence ends,
% they are prompted to decide whether it was true or false.
%
% Between each sentence, a letter is presented auditorially.  At the end
% of a set of sentences, participants are asked to recall the letters they
% saw, in order.
%
% Trial-by-trial data is saved to disk in folder DATAFOLDER within the
% function, based on parameter SUBJNO (subject number).  The function also
% returns scalar SCORE, which reflects the partial-credit unit-weighted
% scoring procedure described by Conway et al. (2005) and participants'
% percentage accuracy on the sentences PCT.  Participants are told to keep
% this accuracy at 85% or above.
%
% The test is displayed on window MAINWINDOW with colors FGCOLOR and
% BGCOLOR.
%
% By default, the experiment uses a calibration period, with just the
% sentences, to determine how much time should be allowed for participants
% to judge each sentence.  (The time allowed is participants' mean time
% during the practice + 2.5 SDs.)  This MAXTIME (in seconds) can be returned
% as extra output from the function.  If you want to force all participants
% to have a particular MAXTIME, you can also pass in a value for MAXTIME to
% override the calibration procedure.  (The calibration period will still be
% used, but it won't influence the time allowed for the participant.)
%
% After the calibration phase, there are 2 practice sets, followed by 10
% critical sets (2 each at sizes 2, 3, 4, 5, 6).
%
% Requires lspantrials.csv, a CSV file with stimuli, and a set of sound
% files in folder SOUNDFILEFOLDER
%
% Parameter LATENCY ranges between 0 and 1 controls the timing of the sound
% files.  A lower number results in more precise timing, but setting the
% number TOO low for your system may make the audio sound static-y.  See
% IndividualDifferences.m and the "Low-Latency Audio in Psychophysics
% Toolbox.doc" file in the CogToolbox for more information.
%
% Credits: Recordings - Shelby Luzzi
%
% 06.22.11 - S.Fraundorf - first version
% 06.22.11 - S.Fraundorf - feedback screen now tells you to push a key to
%                            continue
% 06.22.11 - S.Fraundorf - save what people type for each letter.  fixed
%                            errors in instructions
% 06.22.11 - S.Fraundorf - return % accuracy
% 06.22.11 - S.Fraundorf - fixed spacing in instructions
% 07.05.11 - S.Fraundorf - added LATENCY parameter.  closes sound channel when done
% 08.22.12 - S.Fraundorf - improved RT collection by getting the RT
%                            directly from the Screen('Flip') statement
% 08.24.12 - S.Fraundorf - fixed a bug where not all timeouts were counted
%                            against your processing accuracy performance.

function [score pct maxtime] = lspan(mainwindow, fgcolor, bgcolor, datafolder, soundfilefolder, subjno, maxtime, latency)

%% --DEFAULT PARAMETERS--
if nargin < 8
    latency = 0.015; % default latency
    if nargin < 7
       maxtime = 9999; % default is to calibrate for each participant
    end
end

if maxtime <= 0
    % 0 is the same as calibrating
    maxtime = 9999;
end

%% -- HARD CODED PROPERTIES --

% key indices:
letterT = KbName('D');  % for TRUE probes
letterF = KbName('K');  % for FALSE probes

% Targets:
targetletters = 'fhjklnpqrsty'; % possible letters to see as TBR stimuli

% Timing:
TBRtime = .4; % 400 ms

% Text colors:
negfeedback = [255 0 0]; % red
posfeedback = [0 255 0]; % green

% Text properties:
%TextSize = 18;
%TextFont = 'Courier';

% Instructions:
recallinstructions = ['Type in the letters you saw, IN ORDER.  (Don''t worry about capitalization.)  '...
    'Press Enter after each letter.  If you cannot remember a letter, it''s fine to guess.'];

%% --SET UP WINDOWS--
rect = Screen('Rect', mainwindow); % get window size
TextSize = Screen('TextSize', mainwindow); % and text size

XMid = floor(rect(3) ./ 2);
YMid = floor(rect(4) ./ 2);
YProbe = YMid - (TextSize * 2);
YFeedback = YMid + (TextSize * 2);

%% --SET UP AUDIO--
SOUNDFREQ = 48000;
SOUNDCHANNELS = 1;
InitializePsychSound;
pahandle = PsychPortAudio('Open', [], 1, 1, SOUNDFREQ, SOUNDCHANNELS, [], latency);

%% -- CELL ARRAY INDICES --
TRUTH = 1;
MEMWORD = 2;

%% -- DATA FILES --
% first operation data
infile=fopen('lspantrials.csv');
testitems = textscan(infile, '%d%s', 'Delimiter', ',');
fclose(infile);

% parse the items into sets
listposition = 1; % initialize position on list of items
blocksizes = [15 2 2 2 2 3 3 4 4 5 5 6 6]; % 15 for calibration, 2 x 2 practice, then test items
numblocks = numel(blocksizes);
% create array of blocks
for blocknum=1:numblocks
    for trialinblock=1:blocksizes(blocknum)
        blocks{blocknum}{TRUTH}(trialinblock) = testitems{TRUTH}(listposition);
        blocks{blocknum}{MEMWORD}{trialinblock} = testitems{MEMWORD}{listposition};
        listposition = listposition+1;
    end
end
% this creates a cell array of "blocks", each of which then contains lists of
% soundfile names, T/F answers, and target words
clear testitems blocksizes
% clear the raw data once the list of blocks is assembled

% put the blocks in a random order, with the constraint that the first
% three blocks (calibration, practice, practice) are always in the same
% order
blockorder = [1 2 3 randorder(4:numblocks)];

% output file
outfile=fopen([datafolder 'lspan' num2str(subjno) '.csv'], 'w');
% header row:
fprintf(outfile,'SUBJNO,BLOCKNUM,BLOCKNAME,BLOCKSIZE,NUMINBLOCK,ITEMID,ANSWER,');        
fprintf(outfile,'TFRESP,TFACC,TIMEOUT,TBRLETTER,TYPED,RECALLED,TFTIME,MAXTIME\n');        

%% -- SHOW INITIAL INSTRUCTIONS --

sentence = audioread([soundfilefolder 'finger.wav']);
PsychPortAudio('FillBuffer', pahandle, sentence');

blurb = ['In this task, you will hear sentences over the computer speakers and decide whether or not they are true statements.|'...
    'On the next screen, we will play you an example sentence.  As you are listening, decide whether or not the sentence is true.'];
InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);

% blank screen, play & wait for sound to finish
Screen('Flip', mainwindow);
PsychPortAudio('Start', pahandle);
PsychPortAudio('Stop', pahandle, 1);

blurb = ['After you hear each sentence, you will then be asked if the sentence was true.|' ...
    'Press <b>D for YES</b> if the sentence <b>IS</b> true.|' ...
    'Press <b>K for NO</b> if the sentence is <b>NOT</b> true.|'];
WriteLine(mainwindow, blurb, fgcolor, 30, 30, 30);
WriteCentered(mainwindow, 'Is this true?', XMid, YProbe, fgcolor);
Screen('Flip', mainwindow);
[junk keybresponse] = Wait4Key([letterT letterF]);

if keybresponse(letterF)
    blurb = 'That''s right.  You don''t wear a shoe on your finger, so the sentence was not true.';
else
    blurb = 'In this case, you should have pressed K for NO.  A finger is not where you wear your shoe, so the sentence is NOT true.';
end
blurb = [blurb '| Does that make sense?  Let''s try one more.'];
sentence = audioread([soundfilefolder 'lettuce.wav']);
PsychPortAudio('FillBuffer', pahandle, sentence');
InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);

% blank screen, play & wait for sound to finish
Screen('Flip', mainwindow);
PsychPortAudio('Start', pahandle);
PsychPortAudio('Stop', pahandle, 1);

WriteCentered(mainwindow, 'Is this true?', XMid, YProbe, fgcolor);
Screen('Flip', mainwindow);
[junk keybresponse] = Wait4Key([letterT letterF]);

if keybresponse(letterT)
    blurb = 'That''s right.  Lettuce is often found in salads.  The sentence is true.';
else
    blurb = 'In this case, you should have pressed D for YES.  Lettuce is often found in salads, so the sentence IS true.';
end
InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);

blurb = ['The overall procedure will work like this:|'....
    '(1) You will hear the sentence.|'...
    '(2) As soon as the sentence ends, "Is this true?" appears.|'...
    '(3) You press D for YES or K for NO.|'...
    '(4) The next trial starts automatically.|'...
    'Does that make sense?  Please ask the experimenter if you are confused.'];
InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);    

blurb = ['In the next section, you will hear more sentences.|'...
    'It is important that you answer correctly, but try to go as quickly as you can while still ' ...
    'being accurate.|'...
    'Ask the experimenter now if you have any questions.'];
InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);

%% --INITIALIZE COUNTERS--
trialnum = 1;
respinrow = 0;% initialize run tracker
lastresp = -1;
blockcounter = 1;

% score:
score = 0;
% running sentence accuracy count through experiment
totalacc = 0;
totaltrials = 0;

calibration = true; % first block has sentences only

%% -- RUN THE ACTUAL TEST! --
for blocknum = blockorder
    
    % create trials: target letters
    TBR = randorder(targetletters); % put the target letters in a random order
       % gives us more than we need, but that's OK - we just take the first
       % X    
       
    % check block size
    blocksize = numel(blocks{blocknum}{MEMWORD});
    
    % reserve space for subject responses
    tftimes = zeros(1,blocksize);
    timeouts = zeros(1,blocksize);
    responses = repmat(-1,1,blocksize);
    accuracy = zeros(1,blocksize);
    hits = repmat(-1,1,blocksize);
    lettersrecalled = repmat({'-'}, 1, blocksize);
        
    for item = 1:blocksize
        
        % load the sentence & letter files, put the former in the buffer
        sentence = audioread([soundfilefolder blocks{blocknum}{MEMWORD}{item} '.wav']);
        if ~calibration
           letterwav = audioread([soundfilefolder TBR(item) '.wav']);
        end
        PsychPortAudio('FillBuffer', pahandle, sentence');
        
        % play the sentence (w/ blank screen)
        Screen('Flip', mainwindow);
        PsychPortAudio('Start', pahandle);
        PsychPortAudio('Stop', pahandle, 1);
        
        % present test probe
        WriteCentered(mainwindow, 'Is this true?', XMid, YProbe, fgcolor);
        starttime = Screen('Flip', mainwindow, 0);
        
        % collect True/False response to probe
        [tftimes(item) keybresponse] = Wait4KeyTimed(maxtime,[letterT letterF]);
        tftimes(item) = tftimes(item) - starttime; % change CPU time to RT
        if tftimes(item) >= maxtime % time out
           WriteCentered(mainwindow, 'TOO SLOW!', XMid, YMid, negfeedback);
           Screen('Flip', mainwindow);
           WaitSecs(1);
           % record as a timeout
           timeouts(item) = 1;
        elseif keybresponse(letterT) && keybresponse (letterF) % both letters were pressed
           WriteCentered(mainwindow, 'Please press either D or K only!!', XMid, YMid, negfeedback);
           Screen('Flip', mainwindow);
           WaitSecs(1);
        elseif keybresponse(letterT)
           responses(item) = 1;
        elseif keybresponse(letterF)
           responses(item) = 0;
        else % bad response
           WriteCentered(mainwindow, 'Please press either D or K only!!', XMid, YMid, negfeedback);
           Screen('Flip', mainwindow);
           WaitSecs(1);
        end      
        
        % evaluate response:
        accuracy(item) = (responses(item) == blocks{blocknum}{TRUTH}(item));
        if calibration && ~timeouts(item)
            % PROVIDE FEEDBACK
            WriteCentered(mainwindow, 'Is this true?', XMid, YProbe, fgcolor); % redisplay probe
            if accuracy(item)                                
                WriteCentered(mainwindow, 'GOOD!', XMid, YFeedback, posfeedback);
            else
                WriteCentered(mainwindow, 'NO!', XMid, YFeedback, negfeedback);
            end
            Screen('Flip', mainwindow);
            WaitSecs(0.80);
        end
        
        % check against the subject hitting the same key over and over
        if responses(item) == lastresp
           respinrow = respinrow + 1;
            if respinrow > 6 % hit the same key 7 times in a row or more
               % nag the subject
               WriteCentered(mainwindow, 'Are you pressing the same key over and over?', textcenter, textheight, negfeedback);
               WriteCentered(mainwindow, 'You must decide if each sentence IS TRUE or IS NOT TRUE.', textcenter, textheight+(TextSize*2), negfeedback);
               Screen('Flip', mainwindow);
               WaitSecs(1);
            end
       else
           respinrow = 0;
       end
        
        % present TBR letter (except in calibration phrase)
        if ~calibration
           PsychPortAudio('FillBuffer', pahandle, letterwav');
           Screen('Flip', mainwindow);
           PsychPortAudio('Start', pahandle);
           PsychPortAudio('Stop', pahandle, 1);
           WaitSecs(TBRtime);
        end
        
        % advance to next trial
        trialnum = trialnum + 1;
    end    
    % end of block
    
    % now, do the test
    if ~calibration
       lettersrecalled = freerecall(mainwindow, blocksize, blocksize, fgcolor, bgcolor, recallinstructions, 0);
       Screen('Flip', mainwindow); % clear screen
    end
    
    % save results
    % name of block
    if blocknum == 1
        blockname = 'Cal';        
        TBR = repmat('-',1,blocksize);
    elseif blocknum < 4
        blockname = ['Prac' num2str(blocknum-1)];
    elseif iseven(blocknum)
        blockname = [num2str(blocknum/2) 'A'];
    else
        blockname = [num2str(floor(blocknum/2)) 'B'];
    end
    % check each target word to see if it was recalled
    for item=1:blocksize
        if ~calibration % no letters to check in calibration phase
            hits(item) = strcmpi(lettersrecalled{item}, TBR(item));
        end
        
        % save the data for this item
        % fprintf(outfile,'SUBJNO,BLOCKNUM,BLOCKNAME,BLOCKSIZE,NUMINBLOCK,ITEMID,ANSWER,');        
        % fprintf(outfile,'TFRESP,TFACC,TIMEOUT,TBRLETTER,TYPED,RECALLED,TFTIME,MAXTIME\n');        
         fprintf(outfile,'%d,%d,%s,%d,%d,', subjno, blockcounter, blockname, blocksize, item);
         fprintf(outfile,'%s,%d,', blocks{blocknum}{MEMWORD}{item}, blocks{blocknum}{TRUTH}(item));
         fprintf(outfile,'%d,%d,%d,', responses(item), accuracy(item), timeouts(item));
         fprintf(outfile,'%s,%s,%d,', TBR(item), lettersrecalled{item}, hits(item));
         fprintf(outfile,'%2.4f,%2.4f\n', tftimes(item), maxtime);
    end
    
    % do scoring (not on calibration or practice blocks)
    if blocknum > 3
       score = score + (sum(hits)/blocksize);
    end
    
    % check ACCURACY of TRUE/FALSE ANSWERS
    totalacc = totalacc + sum(accuracy);
    totaltrials = totaltrials + blocksize;
    pct = round((totalacc/totaltrials) * 100);
    WriteCentered(mainwindow, 'So far, your TOTAL accuracy on the sentences is:', XMid, YProbe, fgcolor);
    if pct < 85
        % not doing so well
        WriteCentered(mainwindow, [num2str(pct) '%'], XMid, YMid, negfeedback);
        WriteCentered(mainwindow, 'Please try to work more carefully on the sentences', XMid, YFeedback, fgcolor);
    else
        % doing fine
        WriteCentered(mainwindow, [num2str(pct) '%'], XMid, YMid, posfeedback);
        WriteCentered(mainwindow, 'Keep up the good work!', XMid, YFeedback, fgcolor);
    end       
    Screen('Flip', mainwindow, [], 1);
    WaitSecs(1);
    WriteCentered(mainwindow, 'Press a key to continue.', XMid, (YFeedback+TextSize*2), fgcolor);
    Screen('Flip', mainwindow);
    getKeys;
    
    % display further instructions
    if calibration % FINISHED CALIBRATION BLOCK
        
        calibration = false; % mark that we are done with calibration
        
        % show instructions for PRACTICE phase of actual span task:
        blurb = ['OK, did you get the hang of it?|' ...
            'The next phase of the task will be a little bit different.  After you judge each sentence as right or wrong, the speaker ' ...
            'will say a letter of the alphabet before the next sentence starts.  Your job is to <b>remember these letters</b> ' ...
            'in addition to judging the sentences.|' ...
            'After a few sentences, we will ask you to <b>type in the letters you just heard, in the order you heard them</b> .|' ...
            'On the next screen, we will play you an example letter.'];
        letterwav = audioread([soundfilefolder 'r.wav']);
        PsychPortAudio('FillBuffer', pahandle, letterwav');
        InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);
        
        % present example letter
        Screen('Flip', mainwindow);
        PsychPortAudio('Start', pahandle);
        PsychPortAudio('Stop', pahandle, 1);    
        WaitSecs(TBRtime);
        
        blurb = ['In this case, you would be trying to remember the letter R.|'...
            'You will hear a <b>DIFFERENT</b> letter after <b>EVERY</b> sentence and your job is to remember them <b>in order</b>.'];
        InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);  
        
        if maxtime == 9999
            % calibrating, switch maxtime to mean + 2.5 SDs
            maxtime = mean(tftimes) + (2.5 * std(tftimes));
            
            blurb = ['The next part of the experiment will also give you less time to judge the sentences.|' ...
                'If you take a long time on a sentence, the computer will display a message saying you were too slow, ' ...
                'and we will count that trial as an error.|' ...
                'So, try to judge the sentences quickly.'];
            InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);  
        end               
            
        blurb = ['Even though you are trying to remember the letters, please still try to judge the sentences quickly and accurately.|'...
            'Your <b>goal is to be at least 85% accurate with the sentences</b>.|' ...
            'We won''t show you feedback after each sentence any more, but after each memory test, we will tell you how you are doing.|' ...
            'On the next screen, we will practice the new version of the task.|' ...
            'We know that you probably won''t remember everything, but just do the best you can.'];
        InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);  
    elseif blocknum == 2
        % finished first practice
        blurb = ['In this section, the letters you heard between the sentences were <b>' upper(TBR(1)) '</b> and <b>' upper(TBR(2)) '</b> .  ' ...
            'So, that is what you should have typed in.|' ...
            'Does that make sense?  Please ask the experimenter if you have any questions.|' ...
            'Let''s do <b>one more practice</b>.'];
        InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);
    elseif blocknum == 3
        % finished last practice
        blurb = ['OK, got the hang of it?|'...
            'That section had 2 letters to remember.  ' ...
            'For the rest of experiment, there will be <b>2 to 6 letters</b> in each section.|'...
            'Don''t forget to listen carefully and judge the sentences accurately.  '...
            'We need you to keep your accuracy on the sentences at 85% or above.|' ...
            'If you have any questions, please ask the experimenter now.'];
        InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);
    end
    
    blockcounter = blockcounter + 1;
    
end

%% WRAP-UP

% exit message
instructions = ['Good work!  This task is complete!|'...
    'We know that this was an especially difficult task.  But, it is those difficulties ' ...
    'that we are researching.  We definitely don''t expect that anyone will remember all the ' ...
    'letters!'];
InstructionsScreen(mainwindow, fgcolor, bgcolor, instructions);

fclose(outfile);
PsychPortAudio('Close', pahandle);
end