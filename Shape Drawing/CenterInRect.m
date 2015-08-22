% function centeredrect = CenterInRect(rectofarea,rectofitem)
%
% Returns a rect of coordinates to center one rectangle (RECTOFITEM)
% inside another larger area (RECTOFAREA).  For instance, this could be
% used to center an item on the rect of the screen.
%
% To center an item on only ONE dimension:
%   horizontally only - just use centeredrect(1) and (3)
%   vertically only - just use centeredrect(2) and (4)
%
% 01.25.10 - S.Fraundorf, M.Lewis, K.Tooley - first version

function centeredrect = CenterInRect(rectofarea,rectofitem)

areacenter = [rectofarea(3) / 2, rectofarea(4) / 2];

halfitemsize = [(rectofitem(3)-rectofitem(1))/2 (rectofitem(4)-rectofitem(2))/2];

centeredrect = [areacenter(1) - halfitemsize(1), ...
    areacenter(2) - halfitemsize(2), ...
    areacenter(1) + halfitemsize(1), ...
    areacenter(2) + halfitemsize(2)];