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

data_myr  = xlsread(filename2,'MYR');           % Read data without headers but with dates
dates_cty = x2mdate(data_myr(:,1),0);           % Convert dates from Excel to Matlab format
data_myr(:,1) = dates_cty;
data_myr  = data_myr(1:end-2,:);                % Interested in first obs; last obs may have NaNs
data_myr  = data_myr(isnan(data_myr(:,2)),3);   % Extract Bloomberg GDP survey data for missing obs

cd(path)

clear path txt filename* dates_*