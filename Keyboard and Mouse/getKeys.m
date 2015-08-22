function varargout=getKeys(maxtime)
% 
%     key=getKeys(maxtime)
%     [key time]=getKeys(maxtime)
% 
% returns the key(s) that are pressed AFTER function was executed.  Will
% not return a key that was being held down prior to the function call.
%
% Optional parameter MAXTIME will end the wait (returning no keys pressed)
% after MAXTIME seconds have elapsed.  (This can be used to add a time limit
% to trials.)  If MAXTIME is not specified, the function will indefinitely
% wait for a response.
% 
%  6.20.06 M.Diaz
% 11.21.09 S.Fraundorf - added optional maxtime parameter
% 08.21.12 S.Fraundorf - updated error message

if nargin>0 % time limit
    starttime=GetSecs;
end

if nargout>2
    Screen('CloseAll');
    error('CogToolbox:getKeys:TooManyOutputArguments', 'Too many output arguments');
end
while KbCheck; end % make sure user is not presing any keys already
while true
    [down time code]=KbCheck;
    if down==1
        varargout{1}=find(code==1);
        if nargout==2
            varargout{2}=time;
        end
        return
    end

    if nargin>0 % check if time limit exceeded (if we have one)
        if GetSecs-starttime > maxtime
            varargout{1} = [];
            if nargout==2
                varargout{2} = starttime+maxtime;
            end
            return
        end
    end
end