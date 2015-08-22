% score = listeningspan(mainwindow,fgcolor,bgcolor,highlighted,TFtime,datafolder,subjno, randspan, soundfilefolder, title, latency)
%
% !!NOTE!!: This task is OUTDATED.  The newer listening span task, lspan.m, is
% preferred.  But, this task is still here in case you want to keep using
% it.
%
% 1st of 4 tasks for the Working Memory Battery (see wmbattery).  In this
% task, subjects listen to sentences and make True/False judgments about them.
% After each set of sentences, they have to recall the last word from each
% sentence.  An additional rule is that the first word participants recall
% may not be the word from the last sentence.
%
% Trial-by-trial data is saved to disk in folder DATAFOLDER within the
% function, based on parameter SUBJNO (subject number).  The function also
% returns scalar SCORE.  The meaning of SCORE depends on which test format
% you are using (controlled by RANDSPAN); see help for wmbattery.m for
% more information
%
% The test is displayed on window MAINWINDOW with colors FGCOLOR and
% BGCOLOR.  Nag messages when the subject is not properly completing the
% True/False task are displayed in color HIGHLIGHTED.  Subjects have TFTIME
% seconds to complete the True/False judgment; the default is 2 seconds.
%
% Requires listeningspandata.csv, a CSV file with the target words, and a
% folder of the audio stimuli.  Parameter SOUNDFILEFOLDER specifies the
% location of the audio stimuli and is set in wmbattery.m; by default this
% is 'listeningspan/'
%
% Parameter RANDSPAN controls the order in which the sets are presented.
%   0 - present in order of ascending size (up to a maximum of 8) until
%         the participant misses both attempts at a given size (default)
%   1 - present sets in a random order (RECOMMENDED).  only set sizes 2-6
%         are used
% See wmbattery.m for further discussion of this
%
% Optional parameter TITLE is the title of the test, as displayed to the
% subject.  Default is 'PART ONE' since this is the 1st task in the
% battery, but this can be changed in case to suit your experiment.
%
% Parameter LATENCY ranges between 0 and 1 controls the timing of the sound
% files.  A lower number results in more precise timing, but setting the
% number TOO low for your system may make the audio sound static-y.  See
% IndividualDifferences.m and the "Low-Latency Audio in Psychophysics
% Toolbox.doc" file in the CogToolbox for more information.
%
% Credits: Recordings - Alex Packard
%
% 11.17.09 - S.Fraundorf - first version
% 11.25.09 - S.Fraundorf - fixed a bug with writing the intended True/False
%                            answers.  added ability to change TITLE.  uses
%                            Wait4Key to respond only to T and F.  files
%                            saved as .csv instead of .txt
% 01.24.09 - S.Fraundorf - added RANDSPAN parameter.  now requires the new
%                            version of listeningspandata.csv, which
%                            contains a column for sound file names
% 02.04.10 - S.Fraundorf - PTB-3 version.  nag message now doesn't show up
%                            until 7 repeated responses (vs. 6 previously)
% 02.05.10 - S.Fraundorf - clarified instructions to S and added wrap-up
%                            screen
% 10.25.10 - S.Fraundorf - rewrote to use PsychPortAudio.  now works on
%                            Macs.
% 06.22.11 - S.Fraundorf - added warning that this is outdated
% 07.05.11 - S.Fraundorf - added LATENCY parameter
% 08.24.12 - S.Fraundorf - improved stimulus timing by getting the times
%                            directly from Screen('Flip').  Updated
%                            instructions on how to enter DONE.

function score = listeningspan(mainwindow, fgcolor, bgcolor, highlighted, TFtime, datafolder, ...
    subjno, randspan, soundfilefolder, title, latency)

%% --DEFAULT PARAMETERS--
if nargin < 11
  latency = 0.015; % default latency  
  if nargin < 10
    title = 'PART ONE.'; % default title is PART ONE
    if nargin < 9
        randspan = 0; % default is to abort after 2 fails
    end
  end
end

%% --SET UP WINDOWS--
rect = Screen('Rect', mainwindow); % get window size
TextSize = Screen('TextSize', mainwindow); % get font size

textcenter = floor(rect(3) ./ 2);
textheight = floor(rect(4) ./ 2);

%% --SET UP AUDIO--
SOUNDFREQ = 48000;
SOUNDCHANNELS = 1;
InitializePsychSound;
pahandle = PsychPortAudio('Open', [], 1, 1, SOUNDFREQ, SOUNDCHANNELS, [], latency);

