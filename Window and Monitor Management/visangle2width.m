% screensize = visangle2width(angle, dist_to_screen)
%
% Converts a measure of visual angle ANGLE (in degrees) to distance from
% the center of the screen, given the distance from the plane of the eye
% to the center of the screen DIST_TO_SCREEN.
%
% WIDTH will be measured in whatever units DIST_TO_SCREEN is in.
%
% This returns a measure of PHYSICAL distance.  If you want a measure in
% terms of PIXELS on the screen, use VISANGLE2PIXELS instead.
%
% Note that this function requires knowledge about the physical set-up of
% the computer.  This is inherent to any measure of visual angle.
%
% 06.06.11 - S.Fraundorf - first version

function screensize = visangle2width(angle, dist_to_screen)

screensize = 2 * (tand(angle/2)*dist_to_screen);