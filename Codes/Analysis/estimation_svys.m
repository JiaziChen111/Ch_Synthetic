function [ylds_Q,ylds_P,termprm,params] = estimation_svys(yldsvy,matsY,matsS,matsout,dt,params0,sgmSfree)
% ESTIMATION_SVYS Estimate affine term structure model using yields and surveys
% 
%	INPUTS
% yldsvy   - bond yields and survey forecasts (rows: obs, cols: maturities)
% matsY    - maturities of yields in years
% matsS    - maturities of surveys in years
% matsout  - bond maturities (in years) to be reported
% dt       - length of period in years (eg. 1/12 for monthly data)
% params0  - initial values of parameters
% sgmSfree - logical whether to estimate sgmS (o/w fixed at 75 bp)
%
%	OUTPUT
% ylds_Q  - estimated yields under Q measure
% ylds_P  - estimated yields under P measure
% termprm - estimated term premia
% params  - estimated parameters
%
% m-files called: llkfn, atsm_params, Kfs, parest2vars, loadings
% Pavel Sol�s (pavel.solis@gmail.com), June 2020
%%
nobs   = size(yldsvy,1);                                                    % number of observations
x00    = params0.x00;
P00    = params0.P00;
fmflag = 0;
niter  = 2000;

% Estimate parameters
while fmflag == 0
    if niter == 2000                                                        % use initial values in 1st run
        if sgmSfree
            par0 = [params0.PhiP(:);params0.cSgm(:);params0.lmbd1(:);params0.lmbd0(:);...
                    params0.mu_xP(:);params0.rho1(:);params0.rho0;params0.sgmY;params0.sgmS];
        else                                                                % sgmS fixed in atsm_params
            par0 = [params0.PhiP(:);params0.cSgm(:);params0.lmbd1(:);params0.lmbd0(:);...
                    params0.mu_xP(:);params0.rho1(:);params0.rho0;params0.sgmY];
        end
    else
        par0 = parest;
    end
    
    maxitr = length(par0)*niter;
    optns  = optimset('MaxFunEvals',maxitr,'MaxIter',maxitr);
    llkhd  = @(x)llkfn(x,yldsvy',x00,P00,matsY,matsS,dt);                   % include vars in workspace
    [parest,fval,fmflag] = fminsearch(llkhd,par0,optns);                    % estimate parameters
    if ~isinf(fval) && fmflag == 0;   niter = niter + 1000;   end
end

% Estimate state vector based on estimated parameters
[mu_x,mu_y,Phi,A,Q,R] = atsm_params(parest,matsY,matsS,dt);                 % get model parameters
[~,~,~,~,~,xs] = Kfs(yldsvy',mu_x,mu_y,Phi,A,Q,R,x00,P00);                  % smoothed state
xs = xs';                                                                   % same dimensions as yldsvy 

% Estimate the term premium
[PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0,sgmY,sgmS] = parest2vars(parest);
Hcov      = cSgm*cSgm';             cSgm = chol(Hcov,'lower');              % crucial: cSgm from Cholesky
mu_xQ     = mu_xP - cSgm*lmbd0;     PhiQ = PhiP  - cSgm*lmbd1;
[AnQ,BnQ] = loadings(matsout,mu_xQ,PhiQ,Hcov,rho0,rho1,dt);
[AnP,BnP] = loadings(matsout,mu_xP,PhiP,Hcov,rho0,rho1,dt);
ylds_Q    = ones(nobs,1)*AnQ + xs*BnQ;
ylds_P    = ones(nobs,1)*AnP + xs*BnP;
termprm   = ylds_Q - ylds_P;        % = ones(nobs,1)*(AnQ - AnP) + xs*(BnQ - BnP);

% Report parameters
params.mu_xP = mu_xP;   params.PhiP  = PhiP;
params.mu_xQ = mu_xQ;   params.PhiQ  = PhiQ;
params.rho0  = rho0;    params.rho1  = rho1;
params.lmbd0 = lmbd0;   params.lmbd1 = lmbd1;
params.sgmY  = sgmY;    params.sgmS  = sgmS;
params.cSgm  = cSgm;    params.xs    = xs;