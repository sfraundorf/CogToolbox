% isodd(number)
%
% Returns whether or not a number is odd.
%
% Note that both even integers and non-integer numbers are "not odd".  If
% you want to test whther something is an even integer, specifically, use
% ISEVEN
%
% 06.02.10 - S.Fraundorf
% 06.30.10 - S.Fraundorf - return boolean rather than integer

function itsodd = isodd(number)

if number == 0
    itsodd = true;
else
   try 
      itsodd = (nth(factor(abs(number)),1) ~= 2);
   catch
      itsodd = false;
   end
end