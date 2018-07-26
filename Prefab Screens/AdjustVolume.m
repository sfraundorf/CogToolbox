% AdjustVolume(window, fgcolor, bgcolor, usekeypress, soundfile, yPositionIsBaseline)
%
% Presents a screen on window WINDOW that allows the user to listen to
% a test sound and adjust the volume.  The screen has background color
% BGCOLOR (default black) and foreground color FGCOLOR (default white).
%
% Optional argument USEKEYPRESS controls how the user indicates when s/he is
% done adjusting the volume.  If USEKEYPRESS is 0 (default), the user
% clicks a button.  If USEKEYPRESS is 1, there is no button and the user
% presses the spacebar.  You can use this to match the response to what you
% use in the rest of your experiment.
%
% The function includes a default test sound.  If you prefer to use one
% of your own, you can specify SOUNDFILE - the path and filename of a sound
% to use.
%
% The default soundfile has mean intensity of 71.87 dB, if you want to
% adjust your stimuli to have similar intensity.
%
% Credits: Jessie George - voice
%
% 08.26.09 S.Fraundorf - PTB-3 version
% 02.05.10 S.Fraundorf - changed order of arguments to match that of other
%                         CaLLtoolbox fxns.  Added USEKEYPRESS argument.
% 07.27.10 S.Fraundorf - added SOUNDFILE argument
% 06.22.11 S.Fraundorf - when using keypress, now only accepts spacebar
%                         (because many computers now have the volume
%                         adjustment ON other keys).  listed intensity of
%                         default file
% 06.22.11 S.Fraundorf - doesn't restore hidden cursor if you are using a
%                         keypress
% 09.30.15 S.Fraundorf - use audioread for current versions of MATLAB
% 05.26.18 S.Fraundorf - added ability to set yPositionIsBaseline - needed
%                          to display text properly on some systems

function AdjustVolume(window, fgcolor, bgcolor, usekeypress, soundfile, yPositionIsBaseline)

%% DEFAULTS

textlinespacing = 1.25; % increase spacing between lines

if nargin < 5
    soundfile = 'AdjustVolume.wav';
    if nargin < 4
      usekeypress = 0;
      if nargin < 3
         fgcolor = [255 255 255]; % white is default foreground color
         if nargin < 2
            bgcolor = [0 0 0]; % black is default bkground color
         end
      end
    end
end

%% SET UP VISUALS

% background color
Screen('FillRect',window,bgcolor);

% screen size
rect=Screen('Rect', window); % get the dimensions of the main window
YBottom=rect(4); % calculate position of bottom of screen

% font size
newtextsize=floor(YBottom ./ 20); % text size
oldsize = Screen('TextSize',window,newtextsize);

% instructions
textx = floor(rect(3) ./ 7); % leave margin of 1/7th the screen on each side
texty = newtextsize; % leave margin of 1 line on top
WriteLine(window, 'Please adjust the volume until you are comfortable and the sound is easy for you to hear.', fgcolor, textx, textx, texty, textlinespacing);

% display response prompt
if usekeypress    
    KbName('UnifyKeyNames');
    spacekey = KbName('space');
    WriteLine(window, 'Press the spacebar when you are done adjusting the volume.', fgcolor, textx, textx, YBottom/2, textlinespacing);
else
  % confirmation button
  clickedcolor = [fgcolor(1) bgcolor(2) bgcolor(3)]; % color for clicked box
  
  labelsize = Screen('TextBounds', window, 'Done adjusting volume');
  paddingX = labelsize(3) / 10;
  paddingY = labelsize(4) / 10;
  boxleft = (rect(3) / 2) - (labelsize(3) / 2);  
  boxcoordinates = [boxleft-paddingX, (YBottom/2)-paddingY, boxleft+labelsize(3)+paddingX, YBottom/2+labelsize(4)+paddingY];

  Screen('FillRect',window,fgcolor,boxcoordinates);
  Screen('DrawText',window,'Done adjusting volume',boxcoordinates(1)+paddingX, boxcoordinates(2)+paddingY, bgcolor);
end

%% SET UP SOUND
% read the sound file
[soundtoplay, Fs] = audioread(soundfile);
 wavedata = soundtoplay';
 nrchannels = size(wavedata,1); % Number of rows == number of channels.

 pahandle = PsychPortAudio('Open', [], [], 0, Fs, nrchannels);
 PsychPortAudio('FillBuffer', pahandle, wavedata);
 
%% GO
% show the screen and start playing the file
Screen('Flip', window, [], 1); % don't clear the framebuffer so stuff stays on the screen when we draw the clicked box
PsychPortAudio('Start', pahandle, 0);

% get confirmation from the user that they're done adjusting volume
if usekeypress
    Wait4Key(spacekey); % wait for space bar
    PsychPortAudio('Stop', pahandle); % stop playing sound
    PsychPortAudio('Close', pahandle);
else % click the button
  ShowCursor; % in case it was hidden
  while 1
     [clicks,x,y] = GetClicks(window);
     if IsInRect(x,y,boxcoordinates)
         Screen('FillRect',window,clickedcolor,boxcoordinates); % show confirmed box
         Screen('Flip',window);
         PsychPortAudio('Stop', pahandle); % stop playing sound
         PsychPortAudio('Close', pahandle);
         WaitSecs(0.5); % wait 1/2 s so user can see they've clicked the box    
         break;
     end
  end
end

%% WRAP-UP
% clear the screen
Screen('Flip', window);

% restore font size
Screen('TextSize',window,oldsize);