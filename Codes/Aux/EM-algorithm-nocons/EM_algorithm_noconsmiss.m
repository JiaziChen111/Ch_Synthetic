function [Phi,A,Q,R,xs,Ps,llk,iter,cvg] = EM_algorithm(y,Phi,A,Q,R,x00,P00,maxiter,tol)
% EM_ALGORITHM Estimate parameters and state of time-invariant state space models
% 
% INPUTS
% y       : q*n matrix of measurements
% Phi     : p*p state transition matrix
% A       : q*p measurement matrix
% Q       : p*p state error covariance matrix
% R       : q*q measurement error covariance matrix
% xf0     : p*1 initial state mean vector
% Pf0     : p*p initial state covariance matrix
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
% like	  : log-likelihood at each iteration
% iter	  : number of iterations to convergence
% cvg     : relative tolerance at convergence

% Pavel Solís (pavel.solis@gmail.com), May 2020
%%
p     = size(Phi,1);
[q,n] = size(y);
cvg   = 1 + tol;
llk   = zeros(maxiter,1);

for iter = 1:maxiter
    [llk(iter),~,~,~,~,xs,Ps,xs0n,Ps0n,S11,S10,S00] = Kfs(y,Phi,A,Q,R,x00,P00);
    
    if iter > 1
        cvg = (llk(iter) - llk(iter-1))/abs(llk(iter-1));
    end
    if cvg < 0
        warning('Likelihood is not increasing')
    end
    if abs(cvg) < tol
        sprintf('iteration  %d,  log-likelihood  %0.3f',iter,llk(iter))
        break
    end
    
    x00   = xs0n;
    P00   = Ps0n;
    Phi   = S10/S00;                                        % smoothers calculated from parameters at iter-1
    Q     = (S11 - Phi*S10')/n;                         	% use Phi from this iteration
    delta = zeros(q,p);
    for t = 1:n
        delta = delta + y(:,t)*xs(:,t)';
    end
    A = delta/S11;
    
    for t = 1:n                                             % use A from this iteration
        v = y(:,t) - A*xs(:,t);                             % innovation
        if t == 1
            R = v*v' + A*Ps(:,:,t)*A';
        else
            R = R + v*v' + A*Ps(:,:,t)*A';
        end
    end
    R = R/n;
end