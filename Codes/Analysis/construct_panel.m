function [TT,TTx] = construct_panel(S,matsout,data_finan,hdr_finan,TT_mps,TT_epu,TT_gbl,TTccy,currEM)
% CONSTRUCT_PANEL Construct panel dataset for regression analysis
% 
%	INPUTS
% S        - structure with fields bsl_pr, s, n, ds, dn
% matsout  - bond maturities in years to be reported
% currEM   - emerging market countries
% currAE   - advanced countries
% plotfit  - logical indicating whether to show a plot of the fit
%
%	OUTPUT
% S - structure includes estimated yields under Q and P measures, estimated term premia

% m-files called: none
% Pavel Solís (pavel.solis@gmail.com), June 2020
%%
S(5).svycbp = []; S(5).svytp = []; S(15).svycbp = []; S(15).svytp = [];
ncntrs  = length(S);
nEMs    = length(currEM);
fldsall = fieldnames(S);
flds1   = [strcat({'dr','dc','dn','ds'},'_blncd') strcat('d_',{'yQ','yP','tp'}) ...
            strcat('bsl_',{'yQ','yP','tp'})];
varnms1 = {'rho','phi','nom','syn','dyq','dyp','dtp','myq','myp','mtp'};

flds2   = {'cbp','inf','une','ip','gdp','svycbp','svycpi','svygdp','svytp','realrt','epu'};
varnms2 = {'cbp','inf','une','ip','gdp','scbp','scpi','sgdp','stp','real','epu'};
nflds1  = length(flds1);    nflds2  = length(flds2);
dtmx    = datetime('31-Jan-2019');                                          % end of the sample

%% Read data
% [data_finan,hdr_finan] = read_financialvars();


