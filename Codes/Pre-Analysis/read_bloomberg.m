%% Read File(s) with Information from Data Platforms
% This code reads data retrieved from Bloomberg and Datastream.
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
path = pwd;
cd(fullfile(path,'..','..','Data','Raw'))   % Use platform-specific file separators
filenameBLP = 'AE_EM_Curves_Data';
filenameDS  = 'EM_Currencies_Data';

data_blp = readtable(filenameBLP,'Sheet',1,'ReadVariableNames',true,...
    'DatetimeType','exceldatenum','TreatAsEmpty','#N/A N/A');
hdr_blp = readtable(filenameBLP,'Sheet',2,'ReadVariableNames',true);

if isfile(filenameDS)
    data_ds = readtable(filenameDS,'Sheet',1,'ReadVariableNames',true,...
        'DatetimeType','exceldatenum','TreatAsEmpty','NA');
    hdr_ds = readtable(filenameDS,'Sheet',2,'ReadVariableNames',true);
else
    data_ds = [];
    hdr_ds  = [];
end

data_aeem = synchronize(data_blp,data_ds,'intersection');
hdr_aeem  = [hdr_blp; hdr_ds];

[nobs, ntick1] = size(data_aeem);
[ntick2, ~]    = size(hdr_aeem);

if ntick1 ~= ntick2
    error('The number of tickers in the ''Data'' and ''Identifiers'' sheets must be the same')
end

cd(path)
clear path filename* data_blp data_ds hdr_blp hdr_ds

% filename = 'original_Zero_Swap_Curves_Bloomberg.xlsx';
% data_blp = xlsread(filenameBLP);               % Read data without headers but with dates

% dates = x2mdate(data_blp(:,1),0);  % Convert dates from Excel to Matlab format
% data_blp(:,1) = dates;             % Use dates in Matlab format
