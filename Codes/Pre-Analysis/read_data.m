%% Read Data
% This code reads data from different files to construct a comprehensive
% dataset of yield curves, swap curves, forward premia, cross-currency swaps
% and deviations from covered interest rate parity.
% m-files called: read_platform.m, read_usyc.m, fwd_prm.m, cip_vars.m,
% append_dataset.m, plot_cip_vars.m
%
% Pavel Solís (pavel.solis@gmail.com), April 2019
%%
clear; clc; close all;
run read_platform.m         % Headers and historic data as (time)tables
run read_usyc.m             % Historic data for U.S. yield curve (merges tables)
%%
% Convert tables to cell arrays
header_daily  = [TH_daily.Properties.VariableNames;table2cell(TH_daily)];              % Convert header to cell
header_daily(2:end,5) = cellfun(@num2str,header_daily(2:end,5),'UniformOutput',false); % Convert tnrs to string
dataset_daily = timetable2table(TT_daily);                                             % Convert data to table
aux           = [num2cell(datenum(TT_daily.Date)), dataset_daily(:,2:end)];            % Convert date to datenum
dataset_daily = table2cell(aux);
dataset_daily = cell2mat(dataset_daily);

% % Convert to categorical: Option 1 (Before readtable)
% opts  = detectImportOptions(filename);          % Detect variable names
% notnr = ~strcmp('Tenor',opts.VariableNames);    % All names except Tenor
% opts  = setvartype(opts,notnr,'categorical');   % Update data type to categorical
% T     = readtable(filename,opts);

% Convert to categorical: Option 2 (After readtable)
TH_daily.Currency = categorical(TH_daily.Currency);
TH_daily.Type     = categorical(TH_daily.Type);
TH_daily.Ticker   = categorical(TH_daily.Ticker);
TH_daily.Name     = categorical(TH_daily.Name);
TH_daily.FloatingLeg = categorical(TH_daily.FloatingLeg);
TH_daily.Source   = categorical(TH_daily.Source);
%%
[curncs,currEM,currAE] = read_currencies();
run fwd_prm.m               % Constructs historic data on forward premiums (generates 'data_fp','hdr_fp')

% Append the data of FP to the dataset
[dataset_daily,header_daily] = append_dataset(dataset_daily, data_fp, header_daily, hdr_fp);
%%
run cip_vars.m              % Historic data of CIP deviations (generates 'data_cip_vars','hdr_cip_vars')

% Append the data of CIP variables to the dataset
[dataset_daily,header_daily] = append_dataset(dataset_daily, data_cip_vars, header_daily, hdr_cip_vars);
%%
run plot_cip_vars.m

%%
run read_cip.m

iso    = read_currencies(T_cip);
curncs = iso2names(iso);
S      = cell2struct(curncs',{'imf','cty','ccy','iso'});
