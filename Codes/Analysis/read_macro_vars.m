%% Read Macro-Finance Variables
% This code reads macroeconomic and financial data retrieved from Bloomberg LP.
%
% Pavel Solís (pavel.solis@gmail.com), May 2019
%%
path = pwd;
cd(fullfile(path,'..','..','Data','Raw'))       % Use platform-specific file separators
filename1   = 'Macro_Vars_Data.xlsx';
data_macro  = xlsread(filename1);               % Read data without headers but with dates
dates_macro = x2mdate(data_macro(:,1),0);       % Convert dates from Excel to Matlab format
data_macro(:,1) = dates_macro;                  % Use dates in Matlab format

filename2 = 'Macro_Vars_Tickers.xlsx';
[~,txt]   = xlsread(filename2,2);
hdr_macro = txt(:,1:6);
cd(path)

clear filename* txt path