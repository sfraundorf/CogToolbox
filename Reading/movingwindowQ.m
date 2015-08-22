% [RTs answer regionlength comptime] = movingwindowQ(mainwindow, fgcolor, bgcolor, stimulus,question,centerMultipleLines,showlegend)
%
% Performs a self-paced moving window reading task on window MAINWINDOW
% with text color FGCOLOR on background color BGCOLOR, then asks
% comprehension question QUESTION afterwards.
%
% Text string STIMULUS is displayed one region at a time, and the
% participant advances through the text by pressing the space bar.  See
% movingwindow.m for more information on the moving window task.
%
% MAXREGIONS specifies, across your experiment, the maximum number of regions
% that any stimulus has.  This is REQUIRED to store the RT data properly.
% Failing to define MAXREGIONS will crash your experiment!
%
% Optional parameter CENTERMULTIPLELINES controls how text is centered
% vertically on the screen when there are multiple lines.  If
% centerMultipleLines is 0, the first line is always at the center of the
% screen, and any additional lines hang below it in the bottom half of the
% screne.  If centerMultipleLines is 1 (default), the entire block of text
% is shifted up or down so that it is centered on the screen.
%
% If SHOWLEGEND is TRUE, a legend indicating which key is YES and which is NO
% is displayed during the comprehension questions.  This can be useful
% during practice trials.  (The default is to not do this.)
%
% The function returns a VECTOR of RTs -- one response time per region --
% and the participant's answer to the comprehension question.
%
% Optionally, the function also returns a vector of REGION LENGTHS.  This
% can be used to convert your reading times to RESIDUAL reading times at
% the end of your experiment, using the ResidReading function.  Type:
%   help ResidReading
% for more information.
%
% Optionally, the function also returns the TIME TAKEN to make the response
% on the comprehension question.
%
% Default response keys are D for YES (answer = 1) and K for NO (answer=0).
% Right now, I don't have an option to change this -- sorry.
%
% The task can be aborted early by pressing the F3 key during the moving
% window task.  This returns -1 as the answer and can be used by your main
% script to quit the experiment.
%
% 07.11.10 - S.Fraundorf - first version
% 07.12.10 - S.Fraundorf - collect response times for comprehension question
%                          deal with items of varying length
%                          improved efficiency using ANY
% 01.06.11 - S.Fraundorf - removed requirement to define MAXREGIONS
%                          argument to increase ease of use.  if you need
%                          to "pad" the vector of RTs or region lengths,
%                          you can perform this operation on what's
%                          returned from the function
% 01.07.11 - S.Fraundorf - Added option to center multiple lines on screen.
% 01.18.12 - S.Fraundorf - Updated documentation to document option to return
%                          time on comprehension question (always present but
%                          I forgot to mention it)
% 01.19.12 - S.Fraundorf - RT for comprehension question time is -1 if
%                          aborted.  exit key in moving window task has been changed

function [RTs answer regionlength comptime] = ...
    movingwindowQ(mainwindow, fgcolor, bgcolor, stimulus,question,centerMultipleLines,showlegend)

%% CHECK INPUT/OUTPUT ARGUMENTS
if nargin < 7
   showlegend = false;
   if nargin < 6
       centerMultipleLines = 1;
   end
end

if nargout > 2
    % user has REGION LENGTHS requested
    reportLength = true;
else
    reportLength = false;
end

%% RUN THE MOVING WINDOW TASK
if reportLength
   [RTs regionlength] = movingwindow(mainwindow, fgcolor, bgcolor,stimulus,centerMultipleLines);
else
    RTs = movingwindow(mainwindow,fgcolor,bgcolor,stimulus,centerMultipleLines);
end

%% DO THE COMPREHENSION QUESTION
if ~any(RTs==-1)
    % ONLY do the comprehension question if the abort key was not pressed
    if nargout == 4
        [answer comptime] = compQ(mainwindow,fgcolor,bgcolor,question,showlegend);
    else
        answer = compQ(mainwindow,fgcolor,bgcolor,question,showlegend);
    end
         
else
    answer = -1;
    comptime = -1;
end