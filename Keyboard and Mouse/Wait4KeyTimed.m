function varargout=Wait4KeyTimed(varargin)
% 
%     time=Wait4KeyTimed(maxtime,keys)
%     [time keyCode]=Wait4KeyTimed(maxtime,keys)
%
% waits until one of the KEYS is pressed and returns cpu TIME of the
% keypress.  If second output argument specified, returns the KEYCODE at
% the time of the key press.
%
% response time is limited to MAXTIME seconds.  if one of KEYS has not been
% pressed within that time, returns no keys pressed.  This can be used to
% have a time limit for trials, etc.
% 
% 11.22.09 S.Fraundorf - created based on M.Diaz's Wait4Key
% 02.07.10 S.Fraundorf - fixed some issues with held-down keys on Windows
% 08.21.12 S.Fraundorf - updated error messages and provided additional
%                          explanation of how to fix the problem if you
%                          defined the keys incorrectly

maxtime=varargin{1};
if nargin < 2
    error('CogToolbox:Wait4Key:NoKeysSpecified', 'Must specify at least one key to wait for');
else
    t1=GetSecs;
end

%put all inputs in a single vector (most efficient if calling function just
%passes in a single vector--but not necessary)
keys=varargin{2};
if ischar(keys)
    Screen ('CloseAll');
    error('CogToolbox:Wait4Key:CharacterKeys', ...
        'Keys should be defined as numerical codes from the KbName function, not as labels.  see help KbName');
end
if size(keys,1)>1
    if size(keys,2)==1;
        keys=keys';
    else
        keys=keys(1:end);
    end
end
for v=3:numel(varargin)
    if size(varargin{v},1)==1
        keys=[keys varargin{v}];
    elseif size(varargin{v},2)==1
        keys=[keys varargin{v}'];
    else
        keys=[keys varargin{v}(1:end)];
    end
end
if max(keys)>255 || min(keys)<1
    Screen ('CloseAll');
    error('CogToolbox:Wait4Key:InvalidKeycode', ...
        'Key code out of range.  Use KbName function to get the actual numerical codes.');
end

[down t2 startKeys] = KbCheck; % get any keys that the user is ALREADY holding down
while true
    [down t2 code]=KbCheck; % check keys that are down  
    startKeys(code==0) = 0; % clear out any start keys that have now been released
    code(startKeys==1) = 0; % ignore keys already pressed
        
    if find(code(keys)==1,1)  % one of the target keys has been pressed
        varargout(1)={t2};
        if nargout==2
            varargout(2)={code};
        end
        return
    elseif t2-t1 > maxtime    % time limit exceeded
        varargout{1} = t1+maxtime;
        if nargout==2
             varargout{2} = [];
        end
        return
    end
    
end