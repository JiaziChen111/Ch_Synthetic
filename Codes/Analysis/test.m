%% Compare pricing factors vs principal components
k0 = 7;
[~,z1] = pca(S(k0).ds_blncd(2:end,2:end));
z1 = [S(k0).ds_blncd(2:end,1) z1(:,1:3)];
subplot(3,1,1)
plot(S(k0).d_xs(2:end,1),S(k0).d_xs(2:end,2),z1(:,1),z1(:,2)) % PC1
subplot(3,1,2)
plot(S(k0).d_xs(2:end,1),S(k0).d_xs(2:end,3),z1(:,1),z1(:,3)) % PC2
subplot(3,1,3)
plot(S(k0).d_xs(2:end,1),S(k0).d_xs(2:end,4),z1(:,1),z1(:,4)) % PC3

%% Compare common factors in AE and EM
TT_gbl = read_global_idxs();

TTaux = cntrstimetable(S,currAE,'dn_blncd');    % 10Y
[~,PCae] = pca(TTaux{:,:},'NumComponents',1);
PCae = [datenum(TTaux.Time) PCae];

TTaux = cntrstimetable(S,currEM,'dn_blncd');    % 10Y
[~,PCem] = pca(TTaux{:,:},'NumComponents',1);
PCem = [datenum(TTaux.Time) PCem];

yyaxis left
plot(PCae(:,1),PCae(:,2),PCem(:,1),PCem(:,2))
yyaxis right
plot(datenum(TT_gbl.Time(TT_gbl.Time > datetime('1-Jan-2000'))),...
    TT_gbl.globalip(TT_gbl.Time > datetime('1-Jan-2000')))
datetick('x','yy')

%%
fldname = {'dn_blncd','d_yP','d_tp','dc_blncd','mn_blncd','bsl_yP','bsl_tp','mc_blncd'};
k1 = 1;
TT3m = cntrstimetable(S,currEM,fldname{k1},0.25);
TT6m = cntrstimetable(S,currEM,fldname{k1},0.5);
TT12m = cntrstimetable(S,currEM,fldname{k1},1);
TT24m = cntrstimetable(S,currEM,fldname{k1},2);
TT60m = cntrstimetable(S,currEM,fldname{k1},5);
TT120m = cntrstimetable(S,currEM,fldname{k1},10);

TTaux = synchronize(TT3m,TT6m,'intersection');
TTaux = synchronize(TTaux,TT12m,'intersection');
TTaux = synchronize(TTaux,TT24m,'intersection');
TTaux = synchronize(TTaux,TT60m,'intersection');
TTaux = synchronize(TTaux,TT120m,'intersection');
TTaux2 = rmmissing(TTaux);


%%
aedata = cell2table(fitrprtmy);


clear input
input.tableRowLabels = aedata{2:31,1}';
input.dataFormat = {'%.2f'};
input.fontSize = 'tiny';

input.tableColLabels = aedata{1,[2 3 4 5 8 10]};
filename   = fullfile('..','..','Docs','Tables','modelfit');
input.data = aedata(1:31,[2 3 4 5 8 10]);
input.tableCaption = 'Model Fit';
input.tableLabel = 'modelfit';
input.texName = filename;
latexTable(input);

%%
figdir  = 'Estimation'; formats = {'eps'}; figsave = true;
vars  = {'yQ','yP','tp'};
names = {'Fitted Yields','Expected Short Rate','Term Premium'};
for k0 = 1:length(vars)
    fldname = {['bsl_' vars{k0}],['bsl_' vars{k0} '_se']};
    figure
    for k1 = 1:nEMs
        subplot(3,5,k1)
        var   = S(k1).(fldname{1})(2:end,S(k1).(fldname{1})(1,:) == 10)*100;
        varse = S(k1).(fldname{2})(2:end,S(k1).(fldname{2})(1,:) == 10)*100;
        plot(S(k1).(fldname{1})(2:end,1),var,'-'); hold on
        plot(S(k1).(fldname{2})(2:end,1),var - 2*varse,'--','Color', [0.6 0.6 0.6])
        plot(S(k1).(fldname{2})(2:end,1),var + 2*varse,'--','Color', [0.6 0.6 0.6]); hold off
        title(S(k1).cty)
        datetick('x','yy'); yline(0);
        L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
    end
    lbl = {names{k0},'Confidence Bands'};
    lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
    set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
    figname = [fldname{1} '_CI']; save_figure(figdir,figname,formats,figsave)
end