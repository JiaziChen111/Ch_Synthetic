function [Ay,By] = yld_loadings(mats,mu,Phi,Hcov,rho0dt,rho1dt,dt)
% Calculates the annualized loadings for bond yields of different maturities.
% 
% INPUT
% mats    : 1*M
% mu      : F*1
% Phi     : F*F
% Hcov    : F*F
% rho0dt  : scalar
% rho1dt  : F*1
% dt      : time period expressed in years (e.g. dt = 1/12 for monthly data)
% 
% OUTPUT
% Ay      : 1*M
% By      : F*M
% 
% ASSUMPTIONS
% M       : number of maturities
% F       : number of factors
% T       : number of observations
% X(t)    : T*F
% r(t)    : scalar
% yields  : T*M
% 
% The dynamics of the state variables are given by
%       X(t+1) = mu + Phi*X(t) + eps(t+1), Cov(eps(t+1)) = Hcov
% The one-period (dt) discount rate is given by
%       r(t)   = rho0dt + rho1dt'*X(t); rho0dt and rho1dt are in per period units (e.g. rho0dt = rho0*dt)
%       yields = ones(T,1)*Ay + X(t)*By
% 
% Pavel Solís (pavel.solis@gmail.com), May 2019
%%
% M  = length(mats);
F  = length(mu);
% Ay = nan(1,M);      An = 0;
% By = nan(F,M);      Bn = zeros(F,1);
% curr_mat = 1;

Mmat = max(mats);
Ay = nan(1,Mmat);      An = 0;
By = nan(F,Mmat);      Bn = zeros(F,1);
% An = nan(1,Mmat);
% Bn = nan(F,Mmat);

for k  = 1:Mmat%mats(M)
    % Loadings for prices for every period
    An = -rho0dt + An + mu'*Bn + 0.5*Bn'*Hcov*Bn;
    Bn = -rho1dt + Phi'*Bn;
    
    yrs = k*dt;
    Ay (1,k) = -An/yrs; By(:,k) = -Bn/yrs;
    % Loadings for yields at specified maturities
%     if k == mats(curr_mat)
%         [An mats(curr_mat)]
%         [Bn' mats(curr_mat)]
%         Ay(1,curr_mat) = -An/-1;%mats(curr_mat);
%         By(:,curr_mat) = -Bn/-1;%mats(curr_mat);
%         curr_mat = curr_mat + 1;
%     end
end

% % Annualized loadings for yields
% Ay = Ay/dt;
% By = By/dt;
Ay = Ay(1,mats);
By = By(:,mats);
