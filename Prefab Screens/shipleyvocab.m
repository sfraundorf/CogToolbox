% score = shipleyvocab(mainwindow, fgcolor, bgcolor, datafolder, subjno)
%
% Administers the Shipley Vocabulary Scale, a 40-item vocabulary test.  On
% each item, the subject has to match a target word to 1 of 4 words that
% represents the most similar meaning.  The trials get progressively more
% difficult.
%
% Also includes an instructions screen and a practice trial.
%
% Trial-by-trial data is saved to disk in folder DATAFOLDER within the
% function.  The function also returns the total SCORE out of 40.
%
% The test is displayed on window MAINWINDOW with colors FGCOLOR and
% BGCOLOR.  Parameter SUBJNO is the subject number; used to save the data.
%
% Requires shipleyvocabdata.csv, a CSV file with the 1 practice trial + 40
% real trials. (The Vocab Scale itself is under copyright and not
% included.)
%
% 11.25.09 - S.Fraundorf
% 02.22.10 - S.Fraundorf - PTB-3 version.  works across different
%                          keyboards.  moved instructions before font size
%                          change so they are displayed in yr existing font
% 08.22.12 - S.Fraundorf - improved stimulus timing by getting the times
%                            directly from Screen('Flip')

function score = shipleyvocab(mainwindow, fgcolor, bgcolor, datafolder, subjno)

%% -- SHOW INSTRUCTIONS --
instructions = 'In this test, the top word on each screen is printed in CAPITAL LETTERS.  Below it are four other words.|Press the 1, 2, 3, or 4 key to indicate the ONE word which means the same thing, or most nearly the same thing, as the word in capital letters.|If you don''t know, guess.|Be sure to choose the ONE word on each screen that means the same thing as the word in capital letters.|There is no time limit.|We will start with a practice trial.';
InstructionsScreen(mainwindow,fgcolor,bgcolor,instructions);

%% --SET UP WINDOWS--
rect = Screen(mainwindow,'Rect'); % get window size

oldsize = Screen('TextSize', mainwindow); % get current font size
if oldsize < 48 % min font size
    Screen('TextSize', mainwindow, 32);
    TextSize = 48;
else
    TextSize = oldsize;
end

textloc = floor(rect(3) ./ 3); % X location of text
cueheight = floor(rect(4) ./ 5); % Y location of cue
respheight = floor(rect(4) ./ 3); % Y location of response options

ISI = 0.66; % 660 ms between trials

%% --KEYBOARD SETUP--
% kb names
KbName('UnifyKeyNames');
responseoptions = [KbName('1!') KbName('2@') KbName('3#') KbName('4$')];

%% -- OPEN FILES --
% stimuli
infile=fopen('shipleydata.csv');
testitems = textscan(infile,'%s%s%s%s%s%d','Delimiter',','); % read in all the items
fclose(infile);

% indices to array of stimuli
CUE = 1;
ANSWER = 6;

% subject data
outfile=fopen([datafolder 'shipley' num2str(subjno) '.txt'], 'w');
fprintf(outfile,'CUE,ANSWER,RESPONSE,CORRECT?,RT\n');

%% -- RUN THE ACTUAL TEST! --
score = 0;        % initialize score
t1 = GetSecs;     % initialize time tracker
for listposition=1:41 % #1 is practice trial, plus 40 real items

    % -- display --
    % cue
    WriteLeft(mainwindow,upper(testitems{CUE}{listposition}),textloc,cueheight,fgcolor);
    textheight = respheight;
    % 4 possible targets
    for i=1:4
        text = ['(' num2str(i) ') ' lower(testitems{i+1}{listposition})];
        WriteLeft(mainwindow,text,textloc,textheight,fgcolor);
        textheight = textheight + TextSize*2; % space to next line
    end
    % copy the finished display over after the ISI between trials
    t1 = Screen('Flip',mainwindow,t1+ISI);
    
    % -- get response --
    [RT resp] = Wait4Key(responseoptions); % get a response from the user
    resp = KbName(find(resp==1,1)); % convert keycode to digit of response (pt 1)
    resp = str2double(resp(1)); % pt 2
    RT = RT - t1; % calculate RT
    % evaluate
    correct = (resp == testitems{ANSWER}(listposition));
    if correct && listposition > 1
        score = score + 1; % practice trial doesn't count towards score
    end

    % -- clear the screen --
    t1 = Screen('Flip', mainwindow, 0);
    
    % -- save the data for this item --
    % reminder:fprintf(outfile,'CUE,ANSWER,RESPONSE,CORRECT?,RT\n');
    fprintf(outfile,'%s,%d,%d,%d,%3.4f\n', ...
      testitems{CUE}{listposition},testitems{ANSWER}(listposition),resp,correct,RT);
    
    % -- if this is the practice, display feedback before continuing --
    if listposition==1
        % assemble feedback text
        if correct % they got it right
            text = ['That''s right.  ' upper(testitems{testitems{ANSWER}(listposition)+1}{listposition}) ' is the most similar word to ' ...
                upper(testitems{CUE}{listposition}) ', so it is the best answer.  Now for the actual test!'];
        else % they got it wrong
            text = ['In this case, ' upper(testitems{testitems{ANSWER}(listposition)+1}{listposition}) ' would have been the best answer.' ...
                '  It is most similar in meaning to ' upper(testitems{CUE}{listposition}) '.  Now for the actual test!'];
        end
        % display in center
        WriteCentered(mainwindow,text,floor(rect(3)./2), floor(rect(4)./2), fgcolor, 20,1.25);
        Screen('Flip',mainwindow,0); % display
        % wait for keypress
        getKeys;
        t1 = Screen('Flip',mainwindow,0); % clear screen
    end
end
% done with the test!

%% --WRAP-UP--

fclose(outfile); % close output file

Screen('TextSize', mainwindow, oldsize); % reset font size