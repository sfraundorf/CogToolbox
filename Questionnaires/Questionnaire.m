% Questionnaire(directory, filename, subject, window, fgcolor, bgcolor);
%
% Collects demographic information from participants.
%
% Right now, this is JUST hometown and languages spoken.  We might want to
% add some of our other standard screening questions like normal hearing,
% normal vision, and color vision.
%
% The answers are then output to a textfile specified by the input
% parameters. Once the file has been created when the first participant is
% run, the data from subsequent participants will be added to the file.
%
% directory = folder to which the file should be saved
% filename = the name of the file
% subject = subject number
% window = handle of the window on which the questionnaire is displayed
% fgcolor = foreground color (optional, default is white)
% bgcolor = background color (optional, default is black)
%
%  1.29.07 - A.Isaacs - initial version
%  2.04.07 - A.Isaacs - revisions
%  2.22.10 - S.Fraundorf - PTB-3 version.  added FGCOLOR and BGCOLOR parameters
%                          now calls Angie's existing questionnaire fxns.
%  8.22.12 - S.Fraundorf - changed str2num to str2double for speed

function Questionnaire(directory, filename, subject, window, fgcolor, bgcolor)

if nargin < 6
    bgcolor = [0 0 0];
    if nargin < 5
        fgcolor = [255 255 255];
    end
end
buttoncolor = floor(bgcolor+fgcolor)/2;

%% --SETUP OUTPUT--
%Output files creation
output_file = [directory filename '.txt'];
   
%OPEN OUTPUT FILE
output = fopen(output_file, 'at+');
   
fprintf(output, '%d ', subject);

%% --INSTRUCTIONS--
InstructionsScreen(window, fgcolor, bgcolor, ...
    'Please answer the following brief questions.', ...
    [], [], 1);

InstructionsScreen(window, fgcolor, bgcolor, ...
    ['For some questions you will click the box containing the best answer.  For other questions you will be asked to type a response.|' ...
    'If you have any questions about a question, please ask the experimenter.'], [], [], 1);

%% --QUESTION 1: HOMETOWN---

% US vs. Other Country
answer = BinaryQuestion(window, fgcolor, buttoncolor, 'Where did you grow up?', 'US', 'Other');

if answer == 1
    % grew up in the US
    HomeState = OpenResponseQuestion(window, fgcolor, bgcolor, 'What state did you grow up in? (Use full name.  Ex. Illinois)', 1);
    Screen('Flip', window); % clear screen
    HomeTown = OpenResponseQuestion(window, fgcolor, bgcolor, 'What is your hometown? (Use full name.  Ex. Chicago)', 1);
    Screen('Flip', window); % clear screen
    fprintf(output, '%s %s %s ', 'US', HomeState, HomeTown);
else
    % grew up outside the US
    HomeCountry = OpenResponseQuestion(window, fgcolor, bgcolor, 'What country did you grow up in? (Use full name.  Ex. Korea)', 1);
    Screen('Flip', window); % clear screen
    fprintf(output, '%s NA NA ', HomeCountry);
end

%% --QUESTION 2: LANGUAGES--

answer = YesNoQuestion(window, fgcolor, buttoncolor, 'Do you speak any languages other than English?');
languages = cell(10,1); % up to 10 languages
age = zeros(10,1); 

done = answer-1; % done if answer = 2 but not if answer = 1
nextlang = 1;
while ~done
    languages{nextlang} = OpenResponseQuestion(window, fgcolor, bgcolor, 'Name ONE other language you speak.', 1);
    Screen('Flip', window); % clear screen
    age(nextlang) = str2double(OpenResponseQuestion(window, fgcolor, bgcolor, ...
        'How old were you when you started learning this language? (example: "6").  Use "0" if since birth.', ...
        1));
    Screen('Flip', window); % clear screen
    
    % see if there are more languages to get
    if nextlang < 10
        answer = YesNoQuestion(window, bgcolor, fgcolor, 'Do you speak any more languages?');
        done = answer-1;
    else
        done = 1; % only accept up to 10 languages
    end
   nextlang = nextlang + 1; % advance to next language
end

% output
for i=1:10
    if isempty(languages{i})
        fprintf(output, 'NA NA ');
    else
        fprintf(output, '%s %d ', languages{i}, age(i));
    end
end
fprintf(output, ' %d\n', nextlang-1); % total languages
 % -1 because nextlang is iterated to the next language at the end of the
 % loop