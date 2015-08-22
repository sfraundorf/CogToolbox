% closingtag = getClosingTag(opentag)
%
% This function returns the appropriate closing tag for a markup code,
% given the opening tag OPENTAG.  The OPENTAG may be enclosed in < > or not
% but the output always is.
%
% 05.26.07 - S.Fraundorf
% 11.21.09 - S.Fraundorf - rewrote to allow input to not contain < >

function closingtag =getClosingTag(opentag)

% remove any existing < >s
closingtag = stripString(opentag, '<');
closingtag = stripString(closingtag, '>');

% assemble the tag
closingtag = ['</' closingtag '>'];