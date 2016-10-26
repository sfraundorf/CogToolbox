% [imagewindow rect] = loadImage(mainwindow, filename, winsize, rescale, bgcolor)
%
% Loads an image from file FILENAME and CENTERS it in a new offscreen
% window.
%
% Optional parameter WINSIZE is a vector of length 4 specifying the X and Y size
% of the offscreen window.  If no size is specified, the window is assumed to
% be the same size as the image. If you are loading multiple stimulus images,
% you will probably want to set WINSIZE to the size of the LARGEST image, so
% that all your images will be in windows of the same size and can be used
% interchangeably.
%
% Optional parameter RESCALE controls what happens when the size of the
% image does not match WINSIZE.  If RESCALE is 0, the image is cropped to
% fit (if bigger than the window), or extra space is simply left (if smaller
% than the window).  If RESCALE 1, the image is resized to fit the window as
% best as possible while preserving the aspect ratio of the image.
%
% BGCOLOR is an optional clut used to color in the parts of the window not
% occupied by the image.  (This is only relevant if the size of the window
% is larger than the image.)  If no BGCOLOR is specified, it is assumed to
% be the modal color of the image.
%
% See IMFORMATS for supported image types in Matlab.
%
% 12.30.09 - S.Fraundorf
% 12.31.09 - S.Fraundorf - added RESCALE parameter
% 01.28.10 - S.Fraundorf - fixed a bug when window size wasn't specified
% 01.31.10 - S.Fraundorf - can directly return the rect of the image window
% 07.20.10 - S.Fraundorf - fixed some bugs in cropping images when
%                            RESCALE=0
% 07.21.10 - S.Fraundorf - fixed some bugs rescaling images with weird
%                            aspect ratios
% 08.11.10 - S.Fraundorf - added some error checking
% 09.30.10 - S.Fraundorf - fixed a bug where some rescaled images would not
%                           display due to having negative coordinates
% 01.31.11 - S.Fraundorf - added support for alpha channels.  thanks to
%                           Tuan Lam for help with this!
% 08.24.12 - S.Fraundorf - updated error messages
% 10.13.12 - S.Fraundorf - supports more grayscale image formats
% 10.26.16 - S.Fraundorf - fixed some issues with polarity check (in newer
%                           versions of MATLAB?)

function [imagewindow, rect] = loadImage(mainwindow, filename, winsize, rescale, bgcolor)

%% check the input parameters
if nargin > 2
    if numel(winsize) ~= 4
        error('CogToolbox:loadImage:WrongWinElements', 'Window size must be a 4-element RECT vector: (X1, Y1, X2, Y2).')
    elseif size(winsize) == [2,2]
        % reformat these into a vector
        error('CogToolbox:loadImage:WrongWinSize', 'Window size must be a VECTOR: (X1, Y1, X2, Y2).')
    end
end

%% detect the image format
% using the 3-character file extension
%filetype = filename(numel(filename)-2:numel(filename))
% unused because Matlab can detect this automatically OK

%% open the image file from disk
[ourimage, map, alpha] = imread(filename);

%% calculate image size
imagesize = size(ourimage);

%% convert to RGB color if needed
if ndims(ourimage) < 3 || imagesize(3) < 3 % black & white or grayscale, convert to RGB color  
        
    % kludge-y check of the color map to make sure we get the polarity right
    if exist('map','var') && ~isempty(map) && map(1,1) == 1 && map(1,2) == 1 && map(1,3) == 1 % need to reverse the colors
        ourimage(:,:) = 1-ourimage(:,:);
    end
   
    ourimage = BWtoRGB(ourimage); % convert to RGB color        
    
else
    % RGB color
    % no need to convert, but...
    imagesize = imagesize(1:2); % discard color when calculating the size of the image
end
% MATLAB image matrices have their X,Y coordinates reversed relative to the
% X,Y coordinates used by PTB, so we need to SWAP the imagesize vector
imagesize = reversevector(imagesize);

%% add alpha channel, if it exists
if ~isempty(alpha)
    ourimage(:,:,4) = alpha(:,:);
end

%% is window size specified?

% n.b. RECT will track the size of the resulting window 
% SCALEDRECT will track the portion of the window occupied by the
% (potentially rescaled) picture
% these are the same IFF the picture takes up the whole window

if nargin < 3
    % if no window size specified, set it to the image size
    winsize = imagesize;
    % in this case, the image size matches the window size exactly.  so we
    % don't need to waste time with backgrounds or rescaling; we can just copy
    % the image directly into the final window.
    scaledrect = [0 0 winsize];
    bgcolor = [0 0 0]; % doesn't matter because we won't use it
    
else % specified by user
    % recalculate the window size if the upper-left is moved from 0,0
    winsize = [winsize(3)-winsize(1) winsize(4)-winsize(2)];

    %% set background color
    if nargin < 5
      % if not specified, is modal color of image
      temp = mode(mode(single(ourimage)));
      bgcolor = zeros(1,3);
      bgcolor(1:3) = double(temp(1,:,1:3));
      clear temp
      
      % and rescaling default
      if nargin < 4
          rescale = 0;
      end
    end
    
    %% check how the image fits into this window
    if rescale % rescale the image to fit in the window
        
        scalingfactor = min(winsize ./ imagesize);
        % this is the limiting dimension, and how much it needs to be
        % scaled by.
        % then, scale the image by that:
        scaledimage = imagesize * scalingfactor;
        
        % calculate the margin and CENTER
        margins = fix((winsize-scaledimage)/2);        
        scaledrect = [margins(1) margins(2) margins(1)+scaledimage(1) margins(2)+scaledimage(2)];
  
    else  % keep the image as-is; don't rescale
        % crop the image if needed
        if imagesize(1) > winsize(1) % horizontal
            excess = ((imagesize(1)-winsize(1))/2)+.1; % CENTER
            ourimage = ourimage(:,ceil(excess):imagesize(1)-ceil(excess),:); % crop the image
        end
        if imagesize(2) > winsize(2) % vertical
            excess = ((imagesize(2)-winsize(2))/2)+.1; % CENTER
            ourimage = ourimage(ceil(excess):imagesize(2)-ceil(excess),:,:); % crop the image
        end
        % update image size
        imagesize = size(ourimage);
        imagesize = reversevector(imagesize(1:2));
        % calculate any extra space needed
        margins = floor((winsize - imagesize)/2);
        % set the final image size
        scaledrect = [margins(1) margins(2) margins(1)+imagesize(1) margins(2)+imagesize(2)];
    end
        
end


%% open the image window
rect = [0 0 winsize]; 
imagewindow=Screen('OpenOffscreenWindow',mainwindow,bgcolor,rect);

%% copy the image onto this window
Screen('PutImage', imagewindow,ourimage,scaledrect);