function [mu_x,mu_y,Phi,A,Q,R,xs,Ps,llk,iter,cvg] = EM_algorithm(y,Phi,A,Q,R,x00,P00,maxiter,tol,mu_x,mu_y)
% EM_ALGORITHM Estimate parameters and state of time-invariant state space models
% 
%               Dynamic linear model with time-invariant coefficients
% transition  : x_t = mu_x + Phi*x_{t-1} + w_t, cov(w) = Q
% measurement : y_t = mu_y +   A*x_t     + v_t, cov(v) = R
% dimensions  : p states, q measurements, n observations
% 
% INPUTS
% y       : q*n matrix of measurements
% Phi     : p*p state transition matrix
% A       : q*p measurement matrix
% Q       : p*p state error covariance matrix
% R       : q*q measurement error covariance matrix
% x00     : p*1 initial state mean vector
% P00     : p*p initial state covariance matrix
% maxiter : maximum number of iterations
% tol     : relative tolerance for determining convergence
% mu_x    : p*1 transition intercept (optional)
% mu_y    : q*1 measurement intercept (optional)
% 
% OUTPUT
% mu_x    : estimate of mu_x
% mu_y    : estimate of mu_y
% Phi     : estimate of Phi
% A       : estimate of A
% Q       : estimate of Q
% R       : estimate of R
% xs      : smoothed estimate of state
% Ps      : smoothed estimate of state covariance matrix
% llk	  : log-likelihood at each iteration
% iter	  : number of iterations to convergence
% cvg     : relative tolerance at convergence

% Pavel Solís (pavel.solis@gmail.com), May 2020
%%
p     = size(Phi,1);
[q,n] = size(y);
cvg   = 1 + tol;
llk   = nan(maxiter,1);
miss  = isnan(y);                                           % keep record of missing data
yt    = y;   yt(miss) = 0;                                 	% y may contain NaNs, yt replace them w/ zeros

for iter = 1:maxiter
    if nargin < 11; mu_y = zeros(q,1); end                  % keep constants at zero if not supplied
    if nargin < 10; mu_x = zeros(p,1); end
    
    % E-step (output accounts for missing data eg. smoothers, uses y)
    [llk(iter),~,~,~,~,xs,Ps,x0n,P0n,S11,S10,S00,Syx] = Kfs(y,Phi,A,Q,R,x00,P00,mu_x,mu_y);
    
    % Determine convergence
    if iter > 1
%         cvg = (llk(iter) - llk(iter-1))/abs(llk(iter-1));
        cvg = (llk(iter-1) - llk(iter))/abs(llk(iter-1)); % when using -llk
    end
    if cvg < 0
        warning('Likelihood stopped increasing at iteration %d, log-likelihood %0.3f',iter,llk(iter))
        break
    end
    if abs(cvg) < tol
        sprintf('Convergence at iteration %d, log-likelihood %0.3f',iter,llk(iter))
        break
    end
    
    % M-step (accounts for missing data in A and R, uses yt and smoothers from this iteration)
    x00   = x0n;
    P00   = P0n;
%     Phi   = S10/S00;                                      	% smoothers calculated from parameters at iter-1
%     Q     = (S11 - Phi*S10')/n;                           	% use 
%     A     = Syx/S11;                                      	% comment if A is not to be estimated
    
    mu_x  = S10(:,1)/S00(1,1);
    Phi   = S10(:,2:p+1)/S00(2:p+1,2:p+1);                	% Phi = S10/S00;
    Q     = (S11(2:p+1,2:p+1) - Phi*S10(:,2:p+1)')/n;       % Q = (S11 - Phi*S10')/n;
    Rlast = R;                                              % use R from previous iteration for missing obs
    for t = 1:n
        At   = A; At(miss(:,t),:) = 0;                    	% account for missing observations
        v    = yt(:,t) - (mu_y + At*xs(:,t));               % innovation
        R22t = diag(miss(:,t))*Rlast;                     	% zero matrix if no missing observations
        if t == 1
            R = v*v' + At*Ps(:,:,t)*At' + R22t;
        else
            R = R + v*v' + At*Ps(:,:,t)*At' + R22t;
        end
    end
    R    = R/n;
    R  = diag(diag(R));                                   % S&S report this for missing data
    mu_y = Syx(:,1)/S11(1,1);                               % mu_y and A computed after R
%     A    = Syx(:,2:p+1)/S11(2:p+1,2:p+1);                	% A = Syx/S11;
end
llk(isnan(llk)) = [];