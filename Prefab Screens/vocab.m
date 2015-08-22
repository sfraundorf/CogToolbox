% scores = ERVT(mainwindow, fgcolor, bgcolor, datafolder, subjno, maxtime)
%
% Administers a vocabulary task.  On each item, the subject has to match a
% target word to 1 of 5 words that represents the most similar meaning.
%
% There are two blocks of 24 words each.  After MAXTIME minutes, the
% participant is required to advance to the next block.  MAXTIME is
% optional; if not specified, the default is 6 minutes per block.
% MAXTIME may be non-integer.
%
% Also includes an instructions screen and a practice trial.
%
% Trial-by-trial data is saved to disk in folder DATAFOLDER within the
% function.  The function also returns SCORES from each block (out of 24
% each).  A -0.25 penalty for incorrect guesses is applied.
%
% The test is displayed on window MAINWINDOW with colors FGCOLOR and
% BGCOLOR.  Parameter SUBJNO is the subject number; used to save the data.
%
% Requires vocabdata.csv, a CSV file with the test items.  This file is NOT
% distributed as part of the toolbox and must be supplied by the user.  You
% could create your own test, or license one from, e.g., the Kit of Factor
% Referenced Tests.
%
% 02.05.10 - S.Fraundorf - created
% 05.13.11 - S.Fraundorf - returns the score from each block separately.
%                           these can easily be summed together if you want
%                           the total score
% 06.20.11 - S.Fraundorf - changed response keys to 1-6. 
%                           added subj # and block # columns in output
% 06.22.11 - S.Fraundorf - now correctly displays DON'T KNOW option as 6
%                           (not F)
% 07.20.11 - S.Fraundorf - DON'T KNOW was displaying as F not 6 for first 
%                           item in block.  fixed.
% 09.21.11 - S.Fraundorf - removed extra comma at the end of each row of
%                           data
% 08.22.12 - S.Fraundorf - improved stimulus timing by getting the times
%                            directly from Screen('Flip')

function scores = vocab(mainwindow, fgcolor, bgcolor, datafolder, subjno, maxtime)

%% --SET UP WINDOWS--
rect = Screen('Rect',mainwindow); % get window size

textloc = floor(rect(3) ./ 3); % X location of text
cueheight = floor(rect(4) ./ 5); % Y location of cue
respheight = floor(rect(4) ./ 3); % Y location of response options

ISI = 0.33; % 330 ms between trials
testFontSize = 48;

if nargin < 6
    maxtime = 6;
end
maxtimeInSec = maxtime * 60;

% kb names
KbName('UnifyKeyNames');
responseoptions = [KbName('1!') KbName('2@') KbName('3#') KbName('4$'), KbName('5%'), KbName('6^')];
letters = '123456';

%% -- OPEN FILES --
% stimuli
infile=fopen('vocabdata.csv');
testitems = textscan(infile,'%s%s%s%s%s%s%d','Delimiter',','); % read in all the items
fclose(infile);

% indices to array of stimuli
CUE = 1;
ANSWER = 7;

% block starting points
startpts = [1 2 26];
endpts = [1 25 49];

% subject data
outfile=fopen([datafolder 'vocab' num2str(subjno) '.csv'], 'w');
fprintf(outfile,'SUBJNO,BLOCKNUM,ITEMID,CUE,ANSWER,RESPONSE,CORRECT?,SCORECHANGE,RT\n');

%% -- SHOW INSTRUCTIONS --
instructions = ['In this task, you will try to figure out the meanings of little-known words that most people don''t know the meaning of.|' ...
    'The top word on each screen is printed in CAPITAL LETTERS.  Below it will be five other words.|'...
    'Press the 1, 2, 3, 4, or 5 keys to indicate the ONE word which you think means the same thing, or most nearly the same thing, as the word in caps.|'...
    'If you don''t know, you should press 6 for DON''T KNOW.|'...
    'We will start with a practice word.'];
InstructionsScreen(mainwindow,fgcolor,bgcolor,instructions);

%% -- RUN THE ACTUAL TEST! --
scorechange = zeros(49,1); % reserve spacing for scoring

