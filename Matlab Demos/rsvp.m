% rsvp.m
%
% This is a demo of how you could do an RSVP experiment in Matlab.
%
% Type:
%   edit rsvp
% for some sample code
%
% At some point, I will develop this into a "real" RSVP function
%
% 01.28.10 - S.Fraundorf
% 08.24.12 - S.Fraundorf - Demonstrated getting the timing information
%                            directly from Screen('Flip') for more accurate
%                            timing.

% colors are 3 numbers - red, green, blue
    red = [255 0 0];
    blue = [0 0 255];
    purple = [255 0 255];
    white = [255 255 255];
    black = [0 0 0];
    
    bgcolor = purple;
    
    % specify these so that we can use them later
    textsize = 32;
    textfont = 'Arial';
    
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

message = 'This is a test message.';

[word message] = strtok(message);
% string tokenizer returns two variables: the next word, AND what's left
% then, we replace the original message with what's left
% so we can keep doing this over and over
%
% we use the brackets [word message] because the function returns 2
% variables

fliptime = GetSecs;
% We will use the variable "fliptime" to keep track of when the last
% Screen('Flip') occurred -- that is, when we last put a new stimulus up.
% This gets updated throughout the loop, but we need to give it some initial
% value frst.  If we try to refer to the variable like "fliptime" and it has
% not been assigned any value yet, MATLAB doesn't know what to do and your
% experiment will crash.

while ~isempty(word) % do this until there are no more words left
     % ~ is the NOT sign
     % i.e., the loop continues until we reach the end of message
    
     % if we wanted to convert to all-uppercase...
     %word = upper(word); 
     % there is also lower(word)
     % and initialCapsOnly(word)

     % We write the word on the next display (that hasn't actually put on
     % the screen yet).
     WriteCentered(mainwindow,word,XCenter,YCenter,red);
     % The third argument of the Flip statement controls exactly when the
     % word gets puts on the screen.  We want to put it up on the screen
     % after the inter-stimulis interval has elapsed.  So, we add "ISI"
     % number of seconds to the time of the last display, then put the word
     % up.
     fliptime = Screen('Flip',mainwindow,fliptime+ISI);
     % And, we save the time of THIS display as the new fliptime.  (That's what
     % the left hand of the equation is.)  This allows us to control how
     % long the word stays on the screen.  We've previously stored the
     % stimulus duration we want as the variable "presentationtime".  What
     % we want is for the screen to go blank after "presentationtime"
     % seconds from the fliptime.  Thus, the time of the next flip should
     % be:   fliptime+presentationtime
          
     % the framebuffer normally gets cleared after we do the flip
     % so flipping AGAIN will clear the screen because it's flipping in a
     % BLANK SCREEN
     fliptime = Screen('Flip',mainwindow, fliptime+presentation);
          
     % The ISI is handled above in line 86.  After the screen goes blank,
     % we wait ISI seconds before we put the next stimulus up.
     
     % get the next word
     [word message] = strtok(message);
end

Screen('CloseAll');

% Ctrl+C = get out of a stuck experiment