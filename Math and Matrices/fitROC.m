function fittedParams=fitROC(hitData, faData)
% 
%   fittedParams=fitROC(old, new)
% 
% returns mle fits for a standard signal detection model.  hitData is a
% subsXrating matrix for the old items containing the frequency of each
% response, faData is a matrix of the same size for the novel items.
% Higher columns correspond to higher confidence.
% 
% Updated 01.21.08 M.Diaz
% Updated 08.12.08 M.Diaz

% output will be mu, sigma, criteria
% DO NOT transform with EXP-- it's already sigma!!

if any(size(hitData) ~= size(faData)) %check for right input size
    if size(hitData,1) ~=  size(faData,1)
        error('inputs have different # of subs')
    else
        error('inputs have different # of ratings')
    end
end

fun=@negLogLike; %handle to the likelihood function to be maximized
opts=optimset('MaxFunEvals', 2^18 ,'MaxIter' ,2^18 ); %fitting options

[nSubs n]=size(hitData);
fittedParams=zeros(nSubs,n+1);

XY=zeros(n,2); %used for starting params estimates

for s=1:nSubs
    d=[hitData(s,:),faData(s,:)];
    
    d=d+1/n; %log-linear corrections....used to deal with zeros
    
    %calculate starting parameters using simple regression
    XY=reshape(d,n,2); 
    XY=norminv(1-cumsum(XY*diag(1./sum(XY))),0,1); %converts freq to reverse cumulative proportions
    beta=[ones(n-1,1) XY(1:n-1,2)]\XY(1:n-1,1); %simple regression
    params=[beta(1)/beta(2) log(1/beta(2)) XY(n-1:-1:1,2)']; %[mu log(sig) criteria]
    
    %use fminsearch to find params that MIN NEG-log-likelihood
    
    fittedParams(s,:)=fminsearch(@(p)fun(d,p),params,opts);
    fittedParams(s,2)=exp(fittedParams(s,2));
end

function neglike=negLogLike(data, params)
%
%     neglike = rocLogLike(data, params)
% 
% data is an (2n X 1) vector of n frequencies for old stacked on n
% frequencies for new.  mu and sig are scalars.  cs is a vector of n-1
% criteria.  This function can serve as the pdf function for an mle of ROC
% parameters .

%get all params
mu=params(1);
muN=-mu/2; %mean of noise (arbitrary)
sig=exp(params(2));
cs=[params(3:end)]+muN;

n=length(data)/2;

%calculate predicted propotions of hits and FA
dataHat=zeros(1,2*n);
dataHat(1:n)=diff([0,normcdf(cs,mu+muN,sig),1]); %predicted hits
dataHat(n+1:2*n)=diff([0,normcdf(cs,muN,1),1]);  %predicted FA

%predicted proportions must be strictly greater than zero
if min(dataHat)<=0 
    neglike=realmax; %smallest possible likelihood
    return
end

%likelihood(data) = multinomial(data)
neglike=-data*log(dataHat)';
if isnan(neglike) 
    neglike=realmax;
end