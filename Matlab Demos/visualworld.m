% visualworld.m
%
% This is a skeleton of code for a visual world eye-tracking experiment.
% You would then fill in the details of your experiment/stimuli/conditions.
%
% Type:
%   edit visualworld
% to look at the code
%
% If you use this as a basis for your experiment, please do File -> Save As
% to save this as a DIFFERENT file, instead of saving over the original base!
%
% This code is intended for use with the EyeLink-1000 desk-mount
% eyetracker.  If you're using a different eye-tracker, all the code for
% displaying images should be the same, but you would probably need to
% change the code that controls the eye-tracker.
%
% This demo will NOT run by itself.  It requires you to fill in the details
% yourself about YOUR experiment.  Please do not run your experiment until
% you've checked through everything and made sure that they match what YOU
% want in YOUR experiment.  I am not a mind-reader and cannot anticipate
% everything you might want to change :)
%
% This requires some basic knowledge of MATLAB and Psychophysics Toolbox to
% use -- check the other files in CogToolbox's Matlab Demos folder for
% help with that if you're new to MATLAB and PTB.
%
% 07.06.10 - S.Fraundorf - first version of the demo, based on prior code
%                          by Angie Isaacs, Sarah Brown-Schmidt, and Alison Trude
% 07.20.10 - S.Fraundorf - fixed text size setting.
%                          made the code a little more efficient
% 08.17.10 - S.Fraundorf - fixed a bug in the code that generates the
%                          Screen: statement.  thanks to Molly Lewis for
%                          the catch!
% 11.29.11 - S.Fraundorf - fixed a typo!
% 08.24.12 - S.Fraundorf - small updates to the help text

%% SETTINGS FOR EXPERIMENTER USE
% You must change these to match YOUR experiment!

% This line comes first to define the colors black & white and set up the
% random number generator:
InitExperiment;

% IMPORTANT: This statement should say test=0;  for real participants
test = 0;
%
% I get sick of reading the instructions every time I test my experiment.
% So, I put in a switch that allows me to skip over the instructions.
%
% Changing the above statement to test = 1; will cause the program to skip
% the sections that display the instructions.  This is useful for
% debugging.  BUT, you should be sure to change it back to test = 1; when
% you get ready to run real participants.


% These settings are the folders where the experiment looks for your lists &
% stimuli, and where it saves the BEHAVIORAL data.  (The eye movement data
% gets saved on the eye-tracking computer, of course.)
sound_dir = makeValidPath('C:/Documents and Settings/dwlab/My Documents/Scott/Cyclops/soundfiles/');
pics_dir = makeValidPath('C:/Documents and Settings/dwlab/My Documents/Scott/Cyclops/images/');
list_dir = makeValidPath('C:/Documents and Settings/dwlab/My Documents/Scott/Cyclops/lists/');
output_dir = makeValidPath('C:/Documents and Settings/dwlab/My Documents/Scott/Cyclops/output/');
%
% The behavioral data file is used if you want to analyze errors or RTs.

