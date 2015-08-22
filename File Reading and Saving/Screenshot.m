% Screenshot(win,filename,format)
%
% Takes a screenshot of whatever is on window WIN and saves it in a file
% named FILENAME with image format FORMATS.  Great if you want a
% demonstration of what your experiment/display looks like!
%
% The default image format is PNG.  For more information on alternate
% formats, type:
%    help imwrite
%
% Note that taking a screenshot can be a little time-consuming and might
% mess up the timing of your experiment.  If you are just capturing your
% display for demonstration purposes, it is probably better to do it with a
% pilot participant rather than an actual participant.
%
% 01.31.11 - S.Fraundorf - first version
% 05.16.11 - S.Fraundorf - syntax updates
% 05.30.11 - S.Fraundorf - added support for alternate file formats

function Screenshot(win,filename,format)

if nargin < 3
    format = 'PNG';
end

sshot = Screen('GetImage', win);
imwrite(sshot,filename,format);