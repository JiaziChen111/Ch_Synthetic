%% Read File(s) with Information from Data Platforms
% This code reads data retrieved from Bloomberg and Datastream and store it
% in Matlab tables (identifiers) and timetables (historical data).
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
path     = pwd;
cd(fullfile(path,'..','..','Data'))
filename = 'original_Zero_Swap_Curves_Bloomberg.xlsx';
data_blp = xlsread(filename);      % Read data without headers but with dates

dates = x2mdate(data_blp(:,1),0);  % Convert dates from Excel to Matlab format
data_blp(:,1) = dates;             % Use dates in Matlab format
cd(path)

cd(path)
clear path filename