% score = minus2span(mainwindow,fgcolor,bgcolor,minustime,datafolder,subjno, randspan, title)
%
% 4th of 4 tasks for the Working Memory Battery (see wmbattery).  In this
% task, subjects see a list of numbers, then have to recall them in order
% while also substracting 2 from each number.
%
% Trial-by-trial data is saved to disk in folder DATAFOLDER within the
% function, based on parameter SUBJNO (subject number).  The function also
% returns scalar SCORE. The meaning of SCORE depends on which test format
% you are using (controlled by RANDSPAN); see help for wmbattery.m for
% more information.
%
% The test is displayed on window MAINWINDOW with colors FGCOLOR and
% BGCOLOR.  Each number is displayed for MINUSTIME seconds.  The default
% MINUSTIME in the wmbattery is 1 second.
%
% Requires minus2spandata.csv, a CSV file with stimuli
%
% Parameter RANDSPAN controls the order in which the sets are presented.
%   0 - present in order of ascending size (up to a maximum of 8) until
%         the participant misses both attempts at a given size (default)
%   1 - present sets in a random order (RECOMMENDED).  only set sizes 2-7
%         are used
% See wmbattery.m for further discussion of this
%
% Optional parameter TITLE is the title of the test, as displayed to the
% subject.  Default is 'PART FOUR' since this is the 4th task in the
% battery, but this can be changed in case to suit your experiment.
%
% 11.17.09 - S.Fraundorf - first version
% 11.25.09 - S.Fraundorf - added ability to change TITLE.  files saved as
%                           .csv rather than .txt
% 01.24.10 - S.Fraundorf - added RANDSPAN parameter.  fixed some confusing
%                           wording in the instructions to participant
% 02.04.10 - S.Fraundorf - PTB-3 version.  added exit screen.
% 02.05.10 - S.Fraundorf - removed the warnings during the critical trials
%                           if you enter a number without subtracting 2.
%                           it's too easy to activate these by accident
%                           (i.e., from GUESSING)
% 02.10.10 - S.Fraundorf - fixed a bug with reporting score when they
%                           forgot to subtract 2
% 12.15.10 - S.Fraundorf - changed "words" in the instructions to "numbers"
% 08.24.12 - S.Fraundorf - improved stimulus timing by getting the times
%                            directly from Screen('Flip').  Updated
%                            instructions on how to enter DONE

function score = minus2span(mainwindow, fgcolor, bgcolor, minustime, datafolder, subjno, randspan, title)

%% --DEFAULT PARAMETERS--
if nargin < 8
    title = 'PART FOUR.'; % default title is PART FOUR
    if nargin < 7
        randspan = 0; % default is to abort after 2 fails
    end
end

%% --SET UP WINDOWS--
rect = Screen('Rect',mainwindow); % get window size
%TextFont = Screen('TextFont',mainwindow); % get font
TextSize = Screen('TextSize',mainwindow); % get font sie

textcenter = floor(rect(3) ./ 2);
textheight = floor(rect(4) ./ 2);

%% -- RECALL TEST INSTRUCTIONS --
recallinstructions = ['Enter the numbers IN ORDER, after SUBTRACTING 2 FROM EACH NUMBER.  Press Enter after each number.  '...
    'Once you have entered all the numbers you can remember, type DONE into the next empty box.'];

%% -- OPEN FILES --
% stimuli
infile=fopen('minus2spandata.csv');
testitems = textscan(infile,'%d'); % read in all the items
fclose(infile);

% parse the items into sets
listposition = 1; % initialize position on list of items
% practice blocks
for blocknum=1:2
    for trialinblock=1:2
      pracblocks{blocknum}(trialinblock) = testitems{1}(listposition);
      listposition = listposition+1;
    end
end
% test blocks
blocknum = 1;
for level=1:7 % 7 levels = set sizes of 2-8
  for blockinlevel=1:2
      for trialinblock=1:(level+1)
        blocks{blocknum}(trialinblock) = testitems{1}(listposition);
        listposition = listposition+1;
      end
      blocknum = blocknum+1;      
  end
end
% this creates a cell array of "blocks", each of which then contains lists of
% soundfile names, T/F answers, and target words
clear testitems
% clear the raw data once the list of blocks is assembled

% put the blocks in order
if ~randspan % ascending order
    blockorder = 1:(numel(blocks));
