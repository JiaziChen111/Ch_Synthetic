function TT = construct_panel(S,matsout,data_finan,hdr_finan)
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
fldsall = fieldnames(S);
flds    = [strcat({'dr','dc','dn','ds'},'_blncd') strcat('d_',{'yQ','yP','tp'}) ...
            strcat('bsl_',{'yQ','yP','tp'}) 'svycbp' 'svycpi' 'svygdp' 'svytp' ...
            'realrt' 'inf' 'une' 'ip' 'gdp' 'cbp' 'epu'];
varnms  = {'rho','phi','nom','syn','dyq','dyp','dtp','myq','myp','mtp','scbp','scpi','sgdp','stp',...
            'real','inf','une','ip','gdp','cbp','epu'};
nflds   = length(flds);
dtmx    = datetime('31-Jan-2019');

% [data_finan,hdr_finan] = read_financialvars();
hdr_finan(ismember(hdr_finan(:,1),'USD') & ismember(hdr_finan(:,2),'STX'),2) = {'SPX'};
USDnames = {'VIX','FFR','SPX','OIL'};
LCnames  = {'CCY','STX'};
fltrUSD  = ismember(hdr_finan(:,2),USDnames);
fltrLC   = ismember(hdr_finan(:,2),LCnames);

for k0 = 1:ncntrs
    % Global and domestic financial variables
    fltrCTY  = ismember(hdr_finan(:,1),S(k0).iso) & fltrLC;
    findata  = data_finan(:,fltrUSD | fltrCTY);
    finnms   = lower(hdr_finan(fltrUSD | fltrCTY,2)');
    findates = data_finan(:,1);
    TT1      = array2timetable(findata,'RowTimes',datetime(findates,'ConvertFrom','datenum'),...
                'VariableNames',finnms);
    TT1.cty  = repmat(S(k0).iso,length(findates),1);
	
    % Field-specific variables
    for k1 = 1:nflds
        fldnm = fldsall{ismember(fldsall,flds{k1})};
        if ~isempty(S(k0).(fldnm))                                          % fields with data
            tnrs  = S(k0).(fldnm)(1,:);
            fltrT = ismember(tnrs,matsout);
            if sum(fltrT) < 2                                               % single variable case
                dates = S(k0).(fldnm)(:,1);
                data  = S(k0).(fldnm)(:,2);                                 % first appearance if various series
                varnm = varnms(k1);
            else                                                            % different tenors
                dates = S(k0).(fldnm)(2:end,1);
                data  = S(k0).(fldnm)(2:end,fltrT);
                varnm = strcat(varnms{k1},cellfun(@num2str,num2cell(tnrs(fltrT)*12),'UniformOutput',false),'m');
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
    TT(k0).tt = TT3;
end
% dummy month

% TT = TT3;
% TT.Time.Format = 'dd-MMM-yyyy';