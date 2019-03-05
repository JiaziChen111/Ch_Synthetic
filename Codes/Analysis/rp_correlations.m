function [data_resd,hdr_resd,corr_tpus,stats_corr_tpus,corr_tpcs,...
    corr_tpepu,corr_ogepu] = rp_correlations(dataset_monthly,...
    header_monthly,dataset_daily,header_daily,data_usrp,hdr_usrp,YCtype,ctrsNcods)
% This function gives the correlations of the estimated term premia in EMs
% with the US term premium, with the EPU index (SBD 2016) and with the LC 
% credit spread per maturitiy. Also saves the residuals of regressing EM TP
% on the US TP (used by rp_common_factors.m).
% Calls to m-files: read_epu_idx.m, rp_us.m, dataset_in_range.m
%
%     INPUTS
% dataset_monthly - matrix with end-of-month N-S curves and their decomposition, col1 has dates
% header_monthly  - cell with names for the columns of dataset_monthly
% dataset_daily   - matrix with daily obs as rows (top-down is first-last obs), col1 has dates
% header_daily    - cell with names for the columns of dataset_daily
% data_usrp
% hdr_usrp
% YCtype          - char with the type of LC yield curve to use (ie risky or risk-free)
% ctrsNcods       - cell with countries (and their IMF codes)
%
%     OUTPUT
% data_resd       - matrix with residuals of regressing EM TP on the US TP for all maturities
% hdr_resd        - cell with names for the columns of data_resd
% corr_tpus       - matrix with correlation of EM TP with US TP (rows: countries, cols: tenors)
% stats_corr_tpus - matrix with statistics (mean, max, min) of corr_tpus per tenor
% corr_tpcs       - matrix with corr of EM TP and LCCS (when exists) (rows: countries, cols: tenors)
% corr_tpepu      - matrix with corr of EM TP and EPU index (rows: countries, cols: tenors)
% corr_ogepu      - matrix with corr of EM orthogonal TP and EPU index
% 
% Pavel Solís (pavel.solis@gmail.com), September 2018
%%
run read_epu_idx.m
% [data_usrp,hdr_usrp,stats_rpus] = rp_us(dataset_daily,header_daily,0);
fltrRP1   = ismember(header_monthly(:,1),[YCtype 'RP']);
fltrRP2   = ismember(hdr_usrp(:,1),'USRP');
fltrLCCS  = ismember(header_daily(:,2),'LCCS');
ntnrs     = sum(fltrRP1);
IDs       = cell2mat(ctrsNcods(:,2));
ctrsLC    = ctrsNcods(:,1);

