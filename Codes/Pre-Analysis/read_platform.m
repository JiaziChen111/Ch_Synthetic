%% Read Information from Data Platforms
% This code reads data retrieved from Bloomberg and Datastream and store it
% in Matlab tables (identifiers or headers) and timetables (historical data).
% The readtable function displays warnings because it changes variable names.
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
path        = pwd;
cd(fullfile(path,'..','..','Data','Raw'))           % Use platform-specific file separators
filenameBLP = 'AE_EM_Curves_Data.xlsx';
filenameDS  = 'EM_Currencies_Data.xlsx';

% Bloomberg
T_blp  = readtable(filenameBLP,'Sheet',1,'ReadVariableNames',true,...
    'DatetimeType','exceldatenum','TreatAsEmpty','#N/A N/A');
T_blp.Date = x2mdate(T_blp.Date,0,'datetime');      % Convert dates from Excel to Matlab format
TT_blp = table2timetable(T_blp);                    % Convert table to a timetable
TH_blp = readtable(filenameBLP,'Sheet',2,'ReadVariableNames',true);

if isfile(filenameDS)                               % If the file exists, read it
    % Datastream
    T_ds  = readtable(filenameDS,'Sheet',1,'ReadVariableNames',true,...
        'DatetimeType','exceldatenum','TreatAsEmpty','NA');
    T_ds.Date = x2mdate(T_ds.Date,0,'datetime');    % Convert dates from Excel to Matlab format
    TT_ds = table2timetable(T_ds);                  % Convert table to a timetable
    TH_ds = readtable(filenameDS,'Sheet',2,'ReadVariableNames',true);
    
    % Combine both datasets
    TT_pltfm = synchronize(TT_blp,TT_ds,'intersection');
    TH_pltfm = [TH_blp; TH_ds];
else
    TT_pltfm = TT_blp;
    TH_pltfm = TH_blp;
end

[~, ntickrs1] = size(TT_pltfm);
[ntickrs2, ~] = size(TH_pltfm);

if ntickrs1 ~= ntickrs2
    error('The number of tickers in the ''Data'' and ''Identifiers'' sheets must be the same.')
end

% % If want to remove duplicated tickers ('EUR BS' from 'HUF' and 'PLN' sheets)
% [~,idx1] = unique(TH_pltfm.Ticker,'last');          % Leave 'EUR BS' from 'EUR' sheet but sorted
% idx2     = sort(idx1);                              % Keep original order
% TT_pltfm = TT_pltfm(:,idx2);
% TH_pltfm = TH_pltfm(idx2,:);

cd(path)
clear path filename* *_blp *_ds ntick*