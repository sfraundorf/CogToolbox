% newstring = strrepNum(oldstring, startpoint, endpoint, newtext)
%
% Replaces a section from string OLDSTRING with string NEWTEXT.  The
% section is defined with numerical positions STARTPOINT and ENDPOINT.
%
% Unlike strrep, this works based on NUMERICAL POSITION within the string,
% not based on a character substring.
%
% 11.27.08 - S.Fraundorf - as strrepOnce
% 11.21.09 - S.Fraundorf - renamed to strrepNum to better describe it

function newstring = strrepNum(oldstring, startpoint, endpoint, newtext)
    if startpoint > 1
        newstring = oldstring(1:startpoint-1);
    else
        newstring = '';
    end
    
    newstring = [newstring newtext oldstring(endpoint+1:numel(oldstring))];
end