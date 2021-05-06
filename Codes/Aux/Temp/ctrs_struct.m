%% Create Group Structures
% This code create array structures to store information for advanced and 
% emerging countries.
% Assumes that read_platform.m and read_usyc.m have already been run.
% m-files called: 
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
ctrs_ccy = unique(TH_daily.Currency);
ctrs_ccy(ismember(ctrs_ccy,'USD')) = [];                % Countries in the dataset other than the U.S.

path        = pwd;
cd(fullfile(path,'..','..','Data','Raw'))               % Use platform-specific file separators
filenameCTR = 'AE_EM_Curves_Tickers.xlsx';
[~,ccy_AE1] = xlsread(filenameCTR,'FWD PRM','B5:B14');  % Update ranges as necessary
[~,ccy_EM] = xlsread(filenameCTR,'FWD PRM','B17:B31');

[~,ccy_AE2]  = xlsread(filenameCTR,'FWD PRM','B41:B50');% Update ranges as necessary
[~,~,cutoff] = xlsread(filenameCTR,'FWD PRM','E41:E50');
cd(path)

idx         = cellfun(@ischar,cutoff);                  % Replace strings with NaNs
cutoff(idx) = {NaN};
cutoff      = x2mdate(cell2mat(cutoff));
% cutoff = datetime(cutoff,'ConvertFrom','datenum');


S_AE = cell2struct(sort(ccy_AE1)','ccy');                % For field ccy, assign a country to a structure
S_EM = cell2struct(sort(ccy_EM)','ccy');


clear path filenameCTR