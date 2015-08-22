% THIS IS A DEMO OF HOW TO MAKE A FUNCTION
%
% type:
%   edit CenterOnScreen
% to see the example code
%
%
% function centeredrect = CenterOnScreen(rectofscreen,rectofitem)
%
% Returns a rect of coordinates to center an item on the screen.
% 
% We are putting a comment up here because a comment at the top of the
% function goes in the help file for that function.  Typically you want to
% describe what the function does, and its syntax.  It's also useful to
% include the date last revised (so you can tell if you have the current
% version).
%
% 01.25.10 - S.Fraundorf, M.Lewis, K.Tooley - first version
% note that we later developed this into CenterInRect, which is part of the
% toolbox!

function centeredrect = CenterOnScreen(rectofscreen,rectofitem)
% function centeredrect <- centeredrect is the variable that's being
%  returned from this function.  so we will need to define it somewhere
%  inside the function.
%  you can omit this if NOTHING is being returned from the function
% CenterOnScreen is the NAME of the function that we will use to call it
%
% the stuff in parentheses are the arguments for the function

% functions only know about variables that you pass to the function
%  e.g. the function doesn't know the trial number if you don't pass it
%  that

screencenter = [rectofscreen(3) / 2, rectofscreen(4) / 2];

halfitemsize = [(rectofitem(3)-rectofitem(1))/2 (rectofitem(4)-rectofitem(2))/2];

centeredrect = [screencenter(1) - halfitemsize(1), ...
    screencenter(2) - halfitemsize(2), ...
    screencenter(1) + halfitemsize(1), ...
    screencenter(2) + halfitemsize(2)];