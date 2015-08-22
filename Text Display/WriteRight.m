function WriteRight(win, text, x, y, color)
% 
%      WriteRight(win, text, x, y, color)
% 
% function writes a string TEXT to screen WIN in color COLOR.  The
% right edge of the TEXT occurs at postion X and vertically centered at 
% position Y.
% 
% 05.18.06 M.Diaz
% 01.31.10 S.Fraundorf - PTB-3 version
% 02.01.10 S.Fraundorf - avoid crashes if text string is empty

if ~isempty(text)
    norm = Screen('TextBounds', win, text);

    Screen('DrawText',win,text,round(x-norm(3)), round(y-norm(4)/2), color);
end

% PTB-3 crashes if getting the TextBounds of an empty string, so we need to
% make sure it's not empty