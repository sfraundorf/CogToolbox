% selfpaced.m
%
% This is a demo of how you could do a self-paced reading experiment in Matlab.
%
% Type
%   edit selfpaced
% for some sample code.
%
% This is rudimentary script for only the most straightforward self-paced
% reading experiment and is intended for programming demonstration
% purposes.  The movingwindow.m function included with the toolbox is a
% much fancier self-paced reading function if you actually want to run an
% experiment.
%
% 01.28.10 - S.Fraundorf
% 08.24.12 - S.Fraundorf - Demonstrated how to more accurately measure RTs by
%                            getting the time from Screen('Flip').  Updated exit
%                            key.  Added additional explanatory comments
%                            and updated the help text to refer to
%                            movingwindow.m
% 08.14.14 - S.Fraundorf - Fixed a bug that could prevent this demo from running.
%                            Thanks to Olga Aizenberg for the pointer.

% colors are 3 numbers - red, green, blue
    red = [255 0 0];
    blue = [0 0 255];
    purple = [255 0 255];
    white = [255 255 255];
    black = [0 0 0];
    
    bgcolor = black;
    fgcolor = white;
    
    % specify these so that we can use them later
    textsize = 32;
    textfont = 'Courier'; % MONOSPACED font so that the underscores are equal to the width of the letters
    % if the width of the letters varied, they wouldn't be the same as the
    % underscores
    
    presentationtime = 0.2; % time per word
    ISI = 0.2; % this in terms of seconds (= 200 ms)

% this is the command you do to set up your graphics
[mainwindow rect] = Screen('OpenWindow',0, bgcolor);
% with a background color of purple
% rect is the size of the mainwindow
% the 0 is just to make it the mainwindow

rect = Screen('Rect',mainwindow);
% this is another way of getting the window size
% like if you forgot to get it when you originally opened the window

Screen('TextSize',mainwindow,textsize); % specify text size
Screen('TextFont',mainwindow,textfont); % specify text font
% we set the textsize and textfont variables back at the top of the script

XRight=rect(3);
YBottom=rect(4);
XCenter = XRight/2;
YCenter = YBottom/2;

%% SET UP KEY CODES
%KbName('KeyNamesOSX'); % LIST of all the key names it knows
F3Key = KbName('F3');
% keyboard keys are tracked with NUMBERS
% and these numbers may be different across different computers (because
% they have different keyboards)
% this will return the number that corresponds to the F3 key on THIS
% keyboard, so we can use it later

%% DEMO FIND
% demo of find
somevector = [3 5 6 8 10 3 8 1 3 5 6 5 0 30];
threes = find(somevector==3) % returns all the cases where somevector = 3
if isempty(threes)
    fprintf('There are no threes in the vector.\n');
end
fours = find(somevector==4)
if isempty(fours)
    fprintf('There are no fours in the vector.\n');
end

%% SET UP TEXT PARAMETERS

% starting points
startx = 50;
starty = 50;

% for each new trial, you'd want to reset back to these starting points
x = startx;
y = starty;

%% CREATE AN OFF-SCREEN WINDOW AND PUT THE BLANK SPACES IN THAT

message = 'This is a test message.';

% create a separate, off-screen window where we will save the ___s
% so we can COME BACK TO THAT
% all off-screen windows are "copies" of the main window
blankswindow = CreateOffWin(mainwindow, bgcolor, textfont, textsize);

allLetters = find(message ~= ' '); % find everything in the message that's NOT a blank space
message(allLetters) % we can use a VECTOR to index another vector or matrix
 % i.e., use allLetters to work with JUST the elemnets of message that are
 % letters
% COPY message into a new string
blankspaces = message;
blankspaces(allLetters) = '_'; % replace JUST those elements of blankspaces that are letters with _

% this create a window that has the ___s permanently stored on it
WriteLine(blankswindow, blankspaces, fgcolor, x, x, y, 1.25);
% now, whenever we want, we can copy this to the main window

%% START DISPLAYING THINGS
% see rsvp.m for a description of the string tokenizer

[word message] = strtok(message);

while ~isempty(word) % do this until there are no more words left
     
  % go back to the version with all the blanks
  Screen('CopyWindow',blankswindow,mainwindow);
 
  [x y] = WriteLine(mainwindow, word, fgcolor, startx, x, y, 1.25);
  starttime = Screen('Flip',mainwindow);
  % We save the time that this display was put up on the screen as the
  % variable "starttime".
  %
  % That's when the trial started, and when we start to measuring the RT
  % from.  (i.e., your RT is the amount of time that's elapsed since the
  % stimulus onset)

  [keysPressed endtime] = getKeys;
  % getKeys waits forever for ANY key to be pressed
  % getKeys(5) waits for ONLY 5 seconds, and then moves on
  
  % keysPressed is a vector of NUMBERS corresponding to particular keys  
  
  RT = (endtime - starttime) * 1000;
  % Your RT is the time between when the stimulus came up, and the time
  % when the key was pressed.  Psychophysics Toolbox measures this in
  % SECONDS; I multiply by 1000 to get miliseconds
  
  fprintf('%2.2f\n', RT);
  
  if keysPressed == F3Key % if the numerical code for the key pressed 
                           % is the code for F3....
      break; % break will take you out of the WHILE or FOR loop you are in
      % in this case, breaking out of the WHILE loop will take us to the
      % end of the experiment
  end
  
  % wait4Key(keycodes) will only wait for CERTAIN keys to be pressed
  % and doesn't accept others
  % the keycodes that it's waiting for are, again, the numerical keycodes
  % that you get from KbName (see above)
  
  % get the next word
  [word message] = strtok(message);
end

Screen('CloseAll'); % note to self: don't forget this, you dummy!