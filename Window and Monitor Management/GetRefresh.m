function refresh=GetRefresh(monitor)
% 
%     refresh=GetRefresh(monitor)
% 
% function return the refresh rate for MONITOR
%
% 02.22.10 - S.Fraundorf - PTB-3 version.  this is totally different from
%                          Mike Diaz's PTB-2 version.  PTB-3 seems to
%                          provide a good estimate of the time that it
%                          takes the monitor to flip, so we just need to
%                          run that and convert it to a refresh rate

fliptime = Screen('GetFlipInterval', monitor); % time to do one flip
refresh=round(1/fliptime); % refreshes per second