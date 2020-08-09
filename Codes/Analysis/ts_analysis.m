%% Term Structure Analysis: Nominal and Synthetic for EM and AE
% This code calls functions to estimate and analyze affine term structure models

% m-files called: daily2dymy, add_macroNsvys, append_svys2ylds, atsm_estimation,
% assess_fit, add_vars, ts_plots, ts_correlations, ts_pca, atsm_daily, construct_panel
% auxiliary: read_macrovars, read_kw
% Pavel Solís (pavel.solis@gmail.com), August 2020
% 
%% Load the data
clear
pathc = pwd;
pathd = '/Users/Pavel/Dropbox/Dissertation/Book-DB-Sync/Ch_Synt-DB/Codes-DB/August-2020';
cd(pathd)
load('struct_datady_S.mat')
load('struct_datady_cells.mat')
cd(pathc)

%% Process the data
S = daily2dymy(S,dataset_daily,header_daily,true);
S = add_macroNsvys(S,currEM);
S = append_svys2ylds(S,currEM);

%% Estimate affine term structure model
matsout = [0.25 0.5 1 2 5 10];                                      % report 3M-6M-1Y-2Y-5Y-10Y tenors
datetime(now(),'ConvertFrom','datenum')
S = atsm_estimation(S,matsout,false);                               % fixed sgmS case, runtime 4.1 hrs
datetime(now(),'ConvertFrom','datenum')
S = atsm_estimation(S,matsout,true);                                % free sgmS case, runtime 4 hrs
datetime(now(),'ConvertFrom','datenum')

%% Baseline estimations
ncntrs  = length(S);
fldname = {'mssb_','mny_'};  % fldname = {'mssb_','msy_','mny_'};
fldtype = {'yQ','yP','tp','pr'};
ntypes  = length(fldtype);
for k0  = 1:ncntrs
    for k1 = 1:ntypes
        if ismember(S(k0).iso,currEM)
            fldaux = fldname{1};                                    % synthetic yields, surveys,fixed sgmS
        else
            fldaux = fldname{2};                                    % nominal yields
        end
%         switch S(k0).iso
%             case setdiff(currEM,{'ILS','ZAR'})
%                 fldaux = fldname{1};                                % synthetic yields, surveys,fixed sgmS
%             case {'ILS','ZAR'}
%                 fldaux = fldname{2};                                % synthetic yields
%             case currAE
%                 fldaux = fldname{3};                                % nominal yields
%         end
        S(k0).(['bsl_' fldtype{k1}]) = S(k0).([fldaux fldtype{k1}]);
    end
end

% Assess fit of the model
[S,fitrprtmy] = assess_fit(S,currEM,currAE,false);

S = add_vars(S,currEM);

%% Store/load results
cd(pathd)
% save struct_datamy_S.mat S currAE currEM
load('struct_datamy_S.mat')
load('struct_datady_cells.mat')
cd(pathc)

%% Post-estimation analysis
[data_macro,hdr_macro] = read_macrovars(S);                 % macro and policy rates
vix = data_macro(:,ismember(hdr_macro(:,2),{'type','VIX'}));
[TT_kw,kwtp,kwyp] = read_kw(matsout);

ts_plots(S,currEM,currAE,kwtp,vix);
[corrTPem,corrTPae,corrBRP,corrTPyP] = ts_correlations(S,currEM,currAE,kwtp,vix);
[pcexplnd,pc1yc,pc1res,r2TPyP] = ts_pca(S,currEM,kwyp,kwtp);

%% Daily frequency estimation
S = daily2dymy(S,dataset_daily,header_daily,false);
[S,fitrprtdy] = atsm_daily(S,matsout,currEM,currAE,false);

%% Construct panel dataset
TT = construct_panel(S,matsout,currEM,currAE);

%%
% [S,dataset_monthly,header_monthly] = daily2monthly(S,dataset_daily,header_daily);
% S = forecast_cbpol(S,currEM);