else
    % randomized block order
    numblocks = 12; % only set sizes 2, 3, 4, 5, 6, 7 are used.  these are the first 12 blocks
    blockorder = randperm(numblocks);
    % note that practice blocks are never randomized
end

% subject data
outfile=fopen([datafolder 'minus' num2str(subjno) '.csv'], 'w');
fprintf(outfile,'BLOCKID,NUMINBLOCK,TARGET,ORIGINAL,ENTRY,CORRECT?\n');

%% -- SHOW INSTRUCTIONS --
taskinstructions = [title '|The experiment is broken down into different sections.|'...
    'In each section, you will be given a group of numbers, one at a time.|READ ALOUD each number in the section.|' ...
    'The computer will automatically advance to the next number.|'...
    'At the end of each section, type in the numbers you saw IN THEIR ORIGINAL ORDER, AFTER SUBTRACTING TWO FROM EACH NUMBER.|'...
    'Be sure to enter the numbers IN ORDER and to SUBTRACT TWO FROM EACH NUMBER!|'];
if randspan == 0
    taskinstructions = [taskinstructions 'As you progress through the experiment, the sections may get longer.'];
else % they vary in length randomly
    taskinstructions = [taskinstructions 'The sections will vary in length.  Some will be easy and some will be hard.  We know that you probably won''t remember everything, but just do the best you can.'];
end
InstructionsScreen(mainwindow,fgcolor,bgcolor,taskinstructions);

%% -- PRACTICE --
for blocknum = 1:2

    % initialize stuff
    hits = zeros(1,2); % clear the memory HITS
        
    % show each number
    t1 = GetSecs;
    for iteminlist = 1:2
       
       % calculate the number that will be DISPLAYED (2 greater than the
       % target)
       displaynumber = pracblocks{blocknum}(iteminlist) + 2;
           
       % display item
       WriteCentered(mainwindow, num2str(displaynumber), textcenter, textheight, fgcolor);
       t1 = Screen('Flip',mainwindow,t1+minustime);
    end
        
    % wait for the last time
    WaitSecs(minustime);
    % now, do the test
    wordsrecalled = freerecall(mainwindow, 0, 2, fgcolor, bgcolor, recallinstructions, 0);
    Screen('Flip',mainwindow,0); % clear the screen
    
    % check each target word to see if it was recalled
    for j=1:2
        if ~isempty(str2double(wordsrecalled{j})) % must be a NUMERIC entry
              if str2double(wordsrecalled{j}) == pracblocks{blocknum}(j)  % numbers must match IN ORDER
                hits(j) = 1;
              elseif str2double(wordsrecalled{j}) == pracblocks{blocknum}(j)+2 % didn't subtract 2
                hits(j) = -1;
              end
        end
                        
        % save the data for this item
        % fprintf(outfile,'BLOCKID,NUMINBLOCK,TARGET,ORIGINAL,ENTRY,CORRECT?\n');
        fprintf(outfile,'P%d,%d,%d,%d,%s,%d\n',...
            blocknum, j, pracblocks{blocknum}(j),...
            pracblocks{blocknum}(j)+2, wordsrecalled{j}, hits(j));
    end
        
     % evaluate outcome
     if ~isempty(find(hits==-1, 1)) % they forgot to subtract 2 from at least one number
         WriteCentered(mainwindow, 'Remember to SUBTRACT TWO from each number before you enter it.', textcenter, textheight, fgcolor);
         failmessage = ['The correct answers were ' num2str(pracblocks{blocknum}(1)) ...
             ' and ' num2str(pracblocks{blocknum}(2)) ' in that order.'];
         WriteCentered(mainwindow, failmessage, textcenter, textheight+(TextSize*2), fgcolor);
     elseif isempty(find(hits==0, 1)) % all items were recalled correctly
        WriteCentered(mainwindow, 'Great!  You got both numbers correct.', textcenter, textheight, fgcolor);
     else
         failmessage = ['The correct answers were ' num2str(pracblocks{blocknum}(1)) ...
             ' and ' num2str(pracblocks{blocknum}(2)) ' in that order.'];
         WriteCentered(mainwindow, failmessage, textcenter, textheight, fgcolor);
         WriteCentered(mainwindow,'That is what you get if you SUBTRACT 2 from each number IN ORDER.', textcenter, textheight+(TextSize*2), fgcolor);
     end
     Screen('Flip',mainwindow); % display whatever message they got
     getKeys;

     % explain what happens next
     if blocknum==1
        WriteCentered(mainwindow, 'Let''s try one more practice round.  Don''t forget to read the numbers OUT LOUD.', textcenter, textheight, fgcolor);
     elseif randspan
        WriteCentered(mainwindow, 'OK, now for the actual experiment.  Remember, some sections will be easier than others, but just do the best you can.', textcenter, textheight, fgcolor);
     else
        WriteCentered(mainwindow, 'OK, now for the actual experiment.', textcenter, textheight, fgcolor);
     end
     Screen('Flip',mainwindow); % display this message
     getKeys;
     
