% [score pct maxtime] = ospan(mainwindow,fgcolor,bgcolor,datafolder,subjno,
% maxtime)
%
% Operation Span task based on Unsworth et al (2005).
%
% Participants read a 3-term equation and have to calculate the answer.
% After solving the equation, they press a key and see a probe answer, and
% have to decide whether this is a true or false answer to the equation.
%
% Between each equation, a letter is presented.  At the end of a set of
% equations, participants are asked to recall the letters they saw, in
% order.
%
% Trial-by-trial data is saved to disk in folder DATAFOLDER within the
% function, based on parameter SUBJNO (subject number).  The function also
% returns scalar SCORE, which reflects the partial-credit unit-weighted
% scoring procedure described by Conway et al. (2005) and participants'
% percentage accuracy on the equations PCT.  Participants are told to keep
% this accuracy at 85% or above.
%
% The test is displayed on window MAINWINDOW with colors FGCOLOR and
% BGCOLOR.
%
% By default, the experiment uses a calibration period, with just the
% equations, to determine how much time should be allowed for participants
% to solve each equation.  (The time allowed is participants' mean time
% during the practice + 2.5 SDs.)  This MAXTIME (in seconds) can be returned
% as extra output from the function.  If you want to force all participants
% to have a particular MAXTIME, you can also pass in a value for MAXTIME to
% override the calibration procedure.  (The calibration period will still be
% used, but it won't influence the time allowed for the participant.)
%
% After the calibration phase, there are 2 practice sets, followed by 15
% critical sets (3 each at sizes 3, 4, 5, 6, 7).
%
% Requires ospan_operation1.csv, a CSV file with stimuli
%
% 06.16.11 - S.Fraundorf - first version
% 06.20.11 - S.Fraundorf - changed response keys to D and K.  clarified the
%                          instructions  added subject # column in output
% 06.21.11 - S.Fraundorf - changed example letter to not be a response key
%                          fixed typo in the instructions
% 06.22.11 - S.Fraundorf - fixed punctuation errors in instructions
% 06.22.11 - S.Fraundorf - feedback screen now tells you to push a key to
%                            continue
% 06.22.11 - S.Fraundorf - save what people type for each letter
% 06.22.11 - S.Fraundorf - return % accuracy
% 06.22.11 - S.Fraundorf - fixed spacing in instructions
% 09.12.11 - S.Fraundorf - fixed a bug where sometimes the probe generated
%                            for "Incorrect" probes would sometimes be the
%                            correct answer
% 08.24.12 - S.Fraundorf - fixed a bug where not all timeouts were counted
%                            against your processing accuracy performance.
%                            Get starting time for RTs directly from Flip
%                            statement

function [score pct maxtime] = ospan(mainwindow, fgcolor, bgcolor, datafolder, subjno, maxtime)

%% --DEFAULT PARAMETERS--
if nargin < 7
    maxtime = 9999; % default is to calibrate for each participant
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
targetletters = 'FHJKLNPQRSTY'; % possible letters to see as TBR stimuli
signs = [1 -1]; % used to generate random numbers

% Timing:
TBRtime = .8; % 800 ms

% Text colors:
negfeedback = [255 0 0]; % red
posfeedback = [0 255 0]; % green

% Text properties:
%TextSize = 18;
%TextFont = 'Courier';

% Instructions:
recallinstructions = ['Type in the letters you saw, IN ORDER.  (Don''t worry about capitalization.)  '...
    'Press Enter after each letter.  If you cannot remember a letter, it''s fine to guess.'];

% Ordering of blocks:
blockorder = [6 4 3 5 7 5 4 3 6 7 6 5 3 7 4];
blockorder = [15 2 3 blockorder];

%% --SET UP WINDOWS--
rect = Screen('Rect', mainwindow); % get window size
TextSize = Screen('TextSize', mainwindow); % and text size

XMid = floor(rect(3) ./ 2);
YMid = floor(rect(4) ./ 2);
YProbe = YMid - (TextSize * 2);
YFeedback = YMid + (TextSize * 2);

%% -- CELL ARRAY INDICES --
DIGIT1 = 1;
OPERATION = 2;
DIGIT2 = 3;
DIFFIC = 4;

%% -- DATA FILES --
% first operation data
infile=fopen('ospan_operation1.csv');
fgetl(infile); % drop header
trialdata = textscan(infile, '%s%s%s%d%d%d', 'Delimiter', ',');
fclose(infile);

% output file
outfile=fopen([datafolder 'ospan' num2str(subjno) '.csv'], 'w');
% header row:
fprintf(outfile,'SUBJNO,BLOCKNUM,BLOCKSIZE,NUMINBLOCK,TERM1,OP,TERM2,TERM3,ANSWER,PROBE,PROBETYPE,DIFFIC,');        
fprintf(outfile,'MATHRESP,MATHACC,TIMEOUT,TBRLETTER,TYPED,RECALLED,MATHTIME,TFTIME,MAXTIME\n');        

%% -- SHOW INITIAL INSTRUCTIONS --
blurb = ['In this task, you will be asked to determine the answer to equations.|' ...
    'First, you will see an equation on the screen, like below.|' ...
    'Take a moment to figure out the answer to the equation.  Press a key once you have the answer in mind.'];
WriteLine(mainwindow, blurb, fgcolor, 30, 30, 30);
WriteCentered(mainwindow, '(6 X 4) - 2 = ?', XMid, YMid, fgcolor);
Screen('Flip', mainwindow);
getKeys;

blurb = ['After each equation, you will then see a possible answer to the equation.|' ...
    'Press <b>D for YES</b> if this <b>IS</b> the answer to the equation you just saw.|' ...
    'Press <b>K for NO</b> if this is <b>NOT</b> the correct answer.|'];
WriteLine(mainwindow, blurb, fgcolor, 30, 30, 30);
WriteCentered(mainwindow, '22', XMid, YProbe, fgcolor);
Screen('Flip', mainwindow);
[junk keybresponse] = Wait4Key([letterT letterF]);

if keybresponse(letterT)
    blurb = 'That''s right.  (6 X 4) - 2 = 22, so 22 was the true answer.';
else
    blurb = 'In this case, you should have pressed D for YES.  (6 X 4) - 2 = 22, so 22 was indeed the correct answer.';
end
blurb = [blurb '| Does that make sense?  Let''s try one more.'];
InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);

