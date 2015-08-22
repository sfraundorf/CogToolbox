% demo of how to PLAY and RECORD sound in Psychophysics Toolbox 3
%
% Before you can use sound, you have to do a set-up procedure (1 time
% per computer).  See the file in the CogToolbox called
% Low-Latency Audio in Psychophysics Toolbox.doc
%
% for sample code, type:
%   edit sounddemo
%
% 02.01.10 - S.Fraundorf
% 06.29.10 - S.Fraundorf - closed the channel at the end!  you should
%                          always do this!
% 12.15.11 - S.Fraundorf - added TIMING demo

InitializePsychSound;
% put this at the beginning of your experiment to set up the SOUND portion
% of Psychophysics Toolbox.  (REQUIRED on a PC, "maybe" on a Mac.)  I
% always do it just to be safe.

numchannels = 1; % mono sound
% stereo has 2 channels

demoplaying = 1; % change to demoplaying = 0 to demo RECORDING sound instead

%% PLAYING SOUND

if demoplaying == 1

% like with pictures, an audio file is just a huge matrix of numbers to
% MATLAB, specifying the sound at many points in time.
%
% these sounds are sampled at many points in time.  we need to know the
% FREQUENCY with which they were sampled in order to play them back at the
% correct speed.

[audiofortrial freq] = wavread('test-scott.wav');
% read a WAV file off the disk and put it in the matrix "audiofortrial"
%
% the frequency is stored in FREQ.  (in Hz - cycles per second)
%
% mono sound has ONE column of numbers.
% stereo sound has TWO columns - one for each speaker/ear
numchannels = size(audiofortrial,2);
% so by examining the SIZE of the matrix, we can tell how many channels we
% have

% like opening a window for video, we need to create an audio channel
audiochannel = PsychPortAudio('Open', [], 1, [], freq, numchannels);
% sound is controlled through PsychPortAudio functions.  it's the audio
% equivalent of Screen functions
%
% it needs to know the frequency
%
% 1 is for PLAYING  (later we will see 2 is for recording and 3 is for
% BOTH)

% we need to put the audio data into the sound channel
%
% the channel stays open, so we can put different audio into it at
% different points in the experiment
PsychPortAudio('FillBuffer', audiochannel, audiofortrial');
% for some reason, WAVREAD reads sound files as a vertical vector, but
% PsychPortAudio wants them as a horizontal vector.  so we need to ROTATE
% our sound vector.  the notation for this is the same as you'd use on
% paper: a ' after the name of the vector
%
% imagine we had 3 different sound files loaded.  the idea of FillBuffer is
% to tell it WHICH sound we want to play
%
% at this point, we have the audio all queued up to play when we're ready
%
% typically you want to load things up BEFORE your trial starts

PsychPortAudio('Start',audiochannel,2);  % starts playing
% 2 = number of repetitions

% by default, the experiment continues while the sound is playing
fprintf('We will see this message before the sound is done.\n');

PsychPortAudio('Stop',audiochannel,1);
% the 1 makes it WAIT for the audio to STOP playing on its own

fprintf('We will not see this until the sound is done.\n');

% load up a new 2nd sound
[audiofortrial freq] = wavread('test-molly.wav');
PsychPortAudio('FillBuffer', audiochannel, audiofortrial');

PsychPortAudio('Start',audiochannel,0);
% 0 = LOOP INDEFINITELY until we tell it to stop
% be SURE to put a stop command in if you do this :)

fprintf('Press a key to stop playing.\n');
getKeys;

% to stop the sound IMMEDIATELY:
PsychPortAudio('Stop',audiochannel);
% this will cut the sound off even if it's in the middle of playing!

WaitSecs(1);
fprintf('One last sound will start in 2 seconds...\n');

% to start a sound at a precise time:
t1 = GetSecs;
t2 = PsychPortAudio('Start',audiochannel,1,t1+2);
% this will queue the sound up, and make sure it starts exactly 2 seconds
% after the "t1" timepoint.  This is the way to get the most accurate
% timing information available (e.g. for timelocking eye-tracking or ERPs,
% or even just the sequence of events within a trial).
%
% If you just did WaitSecs(2) and then started the sound, it would actually
% take a little longer than 2 seconds, because MATLAB first waits 2 seconds
% and THEN goes through the procedure to play the sound
%
% The time the sound starts playing will be returned from the
% PsychPortAudio function, and here it's saved as t2

WaitSecs(5);
% sound will start about now

else

%% RECORDING

% you can CHOOSE your frequency when recording
freq = 44100;
% higher frequency results in a better quality recording (more samples) but
% also produces a larger file size (because you're storing more numbers)
%
% since we have PLENTY of hard drive space, there is no reason to skimp on
% quality

% we also open an audio channel when we're doing recording
audiochannel = PsychPortAudio('Open', [], 2, [], freq, numchannels);
% except we set it to 2 instead of 1
% 2 is for recording mode
% 3 is for BOTH

% we need to set aside from space for the sound that we're going to record
PsychPortAudio('GetAudioData', audiochannel, 10);
% this would set aside 10 seconds of recording per trial
% better to error on the side of caution
% if you use MORE than the time you alloted, it starts writing over the
% start of the sound (like an old VHS tape)
%
% this doesn't actually do any recording itself.  it just sets aside 10
% seconds of time for WHEN we do the recording

fprintf('Press a key to START recording.\n');
getKeys;

PsychPortAudio('Start',audiochannel);
% this actually STARTS the recording

fprintf('Press a key to STOP recording.\n');
getKeys;

% we need to do the reverse of when we played a file
% get the audio OUT of the buffer and into a matrix
% then, save the matrix into a file
recordedaudio = PsychPortAudio('GetAudioData', audiochannel);
% (at this point, since we've dumped things out of the buffer, we could
% record another 10 seconds if we wanted to)

PsychPortAudio('Stop',audiochannel); % stop the recording channel

% right now this is just a matrix in MATLAB.  we need to save it to a file
% on our hard drive
filename = 'subject3trial12.wav'; % in a real experiment, you'd want to have the filename
                                  % be based on the current subject & trial
                                  % no.
wavwrite(recordedaudio, freq, filename);
% write the sound data RECORDEDAUDIO into a wav file with frequency FREQ
% 3rd argument is the filename
end


%% WRAP-UP

% we need to close the audio channel when we are done, just like closing a
% SCREEN
PsychPortAudio('Close', audiochannel);