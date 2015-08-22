function WriteCentered(win, text, x, y, color, margin, linespacing)
% 
%      WriteCentered(win, text, x, y, color, margin, linespacing)
% 
% function writes a string TEXT to screen WIN in color COLOR.  The center
% of the TEXT occurs at postion X and Y.
%
% If the text would exceed a margin of MARGIN on each side of the screen,
% it is split into multiple lines.  (Default MARGIN is 0.)  LINESPACING
% controls the spacing of multiple lines and is a multiple of the regular
% spacing. (e.g. LINESPACING 2 is twice as much spacing as usual)
%
% Note that this function does NOT automatically flip the screen, so you
% will have to do that afterwards when you are ready to display what you've
% drawn.
% 
% 05.18.06 M.Diaz
% 11.22.09 S.Fraundorf - write text on multiple lines if needed
% 01.25.10 S.Fraundorf - PTB-3 version
% 02.22.10 S.Fraundorf - fixed a bug that made the text slightly off-center
% 02.23.10 S.Fraundorf - fixed a bug with really long text strings
% 07.16.11 S.Fraundorf - return w/out crashing if no text to display
% 07.18.11 S.Fraundorf - fixed goof in the above change

% set default parameters if needed
if nargin < 7
    linespacing = 1;
    if nargin < 6
        margin = 0;
    end
end

% find out the margins
rect=Screen('Rect',win);
maxwidth = rect(3) - (2 * margin);

% initialize
curline = 1;
[textlines{1} text] = strtok(text,[9 10 13 32]);
if isempty(textlines{1}) % if no text to display, just return
  return;
end
norm = Screen('TextBounds',win,textlines{1});
width = norm(3);
while ~isempty(text)
    [nextWord text]=strtok(text,[9 10 13 32]);
    norm = Screen('TextBounds',win,[' ' nextWord]);
    
    if (width + norm(3)) > maxwidth % move to the next line
      curline = curline + 1;
      textlines{curline} = nextWord;
      width = norm(3);
    else                                  % write on this line
      textlines{curline} = [textlines{curline} ' ' nextWord];
      width = width + norm(3);
    end  
        
end    

numlines = numel(textlines); % total lines

% get the height of the text block
textsize=Screen(win,'TextSize'); % on ONE line
textsize=round(textsize*.7131-1.3401);
% correction for white space above font
% THESE ESTIMATES MADE BY LEAST SQUARES ON ARIAL FONT, SHOULD CHECK IF SAME
% FOR OTHER FONTS
totalheight=(textsize * numlines) + floor((numlines-1)*linespacing*textsize); % height of entire block
top = y-round(totalheight/2); % top of the text block

% draw the text
for i=1:numel(textlines)
    norm=Screen('TextBounds',win,textlines{i});
    Screen('DrawText',win,textlines{i},round(x-norm(3)/2), top+(textsize*(i-1))+(linespacing*textsize*(i-1)), color);
end