% [mainstring splicedout] = stripStringNum(instring, startpt, endpt)
%
% Removes a portion of string INSTRING, as specified by beginning point
% STARTPT and end position ENDPT.  Returns the beginning and end of the
% string with this specified portion removed.
%
% Optionally, returns the removed portion as well.
%
% Unlike stripString or strrep, stripStringNum edits based on NUMERICAL
% POSITION within the string.
%
% 08.10.08 - S.Fraundorf
% 11.21.09 - S.Fraundorf - renamed removeFromString to stripStringNum for
%                          clarity

function [mainstring splicedout] = stripStringNum(instring, startpt, endpt)

if nargin == 2
    endpt = startpt;
end

mainstring = [instring(1:startpt-1) instring(endpt+1:numel(instring))];
% return the spliced out portion, if requested
if nargout > 1
  splicedout = instring(startpt:endpt);
end

end