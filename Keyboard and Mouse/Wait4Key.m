function varargout=Wait4Key(varargin)
% 
%     time=Wait4Key(keys)
%     [time keyCode]=Wait4Key(keys)
%
% waits until one of the KEYS is pressed and returns cpu TIME of the
% keypress.  If second output argument specified, returns the KEYCODE at
% the time of the key press.
%
% If you want to wait for ANY key, use getKeys.
% 
%  2.27.06 M.Diaz
% 01.30.10 S.Fraundorf - first PTB-3 version
% 08.21.12 S.Fraundorf - updated error messages and provided additional
%                          explanation of how to fix the problem if you
%                          defined the keys incorrectly

if nargin < 1
    error('CogToolbox:Wait4Key:NoKeysSpecified', 'Must specify at least one key to wait for');
end

%put all inputs in a single vector (most efficient if calling function just
%passes in a single vector--but not necessary)
keys=varargin{1};
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
for v=2:numel(varargin)
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

while KbCheck; end
while true
    [t2 code]=KbWait;
    if sum(code(keys))
        varargout(1)={t2};
        if nargout==2
            varargout(2)={code};
        end
        return
    end
end