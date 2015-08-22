% [RTs regionlength regionwidth y] = ...
%   movingwindow(mainwindow, fgcolor, bgcolor, stimulus,centerMultipleLines, widespacing, font)
%
% Performs a self-paced moving window reading task on window MAINWINDOW
% with text color FGCOLOR on background color BGCOLOR.
%
% Text string STIMULUS is displayed one region at a time, and the
% participant advances through the text by pressing the space bar.
%
% Add the PIPE character | into your stimulus to separate it into regions.
% The PIPE is not displayed on the screen; it just tells MATLAB where the
% regions begin and end.
%
% For instance, if STIMULUS = 'The horse|raced|past the barn|fell.' then
% the participant would see:
%   'The horse ----- ---- --- ---- ----.' -> press space ->
%   '--- ----- raced ---- --- ---- ----.' -> press space ->
%   '--- ----- ----- past the barn ----.' -> press space ->
%   '--- ----- ----- ---- --- ---- fell.'
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
% Optional parameter WIDESPACING, if 1, increases the spacing between words,
% as if every word were italicized.  This allows you to use italicized words
% without having them be detectable in advance.  Default is 0 (don't do
% this).
%
% Optional parameter FONTNAME allows you to switch to a different font
% (even a non-monospaced one) by specifying the name of the font, e.g.
% 'Arial'.  In this case, the dash characters (---s) are replaced with a
% single horizontal line spanning the width of the word.  This allows you
% to use fonts where the characters vary in their width (e.g. m is wider
% than i)
%
% If optional parameter DONTCLEAR is set to 1, the display remains on the
% screen after the trial ends.  You probably don't want to do this in most
% cases, but it could be used if you wanted to keep the moving window
% display up while you asked some comprehension questions.
%
% The function returns a VECTOR of RTs -- one response time per region.
%
% Optionally, the function also returns vectors of REGION LENGTHS (in # of
% characters) and REGION WIDTHS (in # of pixels).  These can be used to
% convert your reading times to RESIDUAL reading times at the end of your
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
% 01.28.10 - S.Fraundorf, K.Tooley - initial version
% 07.09.10 - S.Fraundorf - converted to a FUNCTION.  allowed custom
%                          region definitions.  collect region LENGTH.
% 07.12.10 - S.Fraundorf - deal with items of varying length.
%                          improved efficiency using ANY
% 01.06.11 - S.Fraundorf - removed requirement to define MAXREGIONS
%                          argument to increase ease of use.  if you need
%                          to "pad" the vector of RTs or region lengths,
%                          you can perform this operation on what's
%                          returned from the function
% 01.07.11 - S.Fraundorf - Added option to center multiple lines on screen.
%                          Handles markup codes now used by WriteLine
% 01.24.11 - S.Fraundorf - Kludge to deal with manual line breaks
% 01.26.11 - S.Fraundorf - improved efficiency by doing the clear screen
%                          only ONCE, at the start of the stimulus
% 01.28.11 - S.Fraundorf - improved efficiency by calculating line breaks
%                          in advance.
% 02.19.11 - S.Fraundorf - precalculate locations of ALL words to allow
%                          italics to be used without messing up the
%                          spacing.  added parameter WIDESPACING.  detect
%                          monospaced font based on OS.
% 03.07.11 - S.Fraundorf - added ability to change font and replace dash
%                          characters (---s) with a single line that can
%                          cover variable width fonts
% 01.19.12 - S.Fraundorf - get the starting time for each word directly
%                          from the Flip statement for more accurate timing
% 04.23.12 - S.Fraundorf - can return ending Y position.  added DONTCLEAR
%                          parameter

function [RTs regionlength regionwidth y] = ...
    movingwindow(mainwindow, fgcolor, bgcolor, stimulus, centerMultipleLines, widespacing, font, dontclear)


%% CHECK INPUT/OUTPUT ARGUMENTS
if nargin < 8
    dontclear = 0;
end
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
       widespacing = 0;
       if nargin < 5
          centerMultipleLines = 1;
       end
    end
  else
    % switch to the specified font
    oldfont = Screen('TextFont',mainwindow, font);
    oldstyle = Screen('TextStyle', mainwindow); % don't default to bold
    varwidth = true;
end

if nargout >= 2
    % user has REGION LENGTHS requested
    reportLength = true;
    if nargout >= 3
        % and PIXEL WIDTHS
        reportWidth=true;
    else
        reportWidth=false;
    end
else
    reportLength = false;
    reportWidth = false;
end

%% GET SCREEN & FONT PARAMETERS

rect = Screen('Rect',mainwindow); % get the screen size
if varwidth
   TextSize = Screen('TextSize', mainwindow); % get the font size
   HalfTextSize = TextSize/2;
   penwidth = TextSize/8;
end

% BOLDFACE

%% SET UP KEY CODES
ExitKey = KbName('F3'); % abort task if F3 pressed

%% PARSE THE STIMULUS TEXT

% if stimulus has italics anywhere, need to adjust the spacing
if widespacing
   markup = {'<em>' '</em>'};
else
   markup = {'' ''};
end

% parse the string into regions
if any(stimulus=='|')  % using PIPE character |

    % add a region boundary at the end, if it doesn't already exist
    if stimulus(numel(stimulus)) ~= '|'
       stimulus = [stimulus '|'];
    end
    
    % if region boundaries have SPACES around them, remove them  so we don't
    % create extra space
    stimulus = strrep(stimulus, ' | ', '|');
    
    regions = textscan(stimulus, '%s', 'Delimiter', '|');
else
    % NO pipes found, use spaces instead
    stimulus = doubleToSingleSpacing(stimulus); % remove any double-spacing
    regions = textscan(stimulus, '%s', 'Delimiter', ' ');
end

% count the number of regions
numregions = numel(regions{1});

% set up the vector of reading times
RTs = zeros(1,numregions);
% set up the region length & width, if requested
if reportLength
    regionlength = zeros(1,numregions);
end
if reportWidth
    regionwidth = zeros(1,numregions);
end

% set up matrix of word locations on the screen.
% startX, startY, endX, endY
wordcoords = zeros(numregions,4);

% create the BLANKED OUT VERSION
blankedversion = regions;
for i=1:numregions
    % remove any markup codes
    blankedversion{1}{i} = stripMarkup(blankedversion{1}{i});
    % then, replace all NON-SPACE characters with dashes
    blankedversion{1}{i}(blankedversion{1}{i} ~= ' ') = '-';
    % calculate region length, if needed
    if reportLength
        regionlength(i) = numel(find(blankedversion{1}{i} == '-'));
    end
end

%% CALCULATE TEXT POSITION

% margin on the left:
startx = 50;
x = 50;
y = 0;

% write all the text to determine its location (a KLUDGE):
for i=1:numregions
   wordcoords(i,1:2) = [x y];    
   [x y textend] = WriteLine(mainwindow, [markup{1} regions{1}{i} markup{2}], fgcolor, startx, x, y, 1.25);
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

%% PERFORM THE TASK

for region=1:numregions % display each region separately
     
  % write the text
  for i=1:numregions
      % for each region....
      % if this is the CURRENTLY DISPLAYED REGION, write the TEXT
      if region==i
          WriteLine(mainwindow, regions{1}{i}, fgcolor, startx, wordcoords(i,1), wordcoords(i,2), 1.25);
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
  
  % display the text
  [garbage starttime] = Screen('Flip',mainwindow, [], dontclear);

  % get the RT
  [keysPressed endtime] = getKeys;
  RTs(region) = (endtime - starttime) * 1000;
    
  if keysPressed == ExitKey % if the numerical code for the key pressed 
                           % is the code for the exit key....
      RTs(region) = -1; % set reading time to -1 so we know we quit
      break; % break will take you out of the WHILE or FOR loop you are in
  end
  
end

%% WRAP-UP
Screen('TextFont', mainwindow, oldfont); % restore the old font
Screen('TextStyle', mainwindow, oldstyle); % and old style