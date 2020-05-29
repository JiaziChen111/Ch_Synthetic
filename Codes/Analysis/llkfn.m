function llk = llkfn(parest,y,x00,P00)
% LLKFN Return the negative log-likelihood computed after the Kalman filter

% m-files called: atsm_params, Kfs
% Pavel Solís (pavel.solis@gmail.com), May 2020
%%
[Phi,A,Q,R,mu_x,mu_y] = atsm_params(parest);            % get model parameters
llk = Kfs(y,Phi,A,Q,R,x00,P00,mu_x,mu_y);               % calculate the log-likelihood
llk = -llk;                                             % return minus log-likelihood