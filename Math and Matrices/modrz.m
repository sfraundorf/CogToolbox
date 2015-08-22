% n = modrz(x,y)
%
% Modulus after division, with reassignment of zeros.
%
% Returns mod(x,y) for all mod(x,y) ~= 0.  If mod(x,y) == 0, returns y
% rather than 0.
%
% Thus, modrz(x,4) is 1, 2, 3, or 4, rather than 1, 2, 3, or 0.
%
% 02.05.11 - S.Fraundorf - first version

function n = modrz(x,y)

n = mod(x,y);
if n == 0
    n = y;
end