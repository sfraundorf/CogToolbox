% stripManyStrings.m
%
% Removes any/every case of several substrings from string OLDSTRING, using
% strrepMany.  The substrings to be removed are contained in a cell array
% SUBSTRINGS.
%
% 11.21.09 S.Fraundorf - rewrote using strrepMany

function newstring = stripManyStrings(oldstring, substrings)

newstring = strrepMany(oldstring,substrings,'');
