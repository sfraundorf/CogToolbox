% dualfprintf(filenumber, screen, message, varargin)
%
% Prints a string to a file, to the screen, or both simultaneously.
%
% All of the arguments used with fprintf may also be used for this by
% passing them as arguments.
%
% If FILENUMBER > 0, the string is printed to open file FILENUMBER.
% If SCREEN is 1, the message will be printed to the MATLAB Command Window.
% If FILENUMBER > 0 and SCREEN is 1, the message will be printed to both.
%
% Example:
%  answer = 42;
%  dualfprintf(2,1,'the answer is %d\n',answer);
% Prints 'the answer is 42' both to file 2 and to the Command Window.
%
% 07.11.08 - S.Fraundorf

function dualfprintf(filenumber, screen, message, varargin)

printstring = [];
for i=1:numel(varargin)
    printstring = [printstring ', varargin{' num2str(i) '}'];
end

if screen == 1
  eval(['fprintf(message' printstring ');']);
end
if (filenumber > 0)
    eval(['fprintf(filenumber, message' printstring ');']);
end

end