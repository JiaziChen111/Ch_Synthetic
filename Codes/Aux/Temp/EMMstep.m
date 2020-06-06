function [mu_y,A,R,mu_x,Phi,Q] = EM_Mstep(y,xs,Ps,Pslag)

% params.MLE.sumws=sum(ws,3);             % Sums Ps matrices
%     params.MLE.ws1=ws(:,:,1);               % First Ps matrix
%     params.MLE.wsT=ws(:,:,params.T);        % Last Ps matrix
%     params.MLE.sumcs=sum(cs(:,:,2:end),3);  % Sums PSlag matrices 2 to end
%     params.X=params.MLE.s;                  % Saves xs as x
    % compute statistics
%     params= betadeltagamma(Y,params);
T = size(y,2);
K = size(xs,1);
[beta,delta,gamma,gamma1,gamma2] = betadeltagamma(y,xs,Ps,Pslag);

% Estimate mu_x, Phi and Q
    EF   = beta/gamma1;
    mu_x = EF(:,1);
    Phi  = EF(:,2:end);
    
    [V,D] = eig(Phi);
    [emax,idx] = max(abs(diag(D)));
    if emax > 1       
        if ~isreal(D(idx,idx))
            idx = idx:idx + 1;
        end
        for n = idx
            D(n,n) = (D(n,n)/emax)*0.9999;
        end
        Phi  = real(V*D/V);
        mu_x = (beta(:,1) - Phi*gamma1(2:end,1))/gamma1(1);
        EF(:,1)     = mu_x;
        EF(:,2:end) = Phi;
        warning('max(abs(eig(Phi)))>1');
    end
    
    tmp1 = EF*beta';
    Q    = (gamma2 - tmp1 -tmp1' + EF*gamma1*EF') / (T-1);

% Estimate mu_y, A and R
    AB   = delta/gamma;
    mu_y = AB(:,1);
    A    = AB(:,2:K+1);
    tmp1 = AB*delta';
    R    = (y*y' - tmp1 - tmp1' + AB*gamma*AB')/T;
end


function [beta,delta,gamma,gamma1,gamma2] = betadeltagamma(y,xs,Ps,Pslag)
% EF = beta/gamma1; (K * K+1) x (K+1 * K+1)
% Q  = (gamma2 - EF*beta' - beta*EF' + EF*gamma1*EF') / (T-1);
% AB = delta/gamma; (N * K+1) x (K+1 * K+1)
% R  = diag(diag((Y*Y' - AB*delta' - delta*AB' + AB*gamma*AB'))) / T;
T = size(y,2);
K = size(xs,1);
SumPs    = sum(Ps,3);
SumPslag = sum(Pslag(:,:,2:end),3);
Xtmp     = [ones(1,T); xs];

% t = 1:T
delta = y*Xtmp';
gamma = Xtmp*Xtmp';
gamma(2:K+1,2:K+1) = gamma(2:K+1,2:K+1) + SumPs;

% t = 1:T-1; from t = 1:T, remove t = T
gamma1 = gamma - Xtmp(:,end)*Xtmp(:,end)';
gamma1(2:K+1,2:K+1) = gamma1(2:K+1,2:K+1) - Ps(:,:,end);

% t = 2:T; from t = 1:T, remove t = 1
gamma2 = gamma - Xtmp(:,1)*Xtmp(:,1)';
gamma2 = gamma2(2:K+1,2:K+1) - Ps(:,:,1);

% t = 2:T * 1:T-1
beta          = xs(:,2:end)*Xtmp(:,1:end-1)'; % K by K+1
beta(:,2:end) = beta(:,2:end) + SumPslag;

end
