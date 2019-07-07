%% Read Survey Forecasts
% This code reads survey forecasts from Consensus Economics.
% 
% Pavel Solís (pavel.solis@gmail.com), May 2019
%%
path = pwd;
cd(fullfile(path,'..','..','Data','Raw'))           % Use platform-specific file separators
filename   = 'CE_Forecasts.xlsx';
[data,txt] = xlsread(filename);                     % Read data, and header with dates
hdr_ce     = txt(:,1:3);
dates_ce   = eomdate(datenum(txt(1,4:end)))';       % Convert dates to end-of-month datenums
data_ce    = [dates_ce; data]';                     % Dimensions: nobs*(countries*variables*forecasts)
cd(path)

clear path filename data txt dates_ce