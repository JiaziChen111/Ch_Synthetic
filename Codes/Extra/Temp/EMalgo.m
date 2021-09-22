function [logllk,mu_y,A,R,mu_x,Phi,Q,xs,Ps] = EM_algo(y,p)
% An EM algorithm is used to compute MLE estimates of mu_x,Phi,Q,mu_y,A and R in
% x_t = mu_x + Phi*x_{t-1} + w_t, cov(w) = Q
% y_t = mu_y +    A*x_t    + v_t, cov(v) = R
% where y is a q*n vector of observables and x is a p*n vector of unobserved states.

% Initial E step
maxIter = 2000;     tol = 1e-4;
logllk  = -inf(1,maxIter);
[mu_y,A,R,mu_x,Phi,Q] = EM_init(y,p);
%%
for iter = 2:maxIter
    % E-step
    [logllk(iter),xs,Ps,Pslag] = EM_Estep(y,mu_y,A,R,mu_x,Phi,Q);
    
    % Check log likelihood for convergence
    if abs(logllk(iter)-logllk(iter-1)) < tol*abs(logllk(iter-1)); break; end
    
    % M-step
    [mu_y,A,R,mu_x,Phi,Q] = EM_Mstep(y,xs,Ps,Pslag);
end
logllk = logllk(2:iter);

% Report convergence
if iter > maxIter
  fprintf(1, 'EM algorithm failed to converge after %d iterations.\n', maxIter);
else
  fprintf(1, 'EM algorithm converged after %d iterations.\n', iter-1);
end
