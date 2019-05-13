%% U.S. Term Premia
% This code estimates the U.S. term premia using the methodology of JSZ (2011)
% and compares them with those obtained by KM (2005) and ACM (2013).
% m-files called: loadings4ylds.m, dataset_in_range.m, read_acm.m, getFredData.m
% 
% Pavel Solís (pavel.solis@gmail.com), May 2019
%% Use RKF model in JSZ paper

load('sample_RY_model_jsz.mat')
load('sample_zeros.mat')

N  = 3;
dt = 1/12;
W  = pcacov(cov(yields));
W  = W(:,1:N)';                                         % cP = yields*W'; % T*N
[llks, AcP, BcP, AX, BX, kinfQ, K0P_cP, K1P_cP, sigma_e, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, cP, llkP, llkQ, ...
    K0Q_X, K1Q_X, rho0_X, rho1_X, Sigma_cP] = sample_estimation_fun(W, yields, mats, dt, false);
[llk, AcP, BcP, AX, BX, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, cP, yields_filtered, cP_filtered] = ...
    jszLLK_KF(yields, W, K1Q_X, kinfQ, Sigma_cP, mats, dt, K0P_cP, K1P_cP, sigma_e);
yields_Q = ones(length(dates),1)*AcP + cP_filtered*BcP; % Same as yields_filtered


%% TP from JSZ estimation

maturities = round(mats/dt);
mu = K0P_cP; Phi = K1P_cP + eye(N); Hcov = Sigma_cP;
[Ay,By]  = loadings4ylds(maturities,mu,Phi,Hcov,rho0_cP*dt,rho1_cP*dt,dt);
yields_P = ones(length(dates),1)*Ay + cP_filtered*By;

tpJSZ = (yields_Q - yields_P)*100;


%% Compare against ACM and KW

% ACM
date1    = min(dates);
date2    = max(dates);
yr_dbl   = 10;                                          % Tenor to plot
yr_str   = num2str(yr_dbl); 
run read_acm.m
data_acm = dataset_in_range(data_acm,date1,date2);
if yr_dbl < 10
    acm_labels = {['ACMY0' yr_str],['ACMTP0' yr_str],['ACMRNY0' yr_str]};
else
    acm_labels = {['ACMY' yr_str],['ACMTP' yr_str],['ACMRNY' yr_str]};
end
fltrACM1  = ismember(hdr_acm,acm_labels);
acm_parts = data_acm(:,fltrACM1);

% KW
KW = getFredData(['THREEFYTP' yr_str],datestr(date1,29),datestr(date2,29)); % 29: date format ID
KWtp = KW.Data;
[row,~] = find(isnan(KWtp));
KWtp(row,:)=[];                                         % Remove NaN before doing end-of-month
KWtp = end_of_month(KWtp);
KWtp = dataset_in_range(KWtp,date1,date2);

% z1 = ismember(data_acm(:,1),KWtp(:,1));               % They coincide from the 7th observation onwards
tps = [tpJSZ(7:end,end) acm_parts(7:end,2) KWtp(:,2)];
corr(tps)
mean(tps(:,1) - tps(:,3))
plot(tps)
legend('JSZ','ACM','KW')

% cP_filtered+VAR1: Correlation b/w JSZ and KW is 0.9527 (w/ ACM 0.7867), JSZ > KW by 73.5 bps on average
% cP_filtered+K0,K1,Sigma: Correlation b/w JSZ and KW is 0.968 (w/ ACM 0.822), JSZ > KW by 80.7 bps on average


%% Assess fit

% plot(dates,yields(:,7),'x',dates,yields_Q(:,7),'+')     % Time series; slightly off in 1 and 5 years
% plot(mats,yields(216,:),'x',mats,yields_Q(216,:),'+')   % Cross section
% [~,PCs] = pca(yields,'NumComponents',3);
% [~,PCs_Q] = pca(yields_Q,'NumComponents',3);
% corr(PCs,PCs_Q)
% figure
% plot(dates,[yields(:,7) yields_P(:,7)])                 % Historic
% figure
% plot(mats,yields(100,:),mats,yields_P(100,:))           % One day
