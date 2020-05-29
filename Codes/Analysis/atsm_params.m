function [Phi,A,Q,R,mu_x,mu_y] = atsm_params(parest)
% ATSM_PARAMS Define parameters for affine term structure model

% Pavel Solís (pavel.solis@gmail.com), May 2020
%%
% Define parameters of the model not being estimated
mu_y = zeros(1,1);
mu_x = zeros(4,1);
A    = [1,1,0,0];
Q    = zeros(4); 
Phi  = zeros(4);
Phi(2,:) = [0,-1,-1,-1];
Phi(3,:) = [0,1,0,0];
Phi(4,:) = [0,0,1,0];

% Define parameters of the model to be estimated
Phi(1,1) = parest(1);
Q(1,1)   = parest(2);
Q(2,2)   = parest(3);
R        = parest(4);