% This is the prefix for the behavioral data file (e.g. 'cyclops' if you
% want your behavioral data to be saved as
  % cyclops01.csv, cyclops02.csv, etc.
behav_prefix = 'cyclops';

% This is the prefix attached to the files that the eye-tracker generates.
% e.g. for my experiment called "Cyclops," I set the prefix to "cyc_" and
% the files were cyc_01.edf, cyc_02.edf, etc.
eye_prefix = 'cyc_';
%
% Number of DIGITS that will be in the subject number:
subjnolength = 2;
%
% !!! IMPORTANT: The eye-tracker runs in DOS and only likes 8-character
% file names.  That includes the subject number. 'cyc_43' is fine.
% 'cyclopsexperiment_43' is not.
%
% So, the prefix should be no more than 6 characters if you have a 2-digit
% subject number, or no more than 5 characters if you have a 3-digit subject number.
%
% This VERIFIES that the prefix is no more than 6 characters long, and
% quits if it's not:
if (numel(eye_prefix) + subjnolength) > 8
    fprintf('Prefix for eye-tracking file name is too long.\nIt should be 6 characters long at max.\nPlease fix this in your experiment and try again.\n');
    return
end

% Below is the number of seconds to wait between displaying your visual
% stimuli and playing your auditory stimuli.
% e.g. TimeBeforeSound = 1; means the pictures will be shown for 1 s before
% the auditory instruction begins.
% This can be 0 if you want no delay at all.
TimeBeforeSound = 0.25;

% This is the number of different lists you have.
NumLists = 1;

% This is the number of PRACTICE TRIALS you have.  The practice trials
% should be in the SAME list file as the rest of your trials, but at the
% TOP.  This setting is what tells the experiment that the first X number
% of trials are practice trials.
NumPractice = 1;

% If RandomizeOrder = 1, the program randomizes the order of the
% (non-practice) trials.  If RandomizeOrder = 0, they are always run in
% the order listed in the original file.
RandomizeOrder = 1;

% If you KNOW the frequency your audio stimuli were recorded at, and the
% number of channels (1 = mono, 2= stereo) you can set that here.
%
% If you DON'T KNOW, leave these at 0 and the experiment will try to figure
% it out from the sound files themselves.
%
% At any rate, you DEFINITELY want all your auditory stimuli to have the SAME
% frequency and SAME number of channels.
SOUNDFREQ = 0;
SOUNDCHANNELS = 0;


% Other settings you can change:
TextSize = 32;
TextFont = 'Arial';
bgcolor = white; % background color
fgcolor = black; % color of TEXT in the instructions screen
                 % and of the BORDERS around pictures
%
% If you want to use colors other than white and black, they need to be
% defined in terms of RGB values.  See my graphicsdemo.m for more info.

%% CHECK THE SCREEN RESOLUTION     

% The eye-tracker expects the monitor to have a particular screen
% resolution.  The display should be 1280 pixels wide x 1024 pixels tall.
%
% It's important to CHECK that this is the case.  The experiment will not
% work properly if the screen has a different resolution.
%
% The code below CHECKS the resolution of the screen.  If it's NOT at the
% right resolution, it forces the experiment to stop and displays a message
% about how you can fix it.
%
% This keeps the experiment from being run at the wrong resolution.

resolution=get(0,'ScreenSize');
if resolution(4)<1024 && ~test
    fprintf(['Please change the screen resolution to 1280 x 1024!\n'...
        'Quit Matlab, right-click on the desktop.  Go to "properties", '...
        'then "settings," and change the Screen Resolution to 1280 x 1024\n.'...
        'Restart Matlab after you have done this.\n']);
    return
end

%% GET SUBJECT NUMBER FROM USER

% Figure out the MAXIMUM subject number
if subjnolength == 2 % maximum length is 2 digits
    maxsubjno = 99;
else % maximum length is 3 digits
    maxsubjno = 999;
end

% The getSubjectNumber() functions prompts the experimenter for a subject
% number *and* verifies that the subject number HAS NOT ALREADY BEEN USED.
[subjno listno] = getSubjectNumber([output_dir behav_prefix], '.csv', 1,maxsubjno,NumLists);

% It also AUTOMATICALLY rotates through the different lists you have based
% on the subject number.  You don't have to worry about entering the
% correct list number.

%% DO EYE-TRACKING?

% I also like to ASK the experimenter whether or not to run the eye-tracker. 
% 
% Saying NO to eye-tracking allows us to run the rest of the experiment
% without having an eye-tracker connected & calibrated.  This allows you to
% test the experiment on your own personal computer, for instance.
% (Otherwise, if MATLAB tries to access the eye-tracker and it's not
% connected, the experiment will simply crash.)

% do eyetracking?
doeyetracking = -1;
while doeyetracking < 0
    userstr = upper(inputstring('Do eye-tracking in this session? (Y for Yes, N for No): '));
    if strcmp(userstr, 'Y')
        doeyetracking = 1;
    elseif strcmp(userstr, 'N')
        doeyetracking = 0;
    end
end

fprintf('Please wait - loading experiment... \n');

%% OPEN THE LIST FILES

% In this section, we load up a list of trials.  The list of trials is
% saved in a separate comma-separated spreadsheet (.CSV -- OpenOffice Calc or
% MS Excel can easily save in this format)
%
% Each trial is a ROW in the spreadsheet.
%
% The stuff that goes in your list file will depend on your experiment
% (e.g. what conditions you have).  Some things that it should DEFINITELY
% have are:
%  > the FILENAME of the AUDITORY stimulus for the trial.
%
%  > the FILENAME of the VISUAL stimuli for the trial - 1 column per port.
%    See below for more information on PORTS.
%
%  > the CONDITION that each port represents - e.g. does that port
%    represent the TARGET, the COMPETITOR, an EMPTY spot, etc.?  you should
%    have 1 column per port.  This is the stuff that gets sent to the
%    eye-tracker and is used to analyze your eye-tracking data (so make
%    sure that it is correct!)
%
%  > if the picture is being DRAGGED somewhere, the PORT NUMBER where the
%    the DROP LOCATION is
%
%  > probably, some other columns with condition information that you want
%    to keep track of.
%
% See the list1.csv that comes with the CogToolbox-3 for a brief example
% (NOT a full experiment, but hopefully enough to get you started)
%
% Because each experiment involves DIFFERENT variables, you will need to
% MODIFY this section of code to reflect what YOUR experiment requires.
% See below for what you need to change.
%
% Each LIST is a separate file.  They should be called list1.csv,
% list2.csv, etc.
%
% The PRACTICE TRIALS should come at the TOP of the list file.  At the top
% of the script, the line:
%   NumPractice = 1
% tells the experiment how many practice trials you have.  Change the
% number to properly reflect how many practice trials there are.


% Open the appropriate list of trials:
listfile = fopen([list_dir 'list' num2str(listnum) '.csv']);

% Read in the first line - this is the header row - and then discard it:
fgetl(listfile);
% If you don't have a header row at the top of your file (e.g. a row that has
% the name of each column), you should remove that line.


% !!IMPORTANT: THIS NEXT LINE MUST BE MODIFIED TO REFLECT THE NUMBER OF
% COLUMNS (and their CONTENTS) in YOUR list files.  See matlabbasics.m for
% more information on how to do this.

% Now, read in the DATA and save it in a big cell array (called
% 'trialdata')
%
trialdata = textscan(listfile,'%s%s%d%s%s%s%s%s%s%s%s%s%s%d', 'Delimiter', ',');

% Close the file after reading data;
fclose(listfile);

% !!IMPORTANT: THIS SECTION MUST ALSO BE MODIFIED TO REFLECT YOUR
% EXPERIMENT.
%
% This secton defines WHICH COLUMN to look in for each type of data.
% We use this throughout the experiment to look up stuff from trialdata.
%
% For instance, our ITEM NAME is in column 1:
%
% You will need to UPDATE this to reflect your own experiment:
ITEM = 1; % column where the ITEM NAME is
SOUNDFILE = 2; % column where the SOUND FILE is
ISFILLER = 3; % 1 if FILLER ITEM, 0 if CRITICAL ITEM
DISCSTATUS=4; % a column indicating an experimentally manipualted factor
ACCENT = 5; % another experimental factor
PORT_CONTENTS = 6; % number of FIRST COLUMN definining the PORT CONTENTS
    % (4 columns in total if you have 4 ports, etc.)
PORT_CONDITIONS = 10; % number of FIRST COLUMN defining the PORT CONDITIONS
DROP_PORT = 14; % this column has the PORT NUMBER where the participant should DROP a picture being moved



% If you requested the trials to be in RANDOM ORDER, this next section of
% code randomizes the order of the trials.
%
% Otherwise, the trials are presented in the same order they appear in your
% spreadsheet.
%
if RandomizeOrder    
   % YES, randomizing
   %
   % First, count how many NON-PRACTICE trials there are:
   realtrials = numel(trialdata{1})-NumPractice; % total trials - # of practice trials
    
   % Randomize the order of the real trials:
   realorder = randperm(realtrials)+NumPractice; % +N because the first ones are practice trials
   % This takes all the numbers from X to Y, where X is the first real
   % trial and Y is the last trial, and puts those numbers in a random order.
   
   % Randomize the order of the practice trials:
   practiceorder = randperm(NumPractice);
   % You can comment out the above line if you don't want the practice
   % trials to be put in a random order.
   %
   % This takes the numbers from 1 to N, where N is the number of
   % practice trials, and puts those numbers in a random order.
   
   % Now, concatenate these into a single list of trials, with the practice
   % trials coming first:
   trialorder = [practiceorder realorder];
