% answer = BinaryQuestion(window, textcolor, backgroundcolor, questiontext, option1, option2, confirmcolor);
%
% Displays a binary question on window WINDOW; user responds by clicking 1 of 2 buttons.
%
% QUESTIONTEST is the prompt to the participant and TEXTCOLOR is the color
% in which it is written.  BACKGROUNDCOLOR controls the background color of
% the buttons.
%
% If optional parameter CONFIRMCOLOR is specified, the button that the user
% chooses will briefly be displayed in color CONFIRMCOLOR to show that it
% has been chosen.
%
% 07.13.07 - A.Isaacs - initial version
% 02.22.10 - S.Fraundorf - PTB-3 version. added optional confirmation color

function answer = BinaryQuestion(window, textcolor, backgroundcolor, questiontext, option1, option2, confirmcolor)

if nargin < 7
    confirmcolor = backgroundcolor;
end
options = {option1,option2};

%% GET WINDOW PARAMETERS
   windowsize=Screen(window,'rect');
   width=windowsize(3);
   height=windowsize(4);
   margin=(height/4);
   buttonwidth=(width-(3*margin))/3;
   
%% SET UP BUTTONS
   button1LX=(width/2)-(1.5*buttonwidth);
   button1RX=button1LX+buttonwidth;
   button2LX=button1RX+buttonwidth;
   button2RX=button2LX+buttonwidth;
   
   buttonRY=height-margin;
   buttonLY=buttonRY-(buttonwidth/2);
   
   buttons(1,:) = [button1LX buttonLY button1RX buttonRY];
   buttons(2,:) = [button2LX buttonLY button2RX buttonRY];
   
%% DRAW THE SCREEN
   % question
   WriteLine(window,questiontext, textcolor, margin, margin, margin);   
   % buttons
   for i=1:2
       FilledRectWText(window, options{i}, textcolor, backgroundcolor, buttons(i,:));
   end
   % show finished display
   Screen('Flip', window, 0, 1); 
   
 %% GET USER RESPONSE
 answer = Wait4Mouse(buttons);

 %% WRAP-UP
 FilledRectWText(window,options{answer},textcolor,confirmcolor,buttons(answer,:));
Screen('Flip',window,0);

WaitSecs(0.17);