WriteCentered(mainwindow, '(2 ÷ 1) + 8 = ?', XMid, YMid, fgcolor);
Screen('Flip', mainwindow);
getKeys;

WriteCentered(mainwindow, '7', XMid, YProbe, fgcolor);
Screen('Flip', mainwindow);
[junk keybresponse] = Wait4Key([letterT letterF]);

if keybresponse(letterF)
    blurb = 'That''s right.  (2 ÷ 1) + 8 = 10, so 7 is NOT the answer.';
else
    blurb = 'In this case, you should have pressed K for NO.  (2 ÷ 1) + 8 = 10, so 7 is NOT the answer.';
end
InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);

blurb = ['The overall procedure will work like this:|'....
    '(1) You see the equation.|'...
    '(2) Once you have the answer in your head, press a key.|'...
    '(3) A possible answer appears.|'...
    '(4) You press D for YES or K for NO.|'...
    '(5) The next trial starts automatically.|'...
    'Does that make sense?  Please ask the experimenter if you are confused.'];
InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);    

blurb = ['In the next section, you will be asked to solve more equations.|'...
    'It is important that you answer correctly, but try to go as quickly as you can while still ' ...
    'being accurate.|Ask the experimenter now if you have any questions.'];
InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);

%% --INITIALIZE COUNTERS--
trialnum = 1;
blocknum = 1;
respinrow = 0;% initialize run tracker
lastresp = -1; 

% score:
score = 0;
% running math accuracy count through experiment
totalacc = 0;
totaltrials = 0;

calibration = true; % first block has equations only

