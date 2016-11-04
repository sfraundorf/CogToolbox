% InstructionsScreen(win, fgcolor, bgcolor, instructions, highlightwords, highlightcolor, click, yPositionIsBaseline)
%
% Display a pre-fab instruction screen on window WIN.  The screen includes
% string INSTRUCTIONS (mark paragraphs with a pipe | ) written in FGCOLOR
% on background color BGCOLOR.  Text font & text size are assumed to have
% already been set in the window.
%
% This function waits 1.5 s per paragraph before allowing the user to continue,
% to ensure that they actually READ the text.
%
% The screen is erased afterwards.
%
% You can highlight certain words in the text by passing in optional string
% or cell array of strings HIGHLIGHTWORDS and highlight color HIGHLIGHTCOLOR.
% (N.B. punctuation marks are ignored in doing so, but capitalization is
% NOT, in case you want to highlight only the capitalized instance of a
% word.)
%
% Optional parameter CLICK controls how the user moves on from the screen:
%   1: A mouse click
%   0: A keypress (DEFAULT)
%  -1: The function does not wait for any response at all and returns
%      immediately, leaving everything in the buffer without doing a
%      Screen('Flip') and without enforcing a delay.  Use this if you want
%      to use additional code (outside of the function) to add other
%      display elements to the screen (e.g. example stimuli) or to collect
%      a custom type of response (e.g. pressing a particular key or
%      clicking a button)
%
% 11.22.09 - S.Fraundorf
% 01.26.10 - S.Fraundorf - PTB-3 version
% 02.22.10 - S.Fraundorf - added CLICK parameter
% 02.14.11 - S.Fraundorf - some updates to allow use of WriteLine's
%                            markupcodes, which WriteLineHighlight does not
%                            handle.  WriteLineHighlight will eventually be
%                            phased out completely.
% 07.14.11 - S.Fraundorf, M.Lewis - allow click = -1
% 08.23.12 - S.Fraundorf - updated to reflect merger of WriteLine and
%                            WriteLineHighlight
% 11.04.16 S.Fraundorf - added ability to set yPositionIsBaseline - needed
%                          to display text properly on some systems

function InstructionsScreen(win, fgcolor, bgcolor, instructions, highlightwords, highlightcolor, click, yPositionIsBaseline)

if nargin < 8 
   % get the default if not specified
    yPositionIsBaseline = Screen('Preference', 'DefaultTextYPositionIsBaseline');    
    if nargin < 7
        click = 0; % default is keypress
        if nargin == 5
            % asked for highlighted words but didn't specify color
            warning('CogToolbox:InstructionsScreen:NoHighlightColor', ...
                'Requested highlighted words but highlight color not specified; defaulting to red.');
            highlightcolor = [255 0 0]; 
        end
    end
end

% my defaults
linespacing = 1.25;
timeperpara = 1;

% retrieve text and window size
TextSize=Screen('TextSize', win);
rect=Screen('Rect', win);

% 1) write the instructions
FilledRect(win,bgcolor,rect);
if nargin > 4 && ~isempty(highlightwords)
    % display w/ highlighted words   
    [~, y] = WriteLine(win, instructions, fgcolor, 30, 30,(TextSize*2), linespacing, highlightcolor, highlightwords, yPositionIsBaseline);
else
    % no words to highlight
    [~, y] = WriteLine(win,instructions,fgcolor,30,30,(TextSize*2),linespacing, [], [], yPositionIsBaseline);
end

% 2A) return immediately if click < 0
if click < 0
    return; % return without getting input or flipping the screen
end

% 2B) otherwise, display and wait TIMEPERPARA secs per paragraph
Screen('Flip', win, 0, 1); % keep the frame buffer so we can add the Press a Key message
numparas=numel(find(instructions=='|'))+1;
WaitSecs(timeperpara*numparas);

% 3) display message on how to continue
if click == 1
    WriteLine(win,'Click the mouse to continue.',fgcolor,30,30,y+(TextSize*linespacing*2),linespacing, [], [], yPositionIsBaseline);
else
    WriteLine(win,'Press a key to continue.',fgcolor,30,30,y+(TextSize*linespacing*2),linespacing, [], [], yPositionIsBaseline);
end
Screen('Flip', win);

% 4) after the above delay, wait for the user to respond
if click
    GetClicks;
else
    getKeys;
end