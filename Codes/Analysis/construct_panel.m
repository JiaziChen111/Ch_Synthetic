function TT = construct_panel(S,matsout,data_finan,hdr_finan,TT_mps,TT_epu,TT_gbl,TT_rr,TTccy,tradingdays,currEM)
% CONSTRUCT_PANEL Construct panel dataset for regression analysis
% 
%	INPUTS
% S        - structure with fields bsl_pr, s, n, ds, dn
% matsout  - bond maturities in years to be reported
% currEM   - emerging market countries in the sample
%
%	OUTPUT
% TT - panel dataset

% m-files called: none
% Pavel Solís (pavel.solis@gmail.com), June 2020
%%
S(5).svycbp = []; S(5).svytp = []; S(15).svycbp = []; S(15).svytp = [];
ncntrs  = length(S);
fldsall = fieldnames(S);
flds1   = ['d_usd' strcat({'dr','dc','dn','ds'},'_blncd') strcat('d_',{'yQ','yP','tp'}) ...
            strcat('bsl_',{'yQ','yP','tp'})];
varnms1 = {'usyc','rho','phi','nom','syn','dyq','dyp','dtp','myq','myp','mtp'};    % common variables
flds2   = {'cbp','inf','une','ip','gdp','scbp','scpi','sgdp','stp','rrt','epu'};
varnms2 = {'cbp','inf','une','ip','gdp','scbp','scpi','sgdp','stp','rrt','epu'};   % EM-specific variables
flds    = [flds1 flds2];
varnms  = [varnms1 varnms2];
nflds  = length(flds); 


dtmx    = datetime('31-Jan-2019');                                          % end of the sample

%% Read data
% [data_finan,hdr_finan] = read_financialvars();


%% Variables common to all countries
hdr_finan(ismember(hdr_finan(:,1),'USD') & ismember(hdr_finan(:,2),'STX'),2) = {'SPX'};
USDnames = {'VIX','FFR','SPX','OIL'};
fltrUSD  = ismember(hdr_finan(:,2),USDnames);
fltrLC   = ismember(hdr_finan(:,2),'STX');
findata  = data_finan(:,fltrUSD);
finnms   = lower(hdr_finan(fltrUSD,2)');
findates = data_finan(:,1);
TT0      = array2timetable(findata,'RowTimes',datetime(findates,'ConvertFrom','datenum'),...
                'VariableNames',finnms);
fltrMPS  = contains(TT_mps.Properties.VariableNames,{'MP1','ED4','ED8','ONRUN10','PATH','LSAP'});
TT0      = synchronize(TT0,TT_mps(:,fltrMPS),'union');                      % add MP shocks
TT0      = synchronize(TT0,TT_epu,'union');                                 % add EPU indexes (US and global)
TT0      = synchronize(TT0,TT_gbl,'union');                                 % add global activity indexes
TT0      = synchronize(TT0,TT_rr,'union');                                  % add US real rates

%% Country-specific variables
for k0 = 1:ncntrs
    fltrFX   = strcmp(TTccy.Properties.VariableNames,S(k0).iso);
    TTfx     = TTccy(:,fltrFX);
    TTfx.Properties.VariableNames = {'fx'};                                 % ensure same variable names
    TT1      = synchronize(TT0,TTfx,'union');                               % add FX
    TT1.cty  = repmat(S(k0).iso,size(TT1,1),1);                             % add currency code
    TT1.imf  = repmat(S(k0).imf,size(TT1,1),1);                             % add IMF code
	
    % Field-specific variables
    for k1 = 1:nflds
        fldnm = fldsall{ismember(fldsall,flds{k1})};
        if ~isempty(S(k0).(fldnm))                                          % fields with data
            tnrs  = S(k0).(fldnm)(1,:);
            fltrT = ismember(tnrs,matsout);
            if sum(fltrT) < 2                                               % single variable case
                dates = S(k0).(fldnm)(:,1);
                data  = S(k0).(fldnm)(:,2);                                 % choose first appearance if needed
                varnm = varnms(k1);
            else                                                            % different tenors
                dates = S(k0).(fldnm)(2:end,1);
                data  = S(k0).(fldnm)(2:end,fltrT);
                tnrst = cellfun(@num2str,num2cell(tnrs(fltrT)*12),'UniformOutput',false);
                varnm = strcat(varnms{k1},tnrst,'m');
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
    
    % Append field-specific variables to global variables
    TT3  = synchronize(TT1,TT2,'intersection');
    
    % Domestic financial variables
    fltrCTY = ismember(hdr_finan(:,1),S(k0).iso) & fltrLC;
    findata = data_finan(:,fltrCTY);
    finnms  = lower(hdr_finan(fltrCTY,2)');
    TTstx   = array2timetable(findata,'RowTimes',datetime(findates,'ConvertFrom','datenum'),...
                'VariableNames',finnms);
    TT3     = synchronize(TT3,TTstx,'intersection');
    
    % Stack panels
    if k0 == 1
        TT = TT3;
    else
        TTcolsmiss  = setdiff(TT3.Properties.VariableNames, TT.Properties.VariableNames);
        TT3colsmiss = setdiff(TT.Properties.VariableNames, TT3.Properties.VariableNames);
        TT  = [TT array2table(nan(height(TT), numel(TTcolsmiss)), 'VariableNames', TTcolsmiss)];
        TT3 = [TT3 array2table(nan(height(TT3), numel(TT3colsmiss)), 'VariableNames', TT3colsmiss)];
        TT  = [TT;TT3];
    end
end
TT(~ismember(TT.Time,tradingdays),:) = [];                              % remove non-trading days

% Define dummies
datesmth = unique(lbusdate(year(TT.Time),month(TT.Time)));
TT.eomth = ismember(TT.Time,datetime(datesmth,'ConvertFrom','datenum'));% end of month
TT.eoqtr = (mod(month(TT.Time),3) == 0) & TT.eomth;                     % end of quarter
TT.em    = ismember(TT.cty,currEM);                                     % emerging markets

TT.gdp(mod(month(TT.Time),3) ~= 0) = nan;                              	% only keep quarterly data for GDP
TT.Time.Format = 'dd-MMM-yyyy';

% Export the table to Excel
pathc = pwd;
filename = fullfile(pathc,'..','..','Data','Analytic','dataspillovers.xlsx');
writetimetable(TT,filename,'Sheet',1,'Range','A1')

% cd(pathd)
% save datasets T* rnkt*
% cd(pathc)

% Source
% Merge tables with different dimensions
% https://www.mathworks.com/matlabcentral/answers/179290-merge-tables-with-different-dimensions