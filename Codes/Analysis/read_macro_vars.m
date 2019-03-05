%% Read Macro-Finance Variables
% This code reads macroeconomics and financial data retrieved from Bloomberg LP.
%
% Pavel Solís (pavel.solis@gmail.com), March 2018
%%
path = pwd;
cd(fullfile(path,'..','..','Data'))        % Use platform-specific file separators
filename1   = 'original_Macro_Finance_Vars_Bloomberg.xlsx';
data_macro  = xlsread(filename1);          % Read data without headers but with dates
dates_macro = x2mdate(data_macro(:,1),0);  % Convert dates from Excel to Matlab format
data_macro(:,1) = dates_macro;             % Use dates in Matlab format

filename2 = 'original_Macro_Finance_Vars_Bloomberg_Tickers.xlsx';
[~,txt]   = xlsread(filename2,2);
hdr_macro = txt(:,1:6);
cd(path)

clear filename* txt path
