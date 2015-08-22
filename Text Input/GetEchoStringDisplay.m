function string = GetEchoStringDisplay(windowPtr, msg, x, y, textColor, bgColor)
% string = GetEchoStringDisplay(window, msg, x, y, [textColor], [bgColor])
% 
% Get a string typed at the keyboard. Entry is terminated by
% <return> or <enter>.
%
% Typed characters are displayed in the window. The delete
% character is handled correctly. Useful for i/o in a Screen window.
%
% Unlike PTB's GetEchoString, this version PRESERVES whatever was ALREADY
% on the screen (e.g. a display or a prompt to the participant) before the
% function was called, as well as after the function ends.
%
% ***IMPORTANT*** This *ONLY* works if, if your LAST FLIP before you called
% this function, you called it w/ dontClear = 1.  e.g. 
%  Screen('Flip',win,0,1);
% I'll work on fixing this.
%
% 03.20.08 - PTB-3 version
% 02.22.10 - S.Fraundorf
% 08.22.12 - S.Fraundorf - removed unused variables
% 08.23.12 - S.Fraundorf - corrected a problem where a changed text size or
%                           font wasn't reflected in the initial display.
%                           Made the function more efficient.

if nargin < 6
    bgColor = [];
   if nargin < 5
       textColor = [];
   end
end

% retrieve the current font
textsize = Screen('TextSize', windowPtr);
textfont = Screen('TextFont', windowPtr);

% copy the existing window to an off-screen window
origwindow = Screen('OpenOffscreenWindow', windowPtr, bgColor);
Screen('CopyWindow',windowPtr,origwindow);
% set the font properties of this off-screen window
Screen('TextSize', origwindow, textsize);
Screen('TextFont', origwindow, textfont);

% Flush GetChar queue to remove stale characters:
FlushEvents('keyDown');

string = '';
while true
    % assemble the cue/target display
    output = [msg, ' ', string];
    % show it
    Screen('CopyWindow',origwindow, windowPtr);
    Screen('DrawText', windowPtr, output, x, y, textColor, bgColor);
    Screen('Flip', windowPtr,0);

    char = GetChar;
    switch (abs(char))
        case {13, 3, 10}
            % ctrl-C, enter, or return
            break;
        case 8
            % backspace
            if ~isempty(string)
                string = string(1:length(string)-1);
            end
        otherwise
            string = [string, char];
    end

end

% restore the original screen
Screen('CopyWindow',origwindow,windowPtr);
Screen('Flip',windowPtr,0,1);

% close the offscreen window
Screen('Close',origwindow);