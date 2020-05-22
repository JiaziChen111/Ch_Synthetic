function [llk,xp,Pp,xf,Pf,xs,Ps,xs0n,Ps0n,S11,S10,S00] = Kfs(y,Phi,A,Q,R,xf0,Pf0,mu_x,mu_y)
% KFS Implement the Kalman filter and smoother algorithms in Time Series
% Analysis and Its Applications by Shumway & Stoffer
% 
%               Dynamic linear model (time-invariant coefficients)
% transition  : x_t = mu_x + Phi*x_{t-1} + w_t, cov(w) = Q, x has dimension p, number of state variables
% measurement : y_t = mu_y +   A*x_t     + v_t, cov(v) = R, y has dimension q, number of measured variables
% number of observations : n
% 
% INPUTS
% y     : q*n matrix of measurements
% Phi   : p*p state transition matrix
% A     : q*p measurement matrix
% Q     : p*p state error covariance matrix
% R     : q*q measurement error covariance matrix
% xf0   : p*1 initial state mean vector (optional)
% Pf0   : p*p initial state covariance matrix (optional)
% mu_x  : p*1 transition intercept (optional)
% mu_y  : q*1 measurement intercept (optional)
%
% OUTPUT
% llk   : 1*1   log-likelihood (includes constant)
% xp    : p*n   matrix of predicted mean of state,       stores Exp[x(t)|y(t-1)]
% Pp    : p*p*n matrix of predicted covariance of state, stores Var[x(t)|y(t-1)]
% xf    : p*n   matrix of filtered mean of state,        stores Exp[x(t)|y(t)]
% Pf    : p*p*n matrix of filtered covariance of state,  stores Var[x(t)|y(t)]
% xs    : p*n   matrix of smoothed mean of state,        stores Exp[x(t)|y(n)]
% Ps    : p*p*n matrix of smoothed covariance of state,  stores Var[x(t)|y(n)]
% xs0n  : p*1   estimate of initial state mean
% Ps0n  : p*p   estimate of initial state covariance matrix
% S11   : p*p   smoother using current xs and Ps
% S10   : p*p   smoother using current and past xs and Pslag
% S00   : p*p   smoother using past xs and Ps

% Pavel Solís (pavel.solis@gmail.com), May 2020

%% Premable
% Determine dimensions
p     = size(Phi,1);
[q,n] = size(y);
if n < q; error('y may need to be transposed.'); end
if nargin < 9; mu_y = zeros(q,1); end
if nargin < 8; mu_x = zeros(p,1); end

% Pre-allocate space
xp  = nan(p,n);     Pp  = nan(p,p,n);       Ip    = eye(p);
xf  = nan(p,n);     Pf  = nan(p,p,n);       J     = nan(p,p,n);	
xs  = nan(p,n);     Ps  = nan(p,p,n);       Pslag = nan(p,p,n);
llk = 0;            S11 = zeros(p,p);

% Initialize recursion with unconditional moments assuming state is stationary x0 ~ N(xf0,Pf0)
if nargin < 6
    xf0 = (Ip - Phi)\mu_x;                                         	% p*1
    Pf0 = reshape((eye(p^2)-kron(Phi,Phi))\reshape(Q,p^2,1),p,p);   % p*p
    if any(isnan(Pf0),'all') || any(isinf(Pf0),'all') || any(~isreal(eig(Pf0))) || any(eig(Pf0) < 0)
        xf0 = zeros(p,1);       Pf0 = Ip;                           % in case the state is non-stationary
    end
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