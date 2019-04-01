%% Plot Spreads
% This code plots the forward premium, local and foreign interest rate spreads
% and deviations from covered interest rate parity for different countries.
% Assumes that header_daily and dataset_daily are in the workspace.
% m-files called: save_figure.m
%
% Pavel Solís (pavel.solis@gmail.com), April 2019
%%
if ~exist('T_cip','var')                                % Run code if T_cip is not in the workspace
    run read_cip.m
end

[LCs,currEM,currAE] = read_currencies(T_cip);
dates   = dataset_daily(:,1);
figdir = 'CIPvars'; figsave = false;

%% Spreads per maturity for each country
types  = {'RHO','CIPDEV','LCSPRD','FCSPRD'};
year   = '5';
fltrTP = ismember(header_daily(:,2),types);             % To report the specific types
fltrYR = ismember(header_daily(:,5),year);              % To report a specific year
for k = 1:numel(LCs)
    fltrLC  = ismember(header_daily(:,1),LCs{k});
    fltr    = fltrLC & fltrTP & fltrYR;                 % Criteria to meet
    sprds   = dataset_daily(:,fltr);
    sprdsMA = movmean(sprds,10);                        % To report results as in Du & Schreger (2016)
    labels  = header_daily(fltr,2);                     % Types available for the currency
    figure
    plot(dates,sprdsMA)
    title(['Spreads: ' LCs{k} ' ' year 'Y'])
    ylabel('%')
    legend(labels)
    datetick('x','yy','keeplimits')                     % Annual ticks
    figname = ['sprds_' LCs{k} '_' year 'y'];
    save_figure(figdir,figname,figsave)
end

%% Spreads per country across maturities
keydates = datenum(['30-Sep-2008';'31-May-2013';'30-Nov-2016']);
fltrYR   = ismember(header_daily(:,5),{'1','5','10'});  % To report the specific years
for j = 1:numel(types)
    fltrTP = ismember(header_daily(:,2),types{j});      % To report a specific type
    for k = 1:numel(LCs)
        fltrLC = ismember(header_daily(:,1),LCs{k});
        fltr   = fltrLC & fltrTP & fltrYR;              % Criteria to meet
        if sum(fltr) > 0                                % Some countries don't have the specified type
            sprds   = dataset_daily(:,fltr);
            sprdsMA = movmean(sprds,10);
            labels  = strcat(header_daily(fltr,5),'Y'); % Tenors of the spreads
            figure
            p1 = plot(dates,sprdsMA);
            line(repmat(keydates,1,2),get(gca,'YLim'),'Color',[0 0 0]+0.65,'LineStyle','-.');
            legend(p1,labels,'Location','best','Orientation','horizontal')
            title([types{j} ' ' LCs{k}])
            ylabel('%')
            datetick('x','yy','keeplimits')
            figname = ['TS_' types{j} '_' LCs{k}];      % Term structure per type
            save_figure(figdir,figname,figsave)
        end
    end
end

%% Spreads per maturity across countries
% To see whether CIP deviations are correlated across countries in the sample

type     = 'CIPDEV';
group    = {currEM,currAE};
corrmtrx = cell(length(group),2);
fltrTY   = ismember(header_daily(:,2),type) & ismember(header_daily(:,5),year);
for k = 1:length(group)
    fltrGP  = ismember(header_daily(:,1),group{k});
    fltr    = fltrGP & fltrTY;
    sprds   = dataset_daily(:,fltr);
    sprdsMA = movmean(sprds,10);
    labels  = header_daily(fltr,1);                     % Countries
    figure
    plot(dates,sprdsMA)
    title([type ' ' year 'Y'])
    ylabel('%')
    legend(labels,'Location','best','Orientation','horizontal','NumColumns',5)
    datetick('x','yy','keeplimits')
    figname = ['G' k '_' type '_' year 'y'];
    save_figure(figdir,figname,figsave)
    [corrmtrx{k,1},corrmtrx{k,2}] = corrcoef(sprds,'Rows','complete');  % Omits rows with NaN values
end

clear j k p1 LCs curr* type* year* fltr* sprds* fig* dates keydates labels
