function S = se_components(S,matsout,currEM)
% SE_COMPONENTS Report standard errors for yield components due to uncertainty 
% in the estimated parameters. The state is assumed to be known with certainty

% m-files called: syncdatasets, vars2parest, parest2vars, loadings
% Pavel Solís (pavel.solis@gmail.com), September 2020
%%
dt      = 1/12;
epsilon = 1e-6;                                                             % 0.01 basis point
nEMs    = length(currEM);
nmats   = length(matsout);
fnames  = fieldnames(S);
fnameq  = fnames{contains(fnames,'bsl_pr')};                                % field containing estimated parameters

for k0  = 1:nEMs
    % Nominal yields
    fnameb = 'mn_blncd';                                                    % field containing *nominal* yields
    fltrnm = ismember(S(k0).(fnameb)(1,:),matsout);                         % same maturities as in matsout
    yldnom = S(k0).(fnameb)(2:end,fltrnm);                                  % yields in decimals
    datesn = S(k0).(fnameb)(2:end,1);                                       % dates
    
    % Synthetic yields
    fnameb = 'ms_blncd';                                                    % field containing *synthetic* yields
    fltrsn = ismember(S(k0).(fnameb)(1,:),matsout);                         % same maturities as in matsout
    yldsyn = S(k0).(fnameb)(2:end,fltrsn);                                  % yields in decimals
    nobssn = size(yldsyn,1);                                                % number of observations
    datess = S(k0).(fnameb)(2:end,1);                                       % dates
    
    % Extract estimated parameters
    cSgm  = S(k0).(fnameq).cSgm;    Hcov  = cSgm*cSgm';
    mu_xP = S(k0).(fnameq).mu_xP;   PhiP  = S(k0).(fnameq).PhiP;
    mu_xQ = S(k0).(fnameq).mu_xQ;   PhiQ  = S(k0).(fnameq).PhiQ;
    lmbd0 = S(k0).(fnameq).lmbd0;   lmbd1 = S(k0).(fnameq).lmbd1;
    rho0  = S(k0).(fnameq).rho0;    rho1  = S(k0).(fnameq).rho1;
    sgmY  = S(k0).(fnameq).sgmY;    sgmS  = S(k0).(fnameq).sgmS;
    xs    = S(k0).(fnameq).xs;      Vasy  = S(k0).(fnameq).V1;
    
    % Original decomposition
    [AnQ,BnQ] = loadings(matsout,mu_xQ,PhiQ,Hcov,rho0,rho1,dt);
    [AnP,BnP] = loadings(matsout,mu_xP,PhiP,Hcov,rho0,rho1,dt);
    yQold     = ones(nobssn,1)*AnQ + xs*BnQ;
    yPold     = ones(nobssn,1)*AnP + xs*BnP;
    tpold     = yQold - yPold;
    [~,crynom,cryQold] = syncdatasets([nan matsout; datesn yldnom],[nan matsout; datess yQold]);
    crold     = crynom(2:end,2:end) - cryQold(2:end,2:end);
    datesc    = crynom(2:end,1);
    nobscr    = length(datesc);
    
    % Delta method
    thetaold = vars2parest(PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0,sgmY,sgmS);
    ntheta   = length(thetaold);
    JyQ      = nan(nmats,ntheta,nobssn);
    JyP      = nan(nmats,ntheta,nobssn);
    Jtp      = nan(nmats,ntheta,nobssn);
    Jcr      = nan(nmats,ntheta,nobscr);
    for k1 = 1:ntheta
        % Subtract epsilon to theta
        thetanew     = thetaold;
        thetanew(k1) = thetanew(k1) - epsilon;

        % New decomposition (assumes no uncertainty in state)
        [PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0] = parest2vars(thetanew);    % sgmY and sgmS no needed
        Hcov      = cSgm*cSgm';             cSgm = chol(Hcov,'lower');      % crucial: cSgm from Cholesky
        mu_xQ     = mu_xP - cSgm*lmbd0;     PhiQ = PhiP  - cSgm*lmbd1;
        [AnQ,BnQ] = loadings(matsout,mu_xQ,PhiQ,Hcov,rho0,rho1,dt);
        [AnP,BnP] = loadings(matsout,mu_xP,PhiP,Hcov,rho0,rho1,dt);
        yQnew     = ones(nobssn,1)*AnQ + xs*BnQ;
        yPnew     = ones(nobssn,1)*AnP + xs*BnP;
        tpnew     = yQnew - yPnew;
        [~,crynom,cryQnew] = syncdatasets([nan matsout; datesn yldnom],[nan matsout; datess yQnew]);
        crnew     = crynom(2:end,2:end) - cryQnew(2:end,2:end);

        % Jacobians
        JyQ(:,k1,:) = (yQold - yQnew)'/epsilon;
        JyP(:,k1,:) = (yPold - yPnew)'/epsilon;
        Jtp(:,k1,:) = (tpold - tpnew)'/epsilon;
        Jcr(:,k1,:) = (crold - crnew)'/epsilon;
    end
    
    % Standard errors
    seyQ = nan(nobssn,nmats);
    seyP = nan(nobssn,nmats);
    setp = nan(nobssn,nmats);
    secr = nan(nobscr,nmats);
    for k2 = 1:nobssn
        seyQ(k2,:) = sqrt(diag(JyQ(:,:,k2)*Vasy*JyQ(:,:,k2)'/nobssn));
        seyP(k2,:) = sqrt(diag(JyP(:,:,k2)*Vasy*JyP(:,:,k2)'/nobssn));
        setp(k2,:) = sqrt(diag(Jtp(:,:,k2)*Vasy*Jtp(:,:,k2)'/nobssn));
    end
    for k2 = 1:nobscr
        secr(k2,:) = sqrt(diag(Jcr(:,:,k2)*Vasy*Jcr(:,:,k2)'/nobscr));
    end
    
    S(k0).('bsl_yQ_se') = [nan matsout; datess seyQ];
    S(k0).('bsl_yP_se') = [nan matsout; datess seyP];
    S(k0).('bsl_tp_se') = [nan matsout; datess setp];
    S(k0).('bsl_cr_se') = [nan matsout; datesc secr];
end