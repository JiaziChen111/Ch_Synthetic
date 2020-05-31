function llk = llkfn(parest,y,x00,P00,maturities,dt)
% LLKFN Return the negative log-likelihood computed after the Kalman filter

% m-files called: atsm_params, Kfs
% Pavel Solís (pavel.solis@gmail.com), May 2020
%%
[mu_x,mu_y,Phi,A,Q,R] = atsm_params(parest,maturities,dt);	% get model parameters
llk = Kfs(y,mu_x,mu_y,Phi,A,Q,R,x00,P00);                   % calculate the log-likelihood
llk = -llk;                                                 % return minus log-likelihood