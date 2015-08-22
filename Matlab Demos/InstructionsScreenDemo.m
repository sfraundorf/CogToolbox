mainwindow = Screen('OpenWindow', 0); % open the main window

% define colors
white = [255 255 255];
black = [0 0 0];
red = [255 0 0];

Screen('TextFont', mainwindow, 'Arial');
Screen('TextSize', mainwindow, 32);
Screen('TextStyle', mainwindow, 0); % bold is default on PCs; this will remove it

% screen 1
message = 'This is an example instructions screen.|The pipe (vertical line) indicates a paragraph break.';
InstructionsScreen(mainwindow, black, white, message);

% screen 2
message = ['Don''t forget that an apostrophe normally indicates the end of a text string.|' ...
 'So, if you want to use an apostrophe in your instructions, you need to double it -- that ' ...
 'lets MATLAB know you meant you wanted an apostrophe, rather than the end of the text string.|' ...
 'Screen 2 has an example of this in the code.'];
InstructionsScreen(mainwindow, black, white, message);

% screen 3
wordstohighlight = {'certain', 'cell','array'};
message = ['You can also highlight certain words by including a cell array of words you want '...
 'to highlight, and a color to highlight them in.'];
InstructionsScreen(mainwindow, black, white, message, wordstohighlight, red)

% screen 4
message = ['Finally, adding a ",1" to the end of your function call makes it so that InstructionsScreen waits ' ...
 'for a MOUSE CLICK rather than a KEY PRESS.|In this case, you''ll want to pass empty arguments ' ...
 'to the highlighting function to skip it.|Screen 4 has an example of this in the code.'];
InstructionsScreen(mainwindow, black, white, message, [], [], 1);

Screen('CloseAll');