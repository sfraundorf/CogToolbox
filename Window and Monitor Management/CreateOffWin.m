function newWin=CreateOffWin(monitor, color, font, fontSize)
% 
%      newWin=CreateOffWin(monitor, color, font, fontSize)
% 
% function returns handle NEWWIN to a new OffScreenWindow.  NEWWIN has
% background color COLOR and font FONT of size fontSize
%
% PixelSize is hardcoded inside the function.  Must be set to a value
% appropriate to the machine it is being used on.
%
% 05.18.06 M.Diaz
% 01.31.10 S.Fraundorf - PTB-3 version
% 02.01.10 S.Fraundorf - fixed a typo that led to a bug

global pixelSize
if isempty(pixelSize)
    pixelSize=32
end

newWin=Screen('OpenOffscreenWindow',monitor,color,[], pixelSize);
Screen('TextSize',newWin,fontSize);
Screen('TextFont',newWin,font);