function [Phi,A,Q,R,mu_x,mu_y] = model(Phi,A,Q,R,mu_x,mu_y)
% MODEL Transform parameters from the general state space form calculated
% by the EM algorithm into model-specific parameters

% m-files called: modelparams
% Pavel Solís (pavel.solis@gmail.com), May 2020
%%
% Identify parameters to be estimated
parval(1) = Phi(1,1);
parval(2) = Q(1,1);
parval(3) = Q(2,2);
parval(4) = R;

% Define model-specific parameters
[Phi,A,Q,R,mu_x,mu_y] = modelparams(parval);