% neworder = randorder(avector)
% 
% Puts the elements of vector AVECTOR in a completely random order.
%
% Right now this only supports vectors not matrices.
%
% 11.24.09 - S.Fraundorf
% 08.21.12 - S.Fraundorf - updated error message

function neworder = randorder(avector)

if ndims(avector) > 2 || isempty(find(size(avector)==1, 1))
    error('CogToolbox:randorder:RandorderOnMatrix', ...
        'randorder works on vectors only, not matrices.');
else
    neworder = avector(randperm(numel(avector)));
end