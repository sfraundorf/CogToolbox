% freerecall(mainwindow, minitems, maxitems, fgcolor, bgcolor,
%                         instructions, outputtype,subno,outputfolder)
% recalledwords RTs = freerecall(mainwindow, minitems, maxitems, fgcolor,
%                        bgcolor, instructions, outputtype,subno,outputfolder)
%
% Executes a free recall test on window MAINWINDOW, allowing the user to
% enter up to MAXITEMS one at a time.  The test can be aborted early by
% typing 'done'.  Info about quitting is displayed to the participant after
% they have entered MINITEMS words, so they won't just quit immediately.
% (Set MINITEMS to 0 if you want the info displayed immediately.)
%
% Text is displayed in color FGCOLOR against background BGCOLOR.  Text
% string INSTRUCTIONS is displayed at the top of the screen as instructions
% to the participant.
%
% Data from the test includes the subject's response, and two response RTs:
% the time from the start of each trial until the subject began typing, and
% the time from the start of each trial until the subject FINISHED and hit
% Enter
%
% Optional parameter OUTPUTTYPE type controls how the subject's respones
% are saved:
%    0 - return the recalled words in a cell array and RTs in a matrix
%          (default)
%    1 - save in a file in OUTPUTFOLDER (default = current directory, if
%           not specified) based on subject numberSUBNO
%  >=2 - do both
%
% 11.12.09 - S.Fraundorf - created based on Jason Finley's code
% 11.25.09 - S.Fraundorf - added OUTPUTTYPE parameter
% 02.02.10 - S.Fraundorf - PTB-3 version
% 02.07.10 - S.Fraundorf - test window now reflects screen's existing TextStyle
%                          tried to improve some of the text display for
%                          Windows machine (but still not as good as on
%                          Mac)
% 06.16.11 - S.Fraundorf - now accepts TAB key to move between fields
%                         (which participants often want to use)
% 10.26.16 - S.Fraundorf - use textures

function varargout = freerecall(mainwindow, minitems, maxitems, fgcolor, bgcolor, instructions, outputtype, subno, outputfolder)

%% --SETUP--
% define colors
ghosted = floor((bgcolor+fgcolor) .* 0.5);

if nargin < 7 % default is to save to disk
    outputtype = 0;
end

% output file folder
if nargin < 9   % default is to save in the same folder
    outputfolder = '';
else
    outputfolder=makeValidPath(outputfolder); % make sure this is a good folder name
end

%% --SET UP WINDOWS--
% main window
rect=Screen('Rect',mainwindow); % get screen size
TextFont=Screen('TextFont',mainwindow); % get font size
TextSize=Screen('TextSize',mainwindow); % get text size
TextStyle=Screen('TextStyle',mainwindow); % get text style

% other windows
FreeRecallWindow=CreateOffWin(mainwindow, bgcolor, TextFont, TextSize);
Screen('TextStyle',FreeRecallWindow, TextStyle);

% response box sizes
boxheight = 50;
boxwidth = 285;
% box sizes are FIXED right now ... sorry :(   -Scott

% calculate the box arrangement
if maxitems > 10
    numcolumns = 3;   % number of columns is hard-coded at the moment
else                  % but this could be calculated more dynamically or
    numcolumns = 2;   % made an argument
end
rowspercolumn = ceil((maxitems) / numcolumns);
xoffset = floor(boxwidth / numcolumns); % horizontal spacing
yoffset = floor(boxheight / rowspercolumn); % vertical spacing

% write the instructions
[junk, instructheight] = WriteLine(FreeRecallWindow, instructions, fgcolor, 20, 30, TextSize*2);

% set up the boxes
responseboxes={};
for colnum = 1:numcolumns
    xcoord = ((colnum-1)*boxwidth) + (colnum * xoffset);
    for rownum = 1: rowspercolumn
        ycoord = instructheight + TextSize + ((rownum-1)*boxheight) + (rownum * yoffset);
        if numel(responseboxes) < maxitems
            Screen('FrameRect', FreeRecallWindow, ghosted, [xcoord ycoord xcoord+boxwidth ycoord+boxheight]);
            responseboxes=[responseboxes [xcoord ycoord xcoord+boxwidth ycoord+boxheight]];
        end
    end
end
        
%% --SETUP THE OUTPUT--

% file
if outputtype > 0
  outfile = fopen([outputfolder 'freerecall-' num2str(subno) '.csv'], 'w');
  % header row
  fprintf(outfile, 'WORD,START,END\n');
end

% set up to return OMISSIONS and -1 RTs by default
if outputtype ~= 1
    varargout{1} = repmat({'omission'},1,maxitems);
    varargout{2} = repmat(-1,maxitems,2);
end

%% --DO THE TEST--
     
for i=1:maxitems
    
     if i==minitems+1 % after user has typed in at least MINITEMS words, tell them how they can quit
        WriteLine(FreeRecallWindow, 'When you have finished, type DONE into one of the boxes and press Enter.', fgcolor, 25, 25, rect(4)-(TextSize*2.5));
     end
        
    % turn this into a texture and display
    imageMatrix=Screen('GetImage', FreeRecallWindow);
    FreeRecallTexture = Screen('MakeTexture', mainwindow, imageMatrix);
    clear imageMatrix    
    Screen('DrawTexture',mainwindow, FreeRecallTexture);
    Screen('Flip',mainwindow,0,1);    
    
    % test the next item
    x=responseboxes{i}(1);
    y=responseboxes{i}(2)+22;
    [wordrecalled,startRT,endRT] = GetEchoStringCuedT4(mainwindow,'',x,y,fgcolor,bgcolor,fgcolor,'Box',0,0,1);
    
    % write the subject response on the permanent FreeRecallWindow
    WriteLeft(FreeRecallWindow, wordrecalled, x, y, ghosted);
             
    wordrecalled=strtrim(lower(wordrecalled));  %trim whitespace and convert to lowercase
    
    if strcmp(wordrecalled, 'done')
        break;
    else
        if outputtype > 0 % save the data IF requested
            fprintf(outfile, '%s,%4.4f,%4.4f\n', wordrecalled, startRT, endRT);
        end
        if outputtype ~= 1 % return the cell array IF requested
            varargout{1}{i} = wordrecalled;
            varargout{2}(i,1:2) = [startRT endRT];
        end
    end
    Screen('Close', FreeRecallTexture);
        
end

%% --SHUT DOWN--
if outputtype > 0
  fclose(outfile); % close file if needed
end

Screen('Close',FreeRecallWindow);

end