%% Read CIP
% This code reads data as a Matlab table and timetable from 'original_CIP_Data.xlsx'
% of Du, Im & Schreger (2018).
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
path = pwd;
cd(fullfile(path,'..','..','Data','Raw'))           % Use platform-specific file separators
filenameCIP = 'original_CIP_Data.xlsx';
T_cip = readtable(filenameCIP,'Sheet',1,'ReadVariableNames',true,'DatetimeType','exceldatenum');
cd(path)

% Convert variables as cell arrays to categorical variables
T_cip.group    = categorical(T_cip.group);
T_cip.currency = categorical(T_cip.currency);
T_cip.tenor    = categorical(T_cip.tenor);

% Relocate dates and change to Matlab format
T_cip      = movevars(T_cip,'date','Before',1);     % Relocate dates in first column
T_cip.date = x2mdate(T_cip.date,0,'datetime');      % Convert dates from Excel to Matlab format

% Timetable
TT_cip     = table2timetable(T_cip);                % Convert table to a timetable

clear path filenameCIP