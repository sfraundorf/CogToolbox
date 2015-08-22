% changeFolder
%
% Changes MATLAB's current working directory to the folder where your
% experiment script is.  (where "your experiment script" = whatever script
% or function called changeFolder)
%
% Then, you can just use relative paths to refer to subfolders or files
% within this.  For example, if there is a subfolder called 'images' with the
% file 'camel.png' in the same folder as your experiment, you can always
% refer to that file as:
%      changeFolder;
%      imagefile = 'images/camel.png';
% This will work no matter where on the computer your experiment is.
%
% Using changeFolder is usually a good idea to do at the start of your
% experiment (unless you have a specific reason not to).  It makes it less
% likely that your experiment will look for a file and not be able to find it.
%
% It is particularly useful if you are running your experiment on multiple
% computers and the experiment might be saved in a different location on
% different machines.
%
% 07.21.10 - S.Fraundorf - first version

function changeFolder

% get the stack trace
mystack = dbstack;

% get the name of the function that called changeFolder 
fxnname = mystack(2).name;

% find the folder that contains this
fullpath = which(fxnname);
folder = fileparts(fullpath); % remove the m-file name

% change to this folder
cd(folder);
