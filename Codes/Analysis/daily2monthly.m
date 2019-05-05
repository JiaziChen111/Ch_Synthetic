function [dataset_lc,hdr_lc,ctrsNcods,first_mo,flag_rmse,flag_3mo] = daily2monthly(dataset_daily,...
    header_daily,YCtype,S)
% This function fits the Nelson-Siegel model to local currency (LC) yield
% curves (for different dates and for different countries).
% Assumes that read_data.m has already been run.
% Calls to m-files: init_vals_NS.m, y_NS.m, y_NSS.m, bestNSfit.m, special_cases.m,
% curr2imf.m, construct_monthly_hdr.m, date_first_obs.m
%
%     INPUTS
% dataset_daily - matrix with daily obs as rows (top-down is first-last obs), col1 has dates
% header_daily  - cell with names for the columns of dataset_daily
% YCtype        - char with the type of LC yield curve to fit (ie risky or risk-free)
% S - structure with names of countries and currencies, letter and digit codes
%
%     OUTPUT
% dataset_lc - matrix with end-of-month fitted yields for specified maturities
% hdr_lc     - cell with names for the columns of dataset_lc
% ctrsNcods  - cell with countries (with estimated NS curve) and respective IMF codes
% first_mo   - cell with first month of data per country
% flag_*     - flags are useful when addressing special cases
%
% Pavel Solís (pavel.solis@gmail.com), April/October 2018
%%
% Filters and variables
% options    = optimoptions('lsqcurvefit','Display','off'); lb = []; ub = [];
% options1   = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt','Display','off');
fltrLC     = ismember(header_daily(:,2),YCtype);      % 1 if LC/LCSYNT data
% fltrPRM    = ismember(header_daily(:,2),'PARAMETER'); % 1 for US NSS model parameters
% aux1 = struct2cell(S)';
% aux2 = fieldnames(S);
% curncs = aux1(:,strcmp(aux2,'iso'));              % Extract iso currency codes
ncntrs = length(S);%numel(curncs);

tnrs_all    = [0; cellfun(@str2num,header_daily(2:end,5))];
% fltrMTY = ~ismember(header_daily(:,2),'OIS') & ~ismember(header_daily(:,2),'FFF') & ...
%     ~isnan(tnrs_all) & tnrs_all > 0;
% mtrts   = unique(tnrs_all(fltrMTY));
% times   = linspace(0,max(tnrs_all));                      % Used for plots

% Construct the database of LC yield curves
dataset_lc = [];
for k = 1:ncntrs                                  % Adjust here when working with one country
    crncy = S(k).iso;
