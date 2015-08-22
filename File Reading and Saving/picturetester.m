function picturetester(folder,bgcolor,picsize,rescale)
% picturetester(folder,bgcolor, picsize, rescale)
%
% Tests all of the pictures contained in folder FOLDER by
% displaying them 1 at a time on the screen.  e.g.
%    picturetester('~/Desktop/Expt2/stimuli')
%
% This function can be used to test your stimulus pictures
% before you've put your experiment together.
%
% For your reference, the list of files is displayed into
% the MATLAB window along with any errors encountered
% opening the pictures.
%
% You can either choose to wait for a keypress between each
% picture (if you want to inspect each picture personally to
% make sure they look good) or speed through the pictures as
% fast as possible (to test that they open)
% 
% Parameters:
%  FOLDER - the folder where your pictures are located
%  BGCOLOR - RGB clut for the background (default is [255 255 255] for white)
%   - these are parameters to loadImage
%  PICSIZE, RESCALE  are all parameters to loadImage - 
%      "help loadImage" for more information.  Default is to rescale to
%      200 x 200 picure
%
% 09.30.10 - S.Fraundorf - first version
% 08.21.12 - S.Fraundorf - removed some unused variables

%% DEFAULT PARAMETERS

if nargin < 1
    error('CogToolbox:picturetester:NoFolder', ...
        'You must specify the folder of pictures you want to test!\ne.g. picturetester(''~/Desktop/Expt2/stimuli'')');
end

if nargin < 4
  rescale = 1;
  if nargin < 3
    picsize = [0 0 200 200];
    if nargin < 2
      bgcolor = [255 255 255];
    end
  end
end

% DECIDE PRESENTATION FORMAT

waitOn = -1;
while waitOn < 0
  choice = input('Do you want to (L)ook at each picture, or just (T)est if they open? ', 's');
  if strcmpi(choice, 'L')
      waitOn = 1;
  elseif strcmpi(choice, 'T')
      waitOn = 0;
  end
end

%% GET THE LIST OF FILES
filelist = dir(folder);
folder = makeValidPath(folder);
numfiles = numel(filelist);

%% SCREEN SET UP
[mainwindow rect] = Screen('OpenWindow',0, bgcolor);
        
picloc = CenterInRect(rect, picsize);

%% BEGIN OUTPUT
fprintf('\n\n--TESTING ALL PICTURES IN: %s--\n', folder);

%% DISPLAY ALL THE PICTURES
for i=1:numfiles
 
     % see if this file is a picture
     [path name ext] = fileparts(filelist(i).name);
     ext = strtok(ext,'.'); 
     
     if ~isempty(ext) && ~isempty(imformats(ext))
        % Yes, MATLAB considers this a picture     
          
        % Display the picture
        try
          pic = loadImage(mainwindow, [folder filelist(i).name], picsize, rescale, bgcolor);    
          fprintf(' Picture loaded OK: %s\n', filelist(i).name);
          Screen('CopyWindow',pic,mainwindow,[],picloc);
          Screen('Flip', mainwindow);
          Screen('Close', pic);
     
          if waitOn  % wait for a key
            GetKeys;        
          end
        catch  %% DO THIS
           fprintf(' *** PROBLEM WITH PICTURE: %s\n', filelist(i).name);               
           fprintf('   Error message was: %s in %s', lasterror.msg, lasterror.stack);
        end
     else
        % Not a picture
        fprintf(' Not a picture: %s\n', filelist(i).name);
     end
end % go on to the next file
 
 %% WRAP-UP
 Screen('CloseAll');