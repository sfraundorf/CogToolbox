% newimage = BWtoRGB(oldimage)
%
% Converst a 2-dimensional b&w or grayscale image matrix into a
% 3-dimensional RGB matrix.
%
% This doesn't colorize the image itself, it just changes the format, so
% that you CAN do color-related operations on it.
%
% 12.30.09 - S.Fraundorf
% 10.13.12 - S.Fraundorf - supports images where white = 255 rather than
%                           white = 1

function newimage = BWtoRGB(oldimage)

newimage = zeros([size(oldimage) 3]); % first 2 dimensions are size, 3rd is color depth

% copy the old image into the first channel of the new
if max(max(oldimage)) == 1
    % 1 is the maximum possible brightness, rescale to 255
    newimage(:,:,1) = oldimage * 255;
else
    % don't need to rescale
    newimage(:,:,1) = oldimage;
end

% duplicate this channel into the others
for i=2:3
   newimage(:,:,i) = newimage(:,:,1);
end