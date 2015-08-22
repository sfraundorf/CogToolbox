% [subjno listno] = getSubjectNumber(prefix,suffix,minnumber,maxnumber,numlists)
%
% Gets a subject number from the experimenter and checks to make sure it's
% valid and not already used.  If the subject number is invalid, the
% function repeatedly prompts the user until a valid number is obtained.
%
% Parameters PREFIX and SUFFIX specify the file prefix and suffix for the
% data files for your experiment.  e.g. if your files are
% myexperiment01.csv, myexperiment02.csv, PREFIX is 'myexperiment' and
% SUFFIX is '.csv'
%
% These are used to check to make sure that the subject number has not
% already been used.  If the subject number HAS been used, the user is
% asked if s/he wants to overwrite the file.
%
% If you want to store the files in a different folder than the current
% folder, this can be done simply by including the path as part of PREFIX:
%  e.g. PREFIX = 'datafiles/myexperiment'
%
% Optionally, a MINNUMBER and MAXNUMBER subject number can be specified;
% e.g. so that subject number must be at least 1 but no greater than 99.
%
% Optionally, you can also rotate through a set of lists and also get the list
% number for each subject.  Parameter NUMLISTS specifies the total number
% of lists for your experiment, which is used to rotate the subjects
% through lists.
%
% Note that this function does NOT open any files for output/input.  You
% still have to do that.  This just finds out what the subject # is going
% to be.
%
% 06.08.10 - S.Fraundorf - first version
% 02.08.11 - S.Fraundorf - updated to use modrz

function [subjno listno] = getSubjectNumber(prefix,suffix,minnumber,maxnumber,numlists)

%% -- CHECK INPUT PARAMETERS --
if nargout == 2 && nargin < 5
    error('CogToolbox:getSubjectNumber:NumListsUnspecified', ...
        'Must specify number of lists (NUMLISTS) if also getting a list number');
end

% add a period to file extension, if needed 
if suffix(1) ~= '.'
    suffix = ['.' suffix];
end

%% -- DEAL WITH MIN/MAX -- 
% here we set up a string that will be used to call inputnumber every time
% we try to get the subject number
%
% this saves us from having to repeatedly check whether a minimum or
% maximum is specified

if nargin<4
  if nargin<3
      % no minimum or maximum
      inputcall = 'subjno = inputnumber(''\nPlease enter subject number: '');';
  else
      % minimum, but not maximum
      inputcall = ['subjno = inputnumber(''\nPlease enter subject number: '',' num2str(minnumber) ');'];
  end
else
    % minimum AND maximum
    inputcall = ['subjno = inputnumber(''\nPlease enter subject number: '',' num2str(minnumber) ...
        ',' num2str(maxnumber) ');'];
end

%% -- GET A VALID SUBJECT NUMBER
while 1
  eval(inputcall);
  % try opening this file
  filename = [prefix num2strLZ(subjno, '%d', 2) suffix];
  test = fopen(filename);
  if test < 0
      % this file doesn't exist -- we're good!
      break
  else
      % file already exists
      fclose(test); % first, close the file we opened as a test
      % now, see if we want to overwrite
      fprintf('This subject number has already been used!\n');
      overwrite = upper(inputstring('Do you want to overwrite the old file? - (Y)es or (N)o?: '));
      if strcmp(overwrite,'Y') || strcmp(overwrite, 'YES')
          % OK, we're going to overwrite the old file
          break
      end % otherwise, they will just get prompted for the subject number again      
  end
end % try again

%% -- CALCULATE LIST NUMBER, IF REQUESTED
if nargout == 2
    listno = modrz(subjno,numlists);
    % mod(subjno,numlists) ranges from 0 to (numlists-1)
    % but modrz ranges from 1 to numlists
end