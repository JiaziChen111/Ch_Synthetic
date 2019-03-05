function [data_usrp,hdr_usrp,stats_rpus,pc_expus] = rp_us(dataset_daily,header_daily,other_tp)
% This function estimates the US risk premia using yield curve data from 
% GSW (2007) and compares it with those obtained by KM (2005) and ACM (2013).
% Calls to m-files: fit_ATSM.m, y_NSS.m, end_of_month.m, dataset_in_range.m,
% read_acm.m, getFredData.m
%
%     INPUTS
% dataset_daily - matrix with daily obs as rows (top-down is first-last obs), col1 has dates
% header_daily  - cell with names for the columns of dataset_daily
% other_tp      - double: 1 to plot different estimates of US TP, 0 otherwise
%
%     OUTPUT
% data_usrp  - matrix with end-of-month fitted yields for specified maturities
% hdr_usrp   - cell with names for the columns of data_usrp
% stats_rpus - matrix with statistics for all maturities
% pc_expus   - cell with the proportion of variation explained by first PCs
% 
% Pavel Solís (pavel.solis@gmail.com), September 2018
%%
fltrUSyc   = ismember(header_daily(:,1),'USD') & ismember(header_daily(:,2),'HC');
fltrPRM    = ismember(header_daily(:,2),'PARAMETER'); % 1 for US NSS model parameters
tnrmax     = 10;                                % Maximum tenor needed is 10yrs
maturities = [0.25 1:tnrmax];                   % Maturities used
mats2estim = maturities(2:end);                 % Number of yields to be estimated
times      = linspace(0,tnrmax);
id         = 111;

% End of month data
idxDates = sum(isnan(dataset_daily(:,fltrUSyc)),2) == 0;
data_aux = dataset_daily(idxDates,:);           % Rows with data (not NaN)
data_aux = end_of_month(data_aux);              % Last available trading day per month
params0  = data_aux(:,fltrPRM);                 % Parameters to generate US yield curve
nobs     = size(data_aux,1);

% Database
data_usrp = [];
for l = 1:nobs
    yields    = y_NSS(params0(l,:),maturities); % Through NSS since need 3-month rate
    data_usrp = [data_usrp; data_aux(l,1), id, yields];
end

% ATSM fitted yields
ydata       = data_usrp(:,3:end);               % col3 is 3-month rate
[yieldsQ,yieldsP,yieldsE,rmse,explained] = fit_ATSM(mats2estim,ydata);
risk_premia = ydata - yieldsE; %= ydata(:,2:end) - yieldsE; When update fit_ATSM ie 10 mats in yieldsE
data_usrp   = [data_usrp,params0,yieldsE(:,2:end),yieldsQ,yieldsP,risk_premia(:,2:end),rmse];

% Header
hdr_usrp = construct_monthly_hdr(maturities,'',3);
        
% Statistics
y = ydata(:,2:end); z = risk_premia(:,2:end);
stats_rpus = [mats2estim; mean(y); std(y); mean(z); std(z); max(z); min(z); 
             repmat(size(z,1),1,size(z,2))];
stats_rpus = round(stats_rpus,2);
pc_expus   = ['USD'; cellstr(num2str(round(explained(1:3),2)));
             cellstr(num2str(round(sum(explained(1:3)),2)))]; % All entries are strings

% Plot yields: N-S-S v. Expected v. ATSM
for l = 1:size(ydata,1)
    plot(times,y_NSS(params0(l,:),times),'r-',...
        mats2estim,yieldsQ(l,:),'c*',mats2estim,yieldsP(l,:),'b--o',...
        maturities,yieldsE(l,:),'mx') % [!]
    % title([num2str(id) '  ' datestr(dates_usyc(l))])
    title(['USD ' datestr(data_usrp(l,1))])
    H(l) = getframe(gcf);
end
clear H
close

%% Plots
if other_tp == 1
    yr_dbl   = 10;                                % Tenor to plot, adjust as wanted
    yr_str   = num2str(yr_dbl);                   % Char used to extract the respective year
    fltrZCYR = ismember(hdr_usrp(:,1),'USZC') & ismember(hdr_usrp(:,3),yr_str);
    fltrRPYR = ismember(hdr_usrp(:,1),'USRP') & ismember(hdr_usrp(:,3),yr_str);

    % GSW yield vs implied Q-yield
    plot(data_usrp(:,1),data_usrp(:,fltrZCYR),data_usrp(:,1),yieldsQ(:,end-10+yr_dbl))
    datetick('x','yy')
    legend({'GSW','Q'},'Location','best')
    ylabel('Percent')
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
    ylabel('Percent')
    title('ACM Parts')

    figure                                    % Fit of ACM
    plot(data_usrp(:,1),data_usrp(:,fltrZCYR),data_acm(:,1),acm_parts(:,1))
    datetick('x','yy')
    legend({'GSW','ACMY'},'Location','best')
    ylabel('Percent')
    title([yr_str ' year ' 'GSW vs ACMY'])

    KW = getFredData(['THREEFYTP' yr_str],datestr(date1,29),datestr(date2,29)); % 29: date format ID
    KWtp = KW.Data;
    [row,~] = find(isnan(KWtp));
    KWtp(row,:)=[];                             % Remove NaN before doing end-of-month
    KWtp = end_of_month(KWtp);
    KWtp = dataset_in_range(KWtp,date1,date2);

    figure                                      % Comparison of TP estimates
    p1 = plot(data_usrp(:,1),data_usrp(:,fltrRPYR),data_acm(:,1),acm_parts(:,2),KWtp(:,1),KWtp(:,2));
    datetick('x','yy')
    line(xlim,[0,0],'Color',[0 0 0]+0.6);  % Horizontal line at the origin
    legend(p1,{'ATSM','ACM','KW'},'Location','best')
    ylabel('Percent')
    title([yr_str ' year ' 'estimated risk premia vs ACM vs KW'])

    figure                                      % Comparison of TP estimates
    keydates = [733681; 733863; 735415; 736664];
    p1 = plot(data_acm(:,1),acm_parts(:,2),KWtp(:,1),KWtp(:,2));
    line(repmat(keydates,1,2),get(gca,'YLim'),'Color',[0 0 0]+0.65,'LineStyle','--'); %Vertical lines
    datetick('x','yy')
    line(xlim,[0,0],'Color',[0 0 0]+0.6);  % Horizontal line at the origin
    legend(p1,{'ACM','KW'},'Location','best')
    ylabel('Percent')
    title(['US ' yr_str '-Year Term Premium'])
    save_figure(['rp_us_' yr_str 'yr_ACMvsKM'],1)
    
    corr([data_usrp(:,fltrRPYR),acm_parts(:,2),KWtp(:,2)])
    mean([data_usrp(:,fltrRPYR),acm_parts(:,2),KWtp(:,2)])
end
 