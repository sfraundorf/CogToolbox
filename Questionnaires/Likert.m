% answer = Likert(window, textcolor, questiontext, leftlabel, rightlabel, confirmcolor,
%                     numchoices, centerlabel, numcolor, buttondelay, ydim);
%
% Displays a Likert scale question on window WINDOW; user responds by
% clicking a button.
%
% NUMCHOICES controls the number of buttons/choices - default is 7.
%
% QUESTIONTEXT is the prompt to the participant and TEXTCOLOR is the color
% in which it is written.  LEFTLABEL and RIGHTLABEL describe the low end and high end
% of the scale, respectively.  Optional parameter CENTERLABEL is a label
% for the center point of the scale (ignored if there is an even number of buttons).
%
% If optional parameter CONFIRMCOLOR is specified, the button that the user
% chooses will briefly be displayed in color CONFIRMCOLOR to show that it
% has been chosen.
%
% If optional parameter NUMCOLORS is specified, each button the scale is labeled
% with the corresponding number in color NUMCOLOR.  If NUMCOLOR is not
% specified or is -1, no numbers are drawn.
%
% Optional parameter BUTTONDELAY is a number of seconds to wait after
% displaying the question and before displaying the buttons (e.g. if you
% want to make sure your participants read the question before they
% respond)
%
% Normally, the Likert display uses the whole screen.  Optional parameter
% YDIM allows the display to be restricted to the Y coordinates specified
% in YDIM -- e.g. [0 200] forces the whole display into the top 200
% pixels.
%
% 07.13.07 - A.Isaacs - initial version
% 02.22.10 - S.Fraundorf - PTB-3 version. added optional confirmation color
% 04.26.10 - S.Fraundorf - added parameters NUMCHOICES and CENTERLABEL
% 04.27.10 - S.Fraundorf - calculate width & height of buttons separately
% 05.30.10 - S.Fraundorf - kludge to shrink labels if needed so they don't
%                          overlap with other stuff
% 06.01.10 - M. Lewis - added button number option
% 06.02.10 - S.Fraundorf - added BUTTONDELAY, improved label resizing
% 02.08.11 - S.Fraundorf - improved timing of Flip statement.  Updated calls to
%                          Screen('TextSize')
% 04.23.12 - S.Fraundorf - added YDIM parameter to draw on just part of the
%                          screen

function answer = Likert(window, textcolor,questiontext, leftlabel, rightlabel, ...
    confirmcolor, numchoices, centerlabel, numcolor, buttondelay, ydim)

%% SET DEFAULT PARAMETERS
if nargin < 10
    buttondelay = 0;
    if nargin < 9
      numcolor = -1;
      if nargin < 8
        centerlabel = '';
        if nargin < 7
            numchoices = 7;
            if nargin < 6
              confirmcolor = textcolor;
            end
        end
      end
    end
end
   
if numchoices < 2
    Screen('CloseAll');
    fclose all;
    error('CogToolbox:Likert:TooFewChoices', 'Must have at least 2 choices for the Likert scale.')
end

%% GET WINDOW PARAMETERS
windowsize=Screen('Rect', window);
if nargin > 10
    % specified YDIM
    % use just PART of the screen
    windowsize(2) = ydim(1);
    windowsize(4) = ydim(2);
end

   width=windowsize(3);
   YTop=windowsize(2);
   YBottom=windowsize(4);   
   height=YBottom - YTop;
   buttonmargin=height/4;
   
   buttonheight = height-(3*buttonmargin); % 1/4 of screen
   buttonwidth = width/(numchoices+ceil(numchoices/2));
   % num of buttons + half the width of each button as spacer
        
%% SET UP BUTTONS
   spacerwidth=buttonwidth/2;
   
   buttonbottom=YBottom-buttonmargin;
   buttontop=buttonbottom-buttonheight;
      
   % initialize button matrix and assign coordinates of 1st button
   buttons=repmat([spacerwidth              buttontop ...  
                   spacerwidth+buttonwidth  buttonbottom], numchoices, 1);
   % adjust X coordinates (Y coordinates are constant)
   for i=2:numchoices
       buttons(i,[1 3]) = buttons(i-1,[1 3]) + buttonwidth + spacerwidth; % advance horizontally
   end
      
   labelLloc = buttons(1,1) + (buttonwidth/2);
   labelRloc = buttons(numchoices,1) + (buttonwidth/2);
   
   
%% SET UP LABELS
   
    % see if we need to adjust the text size for the labels
    oldsize = Screen('TextSize', window);
    labelsize = oldsize;
    leftwidth = nth(Screen('TextBounds',window,leftlabel), 3);
    rightwidth = nth(Screen('TextBounds',window,rightlabel), 3);
    while (leftwidth/2 > (spacerwidth + buttonwidth/2)) || (rightwidth/2 > (spacerwidth+buttonwidth/2)) % label is too big
       % houston, we have a problem   
       Screen(window,'TextSize', labelsize-1); % shrink the font
       labelsize = labelsize - 1;
       % check the new size
       leftwidth = nth(Screen('TextBounds',window,leftlabel), 3);
       rightwidth = nth(Screen('TextBounds',window,rightlabel), 3);
    end % repeat until it fits
    
    % assign the Y coordinate of the label accordingly
    labelYloc = buttontop-(labelsize*2);
    
%% WRITE THE QUESTION

    % use original text size
    Screen('TextSize', window, oldsize);

    % Write the question to the screen
    WriteLine(window, questiontext, textcolor, buttonmargin, buttonmargin, windowsize(2)+buttonmargin);  
    [garbage t1] = Screen('Flip',window,0,1);
        
%% DRAW THE LABELS
 
    % write the buttons for the Likert scale to the screen
    Screen('FillRect',window,textcolor, buttons');
    
    % set font size for the label
    Screen('TextSize', window,labelsize);
    
    % write the labels for the Likert ends to the screen
    WriteCentered(window, leftlabel, labelLloc, labelYloc, textcolor);
    WriteCentered(window, rightlabel, labelRloc, labelYloc, textcolor);
    % write the center label IF it exists and we have an odd number of
    % options
    if ~strcmp(centerlabel, '') && isodd(numchoices)
       labelCloc = (buttonwidth/2) + buttons(ceil(numchoices/2),1);
       WriteCentered(window, centerlabel, labelCloc, labelYloc, textcolor);
    end
            
    % draw numbers in boxes, if requested
    if numcolor ~= -1
      for i=1:numchoices
        numX = buttons(i,1) + (buttonwidth/2);
        numY = buttons(i,2) + (buttonheight/2);
        WriteCentered(window, num2str(i), numX, numY, numcolor);
      end
    end
        
Screen('Flip',window,t1+buttondelay,1);

%% GET USER RESPONSE

answer = Wait4Mouse(buttons);

%% WRAP-UP

Screen('FillRect',window,confirmcolor,buttons(answer,:)); % show confirmation
Screen('Flip',window,0);

WaitSecs(0.17);

Screen('TextSize', window, oldsize); % restore original font size