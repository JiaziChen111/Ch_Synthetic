function [data_realr,hdr_realr,TTrr] = read_spf()
% READ_SPF Read survey forecasts from Survey of Professional Forecasters
%   data_realr: stores historical data
%   hdr_realr: headaer (no title in first entry, ready to be appended)

% Pavel Solís (pavel.solis@gmail.com), July 2020
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw','SPF');           	% platform-specific file separators
namefl = 'USrealrates.xlsx';

cd(pathd)
aux_svys   = readcell(namefl,'Sheet','RRCE');
hdr_realr  = aux_svys(1,:);                                         % include column for dates
datessvys  = datenum(aux_svys(2:end,1));                            % exclude header row
datessvys  = unique(lbusdate(year(datessvys),month(datessvys)));    % last U.S. business day per month
data_realr = readmatrix(namefl,'Sheet','RRCE');
data_realr = [datessvys data_realr(:,2:end)];                   	% use end-of-month dates
cd(pathc)

TTrr = array2timetable(data_realr(:,2:end),'RowTimes',datetime(datessvys,'ConvertFrom','datenum'),...
    'VariableNames',hdr_realr(2:end));