%% Term Structure Analysis: Nominal and Synthetic for EM and AE
% This code calls functions to estimate and analyze affine term structure models

% m-files called: daily2monthly, forecast_cbpol, append_surveys, atsm_estimation, compare_atsm_surveys
% add_vars, ts_plots, ts_correlations, ts_pca
% Pavel Solís (pavel.solis@gmail.com), June 2020
% 
%% Load the data
clear
pathc = pwd;
pathd = '/Users/Pavel/Dropbox/Dissertation/Book-DB-Sync/Ch_Synt-DB/Codes-DB/June-2020';
cd(pathd)
load('struct_datady_S.mat')
load('struct_datady_cells.mat')
cd(pathc)

%% Process the data
[S,dataset_monthly,header_monthly] = daily2monthly(S,dataset_daily,header_daily);
% S = daily2dymy(S,dataset_daily,header_daily,true);
S = forecast_cbpol(S,currEM);
S = append_surveys(S,currEM);

%% Estimate affine term structure model

% Cases
matsout = [0.25 0.5 1 2 5 10];                                      % report 3M-6M-1Y-2Y-5Y-10Y tenors
S = atsm_estimation(S,matsout,true);                                % free sgmS case, runtime 4.9 hrs
S = atsm_estimation(S,matsout,false);                               % fixed sgmS case, runtime 5.5 hrs

% Baseline estimations for all countries
fldname = {'ssb_','sy_','ny_'};
fldtype = {'yQ','yP','tp','pr'};
ncntrs  = length(S);
ntypes  = length(fldtype);
for k0  = 1:ncntrs
    for k1 = 1:ntypes
        switch S(k0).iso
            case setdiff(currEM,{'ILS','ZAR'})
                S(k0).(['bsl_' fldtype{k1}]) = S(k0).([fldname{1} fldtype{k1}]); % synthetic,surveys,fixed sgmS
            case {'ILS','ZAR'}
                S(k0).(['bsl_' fldtype{k1}]) = S(k0).([fldname{2} fldtype{k1}]); % synthetic, yields
            case currAE
                S(k0).(['bsl_' fldtype{k1}]) = S(k0).([fldname{3} fldtype{k1}]); % nominal, yields
        end
    end
end

% Assess fit of the model
[S,fitrprt] = assess_fit(S,currEM,currAE,false);

%% Store/load results
cd(pathd)
% save struct_datamy_S.mat S currAE currEM
load('struct_datamy_S.mat')
load('struct_datady_cells.mat')
load('struct_datady_S.mat','currAE')
load('struct_datady_S.mat','currEM')
cd(pathc)

% Report estimated sgmS
fldname = 'ssf_pr';
aux = [];
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        aux = [aux; k0 S(k0).(fldname).sgmS];
    end
end

% [~,corrPC,pctmiss] = compare_pcs(S,nPCs,true);
% save('struct_datamy_S.mat','corrPC','-append')
% save('struct_datamy_S.mat','pctmiss','-append')

% %% Compare results
% [S,corrExp,corrTP] = compare_atsm_surveys(S,currEM,0);      % compare expected policy rate and term premium

%% Post-estimation analysis

[S,uskwfy,uskwyp,uskwtp,ustp10,ustpguim,vix] = add_vars(S,currEM);
ts_plots(S,currEM,currAE,ustp10,ustpguim,vix);
[corrTPem,corrTPae,corrBRP,corrTPyP] = ts_correlations(S,currEM,currAE,ustp10,vix);
[pcexplnd,pc1yc,pc1res,r2TPyP] = ts_pca(S,currEM,uskwyp,uskwtp);


%% Daily frequency estimation
S = daily2dymy(S,dataset_daily,header_daily,false);
[S,fitrprtdy] = atsm_daily(S,matsout,currEM,currAE,false);


%% Construct panel dataset

% Read data
[data_finan,hdr_finan] = read_financialvars();
TT_mps = read_mps();
TT_epu = read_epu_usdgbl();
TT_gbl = read_global_idxs();
addpath('../Pre-Analysis')                                        	% read_platforms.m in different folder
warning('OFF','MATLAB:table:ModifiedAndSavedVarnames')             	% suppress table warnings
TTpltf = read_platforms();                                          % for exchange rate data

