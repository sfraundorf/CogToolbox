% FilledPoly(win,linecolor,vertices,fillcolor,linewidth)
%
% Draws a polygon on window WIN with border color LINECOLOR and interior color
% FILLCOLOR.  Both colors can be a scalars or RGB cluts.
%
% VERTICES is a Nx2 matrix specifying the X and Y coordinates of the N
% vertices of the polygon.
%
% Optional parameter LINEWIDTH controls the width of the line.  Default is
% 1.
%
% Unlike the built-in PTB functions this allows for the outline to be a
% separate color.
%
% 12.30.09 - S.Fraundorf
% 02.05.10 - S.Fraundorf - PTB-3 version

function FilledPoly(win,color,vertices,fillcolor,linewidth)

%% set default line width
if nargin < 7
    linewidth = 1;
end

%% fill the interior
Screen('FillPoly',win,fillcolor,vertices);

%% draw the border
Screen('FramePoly',win,color,vertices,linewidth);
