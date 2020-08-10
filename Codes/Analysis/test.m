% add PCs
% add it in ts_pca
fldname = {'s_blncd','n_blncd'};
for k0 = 1:length(S)
    if ismember(S(k0).cty,currEM)
        dtst = S(k0).(fldname{1});
    else
        dtst = S(k0).(fldname{2});
    end
    ylds = dtst(2:end,2:end);
end
%% PCA variables include in ts_pca
TTinf = emtimetable(S,currEM,'inf');
TTsvy = emtimetable(S,currEM,'scpi',10);
[~,~,~,~,xplnINF] = pca(TTinf{:,:});                % PC1: 81%
z1 = rmmissing(TTvar(:,[4 5 6 8 13 15]));
z2 = rmmissing(TTvar(TTvar.Time <= datetime('31-Oct-2014') & TTvar.Time ~= datetime('30-Sep-2004'),[3 11]));
[~,~,~,~,xplnSCPI] = pca([z1{:,:} z2{:,:}]);        % PC1: 51%, PC2: 24%

%% Stock-Watson include in ts_pca
% TTinf    = emtimetable(S,currEM,'inf');
% TTqtr    = TTinf(ismember(month(TTinf.Time),[3 6 9 12]),:);
% datesqtr = datenum(TTqtr.Time);
% emsdprm  = datesqtr;
% emsdcyc  = datesqtr;
% emtrnd   = datesqtr;
% for k0  = 1:nEMs
%     [sdprm,sdcyc,trnd] = stockwatson(TTqtr{:,k0});
%     emsdprm = [emsdprm, sdprm];
%     emsdcyc = [emsdcyc, sdcyc];
%     emtrnd  = [emtrnd, trnd];
% end
[~,~,~,~,xplnSDPRM] = pca(emsdprm(:,2:end));        % PC1: 93%
[~,~,~,~,xplnSDCYC] = pca(emsdcyc(:,2:end));        % PC1: 62%, PC2: 24%
[~,~,~,~,xplnTRND] = pca(emtrnd(:,2:end));          % PC1: 81%

hptrend = hpfilter(TTqtr{:,:},1600);
[~,~,~,~,xplnHPTR] = pca(hptrend);                  % PC1: 93%

figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(dtsqtr,[TTqtr{:,k0},hptrend(:,k0)])
end