end

%% --INITIALIZE SCORING--
if randspan
    % count number of blocks correctly answered
    score=0;
else
    % count upwards 'til threshold
    score = 1;
    attempt = 1; % 2 consecutive failures = quit
    numhits = 0;
end
skip = 0;

%% -- RUN THE ACTUAL TEST! --
for blocknum=blockorder
    
    if skip % if using absolute threshold, SKIP once a participant gets 1 set correct on a block
        skip = 0; % reset this flag
    else
        
    % calculate size of this block
    blocksize = size(blocks{blocknum},2);
    
    % initialize stuff
    hits = zeros(1,blocksize); % clear the memory HITS

    % show each number
    t1 = GetSecs;
    for iteminlist = 1:blocksize
        
       % calculate the number that will be DISPLAYED (2 greater than the
       % target)
       displaynumber = blocks{blocknum}(iteminlist) + 2;
                                    
       % display item
       WriteCentered(mainwindow, num2str(displaynumber), textcenter, textheight, fgcolor);
       t1 = Screen('Flip',mainwindow, t1+minustime); % show it
    end
        
    % wait for the last item
    WaitSecs(minustime);
    % now, do the test
    wordsrecalled = freerecall(mainwindow, 0, blocksize, fgcolor, bgcolor, recallinstructions, 0);
    Screen('Flip', mainwindow, 0); % clear screen
    
    % get block name for saving data
    if ~randspan
        blockname = [num2str(blocksize) '-' num2str(2-mod(blocknum,2))];
    elseif mod(blocknum, 2) == 0
        % "a" blocks
        blockname = [num2str(blocksize) 'a'];
    else
        blockname = [num2str(blocksize) 'b'];
    end    

    % score the test
    % check each target word to see if it was recalled
    for j=1:blocksize
        if ~isempty(str2double(wordsrecalled{j})) % must be a NUMERIC entry
              if str2double(wordsrecalled{j}) == blocks{blocknum}(j)  % numbers must match IN ORDER
                hits(j) = 1;
              end
        end
                        
        % save the data for this item
        % fprintf(outfile,'BLOCKID,NUMINBLOCK,TARGET,ORIGINAL,ENTRY,CORRECT?\n');
        fprintf(outfile,'%s,%d,%d,%d,%s,%d\n',...
            blockname, j, blocks{blocknum}(j),...
            blocks{blocknum}(j)+2, wordsrecalled{j}, hits(j));
    end
            
    % evaluate outcome & save # of hits
    if ~randspan
        lasthits = numhits; % save PREVIOUS number of hits to combine across the level
    end
    numhits = sum(hits);
    
    % do scoring
    if randspan
        % score = proportion of trials you got right in this block
        score = score + (numhits/blocksize);
        % ALWAYS continue until the end, no matter what
    else
        % continue until participants misses 2 in a row
        if numhits < blocksize
            % fail
            attempt = attempt + 1;
            if attempt > 2
                % failed twice.
                %
                % score = highest span completed (the last blocksize) PLUS
                % the proportion you got right on this span size
                score = (blocksize-1) + ((numhits+lasthits)/(blocksize*2));
                % they have missed TWO IN A ROW, quit!
                break;
            end 
        else
            % win
            if attempt == 1
                % SKIP to the next level
                skip = 1;
                % stay at attempt 1
            else
                % this was the second attempt
                % no need to skip ahead, just reset to attempt 1
                attempt = 1;
            end
        end
    end
    
    end
end

%% WRAP-UP
% exit message
WriteCentered(mainwindow, 'This task is complete.  Good work!  Don''t worry about any numbers you missed--nobody gets them all!', ...
    textcenter, textheight, fgcolor, 25, 1.25);
Screen('Flip', mainwindow,0);
getKeys;

fclose(outfile);
end