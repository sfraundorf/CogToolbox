% result = nth(F,N)
%
% Returns the N-th element of the output of function F
%  e.g. result = nth(mean(RTs), 3)
% returns the mean of column 3
%
% 06.02.10 - S.Fraundorf
% 06.16.10 - S.Fraundorf - bug-catching if N > number of elements of F
% 08.21.12 - S.Fraundorf - updated error message

function result = nth(F,N)

   if N > numel(F)
       error('CogToolbox:nth:NGreaterThanF', 'N is greater than number of elements of F');
   else
       result = F(N);
   end
end