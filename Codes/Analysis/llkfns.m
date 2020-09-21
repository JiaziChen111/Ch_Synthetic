function [llk,llks] = llkfns(parest,y,x00,P00,matsY,matsS,dt)
% LLKFN Return the overall log-likelihood and individual log-likelihoods 
% computed by the Kalman filter. Note: They are *not* minus log-likelihoods

% m-files called: atsm_params, Kfs
% Pavel Solís (pavel.solis@gmail.com), September 2020
%%
[mu_x,mu_y,Phi,A,Q,R] = atsm_params(parest,matsY,matsS,dt);                 % get model parameters
[llk,~,~,~,~,~,~,~,~,~,~,~,~,llks] = Kfs(y,mu_x,mu_y,Phi,A,Q,R,x00,P00);    % calculate the log-likelihoods