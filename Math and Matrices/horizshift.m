% newmatrix = horizshift(oldmatrix, direction, newvalue)
%
% Within each row of matrix OLDMATRIX, shifts all the elements one position
% horizontally.  Optional parameter DIRECTION controls the direction of
% this shift; 0 is to the left (default) and 1 is to the right.
%
% e.g. [ 2 3 4    becomes  [ 3 4 2
%        5 6 7 ]             6 7 5 ] when shifting to the left
%
% The last element in each row is normally filled in with the value that has
% been shifted out of the first cell.  However, if optional parameter
% NEWVALUE is set, the last element is filled in with NEWVALUE.
% e.g., if NEWVALUE is 0, [2,3,4;5,6,7] shifts to [3,4,0;6,7,0]
%
% This could be expanded to support N-D matrices but I haven't done it yet.
%
% 11.24.09 - S.Fraundorf
% 08.21.12 - S.Fraundorf - updated the error message

function newmatrix = horizshift(oldmatrix, direction, newvalue)

if ndims(oldmatrix) > 2
   error('CogToolbox:horizshift:NDimensionalMatrix', ...
       'N-dimensional matrices not yet implemented for this function.');
else

 if nargin < 2
     direction = 0; % to the left, to the left
 end

 newmatrix=zeros(size(oldmatrix)); % reserve space for the new matrix
 matrixsize=size(oldmatrix);

 if ~direction % haters to the left
     for i=1:matrixsize(1) % do this for EACH ROW separately
         if nargin<3
             lastcell = oldmatrix(i,1); % get the cell we're shifting out
         else
             lastcell = newvalue; % user has a value they want to put into the last cell
         end
        
        % shift the cells
         for j=1:matrixsize(2)-1 % SKIP the last cell which gets filled in separately
             newmatrix(i,j) = oldmatrix(i,j+1);
         end
         newmatrix(i,matrixsize(2)) = lastcell;
     end
    
 else % might makes right
     for i=1:matrixsize(1) % do this for EACH ROW separately
         if nargin<3
             lastcell = oldmatrix(i,matrixsize(2)); % get the cell we're shifting out
         else
             lastcell = newvalue; % user has a value they want to put into the last cell
         end
         
         % shift the cells
         for j=matrixsize(2):-1:2 % SKIP the last cell which gets filled in separately
             newmatrix(i,j) = oldmatrix(i,j-1);
         end
         newmatrix(i,1) = lastcell;
     end
 end

end