%% -- RUN THE ACTUAL TEST! --
for blocksize = blockorder
    
    % create trials: target letters
    TBR = randorder(targetletters); % put the target letters in a random order
       % gives us more than we need, but that's OK - we just take the first
       % X
    % create trials: 
    probetype = repmat([0 1], 1, ceil(blocksize/2)); % may have 1 extra, but no biggie
    probetype = randorder(probetype);
    
    % reserve space for trial properties
    terms = repmat(-99,blocksize,3);
    eqanswer = zeros(1,blocksize);
    probe = zeros(1,blocksize);
    diffic = zeros(1,blocksize);
    operations = char(1,blocksize);
    
    % reserve space for subject responses
    MathTimes = zeros(1,blocksize);
    tftimes = zeros(1,blocksize);
    timeouts = zeros(1,blocksize);
    responses = repmat(-1,1,blocksize);
    accuracy = zeros(1,blocksize);
    lettersrecalled = repmat({'-'}, 1, blocksize);
    hits = repmat(-1,1,blocksize);
        
    for item = 1:blocksize
        
        % create the equation item
        terms(item,1) = str2double(trialdata{DIGIT1}{trialnum});
        terms(item,2) = str2double(trialdata{DIGIT2}{trialnum});
        diffic(item) = trialdata{DIFFIC}(trialnum);
        operations(item) = trialdata{OPERATION}{trialnum};
        
        inner = eval([trialdata{DIGIT1}{trialnum} operations(item) trialdata{DIGIT2}{trialnum}]);
        while inner + terms(item,3) <= 0
            % pick random number between 1 & 9, and multiply by either 1 or
            % -1
           terms(item,3) = (floor(rand*9)+1) * signs(floor(rand*2)+1);
        end
        eqanswer(item) = inner + terms(item,3);
        % create item for display
        if trialdata{OPERATION}{trialnum} == '/'
           symb1 = '÷';
        else
           symb1 = 'X';
        end        
        if terms(item,3) > 0
            symb2 = '+';
        else
            symb2 = '-';
        end
        
        % create the probe
        if probetype(item) == 0 % if FALSE
            while probe(item) <= 0 || probe(item) == eqanswer(item)
               probe(item) = eqanswer(item) + floor(rand*19)-9;
            end
        else
            probe(item) = eqanswer(item);
        end
        
        % display equation
        WriteCentered(mainwindow, ['(' num2str(terms(item,1)) ' ' symb1 ' ' num2str(terms(item,2)) ') ' ...
            symb2 ' ' num2str(abs(terms(item,3))) ' = ?'], XMid, YMid, fgcolor);        
        starttime = Screen('Flip', mainwindow, 0);
        % wait for first keypress
        [junk MathTimes(item)] = getKeys(maxtime);
        MathTimes(item) = MathTimes(item) - starttime;
        if MathTimes(item) >= maxtime
            % time out
            WriteCentered(mainwindow, 'TOO SLOW!', XMid, YMid, negfeedback);
            Screen('Flip', mainwindow, 0);
            WaitSecs(1);
            % record as a timeout
            timeouts(item) = 1;
        else
            % show probe only if there is still time remaining
        
            % present test probe

            WriteCentered(mainwindow, num2str(probe(item)), XMid, YProbe, fgcolor);
            starttime = Screen('Flip', mainwindow, 0);
        
            % collect True/False response to probe
            % time allowed is maxtime minus what you spent on the equation
            [tftimes(item) keybresponse] = Wait4KeyTimed(maxtime-MathTimes(item),[letterT letterF]);
            tftimes(item) = tftimes(item) - starttime; % change CPU time to RT
            if tftimes(item) + MathTimes(item) >= maxtime % time out
              WriteCentered(mainwindow, 'TOO SLOW!', XMid, YMid, negfeedback);
              Screen('Flip', mainwindow, 0);
              WaitSecs(1);
              % record as a timeout
              timeouts(item) = 1;
            elseif keybresponse(letterT) && keybresponse (letterF) % both letters were pressed
              WriteCentered(mainwindow, 'Please press either D or K only!!', XMid, YMid, negfeedback);
              Screen('Flip', mainwindow, 0);
              WaitSecs(1);
            elseif keybresponse(letterT)
               responses(item) = 1;
            elseif keybresponse(letterF)
               responses(item) = 0;
            else % bad response
               WriteCentered(mainwindow, 'Please press either D or K only!!', XMid, YMid, negfeedback);
               Screen('Flip', mainwindow, 0);
               WaitSecs(1);
            end
        end        
        
        % evaluate response:
        accuracy(item) = (responses(item) == probetype(item));
        if calibration && ~timeouts(item)
            % PROVIDE FEEDBACK
            WriteCentered(mainwindow, num2str(probe(item)), XMid, YProbe, fgcolor); % redisplay probe
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
               WriteCentered(mainwindow, 'You must decide if each number IS or IS NOT the correct answer to the equation.', textcenter, textheight+(TextSize*2), negfeedback);
               Screen('Flip', mainwindow);
               WaitSecs(1);
            end
       else
           respinrow = 0;
       end
        
        % present TBR letter (except in calibration phrase)
        if ~calibration
           WriteCentered(mainwindow, TBR(item), XMid, YMid, fgcolor);
           Screen('Flip', mainwindow,0);
           WaitSecs(TBRtime);
        end
        
        % advance to next trial
        trialnum = trialnum + 1;
    end    
    % end of block
    
    % now, do the test
    if ~calibration
       lettersrecalled = freerecall(mainwindow, blocksize, blocksize, fgcolor, bgcolor, recallinstructions, 0);
       Screen('Flip', mainwindow,0); % clear screen
    end
    
    % save results
    % name of block
    if blocknum == 1
        blockname = 'Cal';        
        TBR = repmat('-',1,blocksize);
    elseif blocknum < 4
        blockname = ['Prac' num2str(blocknum-1)];
    else
        blockname = num2str(blocknum-3);
    end
    % check each target word to see if it was recalled
    for item=1:blocksize
        if ~calibration % no letters to check in calibration phase
            hits(item) = strcmpi(lettersrecalled{item}, TBR(item));
        end
            
        % save the data for this item
        % fprintf(outfile,'SUBJNO,BLOCKNUM,BLOCKSIZE,NUMINBLOCK,TERM1,OP,TERM2,TERM3,ANSWER,PROBE,PROBETYPE,DIFFIC,MATHRESP,MATHACC');        
        % fprintf(outfile,'TIMEOUT,TBRLETTER,TYPED,RECALLED,MATHTIME,TFTIME,MAXTIME\n');        
         fprintf(outfile,'%d,%s,%d,%d,', subjno, blockname, blocksize, item);
         fprintf(outfile,'%d,%s,%d,%d,', terms(item,1), operations(item), terms(item,2), terms(item,3));
         fprintf(outfile,'%d,%d,%d,%d,', eqanswer(item), probe(item), probetype(item), diffic(item));
         fprintf(outfile,'%d,%d,%d,', responses(item), accuracy(item), timeouts(item));
         fprintf(outfile,'%s,%s,%d,', TBR(item), lettersrecalled{item}, hits(item));
         fprintf(outfile,'%2.4f,%2.4f,%2.4f\n', MathTimes(item), tftimes(item), maxtime);
    end
    
    % do scoring (not on calibration or practice blocks)
    if blocknum > 3
       score = score + (sum(hits)/blocksize);
    end
    
    % check ACCURACY of MATH ANSWERS
    totalacc = totalacc + sum(accuracy);
    totaltrials = totaltrials + blocksize;
    pct = round((totalacc/totaltrials) * 100);
    WriteCentered(mainwindow, 'So far, your TOTAL accuracy on the equations is:', XMid, YProbe, fgcolor);
    if pct < 85
        % not doing so well
        WriteCentered(mainwindow, [num2str(pct) '%'], XMid, YMid, negfeedback);
        WriteCentered(mainwindow, 'Please try to work more carefully on the equations.', XMid, YFeedback, fgcolor);        
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
            'The next phase of the task will be a little bit different.  After you judge each answer as right or wrong, you will see a ' ...
            'letter displayed on the screen before the next equation comes up.  Your job is to <b>remember these letters</b> ' ...
            'in addition to solving the equations.|' ...
            'After a few equations, we will ask you to <b>type in the letters you just saw, in the order you saw them</b> .|' ...
            'On the next screen, we will show you an example display.'];
        InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);
        
        % present example letter
        WriteCentered(mainwindow, 'Y', XMid, YMid, fgcolor);
        Screen('Flip', mainwindow);
        WaitSecs(TBRtime);        
        
        blurb = ['In this case, you would be trying to remember the letter Y.|'...
            'You will see a <b>DIFFERENT</b> letter after <b>EVERY</b> equation and your job is to remember them <b>in order</b>.'];
        InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);  
        
        if maxtime == 9999
            % calibrating, switch maxtime to mean + 2.5 SDs
            TotalTimes = MathTimes + tftimes;
            maxtime = mean(TotalTimes) + (2.5 * std(TotalTimes));
            clear TotalTimes
            
            blurb = ['The next part of the experiment will also give you less time to figure out the equations.|' ...
                'If you take a long time on an equation, the computer will display a message saying you were too slow, ' ...
                'and we will count that trial as an error.|' ...
                'So, try to solve the equations quickly.'];
            InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);  
        end               
            
        blurb = ['Even though you are trying to remember the letters, please still try to solve the equations quickly and accurately.|'...
            'Your <b>goal is to be at least 85% accurate with the equations</b>.|' ...
            'We won''t show you feedback after each equation any more, but after each memory test, we will tell you how you are doing.|' ...
            'On the next screen, we will practice the new version of the task.|' ...
            'We know that you probably won''t remember everything, but just do the best you can.'];
        InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);  
    elseif blocknum == 2
        % finished first practice
        blurb = ['In this section, the letters you saw between the equations were <b>' TBR(1) '</b> and <b>' TBR(2) '</b> .  ' ...
            'So, that is what you should have typed in.|' ...
            'Does that make sense?  Please ask the experimenter if you have any questions.|' ...
            'Let''s do <b>one more practice</b>.'];
        InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);
    elseif blocknum == 3
        % finished last practice
        blurb = ['OK, got the hang of it?|'...
            'That section had 3 letters to remember.  ' ...
            'For the rest of experiment, there will be <b>3 to 7 letters</b> in each section.|'...
            'Don''t forget to answer the math problems accurately.  '...
            'We need you to keep your accuracy on the problems at 85% or above.|' ...
            'If you have any questions, please ask the experimenter now.'];
        InstructionsScreen(mainwindow,fgcolor,bgcolor,blurb);
    end
    
    % advance block counter
    blocknum = blocknum+1;

end

%% WRAP-UP

% exit message
instructions = ['Good work!  This task is complete!|'...
    'We know that this was an especially difficult task.  But, it is those difficulties ' ...
    'that we are researching.  We definitely don''t expect that anyone will remember all the ' ...
    'letters!'];
InstructionsScreen(mainwindow, fgcolor, bgcolor, instructions);

fclose(outfile);
end