% newline = stripMarkup(oldline)
%
% Removes any and all markup codes (denoted by < > ) from a line of text.
%
% 06.16.10 - S.Fraundorf - 1st version
% 11.18.10 - S.Fraundorf - updated to use stripStringNum

function newline = stripMarkup(oldline)

% start with the line as-is
newline = oldline;

codestart = find(oldline == '<',1);
while ~isempty(codestart) % we have a markup code
    
    % find the end of this markup code
    codeend = find(newline == '>', 1);
    
    % remove it
    newline = stripStringNum(newline,codestart,codeend);
    
    % see if there are any more
    codestart = find(newline == '<',1);
    
end