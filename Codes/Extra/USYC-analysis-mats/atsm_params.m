function [mu_x,mu_y,Phi,A,Q,R] = atsm_params(parest,maturities,dt)
% ATSM_PARAMS Define parameters for affine term structure model
% Parameters vectorized in parest: PhiP;Sgm;lmbd1;lmbd0;mu_xP;rho1;rho0;sgmY;sgmS

% m-files called: parest2vars, loadings
% Pavel Solís (pavel.solis@gmail.com), May 2020
%%
% Identify maturities of yields and surveys
matsY = maturities(1:8);                                        % maturities of yields
matsS = maturities(9:end);                                      % maturities of surveys
q1    = length(matsY);                                          % q = q1 + q2
q2    = length(matsS);

[PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0,sgmY,sgmS] = parest2vars(parest);

% Loadings for yields
Hcov  = cSgm*cSgm';
mu_xQ = mu_xP - chol(Hcov,'lower')*lmbd0;
PhiQ  = PhiP  - chol(Hcov,'lower')*lmbd1;
[AnQ,BnQ] = loadings(matsY,mu_xQ,PhiQ,Hcov,rho0,rho1,dt);      	% AnQ: 1*q1, BnQ: p*q1

if ~isempty(matsS)
    % Loadings for survey yields
    [AnS,BnS] = loadings(matsS,mu_xP,PhiP,zeros(size(Hcov)),rho0,rho1,dt);
    
    % Loadings for forward rates to match survey forecasts (use log-price loadings)
    % matsN = maturities(9:end);                             	% define starting date of forward rate
    % matsM = matsN + 3/12;                                 	% define ending date of forward rate
    % [~,~,ApN,BpN] = loadings(matsN,mu_xP,PhiP,zeros(size(Hcov)),rho0,rho1,dt);
    % [~,~,ApM,BpM] = loadings(matsM,mu_xP,PhiP,zeros(size(Hcov)),rho0,rho1,dt);
    % AnS = (-ApM - (-ApN))./(matsM - matsN);
    % BnS = (-BpM - (-BpN))./(matsM - matsN);
    
    % Loadings for bond yields and survey yields
    AnQ = [AnQ,AnS];                                            % 1*q = [1*q1 1*q2]
    BnQ = [BnQ,BnS];                                        	% p*q = [p*q1 p*q2]
end

% Parameters in state space form
mu_x = mu_xP;                                                   % p*1
mu_y = AnQ';                                                    % q*1
Phi  = PhiP;                                                    % p*p
A    = BnQ';                                                    % q*p
Q    = Hcov;                                                    % p*p
if     isempty(sgmY) && isempty(sgmS)                           % q*q
    R = zeros(q1);                                              % this case causes problems
elseif isempty(sgmS)
    R = diag([repmat(sgmY^2,q1,1); repmat(0.0075^2,q2,1)]);     % fixed sgmS case
    % R = diag(repmat(sgmY^2,q1,1));                            % yields only case
else
    R = diag([repmat(sgmY^2,q1,1); repmat(sgmS^2,q2,1)]);
end