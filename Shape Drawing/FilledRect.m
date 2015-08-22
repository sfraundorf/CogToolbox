function FilledRect(win, color, varargin)
% 
%    FilledRect(win, color, xCenter, yCenter, height, width)
%    FilledRect(win, color, rect)
% 
% Draws a filled rectangle to screen WIN.  Rectangle is
% centered at XCENTER, YCENTER and is of size HEIGHT and WIDTH
% If a single vector RECT is provided, rect specifies upper-left and
% bottom-right corners of rectangle.
%
% This does not automatically flip the screen; you will have to do that
% when you are ready to display your stimuli.
% 
% 05.20.06 M.Diaz
% 02.05.10 S.Fraundorf - PTB-3 version
% 08.22.12 S.Fraundorf - updated error message


if nargin==3
    if sum(size(varargin{1}) ~= [1 4])
        error('CogToolbox:FilledRect:ImproperRect', 'Rect should be a 4-element vector');
    end
    corners=varargin{1};
elseif nargin==6
    xCenter=varargin{1};
    yCenter=varargin{2};
    height=varargin{3};
    width=varargin{4};
    corners=[xCenter-round(width/2), yCenter-round(height/2), xCenter+round(width/2), yCenter+round(height/2)];
else
%     error('wrong number of inputs');
end

Screen('FillRect',win,color,corners);