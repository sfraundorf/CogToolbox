% DrawArrow(win,color,startpt,endpt,linewidth,lengthscaling, widthscaling,twoheads)
%
% Draws an arrow on window WIN connecting two points, defined by the
% coordinate vectors STARTPT and ENDPT.
%
% COLOR is a scalar or RGB triplet defining the color of the line.
%
% LINEWIDTH is the width of the line in pixels.  Note that the line is
% centered at the points STARTPT and ENDPT.  Default is 5 if not specified
%
% Parameters LENGTHSCALING and WIDTHSCALING control the scaling of the
% arrowhead relative to the line:
%  - LENGTHSCALING is how much of the line is taken up by the head.  e.g.
%    lengthscaling=.50 means that the arrowhead extends 50% of the way back
%    down the arrow.  Maximum 1; default is .25
% -  WIDTHSCALING is the width of the arrowhead at its widest point, in
%    proportion to its height.  WIDTHSCALING 1 (default) will make the width
%    of the arrowhead equal to its height.  Smaller numbers will give you a
%    narrower arrowhead and larger numbers will give you a fatter
%    arrowhead.
%
% If optional parameter TWOHEADS is 1, a 2nd arrowhead will also be drawn
% pointing to STARTPT (to have a 2-way arrow).  Otherwise, the arrowhead will be
% pointing at ENDPT only.
%
% right now, the arrows are always filled.  this could be adapted to
% support arrows that are transparent or have different border & fill
% colors.
%
% 12.30.09 - S.Fraundorf
% 02.05.10 - S.Fraundorf - PTB-3 version

function DrawArrow(win,color,startpt,endpt,linewidth,lengthscaling, widthscaling,twoheads)

%% default parameter values
if nargin < 8
    twoheads = 0;
    if nargin < 7
        widthscaling = 1;
        if nargin < 6
            lengthscaling = 0.25;
            if nargin < 5
                linewidth = 5;
            end
        end
    end
end

%% check parameter values are acceptable
if lengthscaling > 1
    error('lengthscaling must be not greater than 1');
end

%% draw the arrowhead
vertices = ones(3,2);  % reserve spcae
vertices(1,:) = endpt; % vertex 1 = ending point

% find the base of the head
delta = (endpt-startpt) * lengthscaling; % scale the distance by lengthscaling
baseofheadE = endpt-delta;
headsize = floor(delta * (widthscaling/2));
% calculate the other vertices from there
vertices(2,:) = [baseofheadE(1)-headsize(2) baseofheadE(2)+headsize(1)];
vertices(3,:) = [baseofheadE(1)+headsize(2) baseofheadE(2)-headsize(1)];

% draw it!
FilledPoly(win,color,vertices,color,1);

%% draw the second arrowhead, if requested
if twoheads
    vertices = ones(3,2); % reserve space
    vertices(1,:) = startpt; % vertex 1 = starting point
    
    % find the base of the second head
    baseofheadS = startpt+delta;
    % calculate the other vertices from there
    vertices(2,:) = [baseofheadS(1)-headsize(2) baseofheadS(2)+headsize(1)];
    vertices(3,:) = [baseofheadS(1)+headsize(2) baseofheadS(2)-headsize(1)];

    % draw it!
    FilledPoly(win,color,vertices,color,1);
end

%% draw the rest of the line

% we don't want to draw the line the whole way because if linewidth > 1,
% it will produce a fat point at the tip of the arrow instead of a nice
% sharp arrowhead tip.  so, we only draw it up to the BASE of the arrowhead(s)

if twoheads
   Screen('DrawLine',win,color,baseofheadS(1),baseofheadS(2),baseofheadE(1),baseofheadE(2),linewidth);
else
   Screen('DrawLine',win,color,startpt(1),startpt(2),baseofheadE(1),baseofheadE(2),linewidth);
end