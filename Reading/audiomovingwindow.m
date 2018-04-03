% [RTs, regiontime, regionwidth, y] = ...
%   audiomovingwindow(mainwindow, fgcolor, bgcolor, soundfiles, ...
%                     textstimulus,centerMultipleLines, dontclear, latency)
%
% Performs a self-paced auditory moving window reading task on window
% MAINWINDOW with text color FGCOLOR on background color BGCOLOR.
%
% The cell array of audio filenames contained in SOUNDFILES is played one at
% a time, with the participant pressing the space bar after each sound file
% has concluded to advance to the next one.
%
% The position of each audio segment (region) within the broader sentence
% or text can be displayed by including TEXTSTIMULUS, the text of the
% sound files.  The actual text is not displayed, but the position of the
% current region is indicated with + characters within the overall text.
% Add the PIPE character | into your text stimulus to separate it into
% regions. The PIPE is not displayed on the screen; it just tells MATLAB
% where the regions begin and end.
%
% For instance, if TEXTSTIMULUS = 'The horse|raced|past the barn|fell.' then
% the participant would see:
%   '+++ +++++ ----- ---- --- ---- ----.' -> press space ->
%   '--- ----- +++++ ---- --- ---- ----.' -> press space ->
%   '--- ----- ----- ++++ +++ ++++ ----.' -> press space ->
%   '--- ----- ----- ---- --- ---- ++++.'
%
% If NO pipes are included, the default is to make each WORD a separate
% region.
%
% If you want the ENTIRE sentence displayed as a SINGLE region, just add a
% PIPE at the END.  e.g. STIMULUS = 'The horse raced past the barn fell.|'
% displays:
%   'The horse raced past the barn fell.'
% all at once.
%
% The text is always displaced in a MONOSPACED font so that the underscores
% are equal to the width of the letter.
%
% Optional parameter CENTERMULTIPLELINES controls how text is centered
% vertically on the screen when there are multiple lines.  If
% centerMultipleLines is 0, the first line is always at the center of the
% screen, and any additional lines hang below it in the bottom half of the
% screne.  If centerMultipleLines is 1 (default), the entire block of text
% is shifted up or down so that it is centered on the screen.  If -1, the
% first line is always at the TOP of the screen.
%
% If optional parameter DONTCLEAR is set to 1, the display remains on the
% screen after the trial ends.  You probably don't want to do this in most
% cases, but it could be used if you wanted to keep the moving window
% display up while you asked some comprehension questions.
%
% Parameter LATENCY ranges between 0 and 1 controls the timing of the sound
% files.  A lower number results in more precise timing, but setting the
% number TOO low for your system may make the audio sound static-y.  See
% IndividualDifferences.m and the "Low-Latency Audio in Psychophysics
% Toolbox.doc" file in the CogToolbox for more information.
%
% The function returns a VECTOR of RTs -- one response time per region.
%
% Optionally, the function also returns vectors of REGION TIMES (in
% seconds) and REGION WIDTHS (in # of pixels).  These can be used to conver
% convert your listening times to RESIDUAL listening times at the end of your
% experiment, using the ResidReading function.  Type:
%   help ResidReading
% for more information.
%
% Optionally, the function also returns the Y position on the screen after
% the last text was written.
%
% The task can be aborted early by pressing the F3 key.  This returns a -1
% reading time, which your main function can detect and use to close the
% experiment.
%
% 04.03.18 - initial version

function [RTs, regiontime, regionwidth, y] = ...
    audiomovingwindow(mainwindow, fgcolor, bgcolor, soundfiles, textstimulus, centerMultipleLines, font, dontclear, latency)


%% CHECK INPUT/OUTPUT ARGUMENTS
if nargin < 9
    latency = 0.015; % default latency
    if nargin < 8
        dontclear = 0;
        if nargin < 7
            % font is not specified, set to a mono-spaced font
            varwidth = false;
            if ispc
                oldfont = Screen('TextFont',mainwindow,'Courier New'); % CHANGE the font ... and save the OLD one so we can switch back   
            else
                oldfont = Screen('TextFont',mainwindow,'Courier'); % CHANGE the font ... and save the OLD one so we can switch back   
            end
            oldstyle = Screen('TextStyle',mainwindow,1); % always put this in bold
            % check other parameters, too
            if nargin < 6
                centerMultipleLines = 1;
            end
        else
            % switch to the specified font
            oldfont = Screen('TextFont',mainwindow, font);
            oldstyle = Screen('TextStyle', mainwindow); % don't default to bold
            varwidth = true;
        end
    end
end

% display text?
if nargin < 5 || isempty(textstimulus) || strcmp(textstimulus, '')
    displaytext = false;
    y = -1;
else
    displaytext = true;
end

if nargout >= 2
    % user has REGION LENGTHS requested
    reportTime = true;
    if nargout >= 3
        % and PIXEL WIDTHS
        reportWidth=true;
    else
        reportWidth=false;
    end
else
    reportTime = false;
    reportWidth = false;
end

%% GET SCREEN & FONT PARAMETERS

rect = Screen('Rect',mainwindow); % get the screen size
if varwidth
   TextSize = Screen('TextSize', mainwindow); % get the font size
   HalfTextSize = TextSize/2;
   penwidth = TextSize/8;
end

%% --SET UP AUDIO--
SOUNDFREQ = 48000;
SOUNDCHANNELS = 1;
InitializePsychSound;
pahandle = PsychPortAudio('Open', [], 1, 1, SOUNDFREQ, SOUNDCHANNELS, [], latency);

%% SET UP KEY CODES
ExitKey = KbName('F3'); % abort task if F3 pressed

%% COUNT REGIONS

% count the number of regions
numregions = numel(soundfiles);

% set up the vector of listening times
RTs = zeros(1,numregions);
% set up the region length & width, if requested
if reportTime
    regiontime = zeros(1,numregions);
end
if reportWidth
    regionwidth = zeros(1,numregions);
end

% set up matrix of word locations on the screen.
% startX, startY, endX, endY
wordcoords = zeros(numregions,4);

%% PARSE THE STIMULUS TEXT

if displaytext

    % parse the string into regions
    if any(textstimulus=='|')  % using PIPE character |

        % add a region boundary at the end, if it doesn't already exist
        if textstimulus(numel(textstimulus)) ~= '|'
           textstimulus = [textstimulus '|'];
        end

        % if region boundaries have SPACES around them, remove them  so we don't
        % create extra space
        textstimulus = strrep(textstimulus, ' | ', '|');

        regions = textscan(textstimulus, '%s', 'Delimiter', '|');
    else
        % NO pipes found, use spaces instead
        textstimulus = doubleToSingleSpacing(textstimulus); % remove any double-spacing
        regions = textscan(textstimulus, '%s', 'Delimiter', ' ');
    end

    % check to make sure the audio & text match
    if numel(regions{1}) ~= numregions
        error('CogToolbox:audiomovingwindow:RegionNumberMismatch', 'Number of regions in text does not match number of regions in audio.');
    end

    % create the BLANKED OUT VERSION and the ACTIVE VERSION
    blankedversion = regions;
    activeversion = regions;
    for i=1:numregions
        % remove any markup codes
        blankedversion{1}{i} = stripMarkup(blankedversion{1}{i});
        activeversion{1}{i} = blankedversion{1}{i};
        % then, replace all NON-SPACE characters with dashes or +s
        blankedversion{1}{i}(blankedversion{1}{i} ~= ' ') = '-';
        activeversion{1}{i}(activeversion{1}{i} ~= ' ') = '+';
    end
    
end

%% CALCULATE TEXT POSITION

if displaytext

    % margin on the left:
    startx = 50;
    x = 50;
    y = 0;

    % write all the text to determine its location (a KLUDGE):
    for i=1:numregions
       wordcoords(i,1:2) = [x y];    
       [x, y, textend] = WriteLine(mainwindow, regions{1}{i}, fgcolor, startx, x, y, 1.25);
       wordcoords(i,3:4) = textend;
       if reportWidth
           regionwidth(i) = wordcoords(i,3) - wordcoords(i,1);
       end
    end

    % determine starting Y position
    if centerMultipleLines==1
        % see what the final Y position was:
        textheight = y;
        starty = (rect(4)/2) - (textheight/2); % middle of the screen - 1/2 of text height
    elseif centerMultipleLines == -1
        % start at top of the screen
        starty = 50;
    else % 0
        % center the FIRST LINE
        starty = rect(4)/2;
    end
    % add the starting Y location to the Y coordinates of each word
    wordcoords(:,2) = wordcoords(:,2) + starty;
    wordcoords(:,4) = wordcoords(:,4) + starty;

    % clear the screen
    Screen('FillRect',mainwindow,bgcolor);
    
end

%% READY THE AUDIO FILES
audiosegments = cell(3,1);
for region=1:numregions
    audiosegments{region} = audioread(soundfiles{region});
    if reportTime
        % duration of the sound file, in ms
        regiontime(region) = (numel(audiosegments{region}) / SOUNDFREQ) * 1000;
    end
end

%% PERFORM THE TASK

for region=1:numregions % display each region separately
     
  % write the text, if used
  if displaytext
      for i=1:numregions
          % for each region....
          % if this is the CURRENTLY DISPLAYED REGION, write the ACTIVE VERSION
          % (++++s)
          if region==i          
              WriteLine(mainwindow, activeversion{1}{i}, fgcolor, startx, wordcoords(i,1), wordcoords(i,2), 1.25);
          % otherwise, write the BLANK
          else
              if varwidth
                  % use a SOLID LINE
                  Screen('DrawLine', mainwindow, fgcolor, wordcoords(i,1), wordcoords(i,2)+HalfTextSize, ...
                      wordcoords(i,3), wordcoords(i,4)+HalfTextSize, penwidth);
              else
                  % use the DASHES
                  WriteLine(mainwindow, blankedversion{1}{i}, fgcolor, startx, ...
                      wordcoords(i,1), wordcoords(i,2), 1.25);
              end
          end
      end  
  end
  
  % ready the audio
  PsychPortAudio('FillBuffer', pahandle, audiosegments{region}');
  
  % display the text and start the audio
  [~, starttime] = Screen('Flip',mainwindow, [], dontclear);
  PsychPortAudio('Start', pahandle);
  [~, ~, ~, stoptime] = PsychPortAudio('Stop', pahandle, 1);
  
  % get the RT
  [keysPressed, endtime] = getKeys;
  RTs(region) = (endtime - stoptime) * 1000;
    
  if keysPressed == ExitKey % if the numerical code for the key pressed 
                           % is the code for the exit key....
      RTs(region) = -1; % set reading time to -1 so we know we quit
      break;
  end
  
end

%% WRAP-UP
Screen('TextFont', mainwindow, oldfont); % restore the old font
Screen('TextStyle', mainwindow, oldstyle); % and old style

PsychPortAudio('Close', pahandle);