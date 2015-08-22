% userinput = inputyn(prompt)
%
% Collects string input until the user enters either (Y)es or (N)o.
% Returns 1 if yes and 0 if no.
%
% PROMPT is the optional prompt to display in the INPUT function
%
% 02.17.11 - S.Fraundorf - First version

function userinput = inputyn(prompt)

acceptableresponses = {'y','n','yes','no'};

if nargin == 0
    prompt = '';
end

done=false;

while ~done
  userinput = input(prompt, 's');
  match = strmatch(lower(userinput), acceptableresponses);
  if match
      done = true;
      userinput = nth(mod(match,2),1); % 1 if yes, 0 if no
  end
end