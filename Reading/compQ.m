% [answer resptime] = compQ(mainwindow, fgcolor, bgcolor, question,showlegend)
%
% Asks a comprehension question on window MAINWINDOW with text color
% FGCOLOR on background color BGCOLOR, then asks comprehension question
% QUESTION afterwards.
%
% If SHOWLEGEND is TRUE, a legend indicating which key is YES and which is NO
% is displayed during the comprehension questions.  This can be useful
% during practice trials.  (The default is to not do this.)
%
% Default response keys are D for YES (answer = 1) and K for NO (answer=0).
% Right now, I don't have an option to change this -- sorry.
%
% Optionally, the function also returns the time (in seconds) taken to
% answer the question.
%
% The task can be aborted early by pressing the F3 key.  This returns -1
% as the answer and can be used by your main script to quit the experiment.
%
% 07.11.10 - S.Fraundorf - first version
% 07.12.10 - S.Fraundorf - return RTs as well
% 06.14.11 - S.Fraundorf - call to GetSecs now has correct capitalization
%                           (faster)
% 06.20.11 - S.Fraundorf - 2 response key options are now displayed on the
%                           same line (when displayed), by popular demand
%                           :)
% 01.19.12 - S.Fraundorf - Gets the starting time for each question directly
%                          from the Flip statement for more accurate
%                          timing.  Changed exit key to F3.

function [answer resptime] = compQ(mainwindow, fgcolor, bgcolor, question,showlegend)

%% DEFAULT PARAMETERS
if nargin < 5
    showlegend = false;
end

%% GET SCREEN & FONT PARAMETERS

rect = Screen('Rect',mainwindow); % get the screen size

% starting X & Y coordinates
startx = 50; % margin on left
starty = rect(4)/2; % middle of the screen

if showlegend
    % set up legend if needed
    textsize = Screen('TextSize', mainwindow);
    legendy = starty + (textsize * 2.5);
end

%% SET UP KEY CODES
ExitKey = KbName('F3'); % abort task if F3 pressed
RespKeys = [KbName('K') KbName('D') ExitKey]; % K= no, D = yes

%% DO THE COMPREHENSION QUESTION
    
% blank screen + question
Screen('FillRect', mainwindow, bgcolor);
WriteLine(mainwindow, question, fgcolor, startx, startx, starty);
    
% legend
if showlegend
   newx = WriteLine(mainwindow, '(D) Yes', fgcolor, startx, startx, legendy);
   WriteLine(mainwindow, '(K) No', fgcolor, startx, startx+(newx*2), legendy);
end
    
% show
[garbage t1] = Screen('Flip',mainwindow);
    
% get the response
[t2 keyCode] = Wait4Key(RespKeys);
resptime = t2-t1;
if keyCode(ExitKey)==1
    answer = -1; % abort key pressed
else
    answer = (keyCode(RespKeys(2))==1);
end