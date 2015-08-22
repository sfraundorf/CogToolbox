% function numAsPercent = asPercent(originalnum, decimals)
%
% Returns a string that displays proportion ORIGINALNUM as
% a percentage, out to DECIMAL decimal places.
%
% e.g. asPercent(.652373, 2) returns '65.24%'
%
% 06.23.08 - S.Fraundorf - first version
% 05.26.11 - S.Fraundorf - rescued from the depths of my hard drive
%                          and added helptext
% 08.22.11 - S.Fraundorf - removed unnecessary brackets

% turns a number into a percent-formatted string

function numAsPercent = asPercent(originalnum, decimals)

 if nargin == 1
    decimals = 0;
 end

 percentage = originalnum * 100;
  
 formattingcode = ['%2.' num2str(decimals) 'f'];
  
 eval('numAsPercent = [num2str(percentage, formattingcode) ''%''];');

end