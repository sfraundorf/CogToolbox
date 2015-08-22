% DEMO of various graphical things in MATLAB/Psychophysics Toolbox
%
% type:
%   edit graphicsdemo
% to see some sample code for graphics
%
% 02.01.10 - S.Fraundorf
% 02.08.11 - S.Fraundorf - some additional comments to clarify things
% 07.18.12 - S.Fraundorf - added some demonstrations of TIMING the
%                           screen flips and using font manipulations
%                           in WriteLine, as well as some additional
%                           comments to further explain things

% PTB's Screen function is used for graphics
%
% typing just Screen will list all the subfunctions of Screen
%
% Screen functionname? will tell you about a subfunction
% e.g.
% Screen OpenWindow?

try % if an error is encountered inside a TRY block it jumps down to the CATCH
    
    % colors are 3 numbers - red, green, blue
    red = [255 0 0];
    blue = [0 0 255];
    purple = [255 0 255];
    white = [255 255 255];
    black = [0 0 0];
    MyColor = [174 0 57];
    
    InitExperiment; % this will define white and black for you
    
    bgcolor = purple;
    
    % specify these so that we can use them later
    textsize = 32; % this is the font size, same as in Word.
    textfont = 'Arial';
    
    testing = 0; % if testing = 1, will skip over the Buttons demo

% this is the command you do to set up your graphics
[mainwindow rect] = Screen('OpenWindow',0, bgcolor);
% with a background color of purple
% the 0 is just to make it the mainwindow
%
% This returns 2 things:
%  The handle to the window we just opened
%  and, rect, which is a vector that tells you the screen size

rect = Screen('Rect',mainwindow);
% this is another way of getting the window size
% like if you forgot to get it when you originally opened the window

Screen('TextSize',mainwindow,textsize); % specify text size
Screen('TextFont',mainwindow,textfont); % specify text font
% we set the textsize and textfont variables back at the top of the script

XRight=rect(3);
YBottom=rect(4);
XCenter = XRight/2;

%% DRAW SOME BUTTONS

if testing == 0   % if you want to skip over your instructions when testing your experiment
    % you can put them in an IF statement
    % and then have another variable (like TESTING) that controls whether
    % or not this part of your code gets used

% WaitBlanking;  % for PTB-2
BoxCoordinates=CenterInRect(rect,[0 0 100 100]);
% We're defining the coordinates of 
% Draw a box where pixel 0,0 is the upper-left corner
% 0,0 is in the upper left of the screen
% think of a matrix: 1,1 is the first row, first column (upper left of the
% matrix)

Screen('FillRect',mainwindow,white,BoxCoordinates);


Box2Coordinates = [100 100 250 200]; % from (100,100) to (250, 200)
Screen('FillRect',mainwindow,blue,Box2Coordinates);

UnseenBox = [XRight+50 100 XRight+100 200];
Screen('FillRect',mainwindow,blue,UnseenBox);
% this box has an x-coordinate that's even further to the right of
% the actual screen boundary.  (XRight is the right side of the screen,
% XRight+50 is even further right than that).
% So, WE'LL NEVER SEE IT!  Drawing something outside of the screen coordinates
% means it won't be seen.

WriteLine(mainwindow,'Please click on a box.|The pipes create a <b>paragraph</b> break</b>.', black, 50, 300,600,2);
% the 50 is the MARGIN ... if you go beyond more than 50 pixels on the
% right, it will get wrapped onto the next line
% the 2 is for DOUBLE-SPACED text
%
% The <b> turns on BOLDFACE and the </b> turns it off.  See:
%   help WriteLine
% for some other formatting options (italics, colored text, etc.)

WriteCentered(mainwindow,'Here''s some centered text.', XCenter,100,red);
% This is where it's really helpful to calculate stuff (like the center of
% the point of the screen) rather than hard-coding a particular number.  If
% you move to a different screen where the dimensions are different, this
% will still be centered!  it wouldn't be if we just typed in the numbers
% manually
%
% the double apostrophe is used to tell Matlab that the apostrophe is PART
% OF your string ... rather than the ' that denotes the end of the string
%
% it will display as a single apostrophe in the actual experiment

