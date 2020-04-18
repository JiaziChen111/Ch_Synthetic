%% Read Data
% This code reads data from different files to construct a comprehensive
% dataset of yield curves, swap curves, forward premia, cross-currency swaps
% and deviations from covered interest rate parity.
% m-files called: read_platform.m, read_usyc.m, fwd_prm.m, cip_vars.m,
% append_dataset.m, plot_cip_vars.m
%
% Pavel Solís (pavel.solis@gmail.com), April 2020
%%
clear; clc; close all;
[TTpltf,THpltf] = read_platforms();
[TTusyc,THusyc] = read_usyc();

TTdy = synchronize(TTpltf,TTusyc,'commonrange');        % union over the intersection
THdy = [THpltf; THusyc];
%%
% Convert tables to cell arrays (easier to perform calculations)
header_daily  = [TH_daily.Properties.VariableNames;table2cell(TH_daily)];              % Convert header to cell
header_daily(2:end,5) = cellfun(@num2str,header_daily(2:end,5),'UniformOutput',false); % Convert tnrs to string
dataset_daily = timetable2table(TT_daily);                                             % Convert data to table
aux           = [num2cell(datenum(TT_daily.Date)), dataset_daily(:,2:end)];            % Convert date to datenum
dataset_daily = table2cell(aux);
dataset_daily = cell2mat(dataset_daily);

%%
% curncs = read_currencies();
curncs = cellstr(unique(THdy.Currency(ismember(THdy.Type,'SPT')),'stable'));
run fwd_prm.m               % Constructs historic data on forward premiums (generates 'data_fp','hdr_fp')

% Append the data of FP to the dataset
[dataset_daily,header_daily] = append_dataset(dataset_daily, data_fp, header_daily, hdr_fp);
%%
run cip_vars.m              % Historic data of CIP deviations (generates 'data_cip_vars','hdr_cip_vars')

% Append the data of CIP variables to the dataset
[dataset_daily,header_daily] = append_dataset(dataset_daily, data_cip_vars, header_daily, hdr_cip_vars);
%%
% run plot_cip_vars.m

%%
if ~exist('T_cip','var')                                % Run code if T_cip is not in the workspace
    run read_cip.m
end

% [iso,currEM,currAE] = read_currencies(T_cip);
namescodes = iso2names(curncs);
S = cell2struct(namescodes',{'cty','ccy','iso','imf'});

%% Save variables in mat files (in Dropbox, not in Git directory)
% save struct_data_1_S.mat S
% save struct_data_2_TT.mat curncs currAE currEM T_cip TT_daily TH_daily
% save struct_data_3_cells.mat dataset_daily header_daily