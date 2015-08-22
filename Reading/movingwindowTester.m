% [RTs regionlength regionwidth y] = movingwindowTester(mainwindow, fgcolor, bgcolor, stimulus,centerMultipleLines, widespacing, font)
%
% Tests the layout of a stimulus for a moving window experiment, by putting
% the entire item on the screen at once (i.e., what you'd see if the window
% encompassed the entire item).
%
% Pressing the space bar closes the screen.
%
% See movingwindow.m for further details on the moving window task.
%
% 01.07.11 - S.Fraundorf - first version
% 03.07.11 - S.Fraundorf - updated to reflect additions to movingwindow.m
% 04.23.11 - S.Fraundorf - updated to reflect addition of DONTCLEAR parameter
%                          to movingwindow.m and ability to return Y
%                          position

function [RTs regionlength regionwidth y] = ...
    movingwindowTester(mainwindow, fgcolor, bgcolor, stimulus,centerMultipleLines, widespacing, font, dontclear)

if nargin < 8
    dontclear = 0;
    if nargin < 7
      font = [];
      if nargin < 6
        widespacing = 0; % default in movingwindow.m
        if nargin < 5
          centerMultipleLines = 1; % default in movingwindow.m
        end
      end
   end
end

% remove any region delimiters
stimulus = strrep(stimulus, '|', '');

% add a junk delimiter at the end
stimulus = [stimulus '|'];

% display the moving window task
[RTs regionlength regionwidth y] = ...
    movingwindow(mainwindow, fgcolor, bgcolor, stimulus,centerMultipleLines, widespacing, font, dontclear);