% the 4 coordinates are Xleft,Ytop, Xright,Ybottom
% if don't specify for FillRect, it will default to the whole screen (a
% good way to erase what's on the screen)
Screen('Flip',mainwindow);
% FLIP copies what's in the framebuffer to the mainwindow (in PTB-3)
% NEED to do this or you won't see what you were drawing
%
% in PTB-2, stuff is automatically drawn; you don't need to use Flip
% but to avoid the problem where it starts drawing stuff halfway through
% the screen, use the command WaitBlanking BEFORE the command to display

[areaclicked RT] = Wait4Mouse([BoxCoordinates;Box2Coordinates]);
% Wait4Mouse wait for the user to click in one of a set of rects on the
% screen
% the rects are 4-element vectors, combined into an N x 4 matrix
%
% if you wanted to click ANYWHERE, use Wait4Mouse(rect) because rect is the
% coordinates of the WHOLE SCREEN

fprintf('Area clicked: %d \n', areaclicked);
% areaclicked is which of the areas you clicked on
% since each area is defined by a ROW in the matrix that you sent to
% Wait4Mouse ... this is WHICH ROW Of the matrix you clicked on
%
% then you could do something different depending on which area got clicked

end

%% NOW TRY DISPLAYING A PICTURE
% there's nothing to click, so we might prefer not to show the mouse cursor
% to avoid confusing the user
HideCursor;

[camelPicture camelRect] = loadImage(mainwindow, 'camel_b.jpg');
% this loads up the picture file 'camel_b.jpg' and puts it in a new
% offscreen window called camelPicture.  camelRect is the size of the
% image.
%
% since the image is in an OFFSCREEN window it won't actually displayed
% until we copy onto the main window
%
% typically, it's a good idea to load up the images for a trial BEFORE it
% starts.  loading files off the hard drive takes time, but copying the
% offscreen windows to the main window is very fast.

spotforpicture = CenterInRect(rect,camelRect);
% this will return coordinates for centering our camel picture on the
% screen
Screen('CopyWindow', camelPicture,mainwindow,camelRect,spotforpicture);
 % we're copying the camel picture onto the mainwindow
 % the next argument specifies HOW MUCH of the camel picture to copy
 % the last argument tells Matlab what area of the screen we want to set
 % aside for our camel picture.  by default, it is the WHOLE SCREEN.
 % probably, we just want to copy the picture into PART of the screen
Screen('CopyWindow', camelPicture,mainwindow,camelRect,[0 0 100 100]);
% you can also copy the picture into a region that doesn't match the
% original size of the image. this will make it bigger or smaller.
Screen('CopyWindow', camelPicture,mainwindow,camelRect,[500 0 550 300]);
% here, the region doesn't match the ratio of the original image.  it's
% only 50 pixels wide but 300 pixels tall.  the result is a "funhouse
% mirror" where we get a distorted image.  the ratio of the
% horizontal:vertical size is called the "Aspect Ratio" of an image

t1 = Screen('Flip',mainwindow,[],1); % need to flip to show the image we copied
% we are SKIPPING the 3rd argument to the flip command by just entering an
% empty matrix
% the FOURTH argument determines whether the framebuffer is cleared when
% the flip happens.  the default is to erase everything from the "holding area"
% once we put on the screen.  so we would lose the camels the next time we
% do a flip.
% to KEEP the camels, the fourth argument is 1.  this KEEPS what you just
% copied to the screen in the framebuffer.
%
% When Flip executes, it returns the TIMEPOINT at which the flip occurred.
% We are saving that as t1.  We can use that, later, to time something so
% that it happens 2 seconds after we put these graphics on the screen.

WriteCentered(mainwindow, 'Camels rule!', XCenter, 600, black);
% it's fine to combine text & graphics on the same screen

Screen('Flip', mainwindow, t1+2);
% Here, we are now using the third argument to tell the computer WHEN we
% want to change the display.  This is scheduled to be 2 seconds after the
% time of the first flip (which was t1)
%
% This provides better timing than doing WaitSecs(2) and then doing a Flip.
% Waiting 2 seconds and THEN drawing the box is actually going to take a little
% longer than 2 seconds.


