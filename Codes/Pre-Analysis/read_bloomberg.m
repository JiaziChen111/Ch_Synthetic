%% Read File with Bloomberg Data
% This code reads data retrieved from Bloomberg LP. The dataset can come
% from retrieve_blp_data.m or from original_Zero_Swap_Curves_Bloomberg_BDH.xlsx.
% (second option is recommended because the data already appears in matrix form).
% The data needs to be saved in 'original_Zero_Swap_Curves_Bloomberg.xlsx'.
%
% Pavel Solís (pavel.solis@gmail.com), March 2018
%%
path = pwd;
cd(fullfile(path,'..','..','Data'))% Use platform-dependent file separators
filename = 'original_Zero_Swap_Curves_Bloomberg.xlsx';
data_blp = xlsread(filename);      % Read data without headers but with dates
cd(path)
dates = x2mdate(data_blp(:,1),0);  % Convert dates from Excel to Matlab format
data_blp(:,1) = dates;             % Use dates in Matlab format
