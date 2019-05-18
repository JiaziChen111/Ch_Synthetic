%% Analysis of Term Premia: EM vs AE, Nominal vs Synthetic
% This code calls functions to compare the estimated term premia between
% advanced and emerging countries as well as between nominal and synthetic 
% yield curves.
% 
% m-files called: daily2monthly.m, tp_estimation.m, estimate_TR.m
%
% Pavel Sol�s (pavel.solis@gmail.com), May 2019
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
rowStrt = 2;

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
[corrExp,corrTP] = compare_atsm_surveys(S,currEM,0);



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

%% Compare IP vs GDP data per country

for k = 1:15
    figure
    plot(S(k).ip(:,1),S(k).ip(:,2))
    if size(S(k).gdp,2) > 1
        hold on
        plot(S(k).gdp(:,1),S(k).gdp(:,2))
    end
    title(S(k).iso)
    legend('IP','GDP')
    datetick('x','YYQQ')
end

%% 





%% Sources
% 
% Hold on a legend in a plot
% https://www.mathworks.com/matlabcentral/answers/9434-how-can-i-hold-the-previous-legend-on-a-plot
