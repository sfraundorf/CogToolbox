function DivisionDistractorTask(monitor, rect, fontSize, fontColor, backColor, duration, ISI, filename)
%
% DivisionDistractorTask(monitor, rect, fontSize, fontColor, backColor, duration, ISI, filename)
%
% Presents 2-digit division problems to the screen until at least DURATION
% seconds has passed.  Note that (per Mike Diaz's original PTB-2 function)
% the task will not end until the last problem has completed, so there may
% be some variability in the exact amount of time particiants spend doing the task.
%
% ISI is the # of SECONDS between problems.  The "answer" row of the problems is
% drawn at the center of RECT.  If RECT is not specified, the experiment
% defaults to the whole screen.  Similarly, leaving FONTSIZE unspecified
% defaults to the current font size.
%
% If FILENAME is provided, then all problems are saved to said file.  Otherwise,
% problems are not saved or scored.  If FILENAME is not a legal name for a file,
% an error will be thrown.
%
% The function currently does not display an instructions screen to the
% participant, so you will need to add your own.
%
% To end the program early, type 'p' followed by 'q'. %
%  6.20.06 M.Diaz
% 11.20.09 S.Fraundorf - suppressed output of assignment operations.
%                        allowed user to not define a filename.
%                        fixed some problems I had with writing files.
% 02.22.10 S.Fraundorf - PTB-3 version
% 08.25.12 S.Fraundorf - properly clear the screen during the ISI.
%                        Clarified that ISI is specified in SECONDS.
%                        Allowed use of default RECT and FONTSIZE.
%                        Improved stimulus timing by getting the timing
%                        directly from the Flip statements.


%% CHECK INPUT ARGUMENTS
if nargin < 8
    writeFile=false;
else
    writeFile=true;
    try
       mathout=fopen(filename,'w');
    catch
        Screen('CloseAll');
        error('file name not valid')
    end
end

%% BASIC SET-UP
rand('twister',sum(clock*100));
global endExperiment;

%% KEY SET-UP
KbName('UnifyKeyNames'); % otherwise diff btwn Mac and Windows

ListenChar(2);
% this makes it so that what the user types doesn't bleed through into the Matlab command window
% otherwise the user can execute Matlab commands during your experiment!

%% SCREEN SET-UP
% if display area is not defined, default to whole screen
if isempty(rect)
    rect = Screen('Rect', monitor);
end
if isempty(fontSize)
    fontSize = Screen('TextSize', monitor);
end

%create function handles for commonly used functions
wr=@WriteRight;

% create window with horizontal line
lineWin=CreateOffWin(monitor, backColor, 'Arial', fontSize);
% draw the line
norm = Screen('TextBounds',monitor,'xxxx');
w = norm(3);
xCent=(rect(3)+rect(1))/2;
yCent=(rect(4)+rect(2))/2;
Screen('DrawLine', lineWin, fontColor,xCent-w,yCent,xCent+w,yCent,2);
norm = Screen('TextBounds', monitor, 'x');
w = w-norm(3);

% create window where each problem will be written
probWin=CreateOffWin(monitor, backColor, 'Arial', fontSize);

signs=char(247);

%% RUN THE TASK
FlushEvents('keyDown', 'mouseDown'); % clears anything the user has typed before the display appears
start=GetSecs;
t1=start;
while true
    nums=round(rand(1)*9)+1; %divisor
    nums(1,2)=round(rand(1)*floor(100/nums)+10)*nums;
    
    Screen('CopyWindow', lineWin, probWin);
    wr(probWin, [signs ' ' num2str(nums(1))] , xCent+w, yCent-fontSize, fontColor);
    wr(probWin, num2str(nums(2)) , xCent+w, yCent-2*fontSize, fontColor);
    Screen('CopyWindow', probWin, monitor);
    Screen('Flip', monitor, t1+ISI);
    
    %get answer
    str=[];
    while true
        s=double(GetChar);
        switch lower(s)
            case cellstr(['0':'9']')
            check=0;
            str=[str char(s)];
            Screen('CopyWindow', probWin, monitor); %restore original formula
            wr(monitor, str, xCent+w, yCent+fontSize, fontColor); %write current answer
            Screen('Flip', monitor, 0); %display screen
            case {8} %backspace
               if ~isempty(str)
                   str=str(1:end-1);
                   Screen('CopyWindow', probWin, monitor); %restore original formula
                   wr(monitor, str , xCent+w, yCent+fontSize, fontColor); %write current answer
                   Screen('Flip', monitor, 0); %display screen
               end
            case {13,3,10} % return
                break
            case {'p'}
                check=1;
            case {'q'}
                if check
                    if writeFile
                        fclose(mathout);
                    end
                    Screen('CloseAll');
                    endExperiment=1; %used to inform calling functions
                    return
                end
        end
    end
    Screen('CopyWindow', lineWin, monitor); %restore original display space
    t1 = Screen('Flip', monitor, 0);
    
    %write to text file
    if writeFile
        fprintf(mathout,'%d %s %d = %s\r\n', nums(2), signs, nums(1), str);
    end
    
    if t1-start > duration
        % done, do clean-up
        if writeFile
            fclose(mathout);
        end
        Screen('Close', lineWin);
        Screen('Close', probWin);
        ListenChar; % turn character listening back on
        return
    end
end    