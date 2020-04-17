function [TTusyc,THusyc] = read_usyc()
% READ_USYC Read U.S. yield curve data from Gürkaynak, Sack & Wright (2007).
%   TTusyc: stores historical data in a timetable
%   THusyc: stores headers in a table

% Pavel Solís (pavel.solis@gmail.com), April 2020
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');       % platform-specific file separators
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
THusyc = movevars(THusyc,5,'After',7);                                        % tenor remains as double
THusyc = [varfun(@categorical,THusyc,'inputvariables',THusyc.Properties.VariableNames(1:6)) THusyc(:,7)];
THusyc = movevars(THusyc,7,'After',4);                                        % relocate tenor
THusyc.Properties.VariableNames = {'Currency','Type','Ticker','Name','Tenor','FloatingLeg','Source'};

% In case the NSS parameters want to be included in the dataset
% TTusyc = synchronize(TTparm,TTusyc);
% H_prms  = construct_hdr('USD','PARAMETER',TTparm.Properties.VariableNames',...
%     'USD N-S-S YIELD CURVE',NaN,' ','GSW');
% THusyc = cell2table([H_prms; H_usyc]);

%%
% %% Read U.S. Yield Curve Data from GSW
% % This code reads the U.S. yield curve data and the Nelson-Siegel-Svensson
% % parameters from the database of Gürkaynak, Sack & Wright (2007).
% % Assumes that read_platform.m has already been run.
% % m-files called: y_NSS.m, construct_hdr.m
% %
% % Pavel Solís (pavel.solis@gmail.com), March 2019
% %%
% path        = pwd;
% cd(fullfile(path,'..','..','Data','Raw'))               % Use platform-specific file separators
% filename    = 'US_Yield_Curve_Data.xlsx';
% param_names = {'BETA0','BETA1','BETA2','BETA3','TAU1','TAU2'};
% 
% % Parameters
% opts = spreadsheetImportOptions;
% opts.DataRange     = 'CQ11';                            % Starting cell for parameters
% opts.VariableNames = param_names;
% opts   = setvartype(opts,opts.VariableNames,{'double'});
% T_prms = readtable(filename,opts);
% 
% % Dates
% opts = spreadsheetImportOptions;
% opts.DataRange     = 'A11';                             % Starting cell for dates
% opts.VariableNames = 'Date';
% opts    = setvartype(opts,opts.VariableNames,{'datetime'});
% T_dates = readtable(filename,opts);
% cd(path)
% 
% % Yields
% fltr   = ~ismember(TH_pltfm.Type,'OIS') & ~ismember(TH_pltfm.Type,'FFF') & ...
%     ~isnan(TH_pltfm.Tenor) & TH_pltfm.Tenor > 0;
% mtrts  = unique(TH_pltfm.Tenor(fltr));
% params = table2array(T_prms);
% T_usyc = array2table(y_NSS(params,mtrts));              % Calculate zero yields for specified maturities
% 
% % Headers
% H_prms  = construct_hdr('USD','PARAMETER',param_names','USD N-S-S YIELD CURVE',NaN,' ','GSW');
% tnrs    = strtrim(cellstr(num2str(mtrts)));
% name_yc = strcat('USD ZERO-COUPON YIELD',{' '},tnrs,' YR');
% H_usyc  = construct_hdr('USD','HC',strcat('SVENY',tnrs),name_yc,num2cell(mtrts),' ','GSW'); % HC - hard currency
% TH_usyc = cell2table([H_prms; H_usyc]);
% TH_usyc.Properties.VariableNames = TH_pltfm.Properties.VariableNames;
% 
% % Merge timetables and headers
% TT_usyc  = table2timetable([T_dates, T_prms, T_usyc]);  % Convert table to a timetable
% TT_daily = synchronize(TT_pltfm,TT_usyc,'commonrange'); % Union over the intersection of time ranges
% TH_daily = [TH_pltfm; TH_usyc];
% 
% clear path filename opts param_names fltr mtrts params tnrs name_yc H_* *_pltfm *_usyc *_dates

%%
% 
% path = pwd;
% cd(fullfile(path,'..','..','Data'))% Use platform-dependent file separators
% filename = 'original_US_Yield_Curve_Data.xlsx';
% [dataGSW,txt] = xlsread(filename); % dataGSW only has values, txt includes headers and dates
% cd(path)
% 
% % Headers
% tnrmax = 10;                                % Maximum tenor needed is 10yrs
% tckrUS = txt(10,[2:(tnrmax+1) 95:end])';    % Line 10 in GSW has the 'tickers'
% aux1   = 1:tnrmax;
% aux2   = cellstr(num2str(aux1'));           % Cell with all the tenors as strings
% old    = ' '; new = '';
% tnr_usyc  = strrep(aux2(:),old,new);        % Remove spaces
% name_usyc = strcat('USD ZERO-COUPON YIELD',{' '},tnr_usyc,' YR');
% hdr_usyc1 = construct_hdr('USD','HC',tckrUS(1:tnrmax),name_usyc,tnr_usyc); % HC - hard currency
% hdr_usyc2 = construct_hdr('USD','PARAMETER',tckrUS(tnrmax+1:end),'N-S-S ZERO CURVE','X');
% hdr_usyc  = [hdr_usyc1;hdr_usyc2];
% 
% % Dates
% txt(1:10,:) = []; txt(:,2:end) = [];        % Only keep the dates from txt
% dates_usyc   = datenum(txt);                % Convert dates from char to datenum
% 
% % Data
% dataGSW  = [dates_usyc, dataGSW];           % Append the variables to the dates
% dataGSW  = dataGSW(:,[1:(tnrmax+1) 95:end]);% Keep yields up to tnrmax and parameters
% [~,idx1] = sort(dates_usyc);                % Sort dates in ascending order
% dataGSW  = dataGSW(idx1,:);                 % Reorder dataset from earliest to latest 
% 
% % Sample
% date1st    = min(dates);                    % 'dates' generated by read_bloomberg.m
% dateEnd    = max(dates);                    % Start and end dates relative to 'dates'
% idx2       = (dataGSW(:,1) >= date1st) & (dataGSW(:,1) <= dateEnd); % Logical
% dataGSW    = dataGSW(idx2,:);               % Limit the dataset to the sample dates
% dates_usyc = dataGSW(:,1);
% 
% % Match number of rows to data_blp.m (assumes size(dates,1) >= size(dates_usyc,1))
% nT = numel(dates);
% [datesmiss,idx_miss] = setdiff(dates,dates_usyc); % Dates in 'dates' not in 'dates_usyc'
% samedates = ~ismember(1:nT,idx_miss);             % Logical for same dates
% data_usyc = nan(nT,size(dataGSW,2));              % Pre-allocate output
% data_usyc(samedates,:) = dataGSW(:,:);            % Populate same dates with GSW data
% data_usyc(idx_miss,1)  = datesmiss;               % Cols 2:end are left as NaNs
% 
% clear path aux* idx* old new datesmiss samedates name_usyc hdr_usyc1 hdr_usyc2 nT
% clear date1st dateEnd filename dataGSW tckrUS tnrmax tnr_usyc dates_usyc txt
% 
%% Sources
% Insert rows in a matrix
% https://www.mathworks.com/matlabcentral/answers/...
% 276861-how-can-i-insert-a-row-in-the-middle-of-a-matrix-vector
% Convert a vector of doubles into a cell of strings
% https://www.mathworks.com/matlabcentral/answers/...
% 286544-how-i-could-convert-matrix-double-to-cell-array-of-string
% Concatanate strings with cell arrays of strings
% https://www.mathworks.com/matlabcentral/answers/...
% 18322-append-string-to-each-element-in-string-cell-array
% https://www.mathworks.com/matlabcentral/answers/9285-strcat-including-space-i-e