for blocknum=1:3 % do EACH BLOCK
    oldsize = Screen('TextSize', mainwindow, testFontSize); % set font size & save old
    
    % --set up first item--
    itemnum = startpts(blocknum);
    % cue
    WriteLeft(mainwindow,upper(testitems{CUE}{itemnum}),textloc,cueheight,fgcolor);
    textheight = respheight;
    % 5 possible targets
    for i=1:5
        text = ['(' letters(i) ') ' lower(testitems{i+1}{itemnum})];
        WriteLeft(mainwindow,text,textloc,textheight,fgcolor);
        textheight = textheight + testFontSize*2; % space to next line
    end
    % don't know
    WriteLeft(mainwindow,'(6) DON''T KNOW',textloc,textheight, fgcolor);
    t1 = Screen('Flip',mainwindow);
    
    blockstart = t1;
    timeelapsed = GetSecs - blockstart;
    
    % -- do trials--
    while timeelapsed < maxtimeInSec  % block ends when time limit exeeded
        
        % get a response
        [RT resp] = Wait4KeyTimed (maxtimeInSec - timeelapsed, responseoptions);
        if isempty(resp)
            resp = 6; % count OUT OF TIME same as DON'T KNOW
        else
            resp = find(resp(responseoptions)==1,1);
        end
      
        % check timing
        timeelapsed = GetSecs - blockstart;
        if timeelapsed > maxtimeInSec
            break;
        end
        
        % calculate RT
        RT = RT - t1; % calculate RT

        % right or wrong answer 
        correct = (resp == testitems{ANSWER}(itemnum));
        if correct && itemnum > 1 % practice trial doesn't count towards score
            scorechange(itemnum) = 1; 
        elseif resp ~= 6 && itemnum > 1
            % chose a WRONG answer
            scorechange(itemnum) = -0.25; % penalty for bad guess
        else
           % practice trial or "DON'T KNOW" option do NOT penalize score
           scorechange(itemnum) = 0;
        end

        % clear screen
        t1 = Screen('Flip',mainwindow, 0);
        
        % -- save the data for this item --
        % reminder:fprintf(outfile,'SUBJNO,BLOCKNUM,ITEMID,CUE,ANSWER,RESPONSE,CORRECT?,SCORECHANGE,RT\n');
        fprintf(outfile,'%d,%d,%d,%s,%d,%d,%d,%1.2f,%3.4f\n', subjno, blocknum, itemnum, ...
           testitems{CUE}{itemnum},testitems{ANSWER}(itemnum),resp,correct,scorechange(itemnum),RT);
        
        % -- set up the next item--
        if itemnum == endpts(blocknum)
            % finished all the items in the block within the time limit
            % so advance
            break
        else
            % more items left in the block still
            itemnum = itemnum + 1; % advance in the list
            % cue
            WriteLeft(mainwindow,upper(testitems{CUE}{itemnum}),textloc,cueheight,fgcolor);
            textheight = respheight;
            % 5 possible targets
            for i=1:5
              text = ['(' letters(i) ') ' lower(testitems{i+1}{itemnum})];
              WriteLeft(mainwindow,text,textloc,textheight,fgcolor);
              textheight = textheight + testFontSize*2; % space to next line
            end
            % don't know
            WriteLeft(mainwindow,'(6) DON''T KNOW',textloc,textheight, fgcolor);
        end

        % -- ISI --
        t1 = Screen('Flip', mainwindow, t1+ISI);
        timeelapsed = t1-blockstart; % update timing of block
    end
    
    % --display info about next block--
    % reset font size
    Screen('TextSize', mainwindow, oldsize);
    
    if blocknum == 1
        instructions = ['OK, got the hang of it?|'...
            'There are going to be 24 words in the next set of words. Just to make sure we have '...
            'enough time, after ' num2str(maxtime) ' minutes, we will '...
            'move you on to the next set even if you''re still thinking.|'... 
            '(By the way - "jovial" means "jolly," in case you were wondering.)'];
    elseif blocknum == 2
        instructions = ['OK, done with that set of words!|'...
            'Don''t worry if you ran out of time.  These are tricky words and most people don''t '...
            'get through all of them in the time limit!|'...
            'Next, there will be another set of 24 words, and you will have ' num2str(maxtime) ...
            ' minutes for those as well.'];
    else
        instructions = 'Congratulations, you have now finished this task!';
    end
    InstructionsScreen(mainwindow,fgcolor,bgcolor,instructions);

end
                
%% WRAP-UP
fclose(outfile);

% calculate scores
scores = [sum(scorechange(startpts(2):endpts(2))) sum(scorechange(startpts(3):endpts(3)))];

% reset font size
Screen('TextSize', mainwindow, oldsize);