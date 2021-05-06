function [Ay,By] = loadings4ylds(mats,mu,Phi,Hcov,rho0dt,rho1dt,dt)
% This function calculates the annualized loadings for bond yields of 
% different maturities.
% 
% INPUT
% mats     : 1*M
% mu       : F*1
% Phi      : F*F
% Hcov     : F*F
% rho0dt   : scalar
% rho1dt   : F*1
% dt       : time period expressed in years (e.g. dt = 1/12 for monthly data)
% 
% OUTPUT
% Ay       : 1*M
% By       : F*M
% 
% ASSUMPTIONS
% M        : number of maturities
% F        : number of factors or state variables
% T        : number of observations
% X(t)     : F*1
% r(t)     : scalar
% yields   : 1*M
% Important: r(t) and yields are decimals
% 
% The dynamics of the state variables are given by
%       X(t+1) = mu + Phi*X(t) + eps(t+1), Cov(eps(t+1)) = Hcov
% The dynamics for the one-period (dt) discount rate are given by
%       r(t)   = rho0dt + rho1dt'*X(t); rho0dt and rho1dt are in per period units (e.g. rho0dt = rho0*dt)
% Note: yields = Ay + X(t)'*By but if X(t) is T*F, yields are T*M: yields = ones(T,1)*Ay + X(t)*By
% 
% Pavel Solís (pavel.solis@gmail.com), May 2019
%%
F  = length(mu);        maxM = max(mats);
Ay = nan(1,maxM);       An   = 0;
By = nan(F,maxM);       Bn   = zeros(F,1);

for k  = 1:maxM
    % Loadings for prices
    An = -rho0dt + An + mu'*Bn + 0.5*Bn'*Hcov*Bn;
    Bn = -rho1dt + Phi'*Bn;
    
    % Annualized loadings for yields
    yrs     = k*dt;
    Ay(1,k) = -An/yrs; 
    By(:,k) = -Bn/yrs;
end

Ay = Ay(1,mats);
By = By(:,mats);