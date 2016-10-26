function [string,startRT,endRT] = GetEchoStringCuedT4(window,msg,x,y,cueColor,bgColor,respColor,displaytype,ghost,acceptblanks,endwithtab)
%
% [string,startRT,endRT] = GetEchoStringCuedT4(window,msg,x,y,cueColor,bgColor,respColor,displaytype,ghost,acceptblanks,endwithtab)
%
% Gets a subject's response to string MSG and displays it as they're typing.
% (MSG can be '' if you don't want a cue displayed.)  Entry is terminated
% by <return> or <enter> and subject can backspace.
%
% By default, this version won't accept an empty string response, so subject
% can't just hit return/enter.
%
% Returns:
%   String  : The response that the user entered
%   StartRT : Time from presentation until the FIRST key press
%   EndRT   : Time from presentation until the user presses enter to
%              FINISH entering the string.
%
% Parameters:
%  window - pointer to the window this on which this will be displayed
%  msg - the CUE for the subject
%  x,y - center of the cue/target display
%  cueColor - clut of the CUE word
%  respColor - clut to display the subject's response.  this can be the same
%    as cueColor if you don't want the response in a different color.
%  bgColor - clut of screen background color
%  displaytype - 'Line' for an underline, 'Box' around the whole area,
%    'None' or anything else for no display.  This breaks compatibility
%    with previous versions, sorry :(
%  ghost - optional.  ghost the answer afterwards?  default is 0 (don't).
%  acceptblanks - do you want to accept blank responses?
%  accepttab - accept a TAB key as ending the response (in addition to
%     Enter/Return).  defautl is 0 (don't)
%
% 1st version - Jason Finley - modified from Psychtoolbox GetEchoString
%                              to collect RTs and prevent empty responses
%     7.22.08 - S.Fraundorf - added choice of line vs. box
%                             collect EndRT as well
%    11.12.09 - S.Fraundorf - added ghosting option, cleaned up code
%    11.23.09 - S.Fraundorf - fixed the time by using GetSecs throughout.
%                             the timing could probably be made more
%                             accurate, though.
%    12.29.09 - S.Fraundorf - fixed the order of parameters in the helptext
%                             fixed an error with the LINE display option
%    02.02.10 - S.Fraundorf - PTB-3 version.  slow.
%    02.05.10 - S.Fraundorf - marginal performance improvements (but still
%                             poor compared to PTB-2 version)
%    09.22.10 - S.Fraundorf - added option to ALLOW blank/empty responses
%    02.14.11 - S.Fraundorf - if ghosting the previous response, keeps the
%                             screen in the response buffer so you can
%                             continue drawing on it
%    06.16.11 - S.Fraundorf - parameter to accept TAB key as confirming the
%                             response.  useful for doing this >1 time on a
%                             screen
%    09.21.11 - S.Fraundorf - fixed default setting not terminated with a ;
%    10.26.16 - S.Fraundorf - use textures

%% SET DEFAULT ARGUMENTS
if nargin < 11
    endwithtab = 0;
    if nargin < 10
      acceptblanks = 0;
      if nargin < 9
        ghost = 0;
        if nargin < 8
           displaytype = 'None';
           if nargin < 7
             respColor=cueColor;
           end
        end
      end
    end
end

%% KEYBOARD SETTINGS
KbName('UnifyKeyNames'); % otherwise diff btwn Mac and Windows

ListenChar(2);
% this makes it so that what the user types doesn't bleed through into the Matlab command window
% otherwise the user can execute Matlab commands during your experiment!

%% SET UP INITIAL PARAMETERS
string='';
respondedyet=false; % this tracks whether or not they've hit a key yet

rect = Screen('Rect',window); % get screen size
TextSize = Screen('TextSize', window);
TextFont = Screen('TextFont', window);

origwin = CreateOffWin(window, bgColor, TextFont, TextSize);
respwin = CreateOffWin(window, bgColor, TextFont, TextSize);

% save the stuff on the screen at the time we started
imageMatrix=Screen('GetImage', window);
origTexture = Screen('MakeTexture', window, imageMatrix);
clear imageMatrix

%% DRAW THE CUE & RESPONSE AREA

% start with the original display
Screen('DrawTexture',respwin, origTexture, [], rect);

% write the cue
WriteRight(respwin, msg, x, y, cueColor);

% draw the response area
responseareawidth=280;
switch displaytype
    case 'Line'  % underline
      rarect = [x y+20 x+responseareawidth y+24];
      Screen('FrameRect', respwin, cueColor, rarect, 3);      
    case 'Box'   % entire box
      rarect=[x y-22 x+responseareawidth+5 y+28];     %note this means the height of the box is 50
      Screen('FrameRect', respwin, cueColor, rarect, 3);  
end

% these are drawn on respwin so that they can be automatically redrawn
% everytime the screen is updated

% show this stuff
imageMatrix=Screen('GetImage', respwin);
respTexture = Screen('MakeTexture', window, imageMatrix);
clear imageMatrix    
Screen('DrawTexture',window, respTexture, [], rect);
Screen('Flip',window);

%% GET THE RESPONSE
FlushEvents('keyDown', 'mouseDown'); % clears anything the user has typed before the display appears
t1=GetSecs; % start timing

while 1	% Loop until <return> or <enter>
    
    % show the current string    
    Screen('DrawTexture', window, respTexture, [], rect); % display
    WriteLeft(window, string, x, y, respColor); % string
    Screen('Flip', window);

    mychar=GetChar(0); % the 0 speeds up this call

    if ~respondedyet  %if this is the first letter typed
       startRT=GetSecs-t1;
       respondedyet=true; 
    end
    
    switch(abs(mychar))
        case {13,3, 10} % <return> or <enter>
            if acceptblanks || ~isempty(string)
                endRT = GetSecs-t1;
                break;
            end
        case 8 % backspace
            string = string(1:length(string)-1); % remove last character from the string 
        case 9 % TAB
            if endwithtab && (acceptblanks || ~isempty(string))
                % end IF tab key accepted as enter, AND other input
                % requirements met
                endRT = GetSecs-t1;
                break;
            end
        case 27 %escape
        case 33 %page up
        case 34 %page down
        case 37 %left???
        case 38 %up???
        case 39 %right???
        case 40 %down???
            
        case 28 % left arrow
        case 29 % right arrow
        case 30 % up arrow
        case 31 % down arrow
            
        otherwise % this is stuff that can be added
          % check to make sure it will fit in the response area
          norm = Screen('TextBounds', window, [string mychar]);
          if norm(3) < responseareawidth
              % yes, it WILL fit
              string=[string mychar]; % add new letter to the string
          end
    end
end % get a new keypress
 
%% GHOST THE DISPLAY AFTERWARDS (IF REQUESTED)

if ghost % ghost the display afterwards
    
    % restore the original screen         
    Screen('DrawTexture',window, origTexture, [], rect);    

    % ghosted cue
    ghostColor = floor((cueColor + bgColor) / 2);
    WriteRight(window, msg, x, y, ghostColor);
    
    % ghosted response area
    if ~strcmp(displaytype, 'None')
        Screen('FrameRect',window,ghostColor,rarect);
    end
    
    % ghosted actual response
    ghostColor = floor((respColor + bgColor) / 2);
    WriteLeft(window, string, x, y, ghostColor);
    
    % show the ghosted screen
    Screen('Flip',window,[],1);
    
end

%% WRAP UP
Screen('Close',origwin);
Screen('Close',respwin);
Screen('Close',origTexture);
Screen('Close',respTexture);

ListenChar; % turn character listening back on