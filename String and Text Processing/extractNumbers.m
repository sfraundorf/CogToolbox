% [numbers newstring] = extractNumbers (string)
%
% Removes all numbers from STRING and returns them as separate elements
% in a vector, and optionally, the NEWSTRING string with the numbers removed
%
% Right now this only works with POSITIVE INTEGERS and 0
%
% 06.14.10 - S.Fraundorf

function [numbers newstring] = extractNumbers (string)

%% find all the digits in the text string
digits = '0123456789';

founddigits = [];
for i=digits
    founddigits = [founddigits strfind(string, i)];
end
founddigits = sort(founddigits);

%% find which ones are adjacent to each other
newnums=1; % first number is always a new number
for i=2:numel(founddigits)
    if founddigits(i) > (founddigits(i-1) + 1)
        % NOT the adjacent character
        newnums = [newnums i];
    end
end
% and how many there are
diffnumbers = numel(newnums);
newnums = [newnums numel(founddigits)+1]; % add one more "new number" to close off the last one

%% collect the numbers into a vector
actualnumbers = string(founddigits);

%% separate out the numbers
numbers = zeros(1,diffnumbers);

for i=1:diffnumbers
    startpt = newnums(i);
    endpt = newnums(i+1)-1;
    numbers(i) = str2double(actualnumbers(startpt:endpt));
end

%% return edited string
if nargout==2
    newstring= string;
    for num=numbers
        newstring = strrep(newstring, num2str(num), '');
    end
end