% answer= OpenResponseQuestion(window, textcolor, backgroundcolor,questiontext, forceresponse)
%
% Presents a free-response question to the participant on window WINDOW.
% QUESTIONTEXT is the text of the question
%
% Text is displayed in color TEXTCOLOR on background BACKGROUNDCOLOR.
%
% If optional parameter FORCERESPONSE is 1, the function will not accept a
% blank answer from the participant and requires them to enter something.
%     
% 07.13.07 - A.Isaacs - first version
% 02.22.10 - S.Fraundorf - PTB-3 version.  added FORCERESPONSE parameter

function answer = OpenResponseQuestion(window, textcolor, backgroundcolor, questiontext, forceresponse)

if nargin < 5
    forceresponse = 0;
end

ListenChar(2); % so responses don't bleed through to matlab

% display the prompt
[newx, newy]=WriteLine(window, questiontext, textcolor, 200, 200, 200);  
newy=newy+100;
Screen('Flip',window,0,1);

% get the answer
while 1
  answer = GetEchoStringDisplay(window,'',200,newy,textcolor,backgroundcolor);
  if ~isempty(answer) || ~forceresponse
      % if force response is 1, do not accept an empty answer
      break;
  end
end

ListenChar; % turn listening back on