% Read conventions to quote FX
pathc    = pwd;
pathd    = fullfile(pathc,'..','..','Data','Raw');                  % platform-specific file separators
cd(pathd)
filename = 'AE_EM_Curves_Tickers.xlsx';
convfx   = readcell(filename,'Sheet','CONV','Range','H66:H90');     % update range as necessary
cd(pathc)

% Express all FX as LC per USD
TTccy  = TTpltf(:,ismember(TTpltf.Properties.VariableNames,curncs));
fltrFX = ismember(TTccy.Properties.VariableNames,curncs(~startsWith(convfx,'USD')));
TTccy{:,fltrFX} = 1./TTccy{:,fltrFX};

TT = construct_panel(S,matsout,data_finan,hdr_finan,TT_mps,TT_epu,TT_gbl,TTccy,currEM);


%% US TP
ynsvys = readmatrix(fullfile(fullfile(pwd,'..','..','Data','Aux','USYCSVY'),...
    'USYCSVYdata.xlsx'),'Sheet',1);
dates  = x2mdate(ynsvys(:,1));                                  	% dates as datenum
ynsvys = ynsvys(:,2:end)./100;                                   	% data in decimals
yonly  = ynsvys(:,1:8);                                          	% yield data
matsY  = [0.25 1:5 7 10];                                           % yield maturities in years
matsS  = [0.25:0.25:1 10];
p      = 3;                                                       	% number of state vectors
dt     = 1/12;                                                     	% monthly periods
matout = [1 5 10];

[ylds_Qjsz,ylds_Pjsz,tpjsz,params0] = estimation_jsz(yonly,matsY,matout,dt,p);
[ylds_Q,ylds_P,termprm,params] = estimation_svys(ynsvys,matsY,matsS,matout,dt,params0);

figure; plot(dates,yonly(:,end),dates,ylds_Qjsz(:,end),dates,ylds_Q(:,end))
figure; plot(dates,termprm(:,end),dates,tpjsz(:,end))
svys  = ynsvys(:,9:end);
figure; plot(dates(240:end),ylds_P(240:end,end),dates(240:end),ylds_Pjsz(240:end,end),...
             dates(240:end),svys(240:end,end),'*')


%% Decomposition of Nominal Yield Curves and TP Comparison

ncntrs  = length(S);
tnr = 10;
decomp = nan(ncntrs,5);
tpvslccs = nan(ncntrs,3);
tpcompare = nan(ncntrs,2);
tpnomvssyn = nan(ncntrs,3);

for k = 1:ncntrs
    yieldsnom = mean(S(k).nomblncd(2:end, S(k).nomblncd(1,:) == tnr)*100);
    yieldssyn = mean(S(k).synblncd(2:end, S(k).synblncd(1,:) == tnr)*100);
    yieldsP   = mean(S(k).synyldsP(2:end, S(k).synyldsP(1,:) == tnr)*100);
    x = S(k).syntp(3:end, S(k).syntp(1,:) == tnr);
    tpsyn     = mean(x);
    y = S(k).cipdev(2:end, S(k).cipdev(1,:) == tnr);
    lccs      = mean(y,'omitnan');
    decomp(k,:) = [yieldsnom yieldssyn yieldsP tpsyn lccs];
    [h,p] = ttest2(x,y,'Vartype','unequal');     % Equality of means test b/w TP and LCCS
    tpvslccs(k,:) = [k h p];
    
    z = S(k).nomtp(3:end, S(k).nomtp(1,:) == tnr);
    tpnom     = mean(z);
    tpcompare(k,:) = [tpnom tpsyn];
    [h,p] = ttest2(z,x,'Vartype','unequal');     % Equality of means test b/w TP and LCCS
    tpnomvssyn(k,:) = [k h p];
end

AvgDecomp = [mean(decomp(1:15,:)); mean(decomp([16:19 23:25],:)); mean(decomp(20:22,:))];
clear input
labelcty    = {'EM','A-SOE','G-3'};
labelcty{1} = [' ' labelcty{1}];                % Otherwise, Latex gives an error
input.tableRowLabels = labelcty;
input.tableColLabels = {'Nominal','Synthetic','Expected','Term Premium','CIP Dev'};
input.dataFormat = {'%.2f'};
input.fontSize = 'tiny';
filename   = fullfile('..','..','Docs','Tables','temp_decomp10yr');
input.data = AvgDecomp;
input.tableCaption = '10-Year Yield Decomposition (\%).';
input.tableLabel = 'decomp10yr';
input.texName = filename;
latexTable(input);


