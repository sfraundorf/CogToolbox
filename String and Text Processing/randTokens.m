% [newlabels, oldlabels]=randTokens(tokenstring,seedstream)
%
% Takes in a string that contains tokens separated by spaces and returns a
% string that randomizes the order of the tokens. 
% For example, the line:
%    randTokens('This is a sentence')
%
% could return:
%    is This sentence a
%
% The function uses textscan to tokenize the string. If seedstream is not
% used, then the function will set the stream to use the current time as a
% seed and then return the stream to the old seed value.
%
% 02.21.14 - T.Lam

function [newlabels, oldlabels]=randTokens(tokenstring,seedstream)

if(nargin<2)
    seedstream = RandStream('mt19937ar','seed',sum(100*clock)); % If no stream is specified, creates a seed stream based on current time.
end
oldseedstream=RandStream.getGlobalStream; % stores to previous seed stream
oldlabels=tokenstring;
gridcell=textscan(tokenstring,'%s');
numItems=length(gridcell{1});
RandStream.setGlobalStream(seedstream); % updates the seed stream.
randgrid=randperm(numItems);
newlabels='';
for i=1:length(randgrid);
    if(i<length(randgrid))
        newlabels=[newlabels, gridcell{1}{randgrid(i)}, ' '];
    else
        newlabels=[newlabels,gridcell{1}{randgrid(i)}];
    end
end
RandStream.setGlobalStream(oldseedstream); % sets stream back to previous value.