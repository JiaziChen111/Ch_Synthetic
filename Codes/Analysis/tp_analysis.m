%% Analysis of Term Premia: EM vs AE, Nominal vs Synthetic
% This code calls functions to compare the estimated term premia between
% advanced and emerging countries as well as between nominal and synthetic 
% yield curves.
% 
% m-files called: daily2monthly.m, tp_estimation.m, estimate_TR.m
%
% Pavel Solís (pavel.solis@gmail.com), May 2019
% 
%% Save data to structure
clear
currentDir = pwd;
cd '/Users/Pavel/Dropbox/Dissertation/Book-DB-Sync/Ch_Synt-DB/Codes-DB'
load('struct_data_1_S.mat')
load('struct_data_2_TT.mat')
load('struct_data_3_cells.mat')
cd(currentDir)
N  = 3;
dt = 1/12;

S = daily2monthly(dataset_daily,header_daily,S,'CIPDEV');

S = daily2monthly(dataset_daily,header_daily,S,'LCSYNT');
[S,corrPCsyn] = tp_estimation(S,N,dt,'LCSYNT');

S = daily2monthly(dataset_daily,header_daily,S,'LC');
[S,corrPCnom] = tp_estimation(S,N,dt,'LC');


%% Compare TPs: Nominal vs Synthetic
ncntrs  = length(S);
fnames  = fieldnames(S);
tnr     = 10;
series  = 'yldsP';%'tp';%yldsQ;
if strcmp(series,'tp'); rowStrt = 3; else; rowStrt = 2; end

% figure
% hold on
for k = 1:ncntrs
    idxN    = contains(fnames,['nom' series]);   fnameN  = fnames{idxN};
    idxS    = contains(fnames,['syn' series]);   fnameS  = fnames{idxS};
    matsN   = S(k).(fnameN)(1,2:end);            matsS   = S(k).(fnameS)(1,2:end);
    datesN  = S(k).(fnameN)(rowStrt:end,1);      datesS  = S(k).(fnameS)(rowStrt:end,1);
    seriesN = S(k).(fnameN)(rowStrt:end,2:end);  seriesS = S(k).(fnameS)(rowStrt:end,2:end);
    
    figure
    plot(datesN,seriesN(:,matsN == tnr),datesS,seriesS(:,matsS == tnr))
%     plot(datesN,seriesN(:,matsN == tnr))
%     plot(datesS,seriesS(:,matsS == tnr))
    title([S(k).ccy '  ' num2str(tnr) ' YR']),
    legend('Nominal','Synthetic')%, ylabel('%')
    datetick('x','YY:QQ')
    hline = refline(0,0); hline.Color = 'k';
    ylim([-inf inf])
end
% hold off

%% Use Survey Data

% Estimate Taylor Rule and save weights for inflation and GDP growth
[S,weightsLT,namesWgts,outputLT,outputTR] = estimate_TR(S,currEM);

% Estimate long-term forecasts of policy rates
S = forecastLTcbpol(S,currEM,weightsLT,namesWgts);

% Compare expected policy rate and term premium from ATSM and from surveys
[S,corrExp,corrTP] = compare_atsm_surveys(S,currEM,0);



%% Store macro data in structure

vars = {'INF','UNE','IP','GDP','CBP'};
fnames = lower(vars);

for l = 1:length(vars)
    fltrMAC = ismember(hdr_macro(:,2),vars{l});
    for k = 1:15
        fltrCTY    = ismember(hdr_macro(:,1),S(k).iso) & fltrMAC;
        fltrCTY(1) = true;
        data_mvar  = data_macro(:,fltrCTY);
        if size(data_mvar,2) > 1
            idxNaN     = isnan(data_mvar(:,2));             % Assumes once publication starts, it continues
            S(k).(fnames{l}) = data_mvar(~idxNaN,:);
        end
    end
end

%% Plot macro data

for l = 1:length(vars)
    figure
    for k = 1:15
        if size(S(k).(fnames{l}),2) > 1
            plot(S(k).(fnames{l})(:,1),S(k).(fnames{l})(:,2),'DisplayName',S(k).iso);
            if k == 1
                legend('-DynamicLegend');
                hold all;
            else
                hold all;
            end
        end
    end
    title(vars{l}), ylabel('%')
    datetick('x','YYQQ')
end

% Source
% 
% Hold on a legend in a plot
% https://www.mathworks.com/matlabcentral/answers/9434-how-can-i-hold-the-previous-legend-on-a-plot

%% Plot Synthetic TP

