% visangle = pixels2visangle (pixels, resolution, physdim, dist_to_screen)
%
% Converts specified number of PIXELS from center of screen to the
% corresponding visual angle measure, given the screen RESOLUTION (in
% pixels) in the dimension of interest, the physical dimension of the
% screen PHYSDIM in that direction, and the distance from the viewer's eye
% eye to the center of the screen DIST_TO_SCREEN. PHYSDIM and DIST_TO_SCREEN 
% may be any units as long as they are the same.
%
% Note that this function requires knowledge about the physical set-up of
% the computer.  This is inherent to any measure of visual angle.
%
% via: http://en.wikipedia.org/wiki/Visual_angle
%
% 06.06.11 - S.Fraundorf - first version

function visangle = pixels2visangle(pixels, resolution, physdim, dist_to_screen)

% convert # of pixels to physical distance
% # of pixels / pixels per physical unit
physdist = pixels / (resolution / physdim);

% then, calculate visual angle:
visangle = width2visangle(physdist, dist_to_screen);