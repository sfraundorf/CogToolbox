function WriteLeft(win, text, x, y, color)
% 
%      WriteLeft(win, text, x, y, color)
% 
% function writes a string TEXT to screen WIN in color COLOR.  The
% left edge of the TEXT occurs at postion X and vertically centered at 
% position Y.
% 
% 05.18.06 M.Diaz
% 02.01.10 S.Fraundorf - PTB-3 version

if ~isempty(text)
  norm = Screen('TextBounds', win, text);

  Screen('DrawText',win,text,x, round(y-norm(4)/2), color);
end
% PTB-3 crashes if getting the TextBounds of an empty string, so we need to
% make sure it's not empty