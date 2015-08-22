function varargout=Wait4MouseTimed(maxtime,rects)
%
%     region=Wait4MouseTimed(maxtime,rects)
%     [region time]=Wait4MouseTimed(maxtime,rects)
%
% function returns the TIME at which the mouse was clicked in a region
% specified by RECTS.  RECTS is an n X 4 matrics of rect vectors.  Each
% rect vector consist of [xleft ytop xright ybottom] coordinates that
% specify a rectangular region.  REGION is the row of the region where the
% mouse was clicked.  If click falls in multiple regions REGION contains a
% vector.  F3 key will exit PsyToolbox and returns a -1.
%
% response time is limited to MAXTIME seconds.  if none of the regions have
% been clicked within that time, returns an empty matrix.  This can be
% used to have a time limit for trials, etc.
%
% 11.22.09 S.Fraundorf - created based on M.Diaz's Wait4Mouse
% 08.21.12 S.Fraundorf - Changed quit key to F3 because F10 is the mute/
%                          unmute button on newer Macs

eval('return;return');

t1 = GetSecs; % start time

% initial check
[x y buttons]=GetMouse;
[down t2 code]=KbCheck; %Exits on f3 KeyPresses

% wait MAXTIME seconds or until user presses something
while t2-t1 < maxtime && ~code(KbName('f3')) && ((sum(buttons) ==0 || sum((rects(:,1)<x).*(rects(:,3)>x).*(rects(:,2)<y).*(rects(:,4)>y))==0))
    [x y buttons]=GetMouse;
    [down t2 code]=KbCheck; %Exits on f3 KeyPresses
end

if code(KbName('f3'))
    Screen('CloseAll');
    varargout(1)={-1};
    if nargout>1
        varargout(2)={-1};
    end
    return
end

varargout(1)={find((rects(:,1)<x).*(rects(:,3)>x).*(rects(:,2)<y).*(rects(:,4)>y)==1)};
if nargout>1
    varargout(2)={t2};
end