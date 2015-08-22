% newvector = reversevector(oldvector)
%
% Puts the elements of vector OLDVECTOR in reverse order.
%
% 12.31.09 - S.Fraundorf
% 12.07.10 - S.Fraundorf - improved efficiency
% 08.21.12 - S.Fraundorf - updated error messages

function newvector=reversevector(oldvector)

%% check this is a 1-dimensional vector
if ndims(oldvector) > 2
    error('CogToolbox:reversevector:Not1Dim', 'must be single-dimension vector')
elseif numel(find(size(oldvector)>1)) > 1
    error('CogToolbox:reversecector:Not1Dim', 'must be single-dimension vector')
end

%% reverse
newvector = oldvector(numel(oldvector):-1:1);
