function [b0hat, b1hat, Qhat] = VAR1(Z)
% This function computes the OLS/MLE estimates of the parameters in a VAR(1)
% model.
% 
% INPUT
% Z     : T*K
% 
% OUTPUT
% b0hat : K*1
% b1hat : K*K
% Qhat  : K*K
% 
% ASSUMPTIONS
% T     : number of observations
% K     : number of variables
% 
% The dynamics of the variables in Z are given by (note that z is K*1)
%   z(t+1) = b0 + b1*z(t) + eps(t+1), cov(eps(t+1)) = Q
% 
% Pavel Solís (pavel.solis@gmail.com), May 2019
%%
T     = size(Z,1);
X     = [ones(T-1,1) Z(1:end-1,:)];         % (T-1)*(K+1)
Y     = Z(2:end,:);                         % (T-1)*K
bhat  = (X'*X)\(X'*Y);                      % (K+1)*K
b0hat = bhat(1,:)';                         % K*1
b1hat = bhat(2:end,:)';                     % K*K
eps   = Y - X*bhat;                         % (T-1)*K
Qhat  = eps'*eps/(T-1);                     % K*K
 