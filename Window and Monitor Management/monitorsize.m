% rect = monitorsize(diagsize, aspectratio)
%      = monitorsize(diagsize, win, 'win')
%
% Returns the physical size of the viewable area of a monitor in the
% form [0,0,HSIZE,VSIZE].
%
% This can be calculated in one of two ways:
%   * From the diagonal physical size of a monitor DIAGSIZE and its aspect
%     ratio (horizontal:vertical ratio) ASPECTRATIO
%   * By specfiying 'win' as the third argument, from DIAGSIZE and the handle
%     WIN to a Psychophysics Toolbox window, which will calculate the aspect
%     ratio automatically (assuming the window takes up the whole monitor)
%
% 06.06.11 - S.Fraundorf - first version
% 08.22.12 - S.Fraundorf - added warning message if METHOD cannot be
%                            understood.  removed unneeded calculation

function rect = monitorsize(diagsize, aspectratio, method)

if nargin == 3 && strcmp(method, 'win')
    rect = Screen('rect', aspectratio);
    aspectratio = rect(3)/rect(4);
elseif nargin == 3
    warning('CogToolbox:monitorsize:UnknownMethod', 'Unknown calculation method requested; defaulting to aspect ratio.')
end

vsize = sqrt((diagsize^2)/((aspectratio^2)+1));
hsize = vsize * aspectratio;

rect = [0 0 hsize vsize];