%% Read Data
% This code reads data from different files to construct a comprehensive
% dataset of yield curves, swap curves, cross-currency swaps and credit spreads.
% Calls to m-files: read_tickers_v4.m, read_bloomberg.m, read_usyc.m, ccs.m,
% csp.m, append_dataset.m, plot_spreads.m
%
% Pavel Solís (pavel.solis@gmail.com), March 2018
%%
clear; clc; close all;
run read_platform.m         % Headers and historic data as (time)tables
run read_tickers_v4.m       % Construct the headers (generates 'hdr_blp')
run read_bloomberg.m        % Historic data of swap and yield curves (generates 'data_blp')

run read_usyc.m             % Historic data for U.S. yield curve (generates 'data_usyc')
% Append the data of the US yield curve to the data from Bloomberg
[dataset_daily,header_daily] = append_dataset(data_blp, data_usyc, hdr_blp, hdr_usyc);

% Convert table to cell arrays
hdr_blp  = [TH_daily.Properties.VariableNames;table2cell(TH_daily)];         % Convert header to cell array
hdr_blp(2:end,5) = cellfun(@num2str,hdr_blp(2:end,5),'UniformOutput',false); % Convert tnrs to string
data_blp = timetable2table(TT_daily);                                        % Convert data     to table
aux      = [num2cell(datenum(TT_daily.Date)), data_blp(:,2:end)];   % Convert date from datetime to datenum
data_blp = table2cell(aux);
data_blp = cell2mat(data_blp);

dataset_daily = data_blp;
header_daily  = hdr_blp;

TH_daily.Currency = categorical(TH_daily.Currency);
TH_daily.Type     = categorical(TH_daily.Type);
TH_daily.Ticker   = categorical(TH_daily.Ticker);
TH_daily.Name     = categorical(TH_daily.Name);
TH_daily.FloatingLeg = categorical(TH_daily.FloatingLeg);
TH_daily.Source   = categorical(TH_daily.Source);

[curncs,currEM,currAE] = read_currencies();
run fwd_prm.m               % Historic data of forward premiums (generates 'data_fp')
% run ccs.m                   % Historic data of cross-currency swaps (generates 'data_ccs')
% Append the data of FP to the data of swap and yield curves
[dataset_daily,header_daily] = append_dataset(dataset_daily, data_fp, header_daily, hdr_fp);
%%
run csp.m                   % Historic data of credit spreads (generates 'data_csp')
% Append the data of credit spreads to the data of swap curves, yield curves and CCS 
[dataset_daily,header_daily] = append_dataset(dataset_daily, data_csp, header_daily, hdr_csp);

run plot_spreads.m

clear path sheets aux