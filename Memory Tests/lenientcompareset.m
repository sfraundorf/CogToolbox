% [bestscore index] = lenientcompareset(possiblematches,searchword)
%
% Performs a lenient compare (see help file for lenientcompare) between
% string SEARCHWORD and a 1-dimensional cell array *set* of strings,
% POSSIBLEMATCHES.  Returns both the score of the highest match (BESTSCORE)
% and the INDEX of the entry(ies) in the cell array with the highest match.
%
% 95 is the highest possible score for a non-exact match.
%
% This function is case-insensitive because lenientcompare is.
%
% Note that this function can be used both to (a) compare one response to
% a set of targets to see if matches any of them, or (b) compare a set of
% responses to see if they ANY of them match a particular target.
%
% 11.17.09 S.Fraundorf
% 11.26.09 S.Fraundorf - can return >1 index if there is a tie

function [bestscore index] = lenientcompareset(possiblematches,searchword)

bestscore =0;
index = [];
for i=1:numel(possiblematches)
    curscore = lenientcompare(possiblematches{i},searchword);
    if curscore > bestscore 
        bestscore = curscore;
        index = i; % replace the old index
    elseif curscore == bestscore % tie
        index = [index i]; % expand the array of indices to include both
    end
end