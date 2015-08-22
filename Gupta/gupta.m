% gupta(win, fgcolor, bgcolor, datafolder, subjno, playinglatency, recordinglatency)
%
% Performs the "Gupta task" (Gupta, 2003, QJEP) on window WIN with
% foreground FGCOLOR and background color BGCOLOR.
%
% Participants hear English pseudowords and immediately try to repeat them
% back.  The pseudowords are 2, 4 or 7 syllables in length.
%
% There are 5 blocks of 18 items each (90 trials total), plus 6 practice
% trials.
%
% Data take the form of recorded responses, saved in folder DATAFOLDER
% according to subject number SUBJNO.  Consequently, the data needed to be
% transcribed and scored offline after the task is run.
%
% The two latency parameters range between 0 and 1 control the timing of the sound
% files. Lower numbers result in more precise timing, but setting the
% number TOO low for your system may make the audio sound static-y.  See
% IndividualDifferences.m and the "Low-Latency Audio in Psychophysics
% Toolbox.doc" file in the CogToolbox for more information.
%
% 06.07.11 - S.Fraundorf - first MATLAB version.  thanks to Laurel Brehm
%                            for help.
% 06.09.11 - S.Fraundorf - enforce 1 s delay for accepting a response to
%                            move to the next trial, so people are less
%                            likely to hit the button before they finish
%                            speaking.
% 06.15.11 - S.Fraundorf - changed dot colors
% 06.17.11 - S.Fraundorf - fixed update to dot colors, clarified
%                            instructions
% 06.22.11 - S.Fraundorf - added initial warning to adjust volume.  reduced
%                            volume of materials (was very loud!) to match
%                            AdjustVolume.m
% 06.22.11 - S.Fraundorf - fixed bug in the new initial warning
% 07.03.11 - S.Fraundorf - resampled the audio to 48 kHz so it should play
%                            on PCs now
% 07.05.11 - S.Fraundorf - added latency parameters
% 08.12.12 - S.Fraundorf - improved stimulus timing

function gupta(win, fgcolor, bgcolor, datafolder, subjno, playinglatency, recordinglatency)

%% AUDIO PROPERTIES
% default latency:
if nargin < 7
    recordinglatency = 0.015;
    if nargin < 6
        playinglatency = 0.015;
    end
end

% audio properties are hardcoded in based on the existing stimuli:
numchannels = 1;
freq = 48000;

ISI = .100;

%% GET & SET SCREEN PROPERTIES
rect = Screen('Rect', win);

% calculate center:
XMid = floor(rect(3)/2);
YMid = floor(rect(4)/2);

% dot rect:
DotRect = [XMid-25 YMid-25 XMid+25 YMid+25];
DotDiam = max([DotRect(3)-DotRect(1) DotRect(4)-DotRect(2)]);
dotcolor = [0 255 0]; % green to start speaking
gocolor = [0 0 255]; % blue to proceed on

datafolder = makeValidPath(datafolder);

%% SET UP AUDIO
playchannel = PsychPortAudio('Open', [], 1, [], freq, numchannels, [], playinglatency);
recchannel = PsychPortAudio('Open', [], 2, [], freq, numchannels, [], recordinglatency);

PsychPortAudio('GetAudioData', recchannel, 10);

%% READ IN THE TRIAL DATA
infile = fopen('guptalist.csv');
fgetl(infile); % discard header
trialdata = textscan(infile, '%d%s', 'Delimiter', ',');

% indices:
BLOCKNO = 1;
STIMULUS = 2;

% # of trials
numtrials = numel(trialdata{1});

%% INSTRUCTIONS
blurb=['This task will involve recording sound.|'...
    'Please check with the experimenter to make sure this is ready.'];
InstructionsScreen(win, fgcolor, bgcolor, blurb);

blurb = ['In this experiment, you will listen to and repeat nonsense words.|' ...
    'After you hear each word, wait for a green dot to appear in the center of the '...
    'screen and then <b>repeat the word as accurately as possible</b>.|'...
    'After you have finished speaking, <b>wait for the dot to turn blue</b> and then '...
    '<b>press the spacebar to start the next trial</b>.  Please do not press any ' ...
    'keys until you have finished speaking.|'...
    'You may take as long as you like on each word.  There is no time limit.|' ...
    'We will start with some practice trials.'];
InstructionsScreen(win, fgcolor, bgcolor, blurb);
Screen('Flip', win, 0);

%% DO THE TRIALS
curblock = 1;
for i=1:numtrials % always in the same order
    
    % block transitions
    if curblock ~= trialdata{BLOCKNO}(i)
        if curblock == 1
            % transition out of practice trials
              blurb = ['OK, do you have the hang of it?|  Please ask the experimenter if you have any questions.|' ...
                  'Don''t forget: wait until the green dot appears before you begin speaking, and only press the space' ...
                  'bar after you are done speaking.|'...
                  'Again, there is no time limit, so take as long as you need to respond.'];
        else
            blurb = 'Take a quick break if you want.';
        end
        InstructionsScreen(win, fgcolor, bgcolor, blurb);
        Screen('Flip', win);
        
        % update block number
        curblock = trialdata{BLOCKNO}(i);        
    end
        
    % load the audio for the trial
    audiofortrial = wavread(trialdata{STIMULUS}{i});
    if isempty(audiofortrial)
        fprintf('empty\n');
    end
    PsychPortAudio('FillBuffer', playchannel, audiofortrial');
    
    % play the audio (with nothing on the screen)    
    PsychPortAudio('Start',playchannel);
    PsychPortAudio('Stop',playchannel,1);  % wait 'til done
    
    % start recording, then display dot
    PsychPortAudio('Start', recchannel);
    Screen('FillOval', win, dotcolor, DotRect, DotDiam);
    t1 = Screen('Flip', win, 0);
    
    % trigger end of recording
    Screen('FillOval', win, gocolor, DotRect, DotDiam);
    Screen('Flip', win, t1+1); % 1 second after dot appeared    
    getKeys;
    recordedaudio = PsychPortAudio('GetAudioData', recchannel);
    PsychPortAudio('Stop', recchannel);
    filename = [datafolder 'gupta_S' num2str(subjno) '_T' num2str(i) '.wav'];
    wavwrite(recordedaudio, freq, filename);
    
    % ISI
    Screen('Flip', win, 0);
    WaitSecs(ISI);       
    
end

%% SHUT DOWN

InstructionsScreen(win, fgcolor, bgcolor, 'Thank you!  You are all done with this task!');

PsychPortAudio('Close', recchannel);
PsychPortAudio('Close', playchannel);