%% Estimate US Risk Premia
% This code estimates the US risk premia using yield curve data from GSW (2007)
% and compares it with those obtained by KM (2005) and ACM (2013).
% Assumes in the workspace: dataset_daily, header_daily, tnrs, tnrs3mo
% Calls to m-files: fit_ATSM.m, y_NSS.m, end_of_month.m, dataset_in_range.m,
% read_acm.m, getFredData.m
%
% Pavel Solís (pavel.solis@gmail.com), September 2018
%%
data_usrp   = [];
fltrUSyc    = ismember(header_daily(:,1),'USD') & ismember(header_daily(:,2),'HC');
fltrPRM     = ismember(header_daily(:,2),'PARAMETER'); % 1 for US NSS model parameters
maturities  = [0.25 1:10];                     % Maturities used
maturities1 = 1:10;                            % Number of yields to be estimated
times       = linspace(0,10);
yr_dbl      = 10;                              % Adjust depending on the tenor wanted
yr_str      = num2str(yr_dbl);                 % Char used to extract the respective year
id          = 111;

% End of month data
idxDates = sum(isnan(dataset_daily(:,fltrUSyc)),2) == 0;
data_aux = dataset_daily(idxDates,:);           % Rows with data (not NaN)
data_aux = end_of_month(data_aux);              % Last available trading day per month
params0  = data_aux(:,fltrPRM);                 % Parameters to generate US yield curve
nobs     = size(data_aux,1);

% Database
for l = 1:nobs
    yields    = y_NSS(params0(l,:),maturities); % Through NSS since need 3-month rate
    data_usrp = [data_usrp; data_aux(l,1), id, yields];
end

% ATSM fitted yields
ydata       = data_usrp(:,3:end);               % col3 is 3-month rate
[yieldsQ,yieldsP,yieldsE,rmse,explained] = fit_ATSM(maturities1,ydata);
risk_premia = ydata - yieldsE; %= ydata(:,2:end) - yieldsE; When update fit_ATSM ie 10 mats in yieldsE
data_usrp   = [data_usrp,params0,yieldsE(:,2:end),yieldsQ,yieldsP,risk_premia(:,2:end),rmse];

% Header
name_us   = strcat('USD ZERO-COUPON YIELD',{' '},tnrs3mo,' YR');
paramsNSS = {'BETA0';'BETA1';'BETA2';'BETA3';'TAU1';'TAU2'};
name_yE   = strcat('USD EXPECTED SHORT RATE IN',{' '},tnrs,' YR');
name_yQ   = strcat('USD RISK NEUTRAL YIELD',{' '},tnrs,' YR');
name_yP   = strcat('USD PHYSICAL YIELD',{' '},tnrs,' YR');
name_rp   = strcat('USD RISK PREMIUM',{' '},tnrs,' YR');
hdr_ycus  = construct_hdr('USZC',name_us,tnrs3mo);
hdr_param = construct_hdr('PARAMETER','USD N-S-S YIELD CURVE',paramsNSS);
hdr_yE    = construct_hdr('USYE',name_yE,tnrs);
hdr_yQ    = construct_hdr('USYQ',name_yQ,tnrs);
hdr_yP    = construct_hdr('USYP',name_yP,tnrs);
hdr_rpus  = construct_hdr('USRP',name_rp,tnrs);
hdr_rmseu = construct_hdr('RMSEATSMUSD','USD ATSM FIT RMSE','X');
hdr_usrp  = [{'type','description','tenor'; 'IMFC','IMF CODE','X'};
            hdr_ycus; hdr_param; hdr_yE; hdr_yQ; hdr_yP; hdr_rpus; hdr_rmseu];

% Statistics
fltrZC  = ismember(hdr_usrp(:,1),'USZC') & ~ismember(hdr_usrp(:,3),'0.25');
fltrRP  = ismember(hdr_usrp(:,1),'USRP');
tnrs_rp = cellfun(@str2num,hdr_usrp(fltrRP,3)); % Convert str into double
y       = data_usrp(:,fltrZC);
z       = data_usrp(:,fltrRP);
stats_rpus = [tnrs_rp'; mean(y); std(y); mean(z); std(z); max(z); min(z); 
             repmat(size(z,1),1,size(z,2))];
