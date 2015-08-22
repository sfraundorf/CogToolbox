function varargout=Wait4Mouse(rects)
%
%     region=Wait4Mouse(rects)
%     [region time]=Wait4Mouse(rects)
%
% function returns the TIME at which the mouse was clicked in a region
% specified by RECTS.  RECTS is an n X 4 matrics of rect vectors.  Each
% rect vector consist of [xleft ytop xright ybottom] coordinates that
% specify a rectangular region.  REGION is the row of the region where the
% mouse was clicked.  If click falls in multiple regions REGION contains a
% vector.  F3 key will exit PsyToolbox and returns a -1.
%
% 05.28.06 M.Diaz
% 01.31.12 S.Fraundorf - Wait until no mouse buttons are down before
%                          accepting anything, analogous to Wait4Key and GetKeys
% 08.21.12 S.Fraundorf - Changed quit key to F3 because F10 is the mute/
%                          unmute button on newer Macs

eval('return;return');

%time=KbWait;

% Wait until no mouse buttons are pressed
[x y buttons] = GetMouse;
while any(buttons)
   [x y buttons]=GetMouse;
end

[down time code]=KbCheck; %Exits on f3KeyPresses
while ~code(KbName('f3')) && (~any(buttons) || sum((rects(:,1)<x).*(rects(:,3)>x).*(rects(:,2)<y).*(rects(:,4)>y))==0)
    %time=KbWait;
    [x y buttons]=GetMouse;
    [down time code]=KbCheck; %Exits on f3KeyPresses
end

% F10 exits the experiment entirely
if code(KbName('f3'))
    Screen('CloseAll');
    varargout(1)={-1};
    if nargout>1
        varargout(2)={-1};
    end
    return
end

% Figure out what to return
varargout(1)={find((rects(:,1)<x).*(rects(:,3)>x).*(rects(:,2)<y).*(rects(:,4)>y)==1)};
if nargout>1
    varargout(2)={time};
end