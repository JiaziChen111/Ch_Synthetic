%% Risky vs Risk-free EM Term Premia
% This code calls functions to compare the estimated term premia using
% 'observed' yield curves vs synthetic default-free ones.
% 
% Calls to m-files: fit_NS.m, rp_estimation.m, rp_plot, rp_correlations.m, 
% read_macro_vars.m, rp_common_factors.m
%
% Pavel Solís (pavel.solis@gmail.com), October 2018
%
%% Fit N-S
% call fit_NS with 'LCRF' and save data_month_rf and hdr_month_rf
% [data_month_rf,hdr_month_rf,ctrsNcods_rf,first_mo_rf] = fit_NS(dataset_daily,header_daily,'LCRF');

% call fit_NS with 'LC' and save data_month_rk and hdr_month_rk
[data_month_rk,hdr_month_rk,ctrsNcods_rk,first_mo_rk] = fit_NS(dataset_daily,...
    header_daily,'LC',data_month_rf,hdr_month_rf);

% To address special cases for 'LC'
%[flag_data,~,~,~,flag_rmse,flag_3mo]=fit_NS(dataset_daily,header_daily,'LC',data_month_rf,hdr_month_rf);

%% ATSM Decomposition
% call rp_estimation with 'LCRF' and save dataset_mth_rf and header_mth_rf
[dataset_mth_rf,header_mth_rf,stats_rp_cty_rf,stats_rp_mat_rf,...
    pc_exp_rf] = rp_estimation(data_month_rf,hdr_month_rf,'LCRF',ctrsNcods_rf);

% call rp_estimation with 'LCRK' and save dataset_mth_rk and header_mth_rk
[dataset_mth_rk,header_mth_rk,stats_rp_cty_rk,stats_rp_mat_rk,...
    pc_exp_rk] = rp_estimation(data_month_rk,hdr_month_rk,'LCRK',ctrsNcods_rk);

%% Plots
% call rp_plot with 'LCRFRP'
rp_plot(dataset_mth_rf,header_mth_rf,'LCRF',ctrsNcods_rf,10,1)

% call rp_plot with 'LCRKRP'
% rp_plot(dataset_mth_rk,header_mth_rk,'LCRK',ctrsNcods_rk,10,0)

%% Compare TP estimates
% Needs both ATSM decompositions to have been performed
rpcs = rp_compare(dataset_mth_rf,header_mth_rf,dataset_mth_rk,header_mth_rk,...
       dataset_daily,header_daily,ctrsNcods_rf,ctrsNcods_rk,1);

%% Correlations
[data_usrp,hdr_usrp,stats_rpus] = rp_us(dataset_daily,header_daily,0);

% call rp_correlations with 'LCRF'
% [data_resd_rf,hdr_resd_rf,corr_tpus_rf,stats_corr_tpus_rf,corr_tpcs_rf,...
%     corr_tpepu_rf,corr_ogepu_rf] = rp_correlations(dataset_mth_rf,...
%     header_mth_rf,dataset_daily,header_daily,data_usrp,hdr_usrp,'LCRF',ctrsNcods_rf);

% call rp_correlations with 'LCRK'
[data_resd_rk,hdr_resd_rk,corr_tpus_rk,stats_corr_tpus_rk,corr_tpcs_rk,...
    corr_tpepu_rk,corr_ogepu_rk] = rp_correlations(dataset_mth_rk,...
    header_mth_rk,dataset_daily,header_daily,data_usrp,hdr_usrp,'LCRK',ctrsNcods_rk);

%% Common Factors
run read_macro_vars.m

% call rp_correlations with 'LCRF'
% [pcXdates_rf,pcXregion_rf,pc1corr_varsD_rf,pc1corr_varsR_rf,pcpcXdates_rf,pcpcXregion_rf,...
%     pc1corr_tpogD_rf,pc1corr_tpogR_rf] = rp_common_factors(dataset_mth_rf,...
%     header_mth_rf,data_resd_rf,data_macro,'LCRF',ctrsNcods_rf);

% call rp_correlations with 'LCRK'
[pcXdates_rk,pcXregion_rk,pc1corr_varsD_rk,pc1corr_varsR_rk,pcpcXdates_rk,pcpcXregion_rk,...
    pc1corr_tpogD_rk,pc1corr_tpogR_rk] = rp_common_factors(dataset_mth_rk,...
    header_mth_rk,data_resd_rk,data_macro,'LCRK',ctrsNcods_rk);

%% Regressions

[paneltp,tnrs] = construct_panel(dataset_mth_rf,header_mth_rf,data_macro,hdr_macro,...
                 data_usrp,hdr_usrp,ctrsNcods_rf);
%%
[lm_ols,lm_fe,lm_re,tbl] = rp_panel_reg(paneltp,tnrs);