else
    % NO, always the SAME order
    
    % Count the number of trials
    numtrials = numel(trialdata{1});
    
    % Present these as ordered:
    trialorder = 1:numtrials;
    % Here, the trial order is just the list of numbers from 1 to Y, where
    % Y is the last trial.  It's always in numerical order.
end

%% OPEN THE BEHAVIORAL OUTPUT FILE

% I save data about each trial and the participants' errors into a file.
%
% You could also use this to keep track of RTs or whatever else you want.

% open the output file
outfile = fopen([output_dir behav_prefix num2strLZ(subno, ['%' num2str(subjnolength) 'd'], subjnolength) '.csv'], 'w'); % w for WRITING

% Below we add a header row in the output file
%
% Printing the header row is optional -- but it makes your output easier to
% understand, and helps when importing data into R (so it knows the names
% of your variables)
%
% You'll probably want to change this to reflect YOUR experiment :)
fprintf(outfile,'SUBJECT,LIST,TRIALNUM,ITEM,ISFILLER,DISCSTATUS,ACCENT,TARGET_PORT,DROP_PORT,ERRORS\n');
%
% The ordering of the variables in the header row should reflect the order
% you print them at the end of each trial (in the code for each trial,
% far below).

%% SET-UP VISUALS

% Open the screen
[elwindow rect] = Screen('OpenWindow', 0, bgcolor);
% rect is a 4-element vector that contains the dimensions of the screen

% Set font properties
Screen('TextSize', elwindow,TextSize);
Screen('TextFont', elwindow,TextFont);

% If you have video driver problems, remove the % from the line below to
% activate it.  Otherwise, keep it commented out:

%Screen('Preference','VBLTimestampingMode',-1); 

% The next line is supposed to improve the smoothness of the graphics.  I
% haven't done too much testing of how much it actually helps, but it can't
% *hurt*
Screen(elwindow,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%% SET-UP SOUND

% The next statement sets up Psychophysics Toolbox's sound system.  It is
% REQUIRED to have this at the start of your experiment.  See sounddemo.m
% for more information:
InitializePsychSound;


% If the frequency of the sound was not specified by the programmer, we
% have to try to figure it out from the sound file itself
if SOUNDFREQ == 0
    
    % Check on the frequency by opening up an audio file from trial 1
    [garbage,SOUNDFREQ] = wavread([sound_dir trialdata{SOUNDFILE}{1}]);
    clear garbage; % no need to save the acutal audio itself
    
    % Display a message to the user about what we did (and how to avoid
    % this check in the future)
    fprintf('\n\nYour experiment did not explicitly specify the frequency\nat which the auditory stimuli were recorded.\n');
    fprintf('CogToolbox checked on the files and estimated this to be %d Hz.\n', SOUNDFREQ);
    fprintf('If you change SOUNDFREQ = 0 at the top of your experiment to SOUNDFREQ = %d,\nyou can skip this check in the future.\n\n', SOUNDFREQ);
end


% If the number of channels was not specified by the programmer, we have to
% try to figure it out form the sound file itself
if SOUNDCHANNELS == 0

    % Check on the # of channels by opening up an audio file from trial 1
    garbage = wavread([sound_dir trialdata{SOUNDFILE}{1}]);
    SOUNDCHANNELS = size(garbage,2); % 2nd dimension is # of channels
    clear garbage; % no need to keep the actual audio itself
    
    % Display a message to the user about what we did (and how to avoid
    % this check in the future)
    fprintf('\n\nYour experiment did not explicitly specify the number of channels in your auditory stimuli.\n');
    fprintf('CogToolbox checked on the files and estimated this to be %d channel(s).\n', SOUNDCHANNELS);
    % interpret this for the user
    switch SOUNDCHANNELS
        case 1
            fprintf('This is MONO sound.\n');
        case 2
            fprintf('This is STEREO sound.\n');
        otherwise
            fprintf('This is somewhat weird.\nUsually, you don''t need more than 2 channels (for stereo sound).\nYou might want to check your audio stimulus files.\n');
    end
    fprintf('If you change SOUNDCHANNELS = 0 at the top of your experiment to SOUNDCHANNELS = %d,\nyou can skip this check in the future.\n\n', SOUNDFREQ);
end
    
    
% This opens a channel on the sound card, which we use to play sound
% throughout the experiment:
pahandle = PsychPortAudio('Open', [], 1, 1, SOUNDFREQ, SOUNDCHANNELS, [], 0.015);

%% DISPLAY INTRO

% Show an introduction screen displaying information about eye-tracking.
% 
% You can customize these directions if you don't like mine :)

HideCursor; % hide the mouse cursor

if ~test
  instructions=['Welcome to the experiment!|'...
              'In this experiment, we are going to use the eye-tracker to '...
              'investigate how people follow instructions on the computer.|'...
              'First, we have to set up the eye-tracker to adjust to your eyes.  '...
              'The experimenter will tell you more about this.|'...
              'It might take a few tries to get the eye-tracker matched to your eyes.  '...
              'This is normal!  Everyone''s eyes are a little bit different, so '...
              'it takes the eye-tracker a little while to get adjusted to your eyes.'];
  InstructionsScreen(elwindow,fgcolor,bgcolor,instructions,'',fgcolor,1); 
end

% The instructions prompt the user to CLICK THE MOUSE to continue.
%
% If you would rather use a KEYPRESS, change:
%   , 1);
% at the end of the InstructionsScreen() call to:
%   , 0);

%% SET UP EYE TRACKER

