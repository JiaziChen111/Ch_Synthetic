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
