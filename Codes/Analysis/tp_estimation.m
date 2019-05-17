function [S,corrPC] = tp_estimation(S,N,dt,YCtype)
% This function estimates the term premia in LC yield curves for different
% maturities following the methodology of Joslin, Singleton & Zhu (2011).
%
%	INPUTS
% struct: S    - contains names of countries/currencies, codes and YC data
% char: YCtype - type of LC yield curve to use, i.e. nominal (LC) or synthetic (LCSYNT)
% double: N    - number of state variables
% double: dt   - frequency of the data in years (e.g. 1/12 for monthly data)
%
%	OUTPUT
% struct: S - adds term premia estimates to the input structure
%
%   ASSUMPTIONS
% S in input is generated by daily2monthly.m
% m-files called: loadings4ylds.m
% 
% Pavel Sol�s (pavel.solis@gmail.com), May 2019
%%
if strcmp(YCtype,'LC'); prefix = 'nom'; else; prefix = 'syn'; end
ncntrs  = length(S);
corrPC  = cell(N,4);
fnames  = fieldnames(S);
idxB    = contains(fnames,[prefix 'blncd']);            % Identify the field containing the data
fnameb  = fnames{idxB};                                 % Use field name

for k = 1:ncntrs
    mats   = S(k).(fnameb)(1,2:end);
    dates  = S(k).(fnameb)(2:end,1);
    yields = S(k).(fnameb)(2:end,2:end);
    nobs   = size(yields,1);
    W      = pca(yields,'algorithm','als');             % Allows for missing observations
    W      = W(:,1:N)';                                 % W: N*length(mats)
    
    % Fit the curve
    [llks, AcP, BcP, AX, BX, kinfQ, K0P_cP, K1P_cP, sigma_e, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, cP, ...
        llkP, llkQ,  K0Q_X, K1Q_X, rho0_X, rho1_X, Sigma_cP] = sample_estimation_fun(W, yields, mats, dt, false);
    [llk, AcP, BcP, AX, BX, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, cP, yields_filtered, cP_filtered] = ...
        jszLLK_KF(yields, W, K1Q_X, kinfQ, Sigma_cP, mats, dt, K0P_cP, K1P_cP, sigma_e);
    yields_Q = ones(nobs,1)*AcP + cP*BcP;               % With cP_filtered is same as yields_filtered
    
    % Term premia estimates
    mu = K0P_cP; Phi = K1P_cP + eye(N); Hcov = Sigma_cP;
    maturities = round(mats/dt);
    [Ay,By]    = loadings4ylds(maturities,mu,Phi,Hcov,rho0_cP*dt,rho1_cP*dt,dt);
    yields_P   = ones(nobs,1)*Ay + cP*By;               % Same cP as for yields_Q
    
    term_premia    = (yields_Q - yields_P)*100;         % TP in percentage points
    
    S(k).([prefix 'yldsQ']) = [nan mats; dates yields_Q];
    S(k).([prefix 'yldsP']) = [nan mats; dates yields_P];
    S(k).([prefix 'tp'])    = [nan mats; nan mean(term_premia); dates term_premia];
    
    % Assess fit
    [~,PCs]     = pca(yields,'NumComponents',N);
    [~,PCs_Q]   = pca(yields_Q,'NumComponents',N);
    corrPC{k,1} = S(k).iso;
    for l = 1:N; corrPC{k,l+1} = corr(PCs(:,l),PCs_Q(:,l)); end
end
 