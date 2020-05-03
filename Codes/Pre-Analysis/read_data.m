%% Read Data
% This code reads data from different files to construct a comprehensive
% dataset of yield curves, swap curves, forward premia, cross-currency swaps
% and deviations from covered interest rate parity.

% m-files called: read_platforms, read_usyc, fwd_prm, spreads, read_cip,
% plot_spreads, compare_cip, append_dataset, iso2names
% Pavel Solís (pavel.solis@gmail.com), April 2020
%% Data on yield curves and swap curves
clear; clc; close all; tStart = tic;
warning('OFF','MATLAB:table:ModifiedAndSavedVarnames')                          % suppress table warnings
[TTpltf,THpltf] = read_platforms();
[TTusyc,THusyc] = read_usyc();
TTdy = synchronize(TTpltf,TTusyc,'commonrange');                                % union over intersection
THdy = [THpltf; THusyc];

%% Convert tables to cell arrays (easier for performing calculations)
header_daily  = [THdy.Properties.VariableNames;table2cell(THdy)];                       % header to cell
header_daily(2:end,5) = cellfun(@num2str,header_daily(2:end,5),'UniformOutput',false);  % tnrs to string
dataset_daily = timetable2table(TTdy);                                                  % data to table
dataset_daily = table2cell([num2cell(datenum(TTdy.Date)), dataset_daily(:,2:end)]);     % date to datenum
dataset_daily = cell2mat(dataset_daily);
curncs = cellstr(unique(THdy.Currency(ismember(THdy.Type,'SPT')),'stable'));
clear T*

%% Data on forward premiums 
[data_fp,hdr_fp,tnrs_fp]     = fwd_prm(dataset_daily,header_daily,curncs);
[dataset_daily,header_daily] = append_dataset(dataset_daily,data_fp,header_daily,hdr_fp);

%% Data on nominal yield curves
[data_zc,hdr_zc,fit_zc]      = zc_yields(dataset_daily,header_daily,curncs,false);
[dataset_daily,header_daily] = append_dataset(dataset_daily,data_zc,header_daily,hdr_zc);

%% Data on spreads (synthetic yield curves, interest rate differentials, CIP deviations)
[data_sprd,hdr_sprd,tnrs_spd] = spreads(dataset_daily,header_daily);
[dataset_daily,header_daily]  = append_dataset(dataset_daily,data_sprd,header_daily,hdr_sprd);

%% Clean dataset
types = {'Type','RHO','LCNOM','LCSYNT','LCSPRD','CIPDEV','FCSPRD'};
fltr = ~ismember(header_daily(:,2),types);
dataset_daily(:,fltr) = [];
header_daily(fltr,:)  = [];

%% Assess series
[TTcip,currEM,currAE] = read_cip();
figstop  = false;	figsave = false;
corrsprd = plot_spreads(dataset_daily,header_daily,currEM,currAE,figstop,figsave);
corrDIS  = compare_cip(dataset_daily,header_daily,curncs,TTcip,figstop,figsave);
S = cell2struct(iso2names(curncs)',{'cty','ccy','iso','imf'});
clear data_* hdr_* fig* fltr types
toc(tStart)

%% Save variables in mat files (in Dropbox, not in Git directory)
% save struct_data_1_S.mat S fit_zc corr* cur* tnrs*
% save struct_data_2_cells.mat dataset_daily header_daily