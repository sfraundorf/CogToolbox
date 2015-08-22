% userinput = inputnumber(prompt,minvalue,maxvalue)
%
% Calls input until the user has entered a number that is at least MINVALUE
% and no greater than MAXVALUE.  (Both MINVALUE and MAXVALUE are optional.)
% PROMPT is the optional prompt to disply in the INPUT function.
%
% in case you are worried someone will enter negative subject numbers...
%
%  8.26.09 - S.Fraundorf
% 11.23.09 - S.Fraundorf - reject character/non-numeric input

function userinput = inputnumber(prompt, minvalue, maxvalue)

if nargin == 0
    prompt = '';
end

userinput = NaN;

while isnan(userinput)
    userinput = input(prompt);
    
    if isempty(userinput)
        userinput = NaN; % nothing entered, reject
    elseif ~isnumeric(userinput)
        userinput = NaN; % not a number, reject
    elseif nargin > 1
        if userinput < minvalue
            userinput = NaN;  % below minimum value, reject
        end
        if nargin == 3
            if userinput > maxvalue
                userinput = NaN; % above max value, reject
            end    
        end
    end 
end