%     id = S(k).imf;

    % Available tenors per country
    fltrYLD = ismember(header_daily(:,1),crncy) & fltrLC;   % Country + LC data
    tnrs    = tnrs_all(fltrYLD);                            % Tenors available

    % End-of-month data
    idxDates = sum(~isnan(dataset_daily(:,fltrYLD)),2) > 4; 
    fltrYLD(1) = true;                                      % To include dates
    data_lc  = dataset_daily(idxDates,fltrYLD);             % Keep rows with at least 5 observations
    [data_lc,first_obs] = end_of_month(data_lc);            % Keep end-of-month observations
    S(k).start = datestr(first_obs,'mmm-yyyy');             % First monthly observation
    S(k).lcsynt = [0 tnrs'; data_lc];

    % dates = data_lc(:,1);
% yields = data_lc(:,2:end);
% 
% dates = dates(80:end);
% yields = yields(80:end,:);
% nobs = size(yields,1);
% mats = tnrs';

[coeff1,score1,~,~,~,mu1] = pca(yields,'algorithm','als');
reconstrct = score1*coeff1' + repmat(mu1,nobs,1);
% W = coeff1;

%     % Address special cases
%     if strcmp(YCtype,'LCRF')
%         [data_lc,dropped] = special_cases_rf(fltrYLD,data_lc,tnrs,crncy);
%     elseif strcmp(YCtype,'LC')
%         [data_lc,dropped] = special_cases_rk(fltrYLD,data_lc,tnrs,crncy);
%     end
    
    % Fit NS curve per date
%     dataset_aux = [];  flag_rmse = [];  flag_3mo = [];
    for l = 1:nobs                                  % Adjust here when working in one month
        % Tenors available may fluctuate between 5 and numel(tnrs)
        date    = data_lc(l,1);
        ydataLC = data_lc(l,fltrYLD)';                      % Column vector
        idxY    = ~isnan(ydataLC);                          % sum(idxY) >= 5, see above
        ydataLC = ydataLC(idxY);
        tnrs1   = tnrs(idxY);                               % Tenors with data on date l
        ntnrs(l)= numel(tnrs1);
        if     l == 1
            S(k).ntnrsI = numel(tnrs1);
        elseif l == nobs
            S(k).ntnrsL = numel(tnrs1);
        end

%         % Get initial values
%         params0   = data_lc(l,fltrPRM);             % Initial values from US NSS model
%         if     strcmp(YCtype,'LCRF')
%             init_vals = init_vals_NS(YCtype,params0,tnrs1,ydataLC,options);
%         elseif strcmp(YCtype,'LC')
%             init_vals = init_vals_NS(YCtype,params0,[],ydataLC,[],id,date,data_month,hdr_month);
%         end
% 
%         % Best fit of NS model based on the initial values
%         [params,rmse] = bestNSfit(init_vals,tnrs1,ydataLC,lb,ub,options);
% 
%         % Extract implied yields from estimated NS model and save them
%         yields      = y_NS(params,mtrts);
%         dataset_aux = [dataset_aux; date, id, yields, params, rmse];
% 
% % Uncomment to address special cases
%         hdr_lc = []; ctrsNcods = []; first_mo = [];
%         % Flag special cases and suggest potential solutions
%         if rmse > 3                               % Potential outliers, can adjust limit
%             yrs2drop  = suggest_yrs2drop(init_vals,tnrs1,ydataLC,lb,ub,options);
%             flag_rmse = [flag_rmse; l yrs2drop]; 
%         end  
%         if (yields(1) < 0) || (yields(1) > 30)    % Abnormal 3m implied yield, can adjust limits
%             yrs2drop = suggest_yrs2drop(init_vals,tnrs1,ydataLC,lb,ub,options);
%             flag_3mo = [flag_3mo; l yrs2drop]; 
%         end

%         % Plot yields: actual, dropped, LC NS, US NSS
%         plot(tnrs1,ydataLC)
% %         plot(tnrs1,ydataLC,'ko',dropped(l,1),dropped(l,2),'go',...
% %             times,y_NS(params,times),'r-',times,y_NSS(params0,times),'b-')
%         title([crncy '  ' datestr(date)]), ylabel('%'), xlabel('Maturity')
        plot(mats,yields(l,:)','o',mats,yields_mKF(l,:)','x')
        title([crncy '  ' datestr(dates(l))]), ylabel('%'), xlabel('Maturity')
        H(l) = getframe(gcf);                               % To see individual frames: imshow(H(2).cdata)
    end
%     dataset_lc = [dataset_lc; dataset_aux];
% figure
% plot(ntnrs)
% title(S(k).cty)
end

% Comment next lines when addresing special cases
% Header
% hdr_lc    = construct_monthly_hdr(mtrts,YCtype,1);

% beep

% S = rmfield(S,{'tnrsF','tnrsL'});


%% Construct Balanced Panels for JSZ Estimation

S(1).blncd = S(1).lcsynt([1 81:end],:);
S(2).blncd = S(2).lcsynt(:,[1:10 13]);
S(3).blncd = S(3).lcsynt(:,[1:9 11 14]);
S(4).blncd = S(4).lcsynt([1 12:end],:);
S(5).blncd = S(5).lcsynt([1 8:end],1:16);
S(6).blncd = S(6).lcsynt([1 27:end],[1:9 11 14]);
S(7).blncd = S(7).lcsynt([1 50:end],1:11);
S(8).blncd = S(8).lcsynt([1 3:end],1:11);
S(9).blncd = S(9).lcsynt([1 10:end],1:11);
S(10).blncd = S(10).lcsynt;
S(11).blncd = S(11).lcsynt([1 3:end],:);
S(12).blncd = S(12).lcsynt([1 36:end],:);
S(13).blncd = S(13).lcsynt([1 3:end],1:11);
S(14).blncd = S(14).lcsynt([1 22:end],:);
S(15).blncd = S(15).lcsynt([1 20:end],:);

S(16).blncd = S(16).lcsynt([1 8:end],[1:11 14]);
S(17).blncd = S(17).lcsynt([1 14:end],[1:9 11 14:16]);
S(18).blncd = S(18).lcsynt([1 22:end],[1:12 14:16]);
S(19).blncd = S(19).lcsynt([1 25:end],[1:12 14:16]);
S(20).blncd = S(20).lcsynt([1 24:end],[1:12 14:16 18]);
S(21).blncd = S(21).lcsynt([1 25:end],[1:12 14:16 18]);
S(22).blncd = S(22).lcsynt(:,1:16);
S(23).blncd = S(23).lcsynt([1 33:end],[1:12 14]);

    yieldsNOK = S(23).blncd(2:end,2:end);
%     Interpolation using PCs
%     matsNOK  = S(23).blncd(1,2:end);
%     datesNOK = S(23).blncd(2:end,1);
%     nobs = size(yieldsNOK,1);
%     [coeffNOK,scoreNOK,~,~,~,muNOK] = pca(yieldsNOK,'algorithm','als');
%     yieldsALS = scoreNOK*coeffNOK' + repmat(muNOK,nobs,1);
%     sum(yieldsNOK - yieldsALS)
%     for l = 1:nobs
%         plot(matsNOK,yieldsNOK(l,:)','o',matsNOK,yieldsALS(l,:)','x')
%         title([S(23).ccy '  ' datestr(datesNOK(l))]), ylabel('%'), xlabel('Maturity')
%         H(l) = getframe(gcf);
%     end
    
    colsMSS   = [5 6 7 9 10 11];
%     Linear interpolation
%     datesMSS  = datesNOK(74:81);
%     slopeNOK  = (yieldsNOK(82,colsMSS) - yieldsNOK(73,colsMSS))./(datesNOK(82) - datesNOK(73));
%     yieldsMSS = slopeNOK.*(datesMSS - datesNOK(73)) + yieldsNOK(73,colsMSS);
    yieldsINT = yieldsNOK;
%     yieldsINT(74,colsMSS) = yieldsNOK(73,colsMSS);
    yieldsINT(74:81,colsMSS) = repmat(yieldsNOK(82,colsMSS),8,1);
%     for l = 74:81
%         plot(matsNOK,yieldsNOK(l,:)','o',matsNOK,yieldsINT(l,:)','x')
%         title([S(23).ccy '  ' datestr(datesNOK(l))]), ylabel('%'), xlabel('Maturity')
%         H(l) = getframe(gcf);
%     end
    S(23).blncd(2:end,2:end) = yieldsINT;
    
S(24).blncd = S(24).lcsynt([1 35:end],[1:9 11 14:16]);
S(25).blncd = S(25).lcsynt([1 33:end],[1:12 14:16]);

%% JSZ Estimation per Country

ncntrs = length(S);
N = 3;
dt = 1/12;
corrPC = cell(N,4);

for k = 2%1:ncntrs
    mats  = S(k).blncd(1,2:end);
    dates = S(k).blncd(2:end,1);
    yields = S(k).blncd(2:end,2:end);
    nobs = size(yields,1);
    W = pcacov(cov(yields));
    W = W(:,1:N)';
    cP = yields*W'; % T*N
    VERBOSE = false;
    [llks, AcP, BcP, AX, BX, kinfQ, K0P_cP, K1P_cP, sigma_e, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, cP, llkP, llkQ,  K0Q_X, K1Q_X, rho0_X, rho1_X, Sigma_cP] = ...
        sample_estimation_fun(W, yields, mats, dt, VERBOSE);
    [llk, AcP, BcP, AX, BX, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, cP, yields_filtered, cP_filtered] = ...
        jszLLK_KF(yields, W, K1Q_X, kinfQ, Sigma_cP, mats, dt, K0P_cP, K1P_cP, sigma_e);
    [BcP, AcP, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, K0Q_X, K1Q_X, AX, BX, Sigma_X] = jszLoadings(W, K1Q_X, kinfQ, Sigma_cP, mats, dt);
%     rinfQ = -kinfQ/K1Q_X(1,1);
    yields_kf = ones(length(dates),1)*AcP + (yields*W.')*BcP;
%     % Compare
%     plot(dates,yields(:,7),'x',dates,yields_kf(:,7),'+')    % Time series
%     plot(mats,yields(216,:),'x',mats,yields_kf(216,:),'+')  % Cross section
    
    [~,PCs] = pca(yields,'NumComponents',3);
    [~,PCs_kf] = pca(yields_kf,'NumComponents',3);
    corrPC{k,1} = S(k).iso; corrPC{k,2} = corr(PCs(:,1),PCs_kf(:,1)); 
    corrPC{k,3} = corr(PCs(:,2),PCs_kf(:,2)); corrPC{k,4} = corr(PCs(:,3),PCs_kf(:,3));
%     plot(dates,[PCs(:,1) PCs_kf(:,1)])              % Compare with yields_filtered and cP_filtered

%     for l = 1:nobs
%         plot(mats,yields(l,:)','o',mats,yields_kf(l,:)','x')
%         title([S(k).ccy '  ' datestr(dates(l))]), ylabel('%'), xlabel('Maturity')
%         H(l) = getframe(gcf);
%     end
    % No good fits: BRL, IDR, PEN, PHP
    
    
    % TP
%     [K1P_cP, K0P_cP, Omega_hat] = regressVAR(cP);
%     K1P_cP = K1P_cP - eye(N);  % Given by sample_estimation.m

    % [A,B] = pricing_params(round(mats/dt),K0Q_cP,K1Q_cP,Sigma_cP,rho0_cP*dt,rho1_cP*dt,dt);
    dt = 1/12;
    mats_periods = round(mats/dt);
    N      = length(K0);
    K0 = K0P_cP; %K0Q_cP;
    K1 = K1P_cP + eye(N); %K1Q_cP;
    Hcov = Sigma_cP; %Omega_hat;
    rho0d = rho0_cP*dt;
    rho1d = rho1_cP*dt;
    
    % function [A,B] = pricing_params(mats_periods,K0,K1,Sigma,rho0d,rho1d,dt)
    M      = length(mats_periods);
    N      = length(K0);
    A      = zeros(1,M);
    B      = zeros(N,M);
    A(1)   = -rho0d;
    B(:,1) = -rho1d;
    for t  = 2:M
        A(t)   = -rho0d + A(t-1) + K0'*B(:,t-1) + 0.5*B(:,t-1)'*Hcov*B(:,t-1);
        B(:,t) = -rho1d + K1'*B(:,t-1);
%         B(:,t) = -rho1d + B(:,t-1) + K1'*B(:,t-1);
    end
    Ay = -A./mats_periods;   % Loadings for yields
    By = -B./mats_periods;
    Ay = Ay/dt;               % Annualized
    By = By/dt;
    % end
    
    [B_P, A_P] = gaussianDiscreteYieldLoadingsRecurrence(mats_periods, K0P_cP, K1P_cP, Sigma, rho0d, rho1d, dt);
    
    % This is what is reported by jszLoadings.m (i.e. AcP = A_Q, BcP = B_Q)
%     [B_Q, A_Q] = gaussianDiscreteYieldLoadingsRecurrence(mats_periods, K0Q_cP, K1Q_cP, Sigma, rho0d, rho1d, dt);
    
%     yields_P = ones(length(dates),1)*A + (yields*W.')*B;
%     yields_P = ones(length(dates),1)*A + cP*B;
    yields_P = ones(length(dates),1)*A_P + cP*B_P;
    
%     plot(dates,yields(:,7),'x',dates,yields_P(:,7),'+') % Time series
    plot(mats,yields(50,:),'x',mats,yields_P(50,:),'+') % Cross-section
    legend({'Synthetic Yield','Expected Yield'})
%     yyaxis left
%     plot(dates,yields(:,7),'x')
%     ylabel('Synthetic Yield')
%     yyaxis right
%     plot(dates,yields_P(:,7),'+')
%     ylabel('Expected Yield')
end