corr_tpcs = nan(numel(IDs),ntnrs);
data_resd = [];     corr_tpus = [];     corr_tpepu = [];    corr_ogepu = [];
for k = 1:ntnrs
    fltrEM   = fltrRP1 & ismember(header_monthly(:,3),num2str(k));
    fltrUS   = fltrRP2 & ismember(hdr_usrp(:,3),num2str(k));
    res_aux1 = [];  tp_aux2  = [];   tp_aux3 = [];  tp_aux4 = [];
    
    for  l  = 1:numel(IDs)
        % Extract EM TP
        cty     = ctrsLC{l};
        fltrCTY = dataset_monthly(:,2) == IDs(l);
        tp_EM   = dataset_monthly(fltrCTY,fltrEM);
        date1   = min(dataset_monthly(fltrCTY,1));  % First date for US relative to EM
        date2   = max(dataset_monthly(fltrCTY,1));  % Last date for US relative to EM
        
        % Correlation of EM TP with US TP
        tp_aux1 = dataset_in_range(data_usrp,date1,date2); % Trim to tp_EM range
        tp_US   = tp_aux1(:,fltrUS);
        tp_aux2 = [tp_aux2; corr(tp_EM,tp_US)];     % IT SEEMS TO BE A PROBLEM FOR ILS size tp_EM < tp_US
        
        % Regress EM TP on US TP and save residual
        mdl      = fitlm(tp_US,tp_EM);
        res_aux1 = [res_aux1; mdl.Residuals.Raw];
        
        % Correlation of EM TP with LCCS (later need to CHECK if end-of-month dates coincide)
        fltrCS  = fltrLCCS & ismember(header_daily(:,1),cty);
        tnrsCS  = header_daily(fltrCS,5);
        tnrsCS  = cell2mat(cellfun(@str2num,tnrsCS,'UniformOutput',false));
        if ismember(k,tnrsCS)                           % Get correlation only if tenor exists
            tp_aux5 = dataset_in_range(dataset_daily,date1,date2);
            tp_aux5 = [tp_aux5(:,1) tp_aux5(:,fltrCS)]; % All tenors for LCCS, col1 has dates
            fltrYR  = [true; ismember(tnrsCS,k)];       % Correlation using same tenor
            lccs    = tp_aux5(:,fltrYR);                % col1 dates, col2 tenor
            lccs    = lccs(~isnan(lccs(:,2)),:);        % Remove NaNs before end of month
            lccs    = end_of_month(lccs);
            nobsCS  = size(lccs,1);                     % Sometimes lccs starts after min(date_tp_EM)
            corr_tpcs(l,k) = corr(tp_EM(end-nobsCS+1:end),lccs(:,2)); % From common date to last
        end
        
        % Correlation of EM TP with EPU index
        if any(strcmp(ctrsEPU,cty))               % ctrsLC{k} is any country with EPU index
            idx      = find(ismember(ctrsEPU,cty));
            epu      = dataset_in_range(epuidx(idx).info,date1,date2);         % Trim to tp_EM range
            
            % Need to create tp_EM2 because sometimes EPU has fewer obs (epu_max_date < tp_max_date)
            tp_EM2   = dataset_monthly(fltrCTY,:);      % All obs of EM (need dates)
            res_aux2 = [tp_EM2(:,1) mdl.Residuals.Raw]; % col1: dates, col2: EPU index
            res_aux2 = dataset_in_range(res_aux2,min(epu(:,1)),max(epu(:,1))); % Trim to EPU range
            tp_EM2   = dataset_in_range(tp_EM2,min(epu(:,1)),max(epu(:,1))); 
            tp_EM2   = tp_EM2(:,[1 find(fltrEM)]);      % col1: dates, col2: trimmed tp_EM
            tp_aux3  = [tp_aux3; corr(tp_EM2(:,2),epu(:,2))]; 
            tp_aux4  = [tp_aux4; corr(res_aux2(:,2),epu(:,2))];
            
            if k == 10                                  % Plot series for 10-year tenor
                subplot(2,3,idx)
                yyaxis left;  plot(tp_EM2(:,1),tp_EM2(:,2)); ylabel('Term Premium')
              % yyaxis left; plot(res_aux2(:,1),res_aux2(:,2)); ylabel('Orthogonal TP')
                yyaxis right; plot(epu(:,1),epu(:,2));       ylabel('EPU Index')
                title([cty ' TP and EPU'])
                datetick('x','yy')
            end
        end
    end
    disp([[num2str(k) ' Year:'] ctrsLC(tp_aux2 > 0.5)']); % Countries with correlation > 0.5
    corr_tpus  = [corr_tpus tp_aux2];                   % LC countries x maturities
    corr_tpepu = [corr_tpepu tp_aux3];                  % EPU countries x maturities
    corr_ogepu = [corr_ogepu tp_aux4];
    data_resd  = [data_resd res_aux1];                  % all_obs x maturities
end

% Header for data_resd
hdr_resd = construct_monthly_hdr([0.25 1:10],YCtype,4);

% Statistics for corr_tpus
stats_corr_tpus = [mean(corr_tpus); max(corr_tpus); min(corr_tpus)];
stats_corr_tpus = [1:ntnrs; stats_corr_tpus];           % Add maturities on top
stats_corr_tpus = round(stats_corr_tpus,2);
 