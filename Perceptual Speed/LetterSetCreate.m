% [set same] = LetterSetCreate(consonants, setsize)
%
% Used internally by LetterComparison.m to create random sets of letters.
%
% Returns a random set SET and flag SAME that indicates whether or not they
% are the same
%
% consonants = set of consonants
%
% 01.26.10 - S.Fraundorf - first version

function [set same] = LetterSetCreate(consonants, setsize)

same = round(rand); % 0 or 1
numconsonants = numel(consonants); % 21 if we are using ALL consonants
set = char(2,setsize);

% row 1
for i=1:setsize
    set(1,i) = consonants(ceil(rand*numconsonants));
end

% row 2 is the same
set(2,:) = set(1,:);

if ~same
    % pick a random letter to permute
    i = ceil(rand*setsize);
    % change it
    set(2,i) = consonants(ceil(rand*numconsonants));
end