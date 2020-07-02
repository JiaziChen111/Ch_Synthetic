function [TT,TTx] = construct_panel(S,matsout,data_finan,hdr_finan,TT_mps,TTccy,currEM)
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
flds2   = {'svycbp' 'svycpi' 'svygdp' 'svytp' 'realrt' 'inf' 'une' 'ip' 'gdp' 'cbp' 'epu'};
varnms2 = {'scbp','scpi','sgdp','stp','real','inf','une','ip','gdp','cbp','epu'};
nflds1  = length(flds1);    nflds2  = length(flds2);
dtmx    = datetime('31-Jan-2019');                                          % end of the sample

% [data_finan,hdr_finan] = read_financialvars();
hdr_finan(ismember(hdr_finan(:,1),'USD') & ismember(hdr_finan(:,2),'STX'),2) = {'SPX'};
USDnames = {'VIX','FFR','SPX','OIL'};
LCnames  = {'CCY','STX'};
fltrUSD  = ismember(hdr_finan(:,2),USDnames);
fltrLC   = ismember(hdr_finan(:,2),LCnames);

% Global financial variables and monetary policy shocks
findata  = data_finan(:,fltrUSD);
finnms   = lower(hdr_finan(fltrUSD,2)');
findates = data_finan(:,1);
TT0      = array2timetable(findata,'RowTimes',datetime(findates,'ConvertFrom','datenum'),...
                'VariableNames',finnms);
fltrMPS  = contains(TT_mps.Properties.VariableNames,{'MP1','ED4','ED8','ONRUN10'});
TT0      = synchronize(TT0,TT_mps(:,fltrMPS),'union');                      % add MP shocks

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
    
    % Append field-specific variables to global variables and define dummies
    TT3        = synchronize(TT1,TT2,'intersection');
    datesmonth = unique(lbusdate(year(TT3.Time),month(TT3.Time)));
    TT3.eomth  = ismember(TT3.Time,datetime(datesmonth,'ConvertFrom','datenum'));
    if ismember(S(k0).iso,currEM)
        TT3.em = true(size(TT3,1),1);
    else
        TT3.em = false(size(TT3,1),1);
    end
    
    % Stack panels
    if k0 == 1
        TT = TT3;
    else
        TT = [TT;TT3];
    end
end

TT2 = [];
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
    TTx(k0).vars = TT3;
end

TT.Time.Format = 'dd-MMM-yyyy';

% Export the table to Excel
% pathc = pwd;
% filename = fullfile(pathc,'..','..','Data','Analytic','dataspillovers.xlsx');
% writetimetable(TT,filename,'Sheet',1,'Range','A1')

% cd(pathd)
% save datasets T* rnkt*
% cd(pathc)