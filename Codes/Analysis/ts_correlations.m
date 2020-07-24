function [corrTPem,corrTPae,corrBRP,corrTPyP] = ts_correlations(S,currEM,currAE,ustp10,vix)
% TS_CORRELATIONS Report correlations and p-values of estimated TP with other
% variables (LC credit spread, inflation, EPU index, US term premium, VIX),
% and correlations of yield curve components (yP, TP) with emprical measures

% m-files called: syncdatasets
% Pavel Solís (pavel.solis@gmail.com), June 2020
%%
ncntrs = length(S);
nEMs   = length(currEM);
nAEs   = length(currAE);

%% TP correlations: LCCS, INF, EPU, USTP, VIX
    % EMs
corrTPem = cell(nEMs+1,13); corrBRP = cell(nEMs+1,13);
corrTPem(1,:) = {'' 'LCCS' 'pval' 'INF' 'pval' 'EPU' 'pval','EPULCCS' 'pval' 'USTP' 'pval' 'VIX' 'pval'};
corrBRP(1,:)  = {'' 'LCCS' 'pval' 'INF' 'pval' 'EPU' 'pval','EPULCCS' 'pval' 'USTP' 'pval' 'VIX' 'pval'};
hdrfk = [nan 10];
for k0 = 1:nEMs
    corrTPem{k0+1,1} = S(k0).iso; corrBRP{k0+1,1} = S(k0).iso;
    if ~isempty(S(k0).ssb_tp)
        fldname = {'ssb_tp'};
    else
        fldname = {'sy_tp'};
    end
    fldname = [fldname 'c_blncd' 'inf' 'epu' 'brp'];
    fltr1   = find(S(k0).(fldname{1})(1,:) == 10);
    fltr2   = find(S(k0).(fldname{2})(1,:) == 10);
    fltr5   = find(S(k0).(fldname{5})(1,:) == 10);
    datatp  = S(k0).(fldname{1})(:,[1 fltr1]);
    databrp = S(k0).(fldname{5})(:,[1 fltr5]);
    % LCCS
    mrgd = syncdatasets(datatp,S(k0).(fldname{2})(:,[1 fltr2]));
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPem(k0+1,2:3) = {correl,round(pval,4)};
    
    mrgd = syncdatasets(databrp,S(k0).(fldname{2})(:,[1 fltr2]));
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrBRP(k0+1,2:3) = {correl,round(pval,4)};
    
    % INF
    datacr = [hdrfk; S(k0).(fldname{3})];
    mrgd   = syncdatasets(datatp,datacr);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPem(k0+1,4:5) = {correl,round(pval,4)};
    
    mrgd = syncdatasets(databrp,datacr);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3),'rows','complete');
    corrBRP(k0+1,4:5) = {correl,round(pval,4)};
    
    % EPU
    if ~isempty(S(k0).epu)
        datacr = [hdrfk; S(k0).(fldname{4})];
        mrgd   = syncdatasets(datatp,datacr);
        [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
        corrTPem(k0+1,6:7) = {correl,round(pval,4)};
        
        mrgd = syncdatasets(S(k0).(fldname{2})(:,[1 fltr2]),datacr);
        [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
        corrTPem(k0+1,8:9) = {correl,round(pval,4)};
        
        mrgd = syncdatasets(databrp,datacr);
        [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3),'rows','complete');
        corrBRP(k0+1,6:7) = {correl,round(pval,4)};
    end
    % USTP
    mrgd = syncdatasets(datatp,ustp10);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPem(k0+1,10:11) = {correl,round(pval,4)};
    
    mrgd = syncdatasets(databrp,ustp10);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3),'rows','complete');
    corrBRP(k0+1,10:11) = {correl,round(pval,4)};
    
    % VIX
    datacr = [hdrfk; vix];
    mrgd   = syncdatasets(datatp,datacr);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPem(k0+1,12:13) = {correl,round(pval,4)};
    
    mrgd = syncdatasets(databrp,datacr);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3),'rows','complete');
    corrBRP(k0+1,12:13) = {correl,round(pval,4)};
end

    % AEs
corrTPae = cell(nAEs+1,7);
corrTPae(1,:) = {'' 'CIPdev' 'pval' 'USTP' 'pval' 'VIX' 'pval'};
for k0 = nEMs+1:ncntrs
    corrTPae{k0-14,1} = S(k0).iso;
    fldname = {'ny_tp','c_blncd'};
    fltr1   = find(S(k0).(fldname{1})(1,:) == 10);
    fltr2   = find(S(k0).(fldname{2})(1,:) == 10);
    datatp  = S(k0).(fldname{1})(:,[1 fltr1]);
    % CIP deviations
    mrgd = syncdatasets(datatp,S(k0).(fldname{2})(:,[1 fltr2]));
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPae(k0-14,2:3) = {correl,round(pval,4)};
    
    % USTP
    mrgd = syncdatasets(datatp,ustp10);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPae(k0-14,4:5) = {correl,round(pval,4)};
    
    % VIX
    mrgd = syncdatasets(datatp,[nan 10; vix]);
    [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPae(k0-14,6:7) = {correl,round(pval,4)};
end

mean(cell2mat(corrTPem(2:end,10)))
[mean(cell2mat(corrTPae(2:end,4))), mean(cell2mat(corrTPae(2:end,6)))] % USTP

%% Correlations of YC components with alternative measures
corrTPyP = cell(nEMs+1,5);
corrTPyP(1,:) = {'' 'TP-Slope' 'Res-Slope' 'TP-Res' 'yP-2Y'};
for k0 = 1:nEMs
    corrTPyP{k0+1,1} = S(k0).iso;
    if ~isempty(S(k0).ssb_tp)
        fldname = {'ssb_tp','ssb_yP'};
    else
        fldname = {'sy_tp','sy_yP'};
    end
    fldname = [fldname 's_blncd'];
    [~,datatps,datayld] = syncdatasets(S(k0).(fldname{1}),S(k0).(fldname{3}));
    [~,datayp] = syncdatasets(S(k0).(fldname{2}),datatps);
    
    fltr11  = find(datatps(1,:) == 10);
    fltr21  = find(datayp(1,:) == 10);
    fltr31  = find(datayld(1,:) == 10);
    fltr32  = find(datayld(1,:) == 2);
    fltr33  = find(datayld(1,:) == 0.25);
    datatps = datatps(2:end,fltr11);
    datayp  = datayp(2:end,fltr21);
    datas10 = datayld(2:end,fltr31);
    datas02 = datayld(2:end,fltr32);
    datas3M = datayld(2:end,fltr33);
    slopes  = datas10 - datas3M;
    corrTPyP{k0+1,2} = corr(datatps,slopes);
    
    mdlRSs  = fitlm(datas3M,datas10);
    datarss = mdlRSs.Residuals.Raw;
    corrTPyP{k0+1,3} = corr(datarss,slopes);
    corrTPyP{k0+1,4} = corr(datarss,datatps);
    corrTPyP{k0+1,5} = corr(datayp,datas02);
end