% This is the section where we:
%   (A) have MATLAB connect to the eye-tracker.
%   (B) calibrate the eye-tracker.
%
% The IF block means that this section ONLY gets run if we say we want to
% use the eye-tracker.
%
% This allows us to skip over the eye-tracking code if we don't want to use
% (or don't have) the eye-tracker.  Trying to run the eye-tracker on a
% computer that is not connected to the eye-tracker will crash the
% experiment.
%
% You shouldn't really mess with this code :P

if doeyetracking
   Eyelink('Initialize');
   
   % Provide Eyelink with details about the graphics environment
   % and perform some initializations. The information is returned
   % in a structure that also contains useful defaults
   % and control codes (e.g. tracker state bit and Eyelink key values).
   el=EyelinkInitDefaults(elwindow);

   % Make sure that we get gaze data from the Eyelink:
   Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

   % Display the tracker version:
   [v vs]=Eyelink('GetTrackerVersion');
   fprintf('Running experiment on a ''%s'' tracker.\n', vs );
   % This isn't essential to making the eye-tracker work -- it is just for
   % YOUR reference.
 
   % Open file to record data to:
   edfFile=[eye_prefix num2strLZ(subjno,'%2d',subjnolength) '.edf'];
   % The name of the file is:
   %   PREFIX plus SUBJECT NUMBER (coerced into a particular length
   %   by adding leading zeros) plus '.EDF' EXTENSION

   % Calibrate the eye-tracker:
   EyelinkDoTrackerSetup(el);
end

%% PORT SET UP

% In a typical visual world experiment, the screen is divided up into
% "ports."
%
% A port is a location in which a picture can appear.  For example, if
% each trial has 4 pictures, you have 4 ports.
%
% Each POSSIBLE location needs to be a port, even if nothing appears in
% that port at some times.  For example:
%  > You have 3 pictures per trial but 10 locations in which those
%    pictures could appear -> there are 10 ports.
%  > You have 4 pictures per trial, and 4 other locations to which those
%    pictures could be moved by the participant -> there are 8 ports
%
% The ports are defined in terms of 4 numbers.  The numbers, in order, define:
%   - the LEFT EDGE of the port
%   - the TOP EDGE of the port
%   - the RIGHT EDGE of the port
%   - the BOTTOM EDGE of the port
% in terms of PIXELS.  0s correspond to the top and left corner of the
% screen.  Increasing the #s will move the picture further to the right and
% further down.  See graphicsdemo.m for more information about how graphics
% are displayed in Psychophysics Toolbox.

% Define the ports
ports         = [left_x_coordinate top_y_coordinate right_x_coordinate bottom_y_coordinate; ... % coordinates defining port 1
                 left_x_coordinate top_y_coordinate right_x_coordinate bottom_y_coordinate; ... % coordinates defining port 2
                % ... and so on...
                left_x_coordinate top_y_coordinate right_x_coordinate bottom_y_coordinate]; % coordinates defining LAST port

% You will need to change these to the coordinates that you want your ports
% to have.  For example:
%   ports      = [100 200 300 500;
%                 400 700 600 1000];
% would define two ports.  The first port starts at pixel X:100,Y:200 and
% goes to pixel X:300,Y:500.  The second port starts at pixel X:400,Y:700
% and goes to pixel X:600,Y:1000.  Both ports are 200 pixels wide, and 300
% pixels tall.

% You could type in every number manually.  Or, you could some sort of
% calculation, e.g.:
%     100 300 100+portwidth 300+portheight
% where you previously defined portwidth and portheight to be some numbers
%
% If you want to refer to the screen size, rect(3) is the total width of
% the screen, and rect(4) is the total height of the screen.  Thus:
%     0 0 rect(3)/2 rect(4)/2
% defines a port that occupies the entire upper-left quadrant of the
% screen.


% Calculate the SIZE of the ports (you DON'T need to change this code):
portRects = [zeros(size(ports,1),1) zeros(size(ports,1),1) ports(:,3)-ports(:,1) ports(:,4)-ports(:,2)];
%
% Each row represents 1 port and has the format:
%   0 0 width height
%
% Whereas "ports" represents the RAW COORDINATES of the ports, portRects
% represents their SIZES. We use this later to help with resizing & drawing
% images.

%% CREATE MASTER TRIAL DISPLAY

% Here, we create a "master" window for each trial, called "alltrialwindow"

alltrialwindow = CreateOffWin(elwindow, bgcolor, TextFont,TextSize);

% In some experiments, there are some common elements you might want to
% display on EVERY trial:
%  > For example, you might have a fixation cross that is permanently
%    visible in the center.
%  > Or, you might have a standard set of pictures that serve as GOAL LOCATIONS
%    (e.g. geometric shapes in the corners, so you can give instructions
%    like "Put the candle below the circle.")
%  > Other situations I can't think of right now :P

% alltrialwindow contains these repeated elements.  Anything you put on
% alltrialwindow (e.g. pictures, text, lines) in this section will show up on
% EVERY trial.
%
% Stuff that is UNIQUE to each trial (e.g. particular target pictures) should NOT
% be added here.  That gets done later, for each specific trial.
%
% If the display is going to be completely different on every trial (e.g.
% you just have 4 pictures that are different on every trial), then there
% is nothing you need to add below.

% -----USE THIS SECTION TO DRAW STUFF ON ALLTRIALWINDOW--
%   e.g. DrawLine, loadimage + CopyWindow, etc.
% -----END SECTION FOR DRAWING ON ALLTRIALWINDOW---------

% It's more efficient to draw these elements just once on a master window.
% Drawing them over & over on every single trial is slower.

%% SHOW INSTRUCTIONS TO PARTICIPANTS

% Here you show instructions to the participants detailing the experiment.
%
% The InstructionsScreen() function handles displaying a screen of
% instructions, and forces the participant to spend some time reading the
% instructions before they are allowed to click to continue.  This helps
% makes sure that your participants actually READ your instructions.
%
% Each pair of instructions=[] and InstructionsScreen() commands is a
% separate screen.
%
% You can insert paragraph breaks in your instructions with a pipe: |
% See below for examples.
%
% This set of instructions applies to an experiment I ran.  You will
% probably want to modify them to match your task!

if ~test
    
  instructions=['In this experiment, you will hear recorded instructions.  The instructions will tell you how to move pictures on the computer screen.|'...
          'To move a picture, move the mouse pointer over the picture you wish to move. Hold down the left mouse button and move the mouse until the picture is in the desired location. Release the mouse button to drop the picture.'];
  InstructionsScreen(elwindow,fgcolor,bgcolor,instructions,1);
  
  instructions=['You won''t be able to move pictures until the recorded instruction has ended.  The mouse cursor will appear on the screen when you can move pictures.|' ...
           'If you make a mistake, the picture will be moved back to its starting location and the instruction will be given again.'];
  InstructionsScreen(elwindow,fgcolor,bgcolor,instructions,1); 
  % the apostrophe (') character normally marks the end of a text string.
  % So, to use an apostrophe WITHIN a string, we have to double it: e.g.
  % won''t

  instructions=['After each screen, the experiment will stop and perform a check to make sure that the eyetracker is still set correctly.|'...
      'We might have to readjust the eyetracker to make sure it is still following your eyes.  This is normal, and doesn''t mean ' ...
      'there''s anything wrong!'];
  InstructionsScreen(elwindow,fgcolor,bgcolor,instructions,1);
  
  instructions='First, we''ll start with a few practice trials.| But, feel free to ask the experimenter now if you have any questions.';
  InstructionsScreen(elwindow,fgcolor,bgcolor,instructions,1);
end
  
%% RUN EACH TRIAL

% This large section is where your actual trials get run.
%
% Some people put their practice & experimental trials in separate blocks of
% code.  The experiment is essentially coded twice.  My version combines
% everything into one block, and just uses the "trialcounter" variable to
% keep track of whether or not you are in the practice block.  I prefer
% this because it means you need 1 set of code to run your trials.  It
% guarantees everything works consistently.  Otherwise, you might change
% something in the code for the practice block and forget to change it in
% the "real" trials, or vice versa.

% This next variable keeps track of the serial ordering of trials.  We use this
% to display some transition screens after the practice block. (The code
% for those screens is at the very end of this section.)
trialcounter = 1; % initialize trial counter

for trialnum=trialorder
    % trialorder is the list of trials, and we step through the list 
    
    % This stuff SETS UP each trial; we haven't displayed anything yet.
    
    %% DO DRIFT CORRECTION
    if doeyetracking
      % This does the drift correction (only if the eye-tracker is turned
      % on).  The drift correction helps the eye-tracker keep up to date in
      % case the participant's position has shifted slightly ("drifted")
      % over the course of the experiment.
      %
      % I do the drift correction before every trial, since it only takes
      % a few seconds (if that!).  If you have a LOT of trials and need to
      % make your experimenter shorter, you could consider doing the drift
      % correction only every few trials.  The easiest way to do this would
      % be with mod(trialcounter) -- see my demo in matlabbasics.m for more
      % information on mod()
      EyelinkDoDriftCorrection(el);
    end
    
    %% VARIABLE SET UP
    trialitems = movables; % save a set of the item locations for this trial
                           % so we can adjust them w/o changing the
                           % master coordinates
                                       
    %% READY THE AUDITORY STIMULUS   
    % Read in the file:
    stimulussound = wavread([sound_dir trialdata{SOUNDFILE}{trialnum}]);
    stimulussound = stimulussound';
    % The second line TRANSPOSES the sound file so it's a row vector rather
    % than a column vector.  Psychophysics Toolbox expects the sounds as a row
    % vector, and if you don't transpose it, your experiment will crash.  See
    % sounddemo.m for more information
    
    % Place the auditory stimuli in the sound buffer
    PsychPortAudio('FillBuffer', pahandle, stimulussound);
    % This doesn't play the stimuli yet.  It just gets it READY to play, so
    % we can start it at the exact time we want. 
                                   
    %% READY THE VISUAL STIMULI    
    
    % Copy the "alltrialwindow" template to the main window.
    % ("alltrialwindow" holds stimuli that are COMMON to all trials - e.g.
    % a goal location that is used on every trial.  This is created above
    % in the "CREATE MASTER TRIAL DISPLAY" section)    
    Screen('CopyWindow',alltrialwindow,elwindow,rect,rect);
 
    % Load and place each image in its appropriate port.  Note that nothing
    % has been DISPLAYED yet, since we haven't used the Screen('Flip')
    % command - see my graphicsdemo.m for more information.  Instead, we
    % are just getting the pictures READY.
    %
    % At this time, we also set up the line of data (the "Screen" statement)
    % that we send to the eye-tracker detailing what's in each port.
    % The screen line needs to be formatted
    % "Screen: portnumber,condition;portnumber,condition..."
    %
    % !!!IMPORTANT!!!: It is HIGHLY recommended that you identify the ports by
    % the CONDITIONS they represent, not the actual images.  Otherwise, you
    % will have a real pain later matching each image to the condition it represents.
    %
    % !!!EVEN MORE IMPORTANT!!!: The Screen statement CANNOT be more than 80
    % characters long.  This includes the initial "Screen: " text, and all the
    % text defining the port #s and pictures.  If you have a LOT of ports, you
    % might need to ABBREVIATE the names of the conditions
    
    screenmsg = 'Screen: '; % initialize the Screen statement
    
    for portnum=1:numports % now, check what's in EACH port
        
        % Update the Screen statement with: 'port #,content'
        screenmsg = [screenmsg num2str(portnum) ',' trialdata{PORT_CONDITION+portnum-1}{trialnum}];      
                
        % Now, see if we need to load a PICTURE to go into this port    
        % by checking the port condition
        if ~strcmpi(trialdata{PORT_CONDITION+portnum-1}{trialnum},'x') && ...
            ~strcmpi(trialdata{PORT_CONDITION+portnum-1}{trialnum},'empty')
            % there is NO picture to draw if the port is EMPTY (condition
            % == 'x' or condition == 'empty')
            %
            % so, this code only gets executed if the port is NOT empty
            
            % First, if this port holds the TARGET, note that so that we know which
            % port the participant is supposed to be clicking on
            if strcmpi(trialdata{PORT_CONDITION+portnum-1}{trialnum},'target') || ...
                strcmpi(trialdata{PORT_CONDITION+portnum-1}{trialnum},'t')
                    targetlocation = portnum; % target is located in THIS port
            end
            
            % Load the picture from the picture directory:
            pics{portnum} = loadImage(elwindow, [pics_dir trialdata{PORT_CONTENTS+portnum-1}{trialnum}], portRects(portnum,:), 1, bgcolor);
            
            % Draw a border around the image:
            Screen('FrameRect',pics{portnum}, fgcolor, portRects(portnum,:),2);
            %
            % A border makes your graphics look a lot better when you're dragging
            % things around.  Psychophysics Toolbox treats all the pictures
            % as rectangles, filling up the corners of the pictures with
            % whitespace (or whatever your background color is) if needed.
            % This means that when the pictures are dragged around, even
            % the corner whitespace can occlude another picture.  That
            % looks really weird.  If you add a border to the picture, it's
            % perceived as a rectangular object and the occlusion looks a
            % lot more sensible.
            %
            % (If this description is unclear, try commenting out the
            % FrameRect line and running your experiment.  The dragging
            % will look really weird.)
            %
            % If you're only having people CLICK on the pictures, and not
            % DRAG them, the border is unnecessary.
            %            
            % With Psychophysics Toolbox 3, it's also possible to avoid this
            % problem by making the "whitespace" TRANSPARENT using an alpha
            % channel.  I haven't played around with this too much, though.    
            
            % Put the picture in the appropriate port
            piccoords = ports((portnum),:); % retrieve the X,Y coordinates of the port
            Screen('CopyWindow',pics{portnum},elwindow,portRects(portnum,:),piccoords); % put the picture there
        end       
        
        if portnum < numports
            screenmsg = [screenmsg ';'];
            % if this is not the last port, add a semicolon to separate it from the next port
        end
    end
    
    % At this point, we have the auditory & visual stimulus all ready, but
    % nothing has been displayed to the participant yet.
    %
    % Now, we start the trial:
    
    %% DISPLAY THE VISUAL STIMULI
    Screen('Flip',elwindow);
    
    % It's a good idea to hide the mouse cursor until the auditory
    % instruction is finished.  When participant see the mouse cursor is on
    % the screen, they think they can click on stuff, and get
    % frustrated/confused when it doesn't work.  Hiding the mouse cursor
    % keeps people from trying to respond until the instructions are over
    % (which is usually you want).
    HideCursor;
    
    % After displaying the visual stimuli, wait a certain amount of time
    % before starting the auditory stimuli.  The amount of time is set at
    % the top of this file.
    WaitSecs(TimeBeforeSound);
    
    % From this point forward, the trials with eyetracking are SEPARATED
    % from the trials without eyetracking.  Why do this?  It minimizes the
    % number of times DURING the trial that the computer has to check whether
    % or not we are doing the eye-tracking.  This allows for more precise
    % timing, and that's important when using the eye-tracker.  (Thanks to
    % Angie Isaacs for this suggestion.)
    %
    % You could also adjust this if you don't want to eyetrack the filler
    % trials.  Change the below statement
    %
    % Scott's preference is to eye-track even the filler trials, and just throw
    % out the filler trials during analysis.  
    
    if doeyetracking
        %% TRIAL WITH EYE-TRACKING
        %
        % This section of code controls what happens on trials with
        % eye-tracking
        
        errors = zeros(3); % no errors (yet)
            
            % find out the spots for the clickable pictures
            clickablespots = gridlocations(trialitems,:);
                            
                %% START RECORDING EYES
                Eyelink('startrecording');
                eye_used = -1;    % no one seems to know what this does but everyone has it in their code.  IT IS A MYSTERY  
                
                % Send two messages to the eye-tracker.  The first
                % is the SCREEN statement and describes what is in each of the ports.
                % The second is the STIMULI statement and records what
                % auditory stimulus was played.
                Eyelink('message', sprintf(screenmsg));
                Eyelink('message', sprintf('Stimuli: %s', trialdata{SOUNDFILE}{trialnum}) );
          
                %% PLAY THE AUDTORY STIMULUS AND WAIT FOR IT TO FINISH
                PsychPortAudio('Start', pahandle);
                PsychPortAudio('Stop', pahandle, 1); % wait for the sound to stop playing before continuing
                %
                % This forces the participant to listen to the whole
                % auditory instruction before they can do anything.  This
                % is typical in this type of experiment, but if you DON'T
                % want that, you should remove the 'Stop' line.  Then the
                % participant can control the mouse even while the sound is
                % playing
                
                %% SHOW THE MOUSE CURSOR 
                ShowCursor;
                % The cursor was previously hidden (with HideCursor) so
                % that participants won't try to click on stuff before the
                % sound is done playing.
                                
                %%----USER RESPONSE SECTION----
                
                % Here, we get a response from the user.  What we do here
                % will depend a lot on the task in YOUR experiment.  Is the
                % user just clicking a picture?  Or, are they clicking and
                % dragging it somewhere else?  Do we force them to repeat a
                % response if they get it wrong?
                %
                % I've included 3 examples below that reflect some common
                % tasks you might want to do.
                %
                % DO NOT run the code with all 3 of these examples in the
                % code.  Then you will be trying to get 3 respones from the
                % participant.  Keep one, and delete the examples you don't
                % want to use.
                %
                % You could also program LOTS of other possible responses.
                % These are just 3 simple examples that reflect common
                % visual world examples.  They are by no means the only
                % thing you can do!
                
                %---RESPONSE EXAMPLE 1: CLICK ANY PICTURE---
                % In this example, we get the user to click a single
                % port.  We record what port was clicked, but end the
                % trial whether the selected picture was correct or not.

                % Get them to click one of the ports and return the # of
                % the port that was clicked:                
                picselected = Wait4Mouse(clickablespots);
                                
                % Did they click the correct picture?
                if picselected == targetlocation % clicked the TARGET
                    participanterror = 0; % no error
                else   % clicked something OTHER than the target
                    participanterror = 1; % mark an error
                end
                
                % Stop recording eye movements at this point:                       
                Eyelink('stoprecording');
                
                %---RESPONSE EXAMPLE 2: CLICK THE CORRECT PICTURE---
                % In this example, we force the user to click the correct
                % target picture.  If they click the wrong picture, the
                % instruction is replayed and the participant has to try
                % again.
                                                
                done = 0;
                participanterror = 0; % start with 0 errors
                while ~done  % Repeat until they get it correct

                    % Get them to click one of the ports and return the # of
                    % the port that was clicked:                    
                    picselected = Wait4Mouse(clickablespots);

                    % now, see if this was the CORRECT port                   
                    if picselected == targetlocation % clicked the TARGET
                       
                        % Stop recording eye movements at this point:
                       Eyelink('stoprecording');
                        
                       done = 1; % allow the trial to end
                    else
                        % clicked something OTHER thant the target
                        
                        % Add 1 to the number of errors on this trial:
                       participanterror = participanterror + 1;
                       
                       % Stop recording eye movements after the FIRST error
                       if participanterror == 1
                           Eyelink('stoprecording');
                       end
                       % We don't need to do this after the first error
                       % because we've ALREADY stopped.  I'm not sure if
                       % sending a 2nd stop message would confuse the
                       % eye-tracker or not, but why take the chance?
                       
                       % Hide the cursor, REPLAY the instructions, show
                       % cursor:
                       HideCursor;
                       PsychPortAudio('Start', pahandle); % most recent sound is still in the buffer
                       PsychPortAudio('Stop', pahandle, 1); % wait for the sound to stop playing before continuing
                       ShowCursor;
                       
                       % done is not yet set to 1, so the loop repeats and
                       % we get another response from the participant
                       % (until they get it correct)
                    end
                end

                % Now, they've finally got it correct.
                % Stop recording eye movements at this point:                       
                Eyelink('stoprecording');
                
                %---RESPONSE EXAMPLE 3: DRAG A PICTURE TO THE CORRECT LOCATION---
                % In this example, the user clicks on a picture and (while
                % holding the mouse button down) DRAGS it to a new
                % location, then drops it by releasing the moust button.
                % If the participant clicks the wrong picture or drags it to
                % the wrong port, they have to click again until they get
                % it right.
                %
                % Eye movements are tracked through the first drag & drop
                % attempt. 
                
                participanterror = 0; % assume no error until we see one              
                
                % SELECT TARGET
                % Get them to click one of the ports and return the # of
                % the port that was clicked:                    
                picselected = Wait4Mouse(clickablespots);

                % Also record where the cursor is relative to the top left of
                % the pic.  This is done so the pic will keep its location
                % relative to the cursor even as it starts moving
                [xold,yold,buttons] = GetMouse;
                
                % we are now moving the picture
                moving = 1;
                
                % SELECT DESTINATION
                % While the user is selecting a destination, move the
                % picture along with the mouse
                while moving
                    % get the current mouse coordinates:
                    [x,y,buttons]=GetMouse;

                    % Redraw the screen (except the item being moved)
                    Screen('CopyWindow',alltrialwindow,elwindow,rect,rect); % template
                    for portnum=1:numports
                        if portnum ~= picselected % For items that are NOT being moved...
                            % ...just put them at their normal location.
                            piccoords = ports(portnum,:); % get the X,Y coordinates of the port                           
                            Screen('CopyWindow',pics{portnum},elwindow,portRects(portnum,:),piccoords); % draw this pic
                        end
                    end
                    
                    % Now, draw the item being moved.
                    % We draw this item LAST so that it always appears "on
                    % top" of any other pictures that it may be hovering
                    % over.  Otherwise things look weird :P
                    
                    % First, see where the cursor has moved since the
                    % picture was originally clicked:
                    diff = [x-xold y-yold x-xold y-yold];
                    
                    % Get the original X,Y coordinates of the port and adjust them 
                    piccoords = ports(picselected,:)+diff;
                    % We update the coordinates of the picture by however much the
                    % mouse cursor has moved since the picture was clicked.  Doing this 
                    % rather than always centering the picture at the mouse cursor
                    % prevents the picture from "jumping" in space when it
                    % is clicked (e.g. because the participant clicked a
                    % corner of the picture, but then the picture then
                    % becomes centered on the mouse cursor)

                    % Before drawing the picture, make sure that it is has
                    % not been moved outside the right/left boundary of the
                    % screen:
                    if piccoords(3) > XRight;
                        diff = piccoords(3)-XRight;
                        piccoords(1) = piccoords(1) - diff;
                        piccoords(3) = piccoords(3) - diff;
                    elseif piccoords(1) < 0;
                        diff = abs(piccoords(1));
                        piccoords(1) = piccoords(1) + diff;
                        piccoords(3) = piccoords(3) + diff;
                    end
                    % or the bottom/top boundary
                    if piccoords(4) > YBottom
                        diff = piccoords(4)-YBottom;
                        piccoords(2) = piccoords(2) - diff;
                        piccoords(4) = piccoords(4) - diff;
                    elseif piccoords(2) < 0
                        diff = abs(piccoords(2));
                        piccoords(2) = piccoords(2) + diff;
                        piccoords(4) = piccoords(4) + diff;
                    end
                    % If it HAS, force the picture to STOP at the edge of
                    % the screen
                    
                    % Now, draw the picture being moved at the location we
                    % have just calculated:
                    Screen('CopyWindow',pics{picselected},elwindow,portRects(picselected,:),piccoords);
                                                           
                    % Done drawing the new screen - display it ASAP:
                    Screen('Flip',elwindow,0);    
                    
                    % TEST IF WE HAVE STOPPED MOVING
                    if buttons(1)==0 % yes, the mouse button has been released
                        moving = 0; %
                        
                        % Stop recording eye movements at this point:                       
                        Eyelink('stoprecording');
                        
                        % test if this was the RIGHT picture to move
                        if picselected ~= targetlocation
                            % picture selected is NOT equal to the location
                            % of the target -- they clicked something else!
                            participanterror = participanterror + 1; % record that there was an error
                        else
                            % this is the right picture
                            % now, test if they moved it to the RIGHT SPOT
                            
                            % Get the coordinates of this picture:
                            x = piccoords(1) + floor(portRects(picselected,3) / 2); % use the CENTER of the picture
                            y = piccoords(2) + floor(portRects(picselected,4) / 2);
                            % We test whether the CENTER of the picture is
                            % inside the correct port, rather than whether the mouse
                            % cursor itself is inside the correct port.  This way, if the
                            % participant is dragging the picture by 1 corner, we don't penalize
                            % them if 90% of the picture is inside the port
                            % but the cursor isn't.
                            
                            % Retrieve the port # that it's SUPPOSED to be dropped in:
                            dropsite = trialdata{DROP_PORT}(trialnum);
                            
                            if (x >= ports(dropsite,1)) && (x <= ports(dropsite,3)) ...
                                     && (y >= ports(dropsite,2)) && (y <= ports(dropsite,4))
                                 % Yes, the picture was dropped within the
                                 % boundaries of the correct port.
                                 %
                                 % No error needs to be recorded.
                            else
                                % dropped on the WRONG location
                                participanterror = 1; % record that there was an error
                                
                                % Here, we just have a single error flag that gets activated
                                % whether the participant clicks the wrong picture, or puts it
                                % in the wrong place.  By adding more variables, you could
                                % also distinguish between different TYPES of errors if you want
                                % (e.g. clicking a competitor picture vs.
                                % clicking a different wrong picture,
                                % clicking the wrong picture vs. clicking
                                % the right picture but putting it in the
                                % wrong place.)
                            end
                        end
                        
                        WaitSecs(1); % wait 1 second once the trial has ended
                    end
                 end % this loop gets repeated until the participant has finished moving the picture
            
    else
        %% THIS SECTION OF THE CODE CONTROLS THE PARTICIPANT RESPONSE WHEN
        %% THERE IS NO EYE-TRACKING
        %
        % Copy everything above - between "if doeyetracking" and "else" and
        % paste it here, but with the eye-tracking functions removed.
        % Everything else should be the same.
        %
        % This allows you to test the experiment without trying to access
        % the eye-tracker.  If you try to access the eye-tracker on your
        % own personal computer, the experiment will crash.
        %
        % You could also use this set-up to avoid eye-tracking the filler
        % trials.
        %
        % By putting the eyetracking and non-eyetracking versions of the trial
        % in separate blocks of code (rather then repeatedly checking if
        % eye-tracking is on), we maximize efficiency during the
        % eye-tracking trials.  This increases the accuracy of your
        % eye-tracking!
        %
        % See above for more details on the reasoning behind this.
    end
                
    %% SAVE THE BEHAVIORAL DATA FROM THIS TRIAL
    % This is used on ALL trials, with or without eye-tracking.
    
    % Get the "name" of the trial.  This has a "P" for practice
    % trials; otherwise it is just a number
    if trialcounter <= NumPractice
       trialstring = ['P' num2str(trialcounter)];
    else
       trialstring = num2str(trialcounter-NumPractice);
    end

    % Save information about performance on this instruction to the
    % behavioral data file.
    %
    % See matlabdemo.m for more information about saving to a file.
    %
    % Of course, you will need to edit this to match what information you
    % need to save about the trials in YOUR experiment.
    
    % For my reference, here is my HEADER ROW that denotes what should be in each column: 
    % fprintf(outfile, 'SUBJECT,LIST,TRIALNUM,ITEM,ISFILLER,DISCSTATUS,ACCENT,TARGET_PORT,ERRORS\n');
    
    fprintf(outfile, 'S%d,L%d,%s,%s,%d,%s,%s,P%d,P%d,%d\n', ...
              subjno, listnum, trialstring, trialdata{ITEM}(trialnum), ...
              trialdata{ISFILLER}(trialnum), trialdata{DISCSTATUS}{trialnum}, trialdata{ACCENT}{trialnum}, ...
              trialdata{TARGET_PORT}{trialnum}, participanterror);

    % If you plan to analyze your data in R, it's convenient to make sure
    % that anything that is a FACTOR (e.g. a categorical, not a continuous
    % variable) has a letter somewhere in it.  This means R will
    % automatically interpret it as a factor and saves you from having to
    % as.factor() it.
    %
    % For example, I save the subject numbers as e.g. "S3" and the list
    % number as "L1" -- so R knows that these are categorical variables and
    % not a quantity (subject 4 is not "two times" subject 2).
          
    %% TRIAL CLEAN UP 
    for portnum=1:numports
        % find NON-EMPTY ports
        if ~strcmpi(trialdata{PORT_CONDITION+portnum-1}{trialnum},'x') && ...
            ~strcmpi(trialdata{PORT_CONDITION+portnum-1}{trialnum},'empty')
           Screen('Close',pics{portnum}); % Close the pictures in those ports; we don't need them anymore
        end
    end    
    trialcounter = trialcounter + 1; % Keep track of how many trials we have completed
    
    %% TRANSITION BETWEEN PRACTICE & REAL TRIALS
    if trialcounter==NumPractice

        % This block of code gets executed when (and only when) the
        % participant has just finished the set of practice trials. (i.e.,
        % when the # of trials completed is equal to the # of practice
        % trials).
        %
        % You can use it to display any instructions you want before the
        % participant starts the "real" trials.

        instructions=['OK, you''ve finished the practice trials!|'...
                      'Now for the real experiment.|'...
                      'If you have any questions, please ask the experimenter now.'];
        InstructionsScreen(elwindow,fgcolor,bgcolor,instructions,1);          
    end
    
end

%% FAREWELL SCREEN
instructions=['Congratulations, you are all done with the experiment!|'...
              'Thank you for your participation.'];
InstructionsScreen(elwindow,fgcolor,bgcolor,instructions,1);   

%% WRAP-UP EXPERIMENT

% At this point, the experiment is over.  We just need to close everything
% done.  Don't forget this stuff -- this is IMPORTANT!

% Shut down eye-tracking, if it's on.
if doeyetracking
  Eyelink('closefile');
  Eyelink('shutdown');
end

% Shut down screen & audio
Screen('CloseAll');
PsychPortAudio('Close');

% Close data file
fclose all;

% all done!
fprintf('Experiment ended successfully!  Thank you!\n');