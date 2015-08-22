% s = num2strLZ(x, f, numdigits)
%
% Converts number X to a string with formatting F (see SPRINTF for
% details).
%
% Ensures that the output is NUMDIGITS long, adding leading zeros if
% necessary.
%
% 06.25.08 - S.Fraundorf

function s = num2strLZ(x, f, numdigits)

 s = num2str(x, f);
 
 if (nargin > 2)
     while (x < 10^(numdigits-1) && numdigits > 1)
         s = ['0' s];
         numdigits = numdigits - 1;
     end
 end

end