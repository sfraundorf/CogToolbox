% userinput = inputstring(prompt)
%
% Calls input until the user has entered a non-empty string.
% PROMPT is the optional prompt to display in the INPUT function
%
% 08.26.09 - S.Fraundorf - First version

function userinput = inputstring(prompt)

if nargin == 0
    prompt = '';
end

userinput = '';

while strcmp(userinput, '')
  userinput = input(prompt, 's');
end