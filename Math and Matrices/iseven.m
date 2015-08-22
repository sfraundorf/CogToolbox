% iseven(number)
%
% Returns whether or not a number is even.
%
% Note that both odd integers and non-integer numbers are "not even".  If
% you want to test whther something is an odd integer, specifically, use
% ISODD
%
% 06.02.10 - S.Fraundorf
% 06.30.10 - S.Fraundorf - return boolean rather than integer

function itseven = iseven(number)

if number == 0
    itseven = true;
else
   try 
      itseven = (nth(factor(abs(number)),1) == 2);
   catch
      itseven = false;
   end
end