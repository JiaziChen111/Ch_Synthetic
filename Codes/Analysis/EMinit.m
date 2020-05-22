function [mu_y,A,R,mu_x,Phi,Q] = EM_init(y,p)
% Initialize parameters of state space model at OLS values using principal components.
% y : N*T

% Initialize latent factors (deals with missing observations)
[~,PCs] = pca(y','algorithm','als','NumComponents',p);    % T*K
% PCs = PCs';     % K*T
PCs = PCs.*(1 + 0.1*randn(size(PCs)));

% Intilialize parameters of the transition equation (E,F and Q)
[mu_x, Phi, Q] = VAR1(PCs,1);

% Intilialize parameters of the measurement equation (A,B and R)
[mu_y, A, R] = OLS(y',PCs);

end

function [B0hat, B1hat, Qhat] = VAR1(Z, impose_stationarity)
    % Z(t+1) = B0 + B1*Z(t) + eps(t+1), cov(eps(t+1)) = Q
    % Z: T*K
    % impose_stationarity : 1
    
    T = size(Z,1);
    X = [ones(T-1,1) Z(1:end-1,:)];             % (T-1)*(K+1)
    Y = Z(2:end,:);                             % (T-1)*K
    B = (X'*X)\(X'*Y);                          % (K+1)*K
    B0hat = B(1,:)';                            % K*1
    B1hat = B(2:end,:)';                        % K*K
    
    if nargin == 2 && impose_stationarity == 1	% Impose stationarity
        [V,D] = eig(B1hat);
        [emax,idx] = max(abs(diag(D)));
        if emax > 0.99
            if ~isreal(D(idx,idx))              % Conjugate pair
                idx = idx:idx+1;
            end
            for n = idx
                D(n,n) = (D(n,n)/emax)*0.99;
            end
            B1hat = real(V*D/V);
        end
        residB1 = Y - X(:,2:end)*B1hat';        % (T-1)*K
        B0hat   = mean(residB1)';               % K*1
    end
    
    resid = Y - X*[B0hat'; B1hat'];             % (T-1)*K
    Qhat  = resid'*resid/(T-1);%(size(X,1)-size(X,2));
end

function [B0hat, B1hat, Rhat] = OLS(Y, X)
    % Y(t) = B0 + B1*X(t) + eps(t), cov(eps(t+1)) = R
    % X: T*K
    T = size(X,1);
    X = [ones(T,1) X];
    B = (X'*X)\(X'*Y);
    B0hat = B(1,:)';
    B1hat = B(2:end,:)';
    resid = Y - X*B;
    Rhat  = resid'*resid/(size(X,1)-size(X,2));
end
