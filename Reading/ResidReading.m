% [RRTs beta meanlength] = ResidReading(RTs,regionlength,ztransform,trim)
%
% Calculates residual reading time for participant's reading time
% to a set of items.  Residual reading time (Ferreira & Clifton, 1986) is a
% measure of reading time that controls for 
%   (a) Baseline response time
%   (b) The length of each region (in # of characters)
%
% The inputs are RT and REGIONLENGTH, where RT contains the participant's
% reading items for each region of each item, and REGIONLENGTH contains the
% # of characters in each region.  Note that this is the output from
% movingwindow.m; you just need to combine each item together.
%
% Each of RT and REGIONLENGTH may take either of two forms:
%   (a) an N x R matrix, where N is the number of items and R the number of
%       regions per item
%   (b) a N x 1 cell array of vectors, where N is the number of items
%
% If your items are of DIFFERENT LENGTHS, you will have a different number
% of RTs per item.  In this case, it's easiest to store the RTs from each
% item as a vector within a cell array.  (A matrix is not a good choice
% because MATLAB requires each row in a matrix to be the same length.)
%
% If optional parameter ZTRANSFORM is set to 1, the resulting residual
% reading times are also z-transformed.  Z-transforming the RRTs is a way to
% control for SCALING issues.  That is, people with longer reading times
% (in general) will generally also have larger residual reading times.
% A z-transform rescales things in terms of standard deviations.
%
% If optional parameter TRIM is set, reading times more than TRIM standard
% deviations from the mean are trimmed and replaced with TRIM, and *then*
% the residual reading times are calculated.  For example, setting TRIM to
% 3 replaces all reading times > 3 SDs or < 3 SDs from the mean with
% M +/- 3 SDs.
%
% Reading times of 0 or less are assumed to represent MISSING DATA and
% are ignored.
%
% Optional additional return values include the beta values from the
% regression equation (in a 2x1 vector) and the mean region length.  The
% first element of BETA is the intercept (mean reading time across all
% regions) and the second element is the beta weight for region length
% (i.e., the effect of a 1-unit deviation from mean region length).
%
% This function requires MATLAB's Statistics Toolbox.  If that toolbox is
% not installed, a warning message is displayed and all residual reading
% times are returned as NaN values.
%
% 04.02.10 - S.Fraundorf - first version
% 07.09.10 - S.Fraundorf - turned into a function
% 07.12.10 - S.Fraundorf - deal with items of varying length
% 07.13.10 - S.Fraundorf - fixed a weird crash
% 01.06.11 - S.Fraundorf - fails gracefully if Statistics Toolbox not
%                          installed.  negative RTs are also assumed to be
%                          missing data.
% 01.07.11 - S.Fraundorf - accepts a cell array of vectors of RTs and length
%                          as input.  this is useful when your items are of
%                          different length and RTs can't easily be fit
%                          into a matrix
% 01.07.11 - S.Fraundorf - Option to return betas of the regression
%                          equation.  Regression is now calculated on
%                          mean-centered region lengths so the intercept of
%                          the equation = mean reading time across all
%                          items.

function [RRTs beta meanlength] = ResidReading(RTs,regionlength,ztransform,trim)

%% CHECK INPUT ARGUMENTS
if nargin < 3
    ztransform = 0; % default to NOT z-transforming
elseif nargin > 3 && trim <= 0
    error('CogToolbox:ResidReading:TrimNotPositive', 'TRIM must be a positive # of SDs.');
end

%% CONVERT CELL ARRAYS TO MATRICES
% if inputs are cell arrays of vectors, change each to a matrix
if iscell(RTs)
    RTs = RaggedCellArrayToMatrix(RTs,0);
end
if iscell(regionlength)
    regionlength = RaggedCellArrayToMatrix(regionlength,0);
end

%% CHECK TO MAKE SURE STATISTICS TOOLBOX IS INSTALLED
if exist('regress','file') ~= 2
    % regress function is not available
    % fill the RRTs with NaN values
    RRTs = repmat(nan,size(RTs));    
    % same for the betas
    beta = [nan nan];
    % display the warning
    warning('CogToolbox:ResidReading:NoRegress', ...
        ['Cannot calculate residual reading times because the MATLAB Statistics Toolbox is not installed.\n'...
        'Residual reading times will be output as NaN (Not A Number).']);
    return
end
% the warning message keeps the whole program from crashing if the toolbox
% isn't installed

%% REMOVE 0 RTs
% Reshape the matrices into vectors -- needed for regress()
tempRTs = RTs(:);
allRTs = tempRTs(tempRTs > 0); % DROP zero RTs

% Get the equivalent region lengths
tempLengths = regionlength(:);
allLengths = tempLengths(tempRTs > 0);
clear tempRTs tempLengths;

% Get the total number of (non-missing) observations
numobs = numel(allRTs);

%% TRIM OUTLYING RTs FIRST, IF REQUESTED
if nargin > 3
    % calculate mean & std dev of RTs
    RTmean = mean(allRTs);
    RTstd = std(allRTs);
    
    % calculate max/min reading time allowed
    maxallowed = RTmean + (RTstd * trim);
    minallowed = RTmean - (RTstd * trim);
    
    % replace outliers with these values
    RTs(RTs > maxallowed) = maxallowed;
    RTs(RTs < minallowed & RTs > 0) = minallowed; % don't replace the 0 RTs which will get change to NaNs later
end

%% CALCULATE RESIDUAL READING TIMES

% Mean center the region length so the intercept of the regression equation
% represents baseline reading time:
meanlength = mean(allLengths);
allLengths = allLengths - meanlength;

% Create the design matrix for the regression:
designmatrix = horzcat(ones(numobs,1), allLengths); % the 1s are for the INTERCEPT in the design matrix

% Do the regression
beta = regress(allRTs,designmatrix);

% Get the residuals
regiondev = regionlength - meanlength; % convert region lengths to deviations from the mean
RRTs = RTs - beta(1) - (regiondev .* beta(2)); % compute residuals
% we can't use the residuals from regress because we need to go back to the
% original matrix, rather than the vector

% To find missing data:
waszero = -1 * beta(1) - ((0-meanlength) .* beta(2)); % anything with this value used to be a 0 reading time

%% Z-SCORE
% Z-score if requested
if ztransform
    
    % calculate std.dev, excluding missing data
    allRRTs = RRTs(:);
    allRRTs = allRRTs(allRRTs ~= waszero); % drop zero RRTs
    RRTstd = std(allRRTs);
    
    % divide by this
    RRTs = RRTs ./ RRTstd;    
    % mean is ALREADY zero, so we don't need to factor this in
    
    % Find everything that used to be a 0 RT and change it to a NaN
    waszero = waszero ./ RRTstd; % update this since we z-scored
end
    
%% HANDLE MISSING DATA
RRTs(RRTs == waszero) = NaN;
% Find everything that used to be a 0 RT and change it to a NaN