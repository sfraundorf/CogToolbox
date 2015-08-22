% answer = YesNoQuestion(window, textcolor, backgroundcolor, questiontext, confirmcolor);
%
% Displays a Yes/No question on window WINDOW; user responds by clicking 1 of 2 buttons.
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
%                          since this is basically the same as
%                          BinaryQuestion just with pre-specified response
%                          options, I call BinaryQuestion.  this way there
%                          is less code to maintain.

function answer = YesNoQuestion(window, textcolor, backgroundcolor, questiontext, confirmcolor)

if nargin < 5
    confirmcolor = backgroundcolor;
end

answer = BinaryQuestion(window, textcolor, backgroundcolor, questiontext, 'Yes', 'No', confirmcolor);