%% -- CELL ARRAY INDICES --
TRUTH = 1;
MEMWORD = 2;
FILENAMES = 3;

%% -- KEY INDICES--
letterT = KbName('t');
letterF = KbName('f');

%% -- RECALL TEST INSTRUCTIONS --
recallinstructions = ['Type in the last word from each sentence.  Press Enter after each word.  '...
    'Once you have entered all the words you can remember, type DONE into the next empty box.'];

%% -- OPEN FILES --
% stimuli
infile=fopen('listeningspandata.csv');
testitems = textscan(infile,'%d%s%s','Delimiter',','); % read in all the items
fclose(infile);

% parse the items into sets
listposition = 1; % initialize position on list of items
% practice blocks
for blocknum=1:2
    for trialinblock=1:2
      pracblocks{blocknum}{TRUTH}(trialinblock) = testitems{TRUTH}(listposition);
      pracblocks{blocknum}{MEMWORD}{trialinblock} = testitems{MEMWORD}{listposition};
      pracblocks{blocknum}{FILENAMES}{trialinblock} = testitems{FILENAMES}{listposition};
      listposition = listposition+1;
    end
end
% test blocks
blocknum = 1;
for level=1:7 % 7 levels = set sizes of 2-8
  for blockinlevel=1:2
      for trialinblock=1:(level+1)
        blocks{blocknum}{TRUTH}(trialinblock) = testitems{TRUTH}(listposition);
        blocks{blocknum}{MEMWORD}{trialinblock} = testitems{MEMWORD}{listposition};
        blocks{blocknum}{FILENAMES}{trialinblock} = testitems{FILENAMES}{listposition};
        listposition = listposition+1;
      end
      blocknum = blocknum+1;      
  end
end
% this creates a cell array of "blocks", each of which then contains lists of
% soundfile names, T/F answers, and target words
clear testitems;
% clear the raw data once the list of blocks is assembled

% put the blocks in order
if ~randspan % ascending order
    blockorder = 1:(numel(blocks));
else
    % randomized block order
    numblocks = 10; % only set sizes 2, 3, 4, 5, 6 are used.  these are the first 10 blocks
    blockorder = randperm(numblocks);
    % note that practice blocks are never randomized
end

% subject data
outfile=fopen([datafolder 'listening' num2str(subjno) '.csv'], 'w');
fprintf(outfile,'BLOCKID,NUMINBLOCK,TARGET,TARGTF,SUBJTF,COR_TF,TFTIME,RECALLED?\n');

soundfilefolder = makeValidPath(soundfilefolder);

%% -- SHOW INSTRUCTIONS --
taskinstructions = [title '|The experiment is broken down into different sections.|' ...
    'In each section, you will be given a group of sentences.|' ...
    'Listen to each sentence in the section.  Then judge whether it makes sense (T) or doesn''t make sense (F).|' ...
    'Be sure to make your judgment quickly.|'...
    'After the final sentence of the section, you will be asked to type in the LAST WORD of EACH of the sentences in that section.|'...
    'The first word that you type must NOT be the word from the last sentence that you heard.  Any other order is OK.|'];
if randspan == 0
    taskinstructions = [taskinstructions 'As you progress through the experiment, the sections may get longer.'];
else % they vary in length randomly
    taskinstructions = [taskinstructions 'The sections will vary in length.  Some will be easy and some will be hard.  We know that you probably won''t remember everything, but just do the best you can.'];
end
InstructionsScreen(mainwindow,fgcolor,bgcolor,taskinstructions);

