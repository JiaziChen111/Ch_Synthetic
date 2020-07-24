function rp = rp_compare(dataset_mth_rf,header_mth_rf,dataset_mth_rk,header_mth_rk,...
    dataset_daily,header_daily,ctrsNcods_rf,ctrsNcods_rk,saveit)
% This function compares term premia estimates using risk-free and actual
% (fitted N-S) LC yield curves.
% Note: It does not assume that header_mth_* have variables in the same order.
% Calls to m-files: save_figure.m, pnum2cell.m
%
%     INPUTS
% dataset_mth_* - matrix with monthly obs of N-S curves as rows, col1 has dates
% header_mth_*  - cell with names for the columns of data_monthly
% ctrsNcods_*   - cell with countries (and their IMF codes) to plot
% saveit        - double: 1 to save figures, 0 otherwise
% 
%     OUTPUT
% rp - structure with data for rp (rf and rk) and lccs
% 
% Pavel Solís (pavel.solis@gmail.com), October 2018
%
%%
% Find overlapping countries
IDs      = cell2mat(ctrsNcods_rf(:,2));
ctrsLC   = ctrsNcods_rf(:,1);
fltrWHO  = ismember(ctrsLC,ctrsNcods_rk(:,1));   % Assumes size(ctrsNcods_rf,1) >= size(ctrsNcods_rk,1)
ctrsLC   = ctrsLC(fltrWHO,:);
IDs      = IDs(fltrWHO,:);

% Filters
yrs2plot = [5; 10];                                 % Maturities to plot
yrs_str  = pnum2cell(yrs2plot);
fltrRP1  = ismember(header_mth_rf(:,1),'LCRFRP') & ismember(header_mth_rf(:,3),yrs_str);
fltrRP2  = ismember(header_mth_rk(:,1),'LCRKRP') & ismember(header_mth_rk(:,3),yrs_str);
fltrLCCS = ismember(header_daily(:,2),'LCCS')    & ismember(header_daily(:,5),yrs_str);

% Save country, dates and data in a structure
rp    = struct('ctry',{},'dts1',{},'dat1',{},'dts2',{},'dat2',{},'dts3',{},'dat3',{});
for k = 1:numel(IDs)
    id         = IDs(k);
    fltrCTY1   = dataset_mth_rf(:,2) == id;
    fltrCTY2   = dataset_mth_rk(:,2) == id;
    rp(k).ctry = ctrsLC{k};
    rp(k).dts1 = dataset_mth_rf(fltrCTY1,1);        % sample window need not match
    rp(k).dat1 = dataset_mth_rf(fltrCTY1,fltrRP1);  % ncols = numel(yrs2plot)
    rp(k).dts2 = dataset_mth_rk(fltrCTY2,1);
    rp(k).dat2 = dataset_mth_rk(fltrCTY2,fltrRP2);
    
    % Add LCCS to structure
    fltrCS     = fltrLCCS & ismember(header_daily(:,1),ctrsLC{k});
    aux        = [dataset_daily(:,1) dataset_daily(:,fltrCS)]; % ncols = numel(1+yrs2plot)
    idx1       = sum(isnan(aux(:,2:end)),2) == 0;   % Rows that sum to zero have obs in all cols
    lccs       = aux(idx1,:);                        % Remove NaNs before end of month
    lccs       = end_of_month(lccs);
    rp(k).dts3 = lccs(:,1);
    rp(k).dat3 = lccs(:,2:end);
end

% Plots
keydates = [733681; 733863; 735415; 736664];        % datenum for Sept2008, March 2009, June2013, Nov2016
for l = 1:numel(yrs2plot)
    for k = 1:numel(IDs)
        % Construct variable TP + LCCS
        temp         = struct('date',{});
        temp(1).date = rp(k).dts2;
        temp(2).date = rp(k).dts3;
        [nobs,idx2]  = min([length(rp(k).dat2) length(rp(k).dat3)]);
        dates        = temp(idx2).date;     % They need not have same number of obs
        tpcs         = rp(k).dat2(end-nobs+1:end,l) + rp(k).dat3(end-nobs+1:end,l);
                                            % Assumes both series end on the same date
        figure
        if k == 11
            p1     = plot(rp(k).dts1,rp(k).dat1(:,l),rp(k).dts2(60:end),rp(k).dat2(60:end,l),'-.',dates,tpcs,'--');
        else
            p1     = plot(rp(k).dts1,rp(k).dat1(:,l),rp(k).dts2,rp(k).dat2(:,l),'-.',dates,tpcs,'--');
        end
        labels = {'Synthetic TP', 'Actual TP', 'Synth TP + LCCS'};
        line(repmat(keydates,1,2),get(gca,'YLim'),'Color',[0 0 0]+0.65,'LineStyle','--'); %Vertical lines
        datetick('x','yy')
        line(xlim,[0,0],'Color',[0 0 0]+0.6);  % Horizontal line at the origin
        legend(p1,labels,'Location','best')
        ylabel('Percent')
        title([rp(k).ctry ' ' yrs_str{l} '-Year Term Premium'])
        save_figure(['rp_cmp_' yrs_str{l} '_' rp(k).ctry],saveit)
    end
end
 