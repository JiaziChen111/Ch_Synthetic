function [TTusyc,THusyc] = read_usyc()
% READ_USYC Read U.S. yield curve data from Gürkaynak, Sack & Wright (2007).
%   TTusyc: stores historical data in a timetable
%   THusyc: stores headers in a table

% m-files called: y_NSS, construct_hdr
% Pavel Solís (pavel.solis@gmail.com), April 2020
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                        % platform-specific file separators
namefl = 'US_Yield_Curve_Data.xlsx';

cd(pathd)
opts  = detectImportOptions(namefl);
opts  = setvartype(opts,opts.VariableNames(1),'datetime');
opts  = setvartype(opts,opts.VariableNames(2:end),'double');
opts.VariableNames{1} = 'Date';
ttaux = readtimetable(namefl,opts);
cd(pathc)

% Yields
matmth = [0.25 0.5 0.75];	matyrs = [1:9 10:5:30];     matall = [matmth,matyrs]';
tnrs   = strtrim(cellstr(num2str(matall)));
TTgsw  = removevars(ttaux,~contains(ttaux.Properties.VariableNames,'SVENY')); % keep zero-coupon yields
TTgsw  = TTgsw(:,matyrs);                                                     % keep tenors 1Y-9Y+10Y:5Y:30Y
TTparm = removevars(ttaux,~contains(ttaux.Properties.VariableNames,{'BETA','TAU'})); % keep NSS parameters
TTbill = array2timetable(y_NSS(TTparm{:,:},matmth),'RowTimes',TTparm.Date);   % generate 3M, 6M, 9M
TTbill.Properties.VariableNames = strcat('SVENY',tnrs(1:3));
TTusyc = synchronize(TTbill,TTgsw);                                           % merge yields (old-new)

% Header
H_usyc  = construct_hdr('USD','HC',TTusyc.Properties.VariableNames',...       % variable names as tickers
    strcat('USD ZERO-COUPON YIELD',{' '},tnrs,' YR'),num2cell(matall),' ','GSW'); % HC - hard currency
% H_usyc(1:3,end) = {'CRSP'};                                                 % if Tbill data not from GSW
THusyc = cell2table(H_usyc);
THusyc.Properties.VariableNames = {'Currency','Type','Ticker','Name','Tenor','FloatingLeg','Source'};

% In case the NSS parameters want to be included in the dataset
% TTusyc = synchronize(TTparm,TTusyc);
% H_prms  = construct_hdr('USD','PARAMETER',TTparm.Properties.VariableNames',...
%     'USD N-S-S YIELD CURVE',NaN,' ','GSW');
% THusyc = cell2table([H_prms; H_usyc]);