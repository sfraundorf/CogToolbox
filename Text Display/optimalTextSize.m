% TextSize = optimalTextSize(mainwindow, stimuli)
% TextSize = optimalTextSize(mainwindow, maxlength)
%
% Finds the optimal text size for a moving window experiment: one that is
% as large as possible while still allowing the longest stimulus to fit on
% a single line.
%
% This assumes that you have ALREADY set the font on window MAINWINDOW to
% the font you want to use, and that this font is MONOSPACED (as it is in
% most moving window experiments).
%
% optimalTextSize can be called with a cell array of STIMULI and will find
% the longest stimulus on its own, or with scalar value MAXLENGTH, the
% length in characters of the longest stimulus (if you already know it).
%
% Optionally, returns the maximum length (in characters) of the longest
% stimulus sentence.
%
% 06.13.11 - S.Fraundorf - first version

function [TextSize maxlength] = optimalTextSize(mainwindow, stimuli)

%% What is longest stimulus?
if isnumeric(stimuli)
    % already a number
    maxlength = stimuli;
else
    % find the longest sentence:
    maxlength = 1;
    for i=1:numel(stimuli)
       if length(stimuli{i}) > maxlength
          maxlength = length(stimuli{i});
       end
    end
end

%% What is largest possible text size for this?
% get the screen size:
rect = Screen('Rect', mainwindow);

% set the largest possible text size that keeps this on a single line:
TextSize = 10;
while 1
   Screen('TextSize', mainwindow, TextSize);
   textrect = TextBounds(mainwindow, repmat('x', 1, maxlength));
   if textrect(3) + 125 >= rect(3)
       % too big
       break;
   else
       TextSize=TextSize+1;
   end
end   

%% RETURN VALUE
TextSize = TextSize-1;