stats_rpus = round(stats_rpus,2);
pc_expus   = ['USD'; cellstr(num2str(round(explained(1:3),2)));
             cellstr(num2str(round(sum(explained(1:3)),2)))]; % Compare approach with rp_adjusted.m

% Plot yields: N-S-S v. Expected v. ATSM
for l = 1:size(ydata,1)
    plot(times,y_NSS(params0(l,:),times),'r-',...
        maturities1,yieldsQ(l,:),'c*',maturities1,yieldsP(l,:),'b--o',...
        maturities,yieldsE(l,:),'mx') % [!]
    % title([num2str(id) '  ' datestr(dates_usyc(l))])
    title([num2str(id) '  ' datestr(data_usrp(l,1))])
    H(l) = getframe(gcf);
end
clear H
close

%% Plots
fltrZCYR = fltrZC & ismember(hdr_usrp(:,3),yr_str);
fltrRPYR = fltrRP & ismember(hdr_usrp(:,3),yr_str);

% GSW yield vs implied Q-yield
plot(data_usrp(:,1),data_usrp(:,fltrZCYR),data_usrp(:,1),yieldsQ(:,end-10+yr_dbl))
datetick('x','yy')
legend({'GSW','Q'},'Location','best')
title([yr_str ' year ' 'GSW and Q'])

% Compare estimated risk premia with ACM (2013) and KM (2005) term premium
date1    = min(data_usrp(:,1));             % First date for ACM relative to US
date2    = max(data_usrp(:,1));             % Last date for ACM relative to US
run read_acm.m
data_acm = dataset_in_range(data_acm,date1,date2);

if yr_dbl < 10
    acm_labels = {['ACMY0' yr_str],['ACMTP0' yr_str],['ACMRNY0' yr_str]};
else
    acm_labels = {['ACMY' yr_str],['ACMTP' yr_str],['ACMRNY' yr_str]};
end
fltrACM1  = ismember(hdr_acm,acm_labels);
acm_parts = data_acm(:,fltrACM1);

figure
plot(data_acm(:,1),acm_parts)             % ACMY = ACMTP + ACMRNY
legend(acm_labels,'Location','best')
datetick('x','yy')
title('ACM Parts')

figure                                    % Fit of ACM
plot(data_usrp(:,1),data_usrp(:,fltrZCYR),data_acm(:,1),acm_parts(:,1))
datetick('x','yy')
legend({'GSW','ACMY'},'Location','best')
title([yr_str ' year ' 'GSW vs ACMY'])

KW = getFredData(['THREEFYTP' yr_str],datestr(date1,29),datestr(date2,29)); % 29 - date format identifier
KWtp = KW.Data;
[row,~] = find(isnan(KWtp));
KWtp(row,:)=[];                             % Remove NaN before doing end-of-month
KWtp = end_of_month(KWtp);
KWtp = dataset_in_range(KWtp,date1,date2);

figure                                      % Comparison of TP estimates
plot(data_usrp(:,1),data_usrp(:,fltrRPYR),data_acm(:,1),acm_parts(:,2),KWtp(:,1),KWtp(:,2))
legend({'ATSM','ACM','KW'},'Location','best')
datetick('x','yy')
title([yr_str ' year ' 'estimated risk premia vs ACM vs KW'])

corr([data_usrp(:,fltrRPYR),acm_parts(:,2),KWtp(:,2)])
mean([data_usrp(:,fltrRPYR),acm_parts(:,2),KWtp(:,2)])

clear date explained fltr* id l maturities* params0 times date1 date2 dateIdx
clear acm_parts acm_labels yr_* row KWtp yields* x y z nobs idxDates tnrs_*
clear name_* hdr_y* hdr_param hdr_r* paramsNSS rmse data_aux risk_* ydata
