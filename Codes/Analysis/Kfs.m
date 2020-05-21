function [llk,xp,Pp,xf,Pf,xs,Ps,Pslag] = Kfs(y,Phi,A,Q,R,mu_x,mu_y)
% Implementation of the Kalman filter and smoother algorithms in
% Time Series Analysis and Its Applications by Shumway & Stoffer
% 
% Dynamic linear model:
% x_t = mu_x + Phi*x_{t-1} + w_t, cov(w) = Q            transition equation
% y_t = mu_y +   A*x_t     + v_t, cov(v) = R            measurement equation
%
% p     : number of state variables
% q     : number of observed variables
% n     : number of observations
% 
% INPUTS
% y     : q*n matrix of observables
% Phi   : p*p transition matrix
% A     : q*p measurement matrix
% Q     : p*p transition covariance
% R     : q*q measurement covariance
% mu_x  : p*1 transition intercept (optional)
% mu_y  : q*1 measurement intercept (optional)
%
% OUTPUT
% llk   : 1*1   (not minus) log-likelihood (includes constant)
% xp    : p*n   matrix of predicted mean of state,       stores Exp[x(t)|y(t-1)]
% Pp    : p*p*n matrix of predicted covariance of state, stores Var[x(t)|y(t-1)]
% xf    : p*n   matrix of filtered mean of state,        stores Exp[x(t)|y(t)]
% Pf    : p*p*n matrix of filtered covariance of state,  stores Var[x(t)|y(t)]
% xs    : p*n   matrix of smoothed mean of state,        stores Exp[x(t)|y(n)]
% Ps    : p*p*n matrix of smoothed covariance of state,  stores Var[x(t)|y(n)]
% Pslag : p*p*n matrix of lag-one covariances of state,  stores Cov[x(t),x(t-1)|y(n)]

% Pavel Solís (pavel.solis@gmail.com), May 2020

%% Premable
% Determine dimensions
p     = size(Phi,1);
[q,n] = size(y);
if nargin < 7; mu_y = zeros(q,1); end
if nargin < 6; mu_x = zeros(p,1); end

% Pre-allocate space
xp  = nan(p,n);     Pp  = nan(p,p,n);       Ip    = eye(p);
xf  = nan(p,n);     Pf  = nan(p,p,n);       J     = nan(p,p,n);	
xs  = nan(p,n);     Ps  = nan(p,p,n);       Pslag = nan(p,p,n);
llk = 0;            S11 = zeros(p,p);

% Initialize recursion with unconditional moments assuming state is stationary x0 ~ N(xf0,Pf0)
xf0 = (Ip - Phi)\mu_x;                                         	% p*1
Pf0 = reshape((eye(p^2)-kron(Phi,Phi))\reshape(Q,p^2,1),p,p);   % p*p
if any(~isreal(eig(Pf0))) || any(eig(Pf0) < 0) || any(isnan(Pf0),'all') || any(isinf(Pf0),'all')
    Pf0 = Ip;                                                   % in case the state is non-stationary
end

%% Estimation: Kalman filter
for t = 1:n
    % Predicting equations
    if t == 1
        xp(:,t)   = mu_x + Phi*xf0;
        Pp(:,:,t) = Phi*Pf0*Phi' + Q;
    else
        xp(:,t)   = mu_x + Phi*xf(:,t-1);
        Pp(:,:,t) = Phi*Pf(:,:,t-1)*Phi' + Q;
    end
    
    v = y(:,t) - (mu_y + A*xp(:,t));                            % innovation
    V = A*Pp(:,:,t)*A' + R;                                     % innovation covariance
    K = Pp(:,:,t)*A'/V;                                         % optimal Kalman gain
    
    % Updating equations
    xf(:,t)   = xp(:,t) + K*v;
    Pf(:,:,t) = (Ip - K*A)*Pp(:,:,t);
    
    % Log-likelihood
    term3 = max(v'/V*v,0);                                      % in case V is non-PSD
    llk   = llk - 0.5*(q*log(2*pi) + log(det(V)) + term3);
end

%% Inference: Kalman smoother
for t = n:-1:1
    if t == n
        xs(:,t)   = xf(:,n);
        Ps(:,:,t) = Pf(:,:,n);
        continue
    end
    
    J(:,:,t+1) = Pf(:,:,t)*Phi'/Pp(:,:,t+1);
    xs(:,t)    = xf(:,t) + J(:,:,t+1)*(xs(:,t+1) - xp(:,t+1));
    Ps(:,:,t)  = Pf(:,:,t) + J(:,:,t+1)*(Ps(:,:,t+1) - Pp(:,:,t+1))*J(:,:,t+1)';
    
    if t == 1
        J(:,:,t) = Pf0*Phi'/Pp(:,:,t);
        xs0n     = xf0 + J(:,:,t)*(xs(:,t) - xp(:,t));
        Ps0n     = Pf0 + J(:,:,t)*(Ps(:,:,t) - Pp(:,:,t))*J(:,:,t)';
    end
end

% Lag-one covariance smoother
for t = n:-1:1
    if t == n
        Pslag(:,:,t) = (Ip - K*A)*Phi*Pf(:,:,t-1);
    else
        Pslag(:,:,t) = Pf(:,:,t)*J(:,:,t)' + J(:,:,t+1)*(Pslag(:,:,t+1) - Phi*Pf(:,:,t))*J(:,:,t)';
    end
end

% Smoothers
for t = 1:n
    S11 = S11 + xs(:,t)*xs(:,t)' + Ps(:,:,t);
    if t == 1
        S10 = xs(:,t)*xs0n' + Pslag(:,:,t);
        S00 = xs0n*xs0n' + Ps0n;
    else
        S10 = S10 + xs(:,t)*xs(:,t-1)' + Pslag(:,:,t);
        S00 = S00 + xs(:,t-1)*xs(:,t-1)' + Ps(:,:,t-1);
    end
end