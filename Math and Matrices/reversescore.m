% newscore = reversescore(oldscore,scalesize)
%
% Reverse-scores a Likert scale score OLDSCORE.  SCALESIZE is the number of
% options on the scale (e.g. 7 if it's a 1 to 7 Likert scale).
%
% 04.26.10 - S.Fraundorf - first version
% 06.02.10 - S.Fraundorf - added error checking

function newscore = reversescore(oldscore,scalesize)

if oldscore > scalesize
    error('CogToolbox:reversescore:BiggerThanScale', 'Score is bigger than maximum value on scale.');
elseif oldscore < 1
    error('CogToolbox:reversescore:NotPositiveInteger', 'Score must be a positive integer.');
end
    
newscore = scalesize-oldscore+1;