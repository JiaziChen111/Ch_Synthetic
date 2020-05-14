function [data_macro,hdr_macro] = read_macrovars()
% READ_MACROVARS Read macroeconomic and financial data retrieved from Bloomberg
%   data_macro: stores historical data
%   hdr_macro: stores headers

% Pavel Solís (pavel.solis@gmail.com), May 2020
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                            % platform-specific file separators
namefl = {'Macro_Vars_Tickers.xlsx','Macro_Vars_Data.xlsx'};

cd(pathd)
hdr_macro  = readcell(namefl{1},'Sheet','Tickers');                         % read headers
hdr_macro  = hdr_macro(:,1:6);                                              % remove extra columns
data_macro = readmatrix(namefl{2},'Sheet','All');                           % read macro variables
data_macro(:,1) = x2mdate(data_macro(:,1),0);                               % dates from Excel to Matlab format

% MYR GDP case (correlation between survey and actual series of 0.75)
data_myr = readmatrix(namefl{2},'Sheet','MYR');                          	% read GDP and Bloomberg survey data
data_myr(isnan(data_myr(:,2)),2) = data_myr(isnan(data_myr(:,2)),3);        % use survey data for missing obs
fltrMYR  = contains(hdr_macro(:,3),'MAGDHIY');                            	% identify quarterly GDP for MYR
datesmyr = x2mdate(data_myr(:,1),0);                                        % dates from Excel to Matlab format
datesmyr = unique(lbusdate(year(datesmyr),month(datesmyr)));                % use last business day of quarter
data_macro(ismember(data_macro(:,1),datesmyr),fltrMYR) = data_myr(:,2);     % use constructed quarterly GDP data
cd(pathc)