tnr = 10;
figure
% title('Synthetic Term Premium')
% g = [1 2 3 5 7; 8 9 11 13 15; 4 6 10 12 14];
g = [2 3 5 8 9; 1 7 11 13 15; 4 6 10 12 14];
for m = 1:3
    rowg = g(m,:);
    subplot(3,1,m)
    for l = 1:5
        k = rowg(l);    % k = l + 5*(m-1);
        plot(S(k).syntp(3:end,1),S(k).syntp(3:end, S(k).syntp(1,:) == tnr),'DisplayName',S(k).iso);
        if l == 1
            legend('-DynamicLegend','NumColumns',5,'Location','Best');
            hold all;
        else
            hold all;
        end
    end
    hline = refline(0,0); hline.Color = 'k';
    set(get(get(hline,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    ylabel('%')
    xlim([730516 737456])
    datetick('x','YY','keeplimits')
    % datetick('x','YY','keepticks')
end
save_figure('Temp','temp_tp10yrEM',1)


figure
% g = [16 17 18 19 20; 21 22 23 24 25];
g = [17 18 19 23 25; 16 24 20 21 22];
for m = 1:2
    rowg = g(m,:);
    subplot(2,1,m)
    for l = 1:5
        k = rowg(l);    % k = l + 5*(m-1);
        plot(S(k).syntp(3:end,1),S(k).syntp(3:end, S(k).syntp(1,:) == tnr),'DisplayName',S(k).iso);
        if l == 1
            legend('-DynamicLegend','NumColumns',5,'Location','Best');
            hold all;
        else
            hold all;
        end
    end
    hline = refline(0,0); hline.Color = 'k';
    set(get(get(hline,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    ylabel('%')
    xlim([730516 737456])
    datetick('x','YY','keeplimits')
end
save_figure('Temp','temp_tp10yrAE',1)

%% Term Structure of Term Premia

ncntrs  = length(S);
tnrs     = [1 5 10];
figure
counter = 1;
for k = 5:7%1:ncntrs
    subplot(3,1,counter)
    fltrTNR = ismember(S(k).syntp(1,:),tnrs);
    TPseries = S(k).syntp(3:end,fltrTNR);
    plot(S(k).syntp(3:end,1),TPseries)
    title([S(k).cty '  Term Structure of Term Premia']),
    legend([num2str(tnrs(1)) ' YR'],[num2str(tnrs(2)) ' YR'],[num2str(tnrs(3)) ' YR'])
    datetick('x','YY:QQ'), ylabel('%')
    hline = refline(0,0); hline.Color = 'k';
    set(get(get(hline,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    ylim([-inf inf])
    counter = counter + 1;
end
save_figure('Temp','temp_ts_tp',1)


%% Plot Survey TP

figure
% g = [1 2 3 5 7; 8 9 11 13 15; 4 6 10 12 14];
g = [2 3 5 8 9; 1 7 11 13 15; 4 6 10 12 14];
for m = 1:3
    rowg = g(m,:);
    subplot(3,1,m)
    for l = 1:5
        k = rowg(l);
        if ~isempty(S(k).svysyntp)
            plot(S(k).svysyntp(:,1),S(k).svysyntp(:,2),'DisplayName',S(k).iso);
            if l == 1
                legend('-DynamicLegend','NumColumns',5,'Location','Best');
                hold all;
            else
                hold all;
            end
        end
    end
    hline = refline(0,0); hline.Color = 'k';
    set(get(get(hline,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    ylabel('%')
    xlim([730516 737456])
    datetick('x','YY','keeplimits')
end
save_figure('Temp','temp_tp10yrSvy',1)


%% Percent of variation in synthetic yields explained by first 3 PCs

YCtype = 'LC';
if strcmp(YCtype,'LC'); prefix = 'nom'; else; prefix = 'syn'; end
ncntrs  = length(S);
fnames  = fieldnames(S);
idxB    = contains(fnames,[prefix 'blncd']);            % Identify the field containing the data
fnameb  = fnames{idxB};
for k = 1:ncntrs
    yields = S(k).(fnameb)(2:end,2:end);
    [~,~,~,~,explained] = pca(yields);
    S(k).([prefix 'PCb']) = sum(explained(1:3));        % Percent explained by first 3 PCs using balanced panel
end

%% ATSM Fit: RMSE

YCtype = 'LCSYNT';
if strcmp(YCtype,'LC'); prefix = 'nom'; else; prefix = 'syn'; end
ncntrs  = length(S);
fnames  = fieldnames(S);
idxB    = contains(fnames,[prefix 'blncd']);            % Identify the field containing the data
idxQ    = contains(fnames,[prefix 'yldsQ']);            % Identify the field containing the data
fnameb  = fnames{idxB};
fnameq  = fnames{idxQ};
for k = 1:ncntrs
    yields  = S(k).(fnameb)(2:end,2:end)*100;
    yieldsQ = S(k).(fnameq)(2:end,2:end)*100;
    RMSE = sqrt(mean(mean((yields - yieldsQ).^2)));
    S(k).([prefix 'RMSEb']) = RMSE;
end


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


%% Common Factor Affecting TPs

datesTP   = S(10).syndata(2:end,1);
TPdataset = nan(length(datesTP),26);
TPdataset(:,1) = datesTP;
commonPC = nan(2,2);
ncntrs  = length(S);
tnr = 10;
for k = 1:ncntrs
    datesCTY = S(k).syntp(3:end,1);
    TPdata   = S(k).syntp(3:end, S(k).syntp(1,:) == tnr);
    fltrDTS  = ismembertol(datesTP,datesCTY,4,'DataScale',1);
    TPdataset(fltrDTS,k+1) = TPdata;
end

[~,~,~,~,explainedEM] = pca(TPdataset(84:end,2:16),'algorithm','als');
[~,~,~,~,explainedAE] = pca(TPdataset(84:end,17:end),'algorithm','als');
commonPC(1,:) = [sum(explainedEM(1:3)) sum(explainedAE(1:3))];

 [~,~,~,~,explainedEM] = pca(TPdataset(66:end,[3 5 6 7 8 11 15 16]),'algorithm','als');
[~,~,~,~,explainedAE] = pca(TPdataset(66:end,17:end),'algorithm','als');
 commonPC(2,:) = [sum(explainedEM(1:3)) sum(explainedAE(1:3))];

 clear input
labelcty    = {'EM','AE'};
labelcty{1} = [' ' labelcty{1}];                % Otherwise, Latex gives an error
input.tableRowLabels = labelcty;
input.tableColLabels = {'Dec-2006','Jun-2005'};
input.dataFormat = {'%.2f'};
input.fontSize = 'tiny';
filename   = fullfile('..','..','Docs','Tables','temp_tp_common');
input.data = commonPC';     % Note the transpose
input.tableCaption = 'Total Variation Explained by First 3 PCs (\%): 10-Year Term Premium.';
input.tableLabel = 'temp_tp_common';
input.texName = filename;
latexTable(input);


%% Read LCCS

ncntrs  = length(S);
tnr = 10;
for k = 1:ncntrs
    datesCTY = S(k).cipdev(2:end,1);
    LCCSdata = S(k).cipdev(2:end, S(k).cipdev(1,:) == tnr);
    fltrDTS  = ismembertol(datesTP,datesCTY,4,'DataScale',1);
    TPdataset(fltrDTS,26+k) = LCCSdata;
    TPdataset(TPdataset(:,26+k) == 0,26+k) = NaN;
end


%% Read EPU Indexes

% run read_epu_idx.m
for m = 1:5
    fltrDTS1  = ismembertol(epuidx(m).info(:,1),datesTP,4,'DataScale',1);
    epu_in_range = epuidx(m).info(fltrDTS1,:);
    fltrDTS2  = ismembertol(datesTP,epu_in_range(:,1),4,'DataScale',1);
    TPdataset(fltrDTS2,51+m) = epu_in_range(:,2);
    TPdataset(TPdataset(:,51+m) == 0,51+m) = NaN; % Substitute to avoid altering correl.
end

%% Read US TP

date1  = TPdataset(1,1);
date2  = TPdataset(end,1);
yr_str = '10';

KW = getFredData(['THREEFYTP' yr_str],datestr(date1,29),datestr(date2,29)); % 29: date format ID
KWtp = KW.Data;
[row,~] = find(isnan(KWtp));
KWtp(row,:)=[];                                         % Remove NaNs before doing end-of-month
KWtp = end_of_month(KWtp);
KWtp = dataset_in_range(KWtp,date1,date2);
TPdataset(:,57) = KWtp(:,2);


%% Append TPdataset to data_macro

hdr1_tp = construct_hdr(curncs,'TP','N/A','Term Premium from Synthetic Yields','N/A','Monthly');
hdr2_cipdev = construct_hdr(curncs,'CIPDEV','N/A','Deviations from CIP','N/A','Monthly');
hdr3_epu = construct_hdr({'BRL';'COP';'MXN';'KRW';'RUB'},'EPU','N/A','EPU Index','N/A','Monthly');
hdr4_ustp = construct_hdr('USD','TPUS','N/A','KW US Term Premium','N/A','Monthly');
hdr5_all = [hdr1_tp; hdr2_cipdev; hdr3_epu;hdr4_ustp];

% Merge
fltrMAC = ismembertol(data_macro(:,1),datesTP,4,'DataScale',1);
data_macro = [data_macro(fltrMAC,:) TPdataset(:,2:end)];
hdr_macro = [hdr_macro;hdr5_all];

%% Correlation of TP with US TP, EPU and LCCS

ncntrs  = length(S);
corrTPwIdxs = nan(ncntrs,3);
corrOGwIdxs = nan(ncntrs,2);

for k = 1:ncntrs
    corrTPwIdxs(k,1) = corr(TPdataset(:,1+k),TPdataset(:,57),'Rows','complete');
    mdlTPog      = fitlm(TPdataset(:,57),TPdataset(:,1+k));
    tp_og = mdlTPog.Residuals.Raw;
    
    corrTPwIdxs(k,2) = corr(TPdataset(:,1+k),TPdataset(:,26+k),'Rows','complete');
    corrOGwIdxs(k,1) = corr(tp_og,TPdataset(:,26+k),'Rows','complete');
    
    if     k == 1
        corrTPwIdxs(k,3) = corr(TPdataset(:,1+k),TPdataset(:,52),'Rows','complete');
        corrOGwIdxs(k,2) = corr(tp_og,TPdataset(:,52),'Rows','complete');
    elseif k == 2
        corrTPwIdxs(k,3) = corr(TPdataset(:,1+k),TPdataset(:,53),'Rows','complete');
        corrOGwIdxs(k,2) = corr(tp_og,TPdataset(:,53),'Rows','complete');
    elseif k == 6
        corrTPwIdxs(k,3) = corr(TPdataset(:,1+k),TPdataset(:,55),'Rows','complete');
        corrOGwIdxs(k,2) = corr(tp_og,TPdataset(:,55),'Rows','complete');
    elseif k == 7
        corrTPwIdxs(k,3) = corr(TPdataset(:,1+k),TPdataset(:,54),'Rows','complete');
        corrOGwIdxs(k,2) = corr(tp_og,TPdataset(:,54),'Rows','complete');
    elseif k == 12
        corrTPwIdxs(k,3) = corr(TPdataset(:,1+k),TPdataset(:,56),'Rows','complete');
        corrOGwIdxs(k,2) = corr(tp_og,TPdataset(:,56),'Rows','complete');
    end
end

AvgCorrOGwIdxs = [mean(corrOGwIdxs(1:15,1)); mean(corrOGwIdxs([16:19 23:25],1)); mean(corrOGwIdxs(20:22,1))];

AvgCorrTPwIdxs = [mean(corrTPwIdxs(1:15,:)); mean(corrTPwIdxs([16:19 23:25],:)); mean(corrTPwIdxs(20:22,:))];
AvgCorrTPwIdxs(:,3) = AvgCorrOGwIdxs;
clear input
labelcty    = {'EM','A-SOE','G-3'};
labelcty{1} = [' ' labelcty{1}];                % Otherwise, Latex gives an error
input.tableRowLabels = labelcty;
input.tableColLabels = {'TP-USTP','TP-CIP Dev','$\perp$TP-CIP Dev'};
input.dataFormat = {'%.2f'};
input.fontSize = 'tiny';
filename   = fullfile('..','..','Docs','Tables','temp_tp_corr10yr');
input.data = AvgCorrTPwIdxs;
input.tableCaption = 'Correlations of 10-Year Term Premia: U.S TP and LCCS.';
input.tableLabel = 'temp_tp_corr10yr';
input.texName = filename;
latexTable(input);

AvgCorrTPwEPU(1,:) = corrTPwIdxs([1 2 6 7 12],3)';
AvgCorrTPwEPU(2,:) = corrOGwIdxs([1 2 6 7 12],2)';
clear input
labelcty    = {'TP-EPU','$\perp$TP-EPU'};
labelcty{1} = [' ' labelcty{1}];                % Otherwise, Latex gives an error
input.tableRowLabels = labelcty;
input.tableColLabels = {'BRL','COP','KRW','MXN','RUB'};
input.dataFormat = {'%.2f'};
input.fontSize = 'tiny';
filename   = fullfile('..','..','Docs','Tables','temp_tp_corr10yr_epu');
input.data = AvgCorrTPwEPU;
input.tableCaption = 'Correlations of 10-Year Term Premia: EPU Index.';
input.tableLabel = 'temp_tp_corr10yr_epu';
input.texName = filename;
latexTable(input);

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

