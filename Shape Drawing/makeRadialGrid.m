% [responseloc, response, grid,image] = makeRadialGrid(numItems, window,
%       labels, squarelength, radius, startdegree, highlighton)
% 
% Draws circles evenly arranged radially around the center of the screen.
% 
% numItems determines the number of circles to draw .
%
% labels is a string of label tokens for each item in the grid
%
% squarelength determines the size of the diameter of the circles
%
% radius determines the distance of the circles from the center of the
% streen
%
% startdegree is the start angle for the point for the first circle. All
% other circles will be evenly arranged around the start circle
%
% highlighton is a binary value determining whether or not to highlight 
% circles that are currently being hovered over.
%
% responsecoordinates returns a rect containing the coordinates for the
% circle that was chosen
%
% responsecell returns a string corresponding to the label on the circle
% that was chosen
%
% coordinates returns a matrix containing the rects for all of the circles
% that were drawn
%
% imageArray produces a picture of the screen with a fully drawn RadialGrid
% 
% For example:
% [responseloc, response, grid, image] = makeRadialGrid(3, win, 'ba da ga', 100, 200, 0, 1)
%
% will draw a radial grid with three 100-pixel diameter circles evenly
% arranged around the center of the screen and each circle will be 200
% pixels from the center of the screen. Hovering of the a circle will
% highlight it green.
%
% 02.21.14 T.Lam - PTB-3 version

function [responsecoordinates, responsecell, coordinates, imageArray] = makeRadialGrid(numItems, window, labels, squarelength,radius,startdegree,highlighton)


if(nargin<7)
    highlighton=1;
end
black=[0,0,0];
white=[255,255,255];
green=[0,255,0];
rect=Screen('Rect',window);
screenratio=rect(4)/800;
radians=2*pi/numItems;
points=zeros(numItems,2);
coordinates=zeros(numItems,4);
flux=Screen('OpenOffscreenWindow',window,white,rect);
blank=Screen('OpenOffscreenWindow',window,white,rect);
labelcells=cell(numItems,1);
radoffset=2*pi*(mod(startdegree,360)/360);
for i=1:numItems
    ypoint=radius*sin(i*radians+radoffset);
    xpoint=radius*cos(i*radians+radoffset);
    points(i,:)=[xpoint ypoint];
    
    temp=[xpoint-squarelength/2 ypoint-squarelength/2 xpoint+squarelength/2 ypoint+squarelength/2];
    coordinates(i,:)=temp+[rect(3)/2 rect(4)/2 rect(3)/2 rect(4)/2];
    [label, labels]=strtok(labels); % Get label names
    if(strcmp(label,''))
        label=num2str(i);
    end
    labelcells{i,1}=label;
    FilledOvalWText(window,label,black,white,coordinates(i,:));
    Screen('FrameOval', window, black, coordinates(i,:),screenratio*5);
end
Screen('CopyWindow',window,flux);
imageArray = Screen('GetImage', flux, rect);
Screen('Flip',window);

% This part of the code checks for a click on the target
unclicked = 1;
while(unclicked)
    [xclick, yclick, buttons] = GetMouse(window);
    
    % Check for hovering
    missing=1;
    xcount=1;
    xfound=0;
    while(missing)       
        check=coordinates(xcount,:);
        if(check(1)<xclick && check(3)>xclick && check(2)<yclick && check(4)>yclick)
            missing=0;
            xfound=xcount;
            % Screen('CopyWindow',flux,window);
            % FilledRectWText(window,labelcells{xcount,1},black,green,coordinates(xcount,:));
            % Screen('FrameRect', window, black, coordinates(xcount,:),5);
            % Screen('Flip',window);
        else
            % Screen('CopyWindow',flux,window);
            % Screen('Flip',window);
        end
        xcount=xcount+1;
        if(xcount>numItems)
            missing=0;
        end
    end
    if(xfound>0)
        if(highlighton)
            Screen('CopyWindow',flux,window);
            FilledOvalWText(window,labelcells{xfound,1},black,green,coordinates(xfound,:));
            Screen('FrameOval', window, black, coordinates(xfound,:),screenratio*5);
            Screen('Flip',window);
        end
    else
        Screen('CopyWindow',flux,window);
        Screen('Flip',window);
    end
    responsecell=xcount;
    
    
    % Check for mouse click
    if(any(buttons))
        xmissing=1;
        xcount=1;
        xfound=0;
        while(xmissing)
            check=coordinates(xcount,:);
            if(check(1)<xclick && check(3)>xclick && check(2)<yclick && check(4)>yclick)
                xmissing=0;
                xfound=xcount;
                % This part makes the circle stay green as feedback
                Screen('CopyWindow',flux,window);
                FilledOvalWText(window,labelcells{xfound,1},black,green,coordinates(xfound,:));
                Screen('FrameOval', window, black, coordinates(xfound,:),screenratio*5);
                Screen('Flip',window);
                WaitSecs(.5);
            end
            xcount=xcount+1;
            if(xcount>numItems)
                xmissing=0;
            end
        end
        if(xfound>0)
            responsecoordinates=coordinates(xfound,:);
            responsecell=labelcells{xfound,1};
            unclicked=0;
        end
    end
end
Screen('Close',flux);
Screen('Close',blank);
return;