%% Plot Risk Premia
% This code plots the risk premia of different countries together.
% Assumes that rp_adjusted.m has already been run
% Calls to m-files: pnum2cell.m
%
% Pavel Solís (pavel.solis@gmail.com), September 2018
%
%% Risk premia per maturity across countries
saveit = 0;                                     % 1 to save figures, 0 otherwise
yr_dbl = 5;
yr_str = num2str(yr_dbl);
rp     = struct('cty',{},'dates',{},'data',{});
fltrRP = ismember(header_monthly(:,1),'LCRFRP') & ismember(header_monthly(:,3),yr_str);

% Save the country, dates and the data for all countries in a structure
for k = 1:numel(IDs)
    id          = IDs(k);
    fltrCTY     = dataset_monthly(:,2) == id;
    rp(k).cty   = ctrsLC{k};
    rp(k).dates = dataset_monthly(fltrCTY,1);
    rp(k).data  = dataset_monthly(fltrCTY,fltrRP);
end

% Define the order in which countries will appear
% g = [2 13 11; 1 4 6; 8 9 10; 7 12 15; 3 5 14];    % By pattern
g = [1 5 6; 2 8 9; 3 11 13; 7 10 15; 4 12 14];      % By region

for k = 1:4
    if k < 4
        subplot(2,2,k)
        plot(rp(g(k,1)).dates,rp(g(k,1)).data,rp(g(k,2)).dates,rp(g(k,2)).data,'-.',...
            rp(g(k,3)).dates,rp(g(k,3)).data,'--');
        labels = {rp(g(k,1)).cty, rp(g(k,2)).cty, rp(g(k,3)).cty};
        legend(labels,'Location','best','Orientation','horizontal')
        datetick('x','yy')
    else
        subplot(2,2,k)
        plot(rp(g(k,1)).dates,rp(g(k,1)).data,rp(g(k,2)).dates,rp(g(k,2)).data,'-.');
        labels = {rp(g(k,1)).cty, rp(g(k,2)).cty};
        legend(labels,'Location','best','Orientation','horizontal')
        datetick('x','yy')
    end
end
ax = axes('Units','Normal','Position',[.075 .075 .85 .85],'Visible','off');
set(get(ax,'Title'),'Visible','on')
title([yr_str ' Yr Term Premia'])
save_figure(['rp_' yr_str 'yr_1'],saveit)

% Countries not in subplot
figure
k = 5;
plot(rp(g(k,1)).dates,rp(g(k,1)).data,rp(g(k,2)).dates,rp(g(k,2)).data,'-.',...
    rp(g(k,3)).dates,rp(g(k,3)).data,'--');
labels = {rp(g(k,1)).cty, rp(g(k,2)).cty, rp(g(k,3)).cty};
legend(labels,'Location','best','Orientation','horizontal')
datetick('x','yy')
title([yr_str ' Yr Term Premia'])
save_figure(['rp_' yr_str 'yr_2'],saveit)


%% Risk premia per country across maturities (Term structure of risk premia)
keydates = [733681; 735385; 736664];        % datenum for Sept2008, May2013, Nov2016
years    = [1; 5; 10];                      % Maturities for term structure
tsmats   = pnum2cell(years);

for k = 1:numel(IDs)
    id      = IDs(k);
    fltrCTY = dataset_monthly(:,2) == id;
    fltrYRS = ismember(header_monthly(:,1),'LCRFRP') & ismember(header_monthly(:,3),tsmats);
    figure
    p1      = plot(dataset_monthly(fltrCTY,1),dataset_monthly(fltrCTY,fltrYRS));
    labels  = strcat(tsmats,' Yr');
    
    line(repmat(keydates,1,2),get(gca,'YLim'),'Color',[0 0 0]+0.65,'LineStyle','-.'); % Vertical lines
    legend(p1,labels,'Location','best','Orientation','horizontal')
    title([ctrsLC{k} ' Term Structure of Term Premia'])
    datetick('x','yy')
    save_figure(['rp_ts_' ctrsLC{k}],saveit)
end

clear k g id p1 fltr* saveit keydates labels tsmats years ax yr_*
%% Sources
%
% Insert a title over a group of subplots
% https://www.mathworks.com/matlabcentral/answers/100459-how-can-i-insert-a-title-over-a-group-of-subplots