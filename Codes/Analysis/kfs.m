function [logllk,xp,Pp,xf,Pf,xs,Ps,Pslag] = kfs(y,mu_y,A,R,mu_x,Phi,Q)
% Implementation of the Kalman filter and smoother algorithms in
% Time Series Analysis and Its Applications by Shumway & Stoffer
% 
% Linear dynamic model:
% x_t = mu_x + Phi*x_{t-1} + w_t, cov(w) = Q
% y_t = mu_y +    A*x_t    + v_t, cov(v) = R
%
% p     : number of state variables
% q     : number of observed variables
% n     : number of observations
% 
% INPUT
% y     : q*n matrix of observables
% mu_y  : q*1 measurement intercept
% A     : q*p measurement matrix
% R     : q*q measurement covariance
% mu_x  : p*1 transition intercept
% Phi   : p*p transition matrix 
% Q     : p*p transition covariance
%
% OUTPUT
% logllk: 1*1   not minus log likelihood
% xp    : p*n   matrix of predicted mean of state,       stores Exp[x(t)|y(t-1)]
% Pp    : p*p*n matrix of predicted covariance of state, stores Var[x(t)|y(t-1)]
% xf    : p*n   matrix of filtered mean of state,        stores Exp[x(t)|y(t)]
% Pf    : p*p*n matrix of filtered covariance of state,  stores Var[x(t)|y(t)]
% xs    : p*n   matrix of smoothed mean of state,        stores Exp[x(t)|y(n)]
% Ps    : p*p*n matrix of smoothed covariance of state,  stores Var[x(t)|y(n)]
% Pslag : p*p*n matrix of one-lag covariances of state,  stores Cov[x(t),x(t-1)|y(n)]
%%
% Determine dimensions
p     = size(Phi,1);
[q,n] = size(y);

% Pre-allocate space
xp  = nan(p,n);     xf = nan(p,n);       xs = nan(p,n);
Pp  = nan(p,p,n);   Pf = nan(p,p,n);     Ps = nan(p,p,n);
J   = nan(p,p,n);   Ip = eye(p);         Pslag = nan(p,p,n); 
S11 = zeros(p,p);   logllk = 0;

% Initialize recursion: x0 ~ N(xf0,Pf0)
xf0 = zeros(p,1);                                               % p*1
Pf0 = reshape((eye(p^2)-kron(Phi,Phi))\reshape(Q,p^2,1),p,p);   % p*p
if any(isnan(Pf0),'all') || any(isinf(Pf0),'all')
    Pf0 = Ip;
end
% if p == 1; Pf0 = 2.8; end % For example 6.8 in ASTSA

% Estimation: Kalman filter
for t = 1:n
    % Predicting equations
    if t == 1
        xp(:,t)   = mu_x + Phi*xf0;
        Pp(:,:,t) = Phi*Pf0*Phi' + Q;
    else
        xp(:,t)   = mu_x + Phi*xf(:,t-1);
        Pp(:,:,t) = Phi*Pf(:,:,t-1)*Phi' + Q;
    end
    
    v = y(:,t) - (mu_y + A*xp(:,t));	% Innovation
    V = A*Pp(:,:,t)*A' + R;             % Innovation covariance
    K = Pp(:,:,t)*A'/V;                 % Optimal Kalman gain
    
    % Updating equations
    xf(:,t)   = xp(:,t) + K*v;
    Pf(:,:,t) = (Ip - K*A)*Pp(:,:,t);
    
    % Log-likelihood
    term2  = log(det(V)); 
    term3  = max(v'/V*v,0);             % In case V is non-PSD
    logllk = logllk - 0.5*(q*log(2*pi) + term2 + term3);
end

% Inference: Kalman smoother
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
