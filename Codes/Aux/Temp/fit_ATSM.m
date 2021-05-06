function [yieldsQ,yieldsP,yieldsE,rmse,explained] = fit_ATSM(maturities1,ydata)
% This function estimates an affine term structure model.
% Assumes that fit_NS.m has already been run.
% Calls to m-files: none
%
%     INPUT
% vector: maturities1 - Number of yields to be estimated (eg 1 to 10 years)
% matrix: ydata       - End-of-month LCRF yield curve data for 0.25, 1-10yr (obs x maturities)
%
%     OUTPUT
% matrix: yieldsQ   - Yields under the risk-neutral measure (1 to 10 yr maturities)
% matrix: yieldsP   - Yields under the physical measure (1 to 10 yr maturities)
% matrix: yieldsE   - Expected short term yields based on VAR forecasts (0.25, 1-10 yr maturities)
% vector: rmse      - RMSE of fitting the ATSM to ydata
% matrix: explained - Percent of total variance explained by PCs (size(ydata,2)x1)
%
% Pavel Solís (pavel.solis@gmail.com), September 2018
%%
options = optimoptions('lsqcurvefit','Display','off'); lb = []; ub = [];
nobs    = size(ydata,1);
npc     = 3;                                 % Number of principal components
lambda0 = zeros(npc,npc+1);

% Obtain the state variables as factors of the yields
[~,factors,~,~,explained] = pca(ydata,'NumComponents',npc);

% Dynamics of the state variables
y = factors(2:end,:);
T = size(y,1);
x = [ones(T,1) factors(1:end-1,:)];
b = (x'*x)\x'*y;
u = y - (x*b);
C = (u'*u)/T;
mu    = b(1,:)';
phi   = b(2:end,:)';
sigma = chol(C)';

% Dynamics of the short-term interest rate
r = ydata(:,1);
X = [ones(numel(r),1) factors];
delta  = (X'*X)\X'*r;
delta0   = delta(1);
delta1   = delta(2:end);

% Price of risk
if numel(maturities1) == size(ydata,2)
    [lambda,~,res] = lsqcurvefit(@y_ATSM,lambda0,maturities1,ydata,lb,ub,options);
else
    [lambda,~,res] = lsqcurvefit(@y_ATSM,lambda0,maturities1,ydata(:,2:end),lb,ub,options);
end
%rmse = sqrt(mean(mean(res.^2))); % For a panel
rmse = sqrt(mean(res.^2,2));    % Column vector with rmse per date

% Modeled yields
yieldsQ = y_ATSM(lambda,maturities1);            % [!]
yieldsP = y_ATSM(lambda0,maturities1);           % [!]

yieldsE = expected_yields(r);

    function yields = y_ATSM(lambda,maturities1)
        [A,B]  = pricing_params(lambda,maturities1);
        yields = (-repmat(A',nobs,1) - factors*B)./maturities1;
    end

    function [A,B] = pricing_params(lambda,maturities1)
        nmats    = numel(maturities1);
        A        = zeros(nmats,1);
        B        = zeros(npc,nmats);
        A(1)     = -delta0;
        B(:,1)   = -delta1;
        mu_star  = mu - sigma*lambda(:,1);
        phi_star = phi - sigma*lambda(:,2:end);
        for k    = 2:nmats
            A(k)   = -delta0 + A(k-1) + B(:,k-1)'*mu_star + 0.5*B(:,k-1)'*(sigma*sigma')*B(:,k-1);
            B(:,k) = phi_star'*B(:,k-1) - delta1;
        end
    end

    function yieldsE = expected_yields(r)
        I   = eye(size(phi));
        Ey  = r;
        aux = r;
        for h = 1:10 % Later: parametrize 10
            phi_h = phi^h;
            EX    = repmat(mu',nobs,1)*((I - phi)\(I - phi_h))' + factors*phi_h';
            Er    = repmat(delta0,nobs,1) + EX*delta1;
            Ey    = Ey + Er;
            aux   = [aux Ey];
        end

        nrates  = 1:size(aux,2);
        yieldsE = aux./nrates;
    end
end
