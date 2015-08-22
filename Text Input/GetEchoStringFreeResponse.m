function [string,startRT,endRT] = GetEchoStringFreeResponse(window,msg,x,y,cueColor,bgColor,respColor,margin)
%
% [string,startRT,endRT] = GetEchoStringFreeResponse(window,msg,x,y,cueColor,bgColor,respColor,margin)
%
% Gets a subject's response to question MSG and displays it as they're typing.
%
% This version won't accept an empty string response, so subject can't just
% hit return/enter.
%
% Returns:
%   String  : The response that the user entered
%   StartRT : Time from presentation until the FIRST key press
%   EndRT   : Time from presentation until the user presses enter to
%              FINISH entering the string.
%
% Parameters:
%  window - pointer to the window this on which this will be displayed
%  msg - the question/prompt
%  x,y - starting point
%  cueColor - color of the question/prompt
%  bgColor - currently no effect; retained for compatibility
%  respColor - clut to display the subject's response.  this can be the same
%    as cueColor if you don't want the response in a different color.
%  margin - margin to allow on the right side of the screen
%
% 1st version - Jason Finley - modified from Psychtoolbox GetEchoString
%                              to collect RTs and prevent empty responses
%     7.22.08 - S.Fraundorf - collect EndRT as well
%    11.12.09 - S.Fraundorf - cleaned up code
%    11.23.09 - S.Fraundorf - fixed the time by using GetSecs throughout.
%                             the timing could probably be made more
%                             accurate, though.
%    12.29.09 - S.Fraundorf - fixed the order of parameters in the helptext
%    02.14.11 - S.Fraundorf - major rewrite for PTB-3.  this is somewhat
%                             less flexible, but it looks nicer & works
%                             more cleanly for standard free response questions
%    02.14.11 - S.Fraundorf - also added a cursor at current text position

%% initialization
if nargin < 8
    margin = 0;
    if nargin < 7
       respColor=cueColor;
    end
end

% calculate the response area
TextSize = Screen('TextSize',window);
rect=Screen('Rect',window);
edgeofresparea=rect(3)-margin;

% set up the cursor rect
cursorrect = [0 0 5 TextSize];
cursorwidth = cursorrect(3);

% initialize things:
respondedyet=false;
textblock={''};
numlines = 1;

% prepare keyboard:
FlushEvents('keyDown', 'mouseDown'); % clears anything the user has typed before the display appears
ListenChar(2); % block the text from bleeding through into Matlab

% start timing:
t1=GetSecs;

%% get & show response
while 1	% Loop until <return> or <enter>
    % draw the prompt & existing text
    [newx newy] = WriteLine(window, msg, cueColor, margin, x, y); % prompt
    for i=1:numlines % current text
        newy = newy + TextSize;
        [newx newy] = WriteLine(window, textblock{i}, respColor, margin, x, newy);
    end
    Screen('FillRect', window, respColor, cursorrect+[newx newy newx newy]); % cursor
    % show
    Screen('Flip', window);    
    % get a new character:
	char = GetChar;    %NOTE!!!  GetChar (in Windows) returns the time value, here "t", in MILLISECONDS.  whereas GetSecs and kbcheck return time in SECONDS!
    t2=GetSecs;
    if ~respondedyet  %if this is the first letter typed
       startRT=t2-t1;
       respondedyet=true; 
    end
	switch(abs(char))
		case {10,13,3},	% <return> or <enter>
            if ~isempty(textblock{1})
                endRT=t2-t1;
                break;
            end
		case 8,			% <delete>
            if ~isempty(textblock{numlines})
                % remove the previous character
                textblock{numlines} = textblock{numlines}(1:length(textblock{numlines})-1);
                % back up to the previous line if this line is now empty
                if isempty(textblock{numlines}) && numlines > 1
                    numlines = numlines - 1;
                end

            end
        case 9 %if they hit TAB, do nothing!  
        case 27 %escape
        case 33 %page up
        case 34 %page down
        case 37 %left???
        case 38 %up???
%        case 39 %right???  39 seems like a ' on my Mac - Scott
        case 40 %down???
            
        case 28 % left arrow
        case 29 % right arrow
        case 30 % up arrow
        case 31 % down arrow
            
            
		otherwise,
            % see if room on current line
            norm = Screen('TextBounds', window, [textblock{numlines} char], newx, newy);
            if x+norm(3) + cursorwidth <= edgeofresparea % room on this line
               textblock{numlines}=[textblock{numlines} char];  %add new letter to the string        
               
            else % begin new line               

               % kludgy word-wrap
               spaces = find(textblock{numlines}==' ');
               if ~isempty(spaces)
                  % find what was printed since the last space
                  lastspace = spaces(numel(spaces));
                  if lastspace < length(textblock{numlines}) % something after this last space
                     % save that for the next line:
                     carryover = textblock{numlines}(lastspace+1:length(textblock{numlines}));
                     % erase it from the previous line
                     textblock{numlines} = textblock{numlines}(1:lastspace);
                  else
                     carryover = [];
                  end                  
               else
                  carryover = [];
               end

               % start a new line
               numlines = numlines + 1;
               % add any wrapped text
               textblock{numlines}=[carryover char];
            end
            
	end
end

%% read out text block into a single string
string = textblock{1};
for i=2:numlines
    string = [string textblock{i}];
end

ListenChar(1); % reset the listening