% let's take a SCREENSHOT of this so we can put an example of our display
% in a manuscript or poster:
%screenshot = Screen('GetImage', mainwindow);
% this puts a picture of our current display inside the matrix screenshot
% this is basically a huge matrix of numbers representing the color at each
% point on the screen
%
% then, we want to save this into a file:
%imwrite(screenshot,'screenshot.png');
% this saves the screenshot into the file screenshot.png
% common image file formats: .gif, .jpg, .png
%
% doing this can take a while because the screenshot is a LARGE matrix.  so
% it's typically good to remove this code (or comment it out) when running
% real subjects.  take the screenshot when you're running the expt by yourself

% this time, we didn't keep anything in the framebuffer when we did a Flip
% which means the framebuffer is clear

WaitSecs(2);
% so if we do another flip, it will erase everything off the screen
Screen('Flip', mainwindow);

ShowCursor; % this brings the mouse cursor back

% loading a LOT of offscreen windows can slow things down
% so, once we are done with a picture, it's better to erase that offscreen
% window to free up memory
clear camelPicture;
% you can actually clear ANY variable this way.  so if you had some huge
% matrix that you didn't need anymore, you could erase that too.

%% MORE WITH IMAGES
% maybe we want to FORCE our images to be in a certain size window.  e.g.
% to have all our images in the experiment take up the same size
%
% problem: copying differently sized windows into the same region of the
% screen creates the "funhouse mirror" effect as we saw above
% we need some way to force all images into the same aspect ratio
[camelPicture camelRect] = loadImage(mainwindow, 'camel_b.jpg', [0 0 600 400]);
% the 3rd argument to loadImage allows us to specify a custom window size
% instead of just using the actual size of the picture
%
% this adds whitespace on the edges so that the image matches the size you
% want, without STRETCHING it

spotforpicture = CenterInRect(rect,camelRect);
Screen('CopyWindow', camelPicture,mainwindow,camelRect,spotforpicture);
Screen('Flip', mainwindow);
getKeys;
%
% or, if we want our background color (instead of whitespace), the FIFTH
% argument does that
% example: [camelPicture camelRect] = loadImage(mainwindow, 'camel_b.jpg', [0 0 600 400], [], purple);

%% EVEN MORE WITH IMAGES
[camelPicture camelRect] = loadImage(mainwindow, 'camel_b.jpg', [0 0 600 400], 1);
% this is a 3:2 aspect ratio
% but if we just put our 289 x 289 pixel camel in the 600 x 400 window,
% there will be whitespace on BOTH sides
% what we really want is to make the camel picture as big as possible while
% keeping the aspect ratio
% fourth parameter in loadImage is for RESCALING.
% this will make the picture AS BIG AS POSSIBLE while keeping the aspect
% ratio you specified
spotforpicture = CenterInRect(rect,camelRect);
Screen('CopyWindow', camelPicture,mainwindow,camelRect,spotforpicture);
Screen('Flip', mainwindow);
getKeys;

%% SUBJECT ENTERS TEXT
% the input command just gets input from the Matlab command window; it
% doesn't work when we have a screen up
%
% to get input from the subject with the screen up, use GetEchoString
subjectresponse = GetEchoString(mainwindow, 'Do you like camels?: ', XCenter, 300, black);
%
% Our LAB toolbox has a substantially upgraded version called
%  GetEchoStringCuedT4
% for more details on all the options:
%  help GetEchoStringCuedT4

% this is the command that closes all the screens
Screen('CloseAll');
% it's really important to do this.
% otherwise the screen will stay open forever even after the experiment is
% done

catch
    % This block executes if there was a crash somewhere in the try block.
    % It allows us to do something in response:
    Screen('CloseAll');
    % Close all the screens so we're not stuck with the screen up.
    
    % If you go into a catch block, the error message won't be displayed
    % automatically
    rethrow(lasterror); % display the error message anyway
    % the error message is usually useful in finding out what went wrong
end

% If your experiment crashes while the screen is up, the screen will stay
% up and you won't be able to see anything.  (That is why we have the CATCH
% block above.)
%
% On a PC, you can Alt-Tab back to the Matlab command window and type
% Screen('CloseAll') manually
%
% On a Mac, Ctrl+C to get back to the command window.  type sca and hit
% Enter.  You won't be able to see what you are typing, but just do it
% anyways :P
%
% in PTB-3 (only): sca  is a shortcut to Screen('CloseAll')

% Some other useful pre-built screens that you might want to use in your
% experiment ... see help for more details:
%  help InstructionsScreen
%  help AdjustVolume