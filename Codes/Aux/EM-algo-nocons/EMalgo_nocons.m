function [Phi,A,Q,R,xs,Ps,llk,iter,cvg] = EM_algorithm(y,Phi,A,Q,R,x00,P00,maxiter,tol)
% EM_ALGORITHM Estimate parameters and state of time-invariant state space models
% 
% INPUTS
% [p,q,n] : p states, q measurements, n observations
% y       : q*n matrix of measurements
% Phi     : p*p state transition matrix
% A       : q*p measurement matrix
% Q       : p*p state error covariance matrix
% R       : q*q measurement error covariance matrix
% x00     : p*1 initial state mean vector
% P00     : p*p initial state covariance matrix
% maxiter : maximum number of iterations
% tol     : relative tolerance for determining convergence
% 
% OUTPUT
% Phi     : Estimate of Phi
% A       : Estimate of A
% Q       : Estimate of Q
% R       : Estimate of R
% xs      : Smoothed estimate of state
% Ps      : Smoothed estimate of state covariance matrix
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
    % E-step (output accounts for missing data eg. smoothers, uses y)
    [llk(iter),~,~,~,~,xs,Ps,x0n,P0n,S11,S10,S00] = Kfs(y,Phi,A,Q,R,x00,P00);
    
    % Determine convergence
    if iter > 1
        cvg = (llk(iter) - llk(iter-1))/abs(llk(iter-1));
    end
    if cvg < 0
        warning('Likelihood stopped increasing at iteration %d, log-likelihood %0.3f',iter,llk(iter))
        break
    end
    if abs(cvg) < tol
        sprintf('Convergence at iteration %d, log-likelihood %0.3f',iter,llk(iter))
        break
    end
    
    % M-step (accounts for missing data in A and R, uses yt)
    x00   = x0n;
    P00   = P0n;
    Phi   = S10/S00;                                        % smoothers calculated from parameters at iter-1
    Q     = (S11 - Phi*S10')/n;                         	% use smoothers from this iteration
    
    Rlast = R;                                              % use R from previous iteration for missing obs
    for t = 1:n
        At = A; At(miss(:,t),:) = 0;                    	% account for missing observations
        v  = yt(:,t) - At*xs(:,t);                          % innovation
        Rt = diag(miss(:,t))*Rlast;                         % zero matrix if no missing observations
        if t == 1
            R = v*v' + At*Ps(:,:,t)*At' + Rt;
        else
            R = R + v*v' + At*Ps(:,:,t)*At' + Rt;
        end
    end
    R = R/n;
    % R = diag(diag(R));                                      % S&S report this
    
    delta = zeros(q,p);
    for t = 1:n
        delta = delta + yt(:,t)*xs(:,t)';
    end
    A = delta/S11;                                          % comment if A is not a parameter to be estimated
end
llk(isnan(llk)) = [];