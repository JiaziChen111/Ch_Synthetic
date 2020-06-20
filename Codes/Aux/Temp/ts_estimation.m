function [S,corrPC] = ts_estimation(S,nPCs,dt,YCtype)
% TS_ESTIMATION Estimate affine term structure models applying the 
% methodology of Joslin, Singleton & Zhu (2011)
%
%	INPUTS
% struct: S    - names of countries/currencies, ID codes and YC data
% double: nPCs - number of state variables
% double: dt   - frequency of the data in years (eg. 1/12 for monthly data)
% char: YCtype - type of LC yield curve (nominal LCNOM or synthetic LCSYNT)
%
%	OUTPUT
% struct: S - estimated yields under Q and P measures, term premia estimates
%
% m-files called: loadings4ylds.m
% Pavel Solís (pavel.solis@gmail.com), May 2019
%%
if strcmp(YCtype,'LCNOM'); prefix = 'n_'; else; prefix = 's_'; end
ncntrs = length(S);
corrPC = cell(nPCs,4);
fnames = fieldnames(S);
fnameb = fnames{contains(fnames,[prefix 'blncd'])};             % use field name containing the data

for k = 1:ncntrs
    % Extract data
    mats  = S(k).(fnameb)(1,2:end);
    dates = S(k).(fnameb)(2:end,1);
    ylds  = S(k).(fnameb)(2:end,2:end);
    nobs  = size(ylds,1);
    [W,PCs] = pca(ylds,'NumComponents',nPCs);                   % W': N*length(mats); if NaNs, 'algorithm','als'
    
    % Fit the curve
    [llks,AcP,BcP,AX,BX,kinfQ,K0P_cP,K1P_cP,sigma_e,K0Q_cP,K1Q_cP,rho0_cP,rho1_cP,cP, ...
        llkP,llkQ,K0Q_X,K1Q_X,rho0_X,rho1_X,Sigma_cP] = sample_estimation_fun(W',ylds,mats,dt,false);
    [llk,AcP,BcP,AX,BX,K0Q_cP,K1Q_cP,rho0_cP,rho1_cP,cP,yields_filtered,cP_filtered] = ...
        jszLLK_KF(ylds,W',K1Q_X,kinfQ,Sigma_cP,mats,dt,K0P_cP,K1P_cP,sigma_e);
    yields_Q = ones(nobs,1)*AcP + cP*BcP;                       % with cP_filtered is same as yields_filtered
    
    % Estimate the term premium
    mu = K0P_cP; Phi = K1P_cP + eye(nPCs); Hcov = Sigma_cP;
    maturities = round(mats/dt);
    [Ay,By]    = loadings4ylds(maturities,mu,Phi,Hcov,rho0_cP*dt,rho1_cP*dt,dt);
    yields_P   = ones(nobs,1)*Ay + cP*By;                     	% same cP as for yields_Q
    termpremia = (yields_Q - yields_P)*100;                 	% TP in percentage points
    
    S(k).([prefix 'yQ']) = [nan mats; dates yields_Q];
    S(k).([prefix 'yP']) = [nan mats; dates yields_P];
    S(k).([prefix 'tp']) = [nan mats; dates termpremia];
    
    % Assess the fit
    [~,PCs_Q]   = pca(yields_Q,'NumComponents',nPCs);
    corrPC{k,1} = S(k).iso;
    for l = 1:nPCs; corrPC{k,l+1} = corr(PCs(:,l),PCs_Q(:,l)); end
end