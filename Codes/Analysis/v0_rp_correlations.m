%% EM TP and US TP Correlations
% This code gives the correlations of the estimated term premia in EMs with
% the US term premium and with the EPU index (SBD 2016) per maturitiy. Also saves 
% the residuals of regressing EM TP on the US TP (used by rp_common_factors.m).
% Assumes in workspace: dataset_monthly, header_monthly, data_usrp, hdr_usrp, epuidx
% Calls to m-files: dataset_in_range.m
%
% Pavel Solís (pavel.solis@gmail.com), September 2018
%%
fltrRP1   = ismember(header_monthly(:,1),'LCRFRP');
fltrRP2   = ismember(hdr_usrp(:,1),'USRP');
ntnrs     = sum(fltrRP1);
corr_tpus = [];     corr_tpepu = [];    corr_ogepu = [];
data_resd = [];

for k = 1:ntnrs
    fltrEM   = fltrRP1 & ismember(header_monthly(:,3),num2str(k));
    fltrUS   = fltrRP2 & ismember(hdr_usrp(:,3),num2str(k));
    tp_aux2  = [];   tp_aux3 = [];       tp_aux4 = [];
    res_aux1 = [];
    for  l  = 1:numel(IDs)
        % Extract EM TP
        fltrCTY = dataset_monthly(:,2) == IDs(l);
        tp_EM   = dataset_monthly(fltrCTY,fltrEM);
        date1   = min(dataset_monthly(fltrCTY,1));  % First date for US relative to EM
        date2   = max(dataset_monthly(fltrCTY,1));  % Last date for US relative to EM
        
        % Correlation of EM TP with US TP
        tp_aux1 = dataset_in_range(data_usrp,date1,date2); % Trim to tp_EM range
        tp_US   = tp_aux1(:,fltrUS); 
        tp_aux2 = [tp_aux2; corr(tp_EM,tp_US)];
        
        % Regress EM TP on US TP and save residual
        mdl      = fitlm(tp_US,tp_EM);
        res_aux1 = [res_aux1; mdl.Residuals.Raw];
        
        % Correlation of EM TP with EPU index
        if any(strcmp(ctrsEPU,ctrsLC{l}))               % ctrsLC{k} is any country with EPU index
            idx      = find(ismember(ctrsEPU,ctrsLC{l}));
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
                title([ctrsLC{l} ' TP and EPU'])
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
name_resd = strcat('RESIDUAL REGRESSION EM TP ON US TP',{' '},tnrs,' YR');
hdr_resd  = construct_hdr('RSDRP',name_resd,tnrs);

% Statistics for corr_tpus
stats_corr_tpus = [mean(corr_tpus); max(corr_tpus); min(corr_tpus)];
stats_corr_tpus = [1:ntnrs; stats_corr_tpus];               % Add maturities on top
stats_corr_tpus = round(stats_corr_tpus,2);

clear k l fltr* date1 date2 yr_* tp_aux* res_aux* tp_EM* tp_US idx epu name_* mdl ntnrs
