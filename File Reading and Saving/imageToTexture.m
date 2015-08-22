% [newtexture imagesize] = imageToTexture(window, filename)
%
% Loads an image file and converts it into a texture, returning the handle
% of the new texture.  This preserves an alpha channel, if it exists.
%
% Optionally, also returns the size of the original image as a
% Psychophysics Toolbox rect, e.g. [0 0 XSize YSize]
%
% 02.14.11 - S.Fraundorf - first version

function [newtexture imagesize] = imageToTexture(window,filename)

% read the image
[ourimage imagemap alpha] = imread(filename);

% if there's an alpha channel...
if ~isempty(alpha)
    ourimage(:,:,4) = alpha(:,:);
end

% calculate image size
if nargout == 2 
  imagesize = size(ourimage);
  imagesize = [0 0 reversevector(imagesize(1:2))];
end

% convert to texture
newtexture = Screen('MakeTexture',window,ourimage);