%% Variables common to all countries
hdr_finan(ismember(hdr_finan(:,1),'USD') & ismember(hdr_finan(:,2),'STX'),2) = {'SPX'};
USDnames = {'VIX','FFR','SPX','OIL'};
fltrUSD  = ismember(hdr_finan(:,2),USDnames);
findata  = data_finan(:,fltrUSD);
finnms   = lower(hdr_finan(fltrUSD,2)');
findates = data_finan(:,1);
TT0      = array2timetable(findata,'RowTimes',datetime(findates,'ConvertFrom','datenum'),...
                'VariableNames',finnms);
fltrMPS  = contains(TT_mps.Properties.VariableNames,{'MP1','ED4','ED8','ONRUN10','PATH','LSAP'});
TT0      = synchronize(TT0,TT_mps(:,fltrMPS),'union');                      % add MP shocks
TT0      = synchronize(TT0,TT_epu,'union');                                 % add EPU indexes (US and global)
TT0      = synchronize(TT0,TT_gbl,'union');                                 % add global activity indexes

%% Country-specific variables
for k0 = 1:ncntrs
    fltrFX   = strcmp(TTccy.Properties.VariableNames,S(k0).iso);
    TTfx     = TTccy(:,fltrFX);
    TTfx.Properties.VariableNames = {'fx'};                                 % ensure same variable names
    TT1      = synchronize(TT0,TTfx,'union');                               % add FX
    TT1.cty  = repmat(S(k0).iso,size(TT1,1),1);                             % add currency code
    TT1.imf  = repmat(S(k0).imf,size(TT1,1),1);                             % add IMF code
	
    % Field-specific variables
    for k1 = 1:nflds1
        fldnm = fldsall{ismember(fldsall,flds1{k1})};
        tnrs  = S(k0).(fldnm)(1,:);
        fltrT = ismember(tnrs,matsout);
        dates = S(k0).(fldnm)(2:end,1);
        data  = S(k0).(fldnm)(2:end,fltrT);
        tnrst = cellfun(@num2str,num2cell(tnrs(fltrT)*12),'UniformOutput',false);
        varnm = strcat(varnms1{k1},tnrst,'m');
        TTaux = array2timetable(data,'RowTimes',datetime(dates,'ConvertFrom','datenum'),...
                'VariableNames',varnm);
        if k1 == 1
            TT2 = TTaux;
        else
            TT2 = synchronize(TT2,TTaux,'union');                           % add yields and components
        end
    end
    dtmn = datesminmax(S,k0);
    TT2  = TT2(isbetween(TT2.Time,datetime(dtmn,'ConvertFrom','datenum'),dtmx),:);
    
    % Append field-specific variables to global variables
    TT3       = synchronize(TT1,TT2,'intersection');
    
    % Stack panels
    if k0 == 1
        TT = TT3;
    else
        TT = [TT;TT3];
    end
end

% Define dummies
datesmth = unique(lbusdate(year(TT.Time),month(TT.Time)));
TT.eomth = ismember(TT.Time,datetime(datesmth,'ConvertFrom','datenum'));  % end of month
TT.eoqtr = (mod(month(TT.Time),3) == 0) & TT.eomth;                      % end of quarter
TT.em    = ismember(TT.cty,currEM);

%% EM-specific variables
TT2 = [];
fltrLC = ismember(hdr_finan(:,2),'STX');
for k0 = 1:nEMs
    % Domestic financial variables
    fltrCTY = ismember(hdr_finan(:,1),S(k0).iso) & fltrLC;
    findata = data_finan(:,fltrCTY);
    finnms  = lower(hdr_finan(fltrCTY,2)');
    TT1     = array2timetable(findata,'RowTimes',datetime(findates,'ConvertFrom','datenum'),...
                'VariableNames',finnms);
	
    % Field-specific variables
    for k1 = 1:nflds2
        fldnm = fldsall{ismember(fldsall,flds2{k1})};
        if ~isempty(S(k0).(fldnm))                                          % fields with data
            tnrs  = S(k0).(fldnm)(1,:);
            fltrT = ismember(tnrs,matsout);
            if sum(fltrT) < 2                                               % single variable case
                dates = S(k0).(fldnm)(:,1);
                data  = S(k0).(fldnm)(:,2);                                 % choose first appearance if needed
                varnm = varnms2(k1);
            else                                                            % different tenors
                dates = S(k0).(fldnm)(2:end,1);
                data  = S(k0).(fldnm)(2:end,fltrT);
                tnrst = cellfun(@num2str,num2cell(tnrs(fltrT)*12),'UniformOutput',false);
                varnm = strcat(varnms2{k1},tnrst,'m');
            end
            TTaux = array2timetable(data,'RowTimes',datetime(dates,'ConvertFrom','datenum'),...
                    'VariableNames',varnm);
            if k1 == 1
                TT2 = TTaux;
            else
                TT2 = synchronize(TT2,TTaux,'union');
            end
        end
    end
    dtmn = datesminmax(S,k0);
    TT2  = TT2(isbetween(TT2.Time,datetime(dtmn,'ConvertFrom','datenum'),dtmx),:);
    
    TT3  = synchronize(TT1,TT2,'intersection');
    
    % Stack panels
    if k0 == 1
        TTx = TT3;
    else
        TTxcolsmiss = setdiff(TT3.Properties.VariableNames, TTx.Properties.VariableNames);
        TT3colsmiss = setdiff(TTx.Properties.VariableNames, TT3.Properties.VariableNames);
        TTx = [TTx array2table(nan(height(TTx), numel(TTxcolsmiss)), 'VariableNames', TTxcolsmiss)];
        TT3 = [TT3 array2table(nan(height(TT3), numel(TT3colsmiss)), 'VariableNames', TT3colsmiss)];
        TTx = [TTx;TT3];
    end
    
    TTx.gdp(mod(month(TTx.Time),3) ~= 0) = nan;     % only keep quarterly data for GDP
%     TTx(k0).vars = TT3;
end

TT.Time.Format = 'dd-MMM-yyyy';

% Export the table to Excel
% pathc = pwd;
% filename = fullfile(pathc,'..','..','Data','Analytic','dataspillovers.xlsx');
% writetimetable(TT,filename,'Sheet',1,'Range','A1')

% cd(pathd)
% save datasets T* rnkt*
% cd(pathc)

% Source
% Merge tables with different dimensions
% https://www.mathworks.com/matlabcentral/answers/179290-merge-tables-with-different-dimensions