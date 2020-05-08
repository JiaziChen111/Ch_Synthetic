%% Common Factors in EM Term Premia
% This code gives the proportion of total variance explained by the first
% principal components of EM term premia in two versions: direct and EM-specific.
% The first uses the estimated term premia; the second, uses the residual part
% orthogonal to the US term premium. Both are done for all maturities and 
% different groups of countries. 
% Also gives the correlation of the PCs with macrofinancial variables.
% Assumes in the workspace: dataset_monthly, header_monthly, data_resd,
% hdr_resd, data_macro
% Calls to m-files: date_first_obs.m, dataset_in_range.m, end_of_month.m
%
% Pavel Solís (pavel.solis@gmail.com), September 2018
%%
% Common factors for countries with same initial date 
fltrRP    = ismember(header_monthly(:,1),'LCRFRP');
init_mo   = date_first_obs(dataset_monthly);
date_min  = max(init_mo);                           % Minimum common date for all countries
date_cf   = '1-Jul-2005';                           % Date can be changed
init_200X = init_mo(init_mo < datenum(date_cf));
date_200X = max(init_200X);
comn_date = [date_min, date_200X];
for k = 1:numel(comn_date)              % Find factors for different common dates
    ctyIDs  = IDs(init_mo <= comn_date(k));            % Countries with common dates
    fltrCTY = ismember(dataset_monthly(:,2),ctyIDs);
    fltrDTE = dataset_monthly(:,1) >= comn_date(k);
    fltrPNL = fltrCTY & fltrDTE;                    % Construct balanced panels 
    [pc_explnd,pcpc_explnd,pc1corr_tpog,pc1corr_vars] = common_factors(dataset_monthly,...
        data_resd,data_macro,fltrPNL,fltrRP,ctyIDs,comn_date(k));
    pcXdates(:,:,k)      = pc_explnd;               % 3D for different comn_date
    pcpcXdates(:,:,k)    = pcpc_explnd;
    pc1corr_tpogD(:,:,k) = pc1corr_tpog;
    pc1corr_varsD(:,:,k) = pc1corr_vars;
end

% Common factors per regions
regLAT = {'BRL','COP','MXN','PEN'};                 % Note: numel(regXXX) >= npc
regASP = {'IDR','PHP','KRW','MYR','THB'};
regEUR = {'HUF','PLN','TRY','RUB'};
region = {regLAT, regASP, regEUR};
for k = 1:length(region)
    fltrCOD  = ismember(ctrsLC,region{k});
    ctyIDs   = IDs(fltrCOD);                        % IDs of countries in region
    fltrREG  = ismember(dataset_monthly(:,2),ctyIDs);
    data_aux = dataset_monthly(fltrREG,:);
    init_mo  = date_first_obs(data_aux);
    date_min = max(init_mo);                        % Minimum common date for countries in region
    fltrDTE  = dataset_monthly(:,1) >= date_min;    % dataset_monthly to get same size as fltrREG
    fltrPNL  = fltrREG & fltrDTE;
    [pc_explnd,pcpc_explnd,pc1corr_tpog,pc1corr_vars] = common_factors(dataset_monthly,...
        data_resd,data_macro,fltrPNL,fltrRP,ctyIDs,date_min);
    pcXregion(:,:,k)     = pc_explnd;               % 3D for different region
    pcpcXregion(:,:,k)   = pcpc_explnd;
    pc1corr_tpogR(:,:,k) = pc1corr_tpog;
    pc1corr_varsR(:,:,k) = pc1corr_vars;
end

clear k reg* fltr* comn_date ctyIDs data_aux date_* init_*

function [pc_explnd,pcpc_explnd,pc1corr_tpog,pc1corr_vars] = common_factors(dataset_monthly,...
    data_resd,data_macro,fltrPNL,fltrRP,ctyIDs,date1)
    npc    = 3;
    ntnrs  = sum(fltrRP);
    aux_tp = dataset_monthly(fltrPNL,fltrRP);       % For TP
    aux_og = data_resd(fltrPNL,:);                  % For residuals
    nids   = numel(ctyIDs);                        
    pnl_tp = reshape(aux_tp,[],nids,ntnrs);         % A panel per maturity (3rd dimension)
    pnl_og = reshape(aux_og,[],nids,ntnrs);         % Since balanced panel: [npercty]=sum(fltrPNL)/nids; 
    factors_tp = []; factors_og = []; explnd_tp = []; explnd_og = [];
    for k = 1:ntnrs                                 % Find factors per maturity
        [~,factors_tp(:,:,k),~,~,explnd_tp(:,k)] = pca(pnl_tp(:,:,k),'NumComponents',npc);
        [~,factors_og(:,:,k),~,~,explnd_og(:,k)] = pca(pnl_og(:,:,k),'NumComponents',npc);
    end
    pc_explnd = [sum(explnd_tp(1:npc,:)); sum(explnd_og(1:npc,:))]; % PCs per tnr (2 x ntnrs)
    
    % Common factors in PC1's across maturities (PCA on PCA)
    pc1_tp = squeeze(factors_tp(:,1,:));           % PC1 for all maturities (obs x ntnrs)
    pc1_og = squeeze(factors_og(:,1,:));
    [~,~,~,~,xplnd_tp] = pca(pc1_tp,'NumComponents',npc);
    [~,~,~,~,xplnd_og] = pca(pc1_og,'NumComponents',npc);
    pcpc_explnd = [sum(xplnd_tp(1:npc)); sum(xplnd_og(1:npc))]; % PCs of PC1s (2 x 1)
    
    % Correlation between PC1s from tp and og
    pc1corr_tpog = diag(corr(pc1_tp,pc1_og));       % Corr b/w PC1s of tp and og for each maturity
    
    % Correlation between PC1s and macro financial variables
    date2 = dataset_monthly(end,1);                 % Assumes last obs is end of month
    vars  = dataset_in_range(data_macro,date1,date2);
    vars  = end_of_month(vars);                     % Order b/w dataset_in_range and end_of_month matters
    vars3 = vars(:,2:4);                            % var1 = VIX, var2 = FFR, var3 = S&P
    pc1corr_vars = [corr(vars3,pc1_tp); corr(vars3,pc1_og)]; % [v1:v3'; v1:v3'] x ntnrs
end