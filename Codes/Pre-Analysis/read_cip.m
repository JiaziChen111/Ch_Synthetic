function [TTcip,currEM,currAE] = read_cip()
% READ_CIP Read CIP data from Du, Im & Schreger (2018)
%   TTcip: stores historical data
%   currEM: contains currencies of emerging market in ascending order
%   currAE: contains currencies of advanced countries in ascending order

% Pavel Solís (pavel.solis@gmail.com), April 2020
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                  % platform-specific file separators
cd(pathd)
namefl = 'CIP_Data.xlsx';
opts   = detectImportOptions(namefl,'Sheet',1);
opts   = setvartype(opts,opts.VariableNames([1:2 4]),'categorical');
TTcip  = readtimetable(namefl,opts);
cd(pathc)

[~,grp,currencies] = findgroups(TTcip.group,TTcip.currency);
currEM = cellstr(currencies(grp == 'eme'));
currAE = cellstr(currencies(grp == 'g10'));