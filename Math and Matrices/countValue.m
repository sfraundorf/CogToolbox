% function n = countValue(array,value)
%
% Counts the number of time VALUE appears in ARRAY.
%
% ??.??.?? - Tuan Lam - original version
% 02.22.10 - S.Fraundorf - use numel(find)

function n = countValue(array, value)

n = numel(find(array==value));