AvgTPnomvssyn = [mean(tpcompare(1:15,:)); mean(tpcompare([16:19 23:25],:)); mean(tpcompare(20:22,:))];
clear input
labelcty    = {'EM','A-SOE','G-3'};
labelcty{1} = [' ' labelcty{1}];                % Otherwise, Latex gives an error
input.tableRowLabels = labelcty;
input.tableColLabels = {'Nominal','Synthetic'};
input.dataFormat = {'%.2f'};
input.fontSize = 'tiny';
filename   = fullfile('..','..','Docs','Tables','temp_tp_compare');
input.data = AvgTPnomvssyn;
input.tableCaption = '10-Year Term Premium Comparison (\%).';
input.tableLabel = 'tp_compare10yr';
input.texName = filename;
latexTable(input);


%%


% %% Term Spread
% 
% ncntrs  = length(S);
% Mlong  = 10;
% Mshort = 0.25; %2;
% tsnomvssyn = nan(ncntrs,3);
% tsmean = nan(ncntrs,3);
% corrTSprd = nan(ncntrs,2);
% 
% for k = 1:ncntrs
%     x = S(k).nomtsprd(:,2);
%     y = S(k).syntsprd(:,2);
%     [h,p] = ttest2(x,y);     % Equality of means test b/w TSnom and TSsyn
%     tsnomvssyn(k,:) = [k h p]; % Null of equality is not rejected for any country
%     % The mean of the 10yr-3m spread is higher than the mean of the 10-2yr spread
%     % corr of 10-2yr spread b/w nom and syn is generally higher than corr of 10yr-3m spread
% end

%% Average over a field: EM vs AE and Nom vs Syn

fname = 'RMSEb'; % 'PCb'
fnom = ['nom' fname];
fsyn = ['syn' fname];
AvgEM_AE = nan(2,2);
% AvgEM_AE = cell(3,3);
% AvgEM_AE{1,2} = 'Nominal';  AvgEM_AE{1,3} = 'Synthetic';
% AvgEM_AE{2,1} = 'EM';       AvgEM_AE{3,1} = 'AE';

AvgNomb = 0; AvgSynb = 0;
for k = 1:15
    AvgNomb = AvgNomb + S(k).(fnom);
    AvgSynb = AvgSynb + S(k).(fsyn);
end
AvgEMnom = AvgNomb/15; AvgEMsyn = AvgSynb/15;

AvgNomb = 0; AvgSynb = 0;
for k = 16:25
    AvgNomb = AvgNomb + S(k).(fnom);
    AvgSynb = AvgSynb + S(k).(fsyn);
end
AvgAEnom = AvgNomb/10; AvgAEsyn = AvgSynb/10;
clear AvgNomb AvgSynb

% AvgEM_AE{2,2} = AvgEMnom;  AvgEM_AE{2,3} = AvgEMsyn;
% AvgEM_AE{3,2} = AvgAEnom;  AvgEM_AE{3,3} = AvgAEsyn;
AvgEM_AE(1,1) = AvgEMnom;  AvgEM_AE(1,2) = AvgEMsyn;
AvgEM_AE(2,1) = AvgAEnom;  AvgEM_AE(2,2) = AvgAEsyn;

clear input
labelcty    = {'EM','AE'};
labelcty{1} = [' ' labelcty{1}];                % Otherwise, Latex gives an error
input.tableRowLabels = labelcty;
input.tableColLabels = {'Nominal','Synthetic'};
input.dataFormat = {'%.2f'};
input.fontSize = 'tiny';
filename   = fullfile('..','..','Docs','Tables','temp_RMSE_ATSM');
input.data = AvgEM_AE;
input.tableCaption = 'Fit of Affine Term Structure Models.';
input.tableLabel = 'rmse_atsm';
input.texName = filename;
latexTable(input);

