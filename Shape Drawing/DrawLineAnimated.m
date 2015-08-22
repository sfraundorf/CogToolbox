% DrawLineAnimated(window, color, fromH, fromV, toH, toV, penwidth, speed);
%
% Draws a line of thickness PENWIDTH pixels from (fromH,fromV) to (toH,toV)
% on the screen in color COLOR.
%
% Unlike PTB-3's regular DrawLine, this draws an ANIMATED line, so that the
% tuser sees the line being drawn.
%
% SPEED is the number of pixels to draw per screen refresh  (a higher # =
% faster speed)
%
% BETA version
%
% 01.30.10 - S.Fraundorf - first version, for PTB-3

function DrawLineAnimated(window,color,fromH,fromV,toH,toV,penwidth,speed)

coord = [fromH fromV]; % start point
dirH = (toH-fromH) > 0; % are we going left or right?
dirV = (toV-fromV) > 0; % are we going up or down

while coord(1) ~= toH && coord(2) ~= toV
    
    % get next set of pixels
    
    % horizontal
    if dirH % going RIGHT
        newcoord(1) = coord(1) + speed;
        % don't let them go PAST the target
        if newcoord(1) > toH
           newcoord(1) = toH;
        end
    else
        newcoord(1) = coord(1) - speed;
        % don't let them go PAST the target
        if newcoord(1) < toH
           newcoord(1) = toH;
        end
    end
    
    % vertical
    if dirV % going DOWN
        newcoord(2) = coord(2) + speed;
        % don't let them go PAST the target
        if newcoord(2) > toV
           newcoord(2) = toV;
        end
    else
        newcoord(2) = coord(2) - speed;
        % don't let them go PAST the target
        if newcoord(2) < toV
           newcoord(2) = toV;
        end
    end
       
    
    % draw the line
    Screen('DrawLine',window,color,coord(1),coord(2),newcoord(1), newcoord(2),penwidth);
    Screen('Flip',window,0,1);
    
    % move to the new spot
    coord = newcoord;
end