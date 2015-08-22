% visangle = width2visangle(width, dist_to_screen)
%
% Converts a measure of physical distance on the screen, WIDTH, to a
% measure of visual angle (in degrees), given the distance from the plane
% of the eye to the center of the screen DIST_TO_SCREEN.  WIDTH and
% DIST_TO_SCREEN may be any units of measurements as long as they are
% the SAME.
%
% If your stimulus measurement is in pixels on the screen (and not physical
% distance), use PIXELS2VISANGLE instead.
%
% Note that this function requires knowledge about the physical set-up of
% the computer.  This is inherent to any measure of visual angle.
%
% 06.06.11 - S.Fraundorf - first version

function visangle = width2visangle(width, dist_to_screen)

visangle = 2 * atand(width / (2 * dist_to_screen));