% % Baseline estimations
% fldname = {'ssb_','sy_','ny_'};
% fldtype = {'yQ','yP','tp','pr'};
% ncntrs  = length(S);
% ntypes  = length(fldtype);
% for k0  = 1:ncntrs
%     for k1 = 1:ntypes
%         switch S(k0).iso
%             case setdiff(currEM,{'ILS','ZAR'})
%                 S(k0).(['bsl_' fldtype{k1}]) = S(k0).([fldname{1} fldtype{k1}]); % synthetic,surveys,fixed sgmS
%             case {'ILS','ZAR'}
%                 S(k0).(['bsl_' fldtype{k1}]) = S(k0).([fldname{2} fldtype{k1}]); % synthetic, yields
%             case currAE
%                 S(k0).(['bsl_' fldtype{k1}]) = S(k0).([fldname{3} fldtype{k1}]); % nominal, yields
%         end
%     end
% end

% [~,corrPC,pctmiss] = compare_pcs(S,nPCs,true);
% save('struct_datamy_S.mat','corrPC','-append')
% save('struct_datamy_S.mat','pctmiss','-append')

% %% Compare results
% [S,corrExp,corrTP] = compare_atsm_surveys(S,currEM,0);      % compare expected policy rate and term premium

% addpath('../Pre-Analysis')
% notradedays = TTusyc.Date(sum(ismissing(TTusyc),2) == size(TTusyc,2));
% tradingdays = TTusyc.Date(~ismember(TTusyc.Date,notradedays));      % trading days in the U.S.


% %% Decomposition of Nominal Yield Curves and TP Comparison
% 
% ncntrs  = length(S);
% tnr = 10;
% decomp = nan(ncntrs,5);
% tpvslccs = nan(ncntrs,3);
% tpcompare = nan(ncntrs,2);
% tpnomvssyn = nan(ncntrs,3);
% 
% for k = 1:ncntrs
%     yieldsnom = mean(S(k).nomblncd(2:end, S(k).nomblncd(1,:) == tnr)*100);
%     yieldssyn = mean(S(k).synblncd(2:end, S(k).synblncd(1,:) == tnr)*100);
%     yieldsP   = mean(S(k).synyldsP(2:end, S(k).synyldsP(1,:) == tnr)*100);
%     x = S(k).syntp(3:end, S(k).syntp(1,:) == tnr);
%     tpsyn     = mean(x);
%     y = S(k).cipdev(2:end, S(k).cipdev(1,:) == tnr);
%     lccs      = mean(y,'omitnan');
%     decomp(k,:) = [yieldsnom yieldssyn yieldsP tpsyn lccs];
%     [h,p] = ttest2(x,y,'Vartype','unequal');     % Equality of means test b/w TP and LCCS
%     tpvslccs(k,:) = [k h p];
%     
%     z = S(k).nomtp(3:end, S(k).nomtp(1,:) == tnr);
%     tpnom     = mean(z);
%     tpcompare(k,:) = [tpnom tpsyn];
%     [h,p] = ttest2(z,x,'Vartype','unequal');     % Equality of means test b/w TP and LCCS
%     tpnomvssyn(k,:) = [k h p];
% end
% 
% AvgDecomp = [mean(decomp(1:15,:)); mean(decomp([16:19 23:25],:)); mean(decomp(20:22,:))];
% clear input
% labelcty    = {'EM','A-SOE','G-3'};
% labelcty{1} = [' ' labelcty{1}];                % Otherwise, Latex gives an error
% input.tableRowLabels = labelcty;
% input.tableColLabels = {'Nominal','Synthetic','Expected','Term Premium','CIP Dev'};
% input.dataFormat = {'%.2f'};
% input.fontSize = 'tiny';
% namefl   = fullfile('..','..','Docs','Tables','temp_decomp10yr');
% input.data = AvgDecomp;
% input.tableCaption = '10-Year Yield Decomposition (\%).';
% input.tableLabel = 'decomp10yr';
% input.texName = namefl;
% latexTable(input);