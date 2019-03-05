%% Read Data
% This code reads data from different files to construct a comprehensive
% dataset of yield curves, swap curves, cross-currency swaps and credit spreads.
% Calls to m-files: read_tickers_v4.m, read_bloomberg.m, read_usyc.m, ccs.m,
% csp.m, append_dataset.m, plot_spreads.m
%
% Pavel Solís (pavel.solis@gmail.com), March 2018
%%
clear; clc; close all;
run read_tickers_v4.m       % Construct the headers (generates 'hdr_blp')
run read_bloomberg.m        % Historic data of swap and yield curves (generates 'data_blp')

run read_usyc.m             % Historic data of US zero coupon yield curve (generates 'data_usyc')
% Append the data of the US yield curve to the data from Bloomberg
[dataset_daily,header_daily] = append_dataset(data_blp, data_usyc, hdr_blp, hdr_usyc);

run ccs.m                   % Historic data of cross-currency swaps (generates 'data_ccs')
% Append the data of CCS to the data of swap and yield curves
[dataset_daily,header_daily] = append_dataset(dataset_daily, data_ccs, header_daily, hdr_ccs);

run csp.m                   % Historic data of credit spreads (generates 'data_csp')
% Append the data of credit spreads to the data of swap curves, yield curves and CCS 
[dataset_daily,header_daily] = append_dataset(dataset_daily, data_csp, header_daily, hdr_csp);

run plot_spreads.m

clear path sheets