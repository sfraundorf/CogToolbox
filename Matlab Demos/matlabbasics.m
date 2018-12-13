% demonstrates some basic features of MATLAB and Psychophysics Toolbox.
% note that you will need PTB and the CogToolbox installed for this to
% run.
%
% type:
%   edit matlabbasics
% to see some example code!
%
% 01.28.10 - S.Fraundorf
% 07.28.10 - S.Fraundorf - added changeFolder to the demo.
% 12.15.11 - S.Fraundorf - added demos of some more things (keyboard responses,
%                           tests for inequality) and further explanation


% the %s indicate a COMMENT.  everything after this is not executed by Matlab;
% it's just a note to the humans reading your code.  commenting your code is a
% really good idea to help you keep track of what it's doing, and ESPECIALLY so
% other people can understand it

%% LET'S GET STARTED

% When you want to open a file, MATLAB has a folder where it looks for
% that file by default.  This is called MATLAB's "Working Directory" or
% "Current Directory."
%
% If the file is NOT in that folder, MATLAB won't be able to find it (unless
% you tell MATLAB where else to look).  This can cause program crashes if,
% for example, your experiment tries to open a list of stimuli but MATLAB
% can't find it.
% 
% A good thing to do is start your experiment with the changeFolder
% command.  changeFolder updates MATLAB's working directory so that, by
% default, MATLAB will look in the same folder as your experiment for
% files:

changeFolder;

% changeFolder is part of the CogToolbox, so it won't work on a computer
% where you haven't installed that toolbox

%% VARIABLES

% let's assign a value to a variable
a = 2;
 % the semicolon suppresses output to the main MATLAB window
 % normally, this is what we want (to avoid cluttering up the screen)
 % however, if your program is malfunctioning, you can remove the semicolons
 % to watch what your program is doing, and diagnose the problem.

a + 5 % performing an operation
 % this one doesn't have a semicolon, so the output is seen in the MATLAB
 % window
 
 % note that when we typed "a + 5", it didn't actually change the value of a:
 a
 % it's still 2.  "a+5", by itself, just SHOWS US the value of what a+5 would be.
 % if we wanted to actually change the value of a, we would have
 % to assign to "a" the result of "a+5":
 a = a + 5;

b = sqrt(a); % sqrt is a function.  we are assigning the result of sqrt(a) to b
 % to get a description of any function, type: help functionname
 % e.g.   help sqrt
 % that will also tell you the arguments that the function takes
 

c = [2,3,5;4,8,10] % this makes a matrix
 % commas separate columns
 % semicolumns separate rows
numel(c) % total number of elements in this matrix
size(c)  % vector with the dimensions of the matrix
% numel & size also work for cell arrays

c(1,2) % refers to one value
c(1,:) % refers to a whole row

rand('twister',sum(100*clock)); % set up random number generator (by picking a table)
% if you forget to initialize the random number generator, you will get the
% SAME random numbers every time
%
% the InitExperiment function in the CogToolbox will also do this for you

%% two percentage signs creates a cell
% and then you can run just what's inside the cell
% this is useful for TESTING

%% READING IN YOUR TRIAL LISTS
subjno = inputnumber('Please enter subject number: ',1,99);
% use single quotes when using a text string

% the mod function does REMAINDER DIVISION
listno = mod(subjno,4) + 1;
% the remainder of a division can be either 0, 1, 2, or 3
% then we add 1 to get 1, 2, 3, or 4
% this allows us to cycle through 4 different lists

% READ IN OUR DATA FOR ALL THE TRIALS
filename = ['list' num2str(listno) '.txt'];

% i'm just adding this in here to override the filename because we don't
% actually have 4 lists in this demo
filename = 'magicword.txt';

infile = fopen(filename);

% read the file using textscan
trialdata = textscan(infile, '%s%d', 'Delimiter', ',');
% the %s and %ds work the same as printing TO a file (see below)
% 'Delimiter', ',' tells MATLAB the file is comma-delimited

% assign column numbers to variable names so we can remember them later
MAGICWORDS = 1;
MAXTIME = 2;

fclose(infile);

%% SAVING DATA FROM YOUR EXPERIMENT
filename = ['subject' num2str(subjno) '.csv'];
 % the [ ] are used to combine several strings into one
 % this string has three parts to it:
 %   (1) the word 'subject'
 %   (2) the subject number.  Use num2str() to convert numbers to strings
 %          str2num() wil convert strings to numbers
 %   (3) the text '.csv''
 % the result is 'subject33.csv'

outfile = fopen(filename,'w'); % the w is for write mode
% a = will append to the end of the existing file
% if you are just READING from the file, you don't need either of these

fprintf(outfile,'NUMGUESS,WORDGUESSED\n');
% HEADER ROW so we know the columns are

%% FOR LOOPS
%for i=1:10   % a FOR loop does something several times.  e.g. do this 10 times
%    % rand returns a random number between 0 and 1.
%    % but suppose we wanted a number between 1 and 4.  we need to MULTIPLY the
%    % original random nunber, and round it off
%    ceil(rand*4) % ceil = round up
%    % floor = round down; round = round to nearest integer
%end

