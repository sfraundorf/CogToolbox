% InitExperiment
%
% Does a few basic tasks needed at the start of an experiment:
% 1) initializes the random number generator
% 2) turns off the DeprecatedLogicalAPI warning
% 3) sets the global pixelSize.  pixelSize is hardcoded and needs to be set
%     to a value appropriate to the machine it is on
% 4) defines the colors white and black
%
% 11.06.06 - M.Diaz
% 01.31.10 - S.Fraundorf - uses the current rand('twister')

rand('twister',sum(100*clock)); 
warning off MATLAB:DeprecatedLogicalAPI

global pixelSize
pixelSize=32;

white=[255 255 255];
black=[0 0 0];