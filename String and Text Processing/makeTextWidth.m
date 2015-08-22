% output = makeTextWidth(string,width)
% 
% Makes input STRING a specified WIDTH characters along, by adding
% blank spaces or chopping off characters if necessary.
%
% 07.27.08 - S.Fraundorf

function output = makeTextWidth(string, width)

if nargin == 1
    output = string;
else
    stringsize = numel(string); % initial size
    
    if (width < stringsize) % CHOP string to match width
        output = string(1:width);
        
    elseif (width > stringsize) % ADD SPACES to match width
        diff = width-stringsize;
        addition = repmat(' ', 1, diff);
        output = [string addition];
        
    else % exactly the right length
        output = string;
    end
end