%% SAMPLE EXPERIMENT

guess = '';  % we need to initialize this variable before we start
                   % doing things with it.
                  % i.e., we can't compare the GUESS to anything when we don't know
                  % what guessesmade is
                  % we need to define these things BEFORE we start using
                  % them in the while loop

numtrials = numel(trialdata{1}); % counts the number of entries in the list of items to find out how many trials we have
trialorder=randperm(numtrials); % this will give us the integers from 1-3 in a random order
   % e.g. randperm(10) is a random ordering of the integers 1-10
   % and the # of numbers that we want to generate is based on the # of
   % trials we have.

for trialnum=trialorder % you can also do FOR loops through any arbitrary vector of numbers

   guessesmade = 1;
   % this is inside the FOR loop so it gets reset for each trial

   % a WHILE loop repeatedly does whatever in the while ... end section
%  until some condition is meant
% in this case, until the guess is the same as the magicword
  while ~strcmp(guess, trialdata{MAGICWORDS}{trialnum}) % use strcmp not = to compare strings
                                % ~ is the NOT operator
                                % so DO this WHILE the guess is NOT the magic word
    message = ['You''ve made ' num2str(guessesmade-1) ' guesses.'];
    % why do we have the double apostrophe?
    % if we just use ONE apostrophe, MATLAB will think that's the apostrophe
    % that indicates the end of the string.  the DOUBLE apostrophe is the way
    % to tell MATLAB that you want the apostrophe as part of the string itself
        
    fprintf('This is trial %d \n', trialnum);
    
    t1 = GetSecs;
    guess = inputstring('Guess the magic word: ');    
    t2 = GetSecs;
    % GetSecs returns the time on your computer's internal clock.  this isn't
    % useful by itself, but you can COMPARE 2 GetSecs values to see how many
    % seconds have elapsed
    
    fprintf('Your guess took %2.2f seconds.\n', t2-t1);
    
    %allguesses{guessesmade} = guess;
    % matrix uses ( ) to index - a matrix just holds numbers
    % cell array uses { }
    
    fprintf(outfile, '%d,%d,%s,%2.2f\n', trialnum,guessesmade, guess, t2-t1);
    % format to print with goes inside the quotes
    % %d - digit? integer number, %s - string,
    % %3.2f (floating point) = decimal with 3 digits before decimal & 2 after
    % \n = line break (newline)
    %
    % note that strings of text are in purple
    % but variable names are in black
    
    if strcmp(guess, trialdata{MAGICWORDS}{trialnum}) % an IF statement only executes IF some condition is true
                                % in this case, if guess = magicword
        fprintf('Good job!\n');                       
        break; % this takes us out of the WHILE loop
    end
    fprintf('Wrong guess!\n'); % \n = newline ... it's like pressing the ENTER key
    guessesmade = guessesmade + 1;
  end
end


%% DEMO OF MORE COMPLEX FLOW STRUCTURES

%for trialnum=1:10
%    trialnum
%    if trialnum == 5  % use double equal sign == to COMPARE things
%        % || = or
%        % && = and
%        % ~= = NOT equal  (there's no key on the keyboard for the inequality sign so we use this)
%        'hey, trialnum is 5'
%    elseif trialnum == 6  % an ELSEIF creates a decision tree
%                          % if the original IF statement is FALSE
%                          % try THIS instead
%        'hey, trialnum is 6'
%    else   % if NONE of the above 
%        'trialnum is neither 5 nor 6'
%    end
%end

%% KEYBOARD RESPONSES
% The way MATLAB keeps track of what keyboard keys get pressed is that each key
% on the keyboard has a different number.

% The problem is that different computers have different keyboards (e.g. Mac vs
% PC, desktop vs laptop).  To get MATLAB to use a STANDARD set of keyboard
% codes, include this line before you do anything with the keyboard:
KbName('UnifyKeyNames')

% Now, you can get & store the numerical code that corresponds to a particular
% key
SpaceBarNumber = KbName('space');
% This gets us the number that corresponds to the spacebar.  Later, we can use
% this to see if the user is pressing the spacebar or not.

% Another example (we are getting a vector of TWO numbers here):
YesNo = [KbName('y') KbName('n')];

t1 = GetSecs;
fprintf('Press Y or N to end the experiment.\n');
[t2 key] = Wait4Key(YesNo);
% Wait4Key waits until one of a set of keys (that you specify) is pressed.  The
% list of keys you will accept is listed in a vector.  Here, we will accept only
% the two keys in the vector called YesNo ... which are the 'y' and 'n' keys
% (see above where we defined this vector)
%
% The outputs from the function will tell you how long it took someone to press
% the key, and what key they pressed.  This is good for doing reaction time
% experiments.

done = 1;
if done
   % "if variablename" is the same as "if variablename > 0"
   fprintf('Done with experiment\n.');
end

%% WRAP-UP
fclose all;
% need to CLOSE the files that we opened
% we could close them one at a time,  e.g. fclose(outfile);
% or just do fclose all;