% pixels = visangle2pixels (angle, resolution, physdim, dist_to_screen)
%
% Converts specified visual angle measure ANGLE (in degrees) to the
% corresponding number of pixels from the center of the screen, given the
% screen RESOLUTION (in pixels) in the dimension of interest, the physical
% dimension of the screen PHYSDIM in that direction, and the distance from
% the viewer's eye eye to the center of the screen DIST_TO_SCREEN. PHYSDIM
% and DIST_TO_SCREEN  may be any units as long as they are the same.
%
% Note that this function requires knowledge about the physical set-up of
% the computer.  This is inherent to any measure of visual angle.
%
% via: http://en.wikipedia.org/wiki/Visual_angle and 
%      http://www.yorku.ca/eye/visangle.htm
%
% 06.06.11 - S.Fraundorf - first version

function pixels = visangle2pixels(angle, resolution, physdim, dist_to_screen)

% convert visual angle to physical distance on the screen
physdist = visangle2width(angle, dist_to_screen);

% convert physical distance to pixels:
pixels = physdist * (resolution / physdim);
% pixels = distance * (pixels per unit of distance)
