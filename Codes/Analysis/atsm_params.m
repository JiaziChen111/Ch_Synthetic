function [mu_x,mu_y,Phi,A,Q,R] = atsm_params(parest,maturities,dt)
% ATSM_PARAMS Define parameters for affine term structure model
% Parameters vectorized in parest: PhiP;Sgm;lmbd1;lmbd0;mu_xP;rho1;rho0;sgmY;sgmS

% m-files called: parest2vars, loadings
% Pavel Solís (pavel.solis@gmail.com), May 2020
%%
% Identify maturities of yields and surveys
matsY = maturities(1:8);                                        % maturities of yields
matsS = maturities(9:end);                                      % maturities of surveys
matsF = matsS + 3/12;                                         	% mats2 + tenor of rate in surveys
% matsF = matsS + 3;                                              % mats2 + tenor (in months) of rate in surveys
q1    = length(matsY);                                          % q = q1 + q2
q2    = length(matsS);

[PhiP,Sgm,lmbd1,lmbd0,mu_xP,rho1,rho0,sgmY,sgmS] = parest2vars(parest);

% Loadings for yields
mu_xQ = mu_xP - chol(Sgm,'lower')*lmbd0;
PhiQ  = PhiP  - chol(Sgm,'lower')*lmbd1;
[AnQ,BnQ] = loadings(matsY,mu_xQ,PhiQ,Sgm,rho0,rho1,dt);        % AnQ: 1*q1, BnQ: p*q1
% [AnQ,BnQ] = loadings4ylds(matsY,mu_xQ,PhiQ,Sgm,rho0,rho1,dt);   % AnQ: 1*q1, BnQ: p*q1

% Loadings for forward rates (to match survey forecasts)
[~,~,ApE,BpE] = loadings(matsS,mu_xP,PhiP,zeros(size(Sgm)),rho0,rho1,dt);
AnmE = -ApE./(matsF - matsS);
BnmE = -BpE./(matsF - matsS);
% [AnE,BnE] = loadings4ylds(matsS,mu_xP,PhiP,zeros(size(Sgm)),rho0,rho1,dt);
% [AmE,BmE] = loadings4ylds(matsF,mu_xP,PhiP,zeros(size(Sgm)),rho0,rho1,dt);
% AnmE = (matsF.*AmE - matsS.*AnE)./(matsF - matsS);
% BnmE = (matsF.*BmE - matsS.*BnE)./(matsF - matsS);

% Loadings for yields and forward rates
AnQE = [AnQ,AnmE];                                              % 1*q = [1*q1 1*q2]
BnQE = [BnQ,BnmE];                                              % p*q = [p*q1 p*q2]

% Parameters in state space form
mu_x = mu_xP;                                                   % p*1
mu_y = AnQE';                                                   % q*1
Phi  = PhiP;                                                    % p*p
A    = BnQE';                                                   % q*p
Q    = Sgm;                                                     % p*p
R    = diag([repmat(sgmY^2,q1,1); repmat(sgmS^2,q2,1)]);       	% q*q