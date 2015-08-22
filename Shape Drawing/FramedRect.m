function FramedRect(win, color, varargin)
% 
%    FramedRect(win, color, xCenter, yCenter, height, width)
%    FramedRect(win, color, rect)
% 
% function draws the outline of a rectangle to screen WIN.  Rectangle is
% centered at XCENTER, YCENTER and is of size HEIGHT and WIDTH
% If a single vector RECT is provided, rect specifies upper-left and
% bottom-right corners of rectangle.
% 
% 05.20.06 M.Diaz
% 02.05.10 S.Fraundorf - PTB-3 version
% 08.22.12 S.Fraundorf - updated error messages

if nargin==3
    if sum(size(varargin{1}) ~= [1 4])
        error('CogToolbox:FramedRect:ImproperRect', 'Rect should be a 4-element vector');
    end
    corners=varargin{1};
elseif nargin==6
    xCenter=varargin{1};
    yCenter=varargin{2};
    height=varargin{3};
    width=varargin{4};
    corners=[xCenter-round(width/2), yCenter-round(height/2), xCenter+round(width/2), yCenter+round(height/2)];
else
    error('CogToolbox:FramedRect:WrongInputNo', 'Wrong number of inputs');
end
penSize=2;

Screen('FrameRect',win,color,corners,penSize);