%% -- PRACTICE --
lastresp = -1; % initialize run tracker
respinrow = 0; % initialize run tracker
for blocknum=1:2
    % initialize stuff
    responses = repmat(-1,1,2); % clear the T/F responses
    hits = zeros(1,2); % clear the memory HITS
    tftimes = zeros(1,2); % clear the T/F rts
    
    % show each word
    for iteminlist = 1:2

        % make sure display is clear
        Screen('Flip',mainwindow,0);
        
        % load & buffer the sound
        audiofortrial = wavread([soundfilefolder pracblocks{blocknum}{FILENAMES}{iteminlist}]);
        PsychPortAudio('FillBuffer', pahandle, audiofortrial');
        
        % play it and wait it for finish
        PsychPortAudio('Start',pahandle);
        PsychPortAudio('Stop',pahandle,1);
        
        % show T/F display
        WriteCentered(mainwindow, '(T)rue or (F)alse?', textcenter, textheight, fgcolor);
        starttime = Screen('Flip', mainwindow,0);
        
        % collect True/False response
        [tftimes(iteminlist) keybresponse] = Wait4KeyTimed(TFtime,[letterT letterF]);
        tftimes(iteminlist) = tftimes(iteminlist) - starttime; % change CPU time to RT
        if tftimes(iteminlist) > TFtime % time out
            WriteCentered(mainwindow, 'TOO SLOW!', textcenter, textheight, highlighted);
            Screen('Flip', mainwindow);
            WaitSecs(1);            
        elseif keybresponse(letterT) && keybresponse (letterF) % both letters were pressed
            WriteCentered(mainwindow, 'Please press either (T)rue or (F)alse only!!', textcenter, textheight, highlighted);
            Screen('Flip', mainwindow);
            WaitSecs(1);
        elseif keybresponse(letterT)
            responses(iteminlist) = 1;
        elseif keybresponse(letterF)
            responses(iteminlist) = 0;
        else % bad response
            WriteCentered(mainwindow, 'Please press (T)rue or (F)alse only!!', textcenter, textheight, highlighted);
            Screen('Flip', mainwindow);
            WaitSecs(1);            
        end
                
        % check against the subject hitting the same key over and over
        if responses(iteminlist) == lastresp
            respinrow = respinrow + 1;
        else
            respinrow = 0;
        end
        lastresp = responses(iteminlist); % update the last response
        
    end
    
    % now, do the test
    wordsrecalled = freerecall(mainwindow, 0, 2, fgcolor, bgcolor, recallinstructions, 0);
    Screen('Flip', mainwindow); % blank screen
    
    % check each target word to see if it was recalled
    for j=1:2
        hits(j) = ~isempty(strmatch(pracblocks{blocknum}{MEMWORD}{j}, wordsrecalled)); % does this word match anywhere in the array of recalled words?
        if j == 2 && strcmp(pracblocks{blocknum}{MEMWORD}{j}, wordsrecalled{1})
             % do NOT count a hit if they recall the last word first
             WriteCentered(mainwindow, 'Remember, the first word you enter MAY NOT be the word from the last sentence.', textcenter, textheight, fgcolor);
             Screen('Flip', mainwindow);
             getKeys;
             hits(j) = 0;
        end
            
        % save the data for this item
        % fprintf(outfile,'BLOCKID,NUMINBLOCK,TARGET,TARGTF,SUBJTF,COR_TF,T
        % FTIME,RECALLED?\n');        
         fprintf(outfile,'P%d,%d,%s,%d,%d,%d,%2.4f,%d\n',...
             blocknum, j, pracblocks{blocknum}{MEMWORD}{j},...
             pracblocks{blocknum}{TRUTH}(j),responses(j),(blocks{blocknum}{TRUTH}(j) == responses(j)),...
             tftimes(j), hits(j));
    end
    
     % evaluate outcome     
     numhits = sum(hits);
     if numhits == 2 % all items were recalled
        WriteCentered(mainwindow, 'Great!  You got both words correct.', textcenter, textheight, fgcolor);
     else
        failmessage = ['The correct answers were ' upper(pracblocks{blocknum}{MEMWORD}{1}) ' and ' upper(pracblocks{blocknum}{MEMWORD}{2}) '.'];
        WriteCentered(mainwindow, failmessage, textcenter, textheight, fgcolor);
        WriteCentered(mainwindow,'Those were the last words from the 2 sentences.', textcenter, textheight+(TextSize*2), fgcolor);
     end
     Screen('Flip', mainwindow,0); % show this message
     getKeys;
     
     % explain what happens next
     if blocknum==1
        WriteCentered(mainwindow, 'Let''s try one more practice round.', textcenter, textheight, fgcolor);
     elseif randspan
        WriteCentered(mainwindow, 'OK, now for the actual experiment.  Remember, some sections will be easier than others, but just do the best you can.', textcenter, textheight, fgcolor);        
     else
        WriteCentered(mainwindow, 'OK, now for the actual experiment.', textcenter, textheight, fgcolor);
     end
     Screen('Flip', mainwindow,0); % show the msg
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
    blocksize = size(blocks{blocknum}{TRUTH},2);
    
    % initialize stuff
    responses = repmat(-1,1,blocksize); % clear the T/F responses
    hits = zeros(1,blocksize); % clear the memory HITS
    tftimes = zeros(1,blocksize); % clear the T/F rts
    
    % show each word
    for iteminlist = 1:blocksize
        
        % make sure display is clear
        Screen('Flip',mainwindow,0);
        
        % load & buffer the sound
        audiofortrial = wavread([soundfilefolder blocks{blocknum}{FILENAMES}{iteminlist}]);
        PsychPortAudio('FillBuffer', pahandle, audiofortrial');
        
        % play it and wait it for finish
        PsychPortAudio('Start',pahandle);
        PsychPortAudio('Stop',pahandle,1);
                                          
      % do T/F display
      WriteCentered(mainwindow, '(T)rue or (F)alse?', textcenter, textheight, fgcolor);
      starttime = Screen('Flip', mainwindow,0);
      
      % collect True/False response
      [tftimes(iteminlist) keybresponse] = Wait4KeyTimed(TFtime,[letterT letterF]);
      tftimes(iteminlist) = tftimes(iteminlist) - starttime; % change CPU time to RT
      if tftimes(iteminlist) > TFtime % time out
          WriteCentered(mainwindow, 'TOO SLOW!', textcenter, textheight, highlighted);
          Screen('Flip', mainwindow);
          WaitSecs(1);
      elseif keybresponse(letterT) && keybresponse (letterF) % both letters were pressed
          WriteCentered(mainwindow, 'Please press either (T)rue or (F)alse only!!', textcenter, textheight, highlighted);
          Screen('Flip', mainwindow);
          WaitSecs(1);
      elseif keybresponse(letterT)
          responses(iteminlist) = 1;
      elseif keybresponse(letterF)
          responses(iteminlist) = 0;
      else % bad response            
           WriteCentered(mainwindow, 'Please press (T)rue or (F)alse only!!', textcenter, textheight, highlighted);
           Screen('Flip', mainwindow);
           WaitSecs(1);
      end
                    
      % check against the subject hitting the same key over and over
      if responses(iteminlist) == lastresp
          respinrow = respinrow + 1;
          if respinrow > 6 % hit the same key 6 times in a row or more
               % nag the subject
               WriteCentered(mainwindow, 'Are you pressing the same key over and over?', textcenter, textheight, fgcolor);
               WriteCentered(mainwindow, 'Please judge each statement as (T)rue or (F)alse.', textcenter, textheight+(TextSize*2), fgcolor);
               Screen('Flip', mainwindow);
               getKeys;
          end
      else
          respinrow = 0;
      end
          lastresp = responses(iteminlist); % update the last response
            
    end % move on to the next item
        
    % now, do the test
    wordsrecalled = freerecall(mainwindow, 0, blocksize, fgcolor, bgcolor, recallinstructions, 0);
    Screen('Flip', mainwindow,0);

    % get block name for saving data
    if ~randspan
        blockname = [num2str(blocksize) '-' num2str(2-mod(blocknum,2))];
    elseif mod(blocknum, 2) == 0
        % "a" blocks
        blockname = [num2str(blocksize) 'a'];
    else
        blockname = [num2str(blocksize) 'b'];
    end     
    
    % check each target word to see if it was recalled
    for j=1:blocksize
        hits(j) = ~isempty(strmatch(blocks{blocknum}{MEMWORD}{j}, wordsrecalled)); % does this word match anywhere in the array of recalled words?
        if j == blocksize && strcmp(blocks{blocknum}{MEMWORD}{j}, wordsrecalled{1})
             % do NOT count a hit if they recall the last word first
             WriteCentered(mainwindow, 'Remember, the first word you enter MAY NOT be the word from the last sentence.', textcenter, textheight, fgcolor);
             Screen('Flip', mainwindow);
             getKeys;
             hits(j) = 0;
        end
            
        % save the data for this item
        % fprintf(outfile,'BLOCKID,NUMINBLOCK,TARGET,TARGTF,SUBJTF,COR_TF,T
        % FTIME,RECALLED?\n');        
         fprintf(outfile,'%s,%d,%s,%d,%d,%d,%2.4f,%d\n',...
             blockname, j, blocks{blocknum}{MEMWORD}{j},...
             blocks{blocknum}{TRUTH}(j),responses(j),(blocks{blocknum}{TRUTH}(j) == responses(j)),...
             tftimes(j), hits(j));
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
instructions = ['Good work!  This task is complete!|'...
    'We know that this was an especially difficult task.  But, it is those difficulties ' ...
    'that we are researching.  We definitely don''t expect that anyone will remember all the ' ...
    'words!'];
InstructionsScreen(mainwindow, fgcolor, bgcolor, instructions);

% close the audio channel
PsychPortAudio('Close',pahandle);

% close the file
fclose(outfile);
end