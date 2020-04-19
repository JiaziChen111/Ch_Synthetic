function [data_cip,hdr_cip,tnrsLCcip] = cip_vars(dataset_daily,header_daily)
% CIP_VARS Calculate deviations from covered interest parity (CIP)
% Use yield curves and forward premiums (FPs)
%   data_cip: stores historical data
%   hdr_cip: stores headers (note: row 1 has no titles, i.e. ready to be appended)
%   tnrsLCcip: reports CIP tenors per currency

% m-files called: compute_cip_vars, remove_NaNcols
% Pavel Solís (pavel.solis@gmail.com), April 2020
%% Identify Countries with LC and FC
fltrRHO = ismember(header_daily(:,2),'RHO');        % 1 for countries with FP data
fltrFC  = ismember(header_daily(:,2),'USD');        % 1 for countries with FC data
ctrsLC  = unique(header_daily(fltrRHO,1),'stable'); % countries with LC data
ctrsFC  = unique(header_daily(fltrFC,1),'stable');  % countries with FC data
ctrs    = {ctrsLC', ctrsFC'};

%% Construct the CIP Database
hdr_cip  = {};                                      % no row 1 with titles (i.e. ready to be appended)
data_cip = dataset_daily(:,1);

for k = 1:2                                         % 1 for LC, 2 for FC
    countries = ctrs{k};                            % ctrs{1} = ctrsLC, ctrs{2} = ctrsFC
    aux_hdr   = {};    aux_data  = [];              % temporarily store results
    for l  = 1:numel(countries)                     % for all countries with LC or FC
        LC = countries{l};
        [CIPvars,hdr] = compute_cip_vars(LC,k,header_daily,dataset_daily);
        aux_hdr   = [aux_hdr; hdr];                 % after each currency, append
        aux_data  = [aux_data, CIPvars];
    end
    hdr_cip  = [hdr_cip; aux_hdr];                  % once LC & FC done for all countries, append
    data_cip = [data_cip, aux_data];
end

[data_cip,hdr_cip] = remove_NaNcols(hdr_cip,data_cip);

%% Report CIP Tenors per Currency
tnrsLCcip = {};                                     % count only after remove_NaNcols.m is called
LoFC = {'CIPDEV','FCSPRD'};
for k = 1:2                                         % 1 for LC, 2 for FC
    countries = ctrs{k};                            % ctrs{1}=ctrsLC, ctrs{2}=ctrsFC
    for l = 1:numel(countries)                      % for all countries with LC or FC
        LC = countries{l};
        ntnrperLC = sum(strcmp(hdr_cip(:,1),LC) & strcmp(hdr_cip(:,2),LoFC{k}));
        tnrsLCcip  = [tnrsLCcip; LC, LoFC(k), ntnrperLC];
    end
end