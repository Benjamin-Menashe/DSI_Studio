function [score, tcrt2] = crawfordReverse_benj(vec,tail,alpha,varargin)
% this function takes a vec of scores from the control group and returns
% the significant score or scores which beyond them the subject would be
% significantly different than the control population (in the appropriate
% alpha value). 

% IMPORTANT : for one-tailed tests, the function returns both upper and
% lower tails, bt only the one which you wrote in your hpothesis is the one
% you must use, and you MUST ignore the other!

% defaults tail = two-tailed, alpha=0.05
score = [0 0];

% set defaults
if nargin==1
    alpha=0.05;
    tail = 2;
elseif nargin==2
    alpha=0.05;
end

% get values
X = mean(vec);
SD = std(vec);
N = length(vec);
df = N-1;

if tail == 2 % for two-tailed tests we cut the alpha by half
        alpha = alpha/2;
end

% calculate lower and upper values
tcrt1 = tinv(alpha,df);
score(1) = X+tcrt1*SD*sqrt((N+1)/N);
tcrt2 = tinv(1-alpha,df);
score(2) = X+tcrt2*SD*sqrt((N+1)/N);

end