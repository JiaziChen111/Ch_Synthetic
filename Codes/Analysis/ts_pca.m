function [pcexplnd,pc1yc,pc1res,r2TPyP] = ts_pca(S,currEM,uskwyp,uskwtp)
% TS_PCA Report results from principal component analysis on yields,
% components, residuals after regressing components on US yield components;
% R2 of those regressions are also reported

% m-files called: syncdatasets
% Pavel Solís (pavel.solis@gmail.com), June 2020
%%
ncntrs = length(S);
nEMs   = length(currEM);

%% Percent of variation in yields explained by first 3 PCs

pcexplnd = cell(ncntrs+1,5);
pcexplnd(1,:) = {'' 'PC1' 'PC2' 'PC3' 'PC1-PC3'};
for k0 = 1:ncntrs
    pcexplnd{k0+1,1} = S(k0).iso;
    if ismember(S(k0).iso,currEM)
        fnameb = 's_blncd';
    else
        fnameb = 'n_blncd';
    end
    yields = S(k0).(fnameb)(2:end,2:end);
    [~,~,~,~,explained] = pca(yields);
    pcexplnd{k0+1,2} = sum(explained(1));
    pcexplnd{k0+1,3} = sum(explained(2));
    pcexplnd{k0+1,4} = sum(explained(3));
    pcexplnd{k0+1,5} = sum(explained(1:3));         % percent explained by first 3 PCs using balanced panel
end

[mean(cell2mat(pcexplnd(2:16,2))),   mean(cell2mat(pcexplnd(2:16,3))),...
 mean(cell2mat(pcexplnd(2:16,4))),   mean(cell2mat(pcexplnd(2:16,5)));...
 mean(cell2mat(pcexplnd(17:end,2))), mean(cell2mat(pcexplnd(17:end,3))),...
 mean(cell2mat(pcexplnd(17:end,4))), mean(cell2mat(pcexplnd(17:end,5)))]

%% Common factors affecting YC components
% TPs, real rates, yP, LCCS, BRP for all, ST vs LT
k2 = 0;
pc1yc = cell(5,2);
pc1yc(2:end,1) = {'Nominal' 'Expected' 'TP' 'LCCS'};
grp = 'EM';                                         % 'EM' or 'AE'
if strcmp(grp,'EM'); n1 = 1; nN = nEMs; else; n1 = nEMs+1; nN = ncntrs; end
tnrspc = 10;                                        % All: 0.25:0.25:10, ST: 1, LT: 10
dateskey = {'1-Jan-2008','1-Jan-2000'};             % {'1-Jan-2008','1-Sep-2008'} all countries after GFC
datestrt = datenum(dateskey{1});                    % select countries based on date of first observation
datecmmn = datenum(dateskey{2});                    % select sample period for selected countries
for k0 = n1:nN
    if strcmp(grp,'EM')                             % for EMs synthetic, distinguish those w/ surveys
        if ~isempty(S(k0).ssb_tp)
            fldname = {'n_blncd','ssb_yP','ssb_tp','c_blncd'};
        else
            fldname = {'n_blncd','sy_yP','sy_tp','c_blncd'};
        end
    else                                            % for AEs nominal
        fldname = {'n_blncd','ny_yP','ny_tp','c_blncd'};
    end
    if datenum(S(k0).s_dateb,'mmm-yyyy') <= datestrt
%     if ismember(S(k0).iso,{'BRL','HUF','KRW','MXN','MYR','PHP','PLN','THB'})    % EM TP < 0
%     if ismember(S(k0).iso,currEM(~contains(currEM,{'ILS','ZAR'})))              % EM w/ surveys
        k2 = k2 + 1;
        fltrtnr1 = [true ismember(S(k0).(fldname{1})(1,2:end),tnrspc)];  % include dates
        fltrtnr2 = [true ismember(S(k0).(fldname{2})(1,2:end),tnrspc)];
        fltrtnr3 = [true ismember(S(k0).(fldname{3})(1,2:end),tnrspc)];
        fltrtnr4 = [true ismember(S(k0).(fldname{4})(1,2:end),tnrspc)];
        if k2 == 1
            ttyld = S(k0).(fldname{1})(:,fltrtnr1);
            ttyP  = S(k0).(fldname{2})(:,fltrtnr2);
            tttp  = S(k0).(fldname{3})(:,fltrtnr3);
            ttcip = S(k0).(fldname{4})(:,fltrtnr4);
        else
            ttyld = syncdatasets(ttyld,S(k0).(fldname{1})(:,fltrtnr1),'union');
            ttyP  = syncdatasets(ttyP, S(k0).(fldname{2})(:,fltrtnr2),'union');
            tttp  = syncdatasets(tttp, S(k0).(fldname{3})(:,fltrtnr3),'union');
            ttcip = syncdatasets(ttcip,S(k0).(fldname{4})(:,fltrtnr4),'union');
        end
    end
end
fltrbln = find(any(isnan(ttyld),2),1,'last') + 1;                   % first date w/ balanced panel
ttyld   = ttyld(fltrbln:end,:);                                     % no headers, sample w/ no NaNs
[~,~,~,~,explndemyld] = pca(ttyld(ttyld(:,1) >= datecmmn,2:end));   % factors after common date

fltrbln = find(any(isnan(ttyP),2),1,'last') + 1;
ttyP    = ttyP(fltrbln:end,:);
[~,~,~,~,explndemyP] = pca(ttyP(ttyP(:,1) >= datecmmn,2:end));

fltrbln = find(any(isnan(tttp),2),1,'last') + 1;
tttp    = tttp(fltrbln:end,:);
[~,~,~,~,explndemtp] = pca(tttp(tttp(:,1) >= datecmmn,2:end));

fltrbln = find(any(isnan(ttcip),2),1,'last') + 1;
ttcip   = ttcip(fltrbln:end,:);
[~,~,~,~,explndemlccs] = pca(ttcip(ttcip(:,1) >= datecmmn,2:end));  %ttcip(fltrbln:end,2:end)

pc1yc(1,:)     = {'' [num2str(k2) '-' datestr(datecmmn,'mm/yy')]};
pc1yc(2:end,2) = {explndemyld(1); explndemyP(1); explndemtp(1); explndemlccs(1)};

%% US and non-US common factors
k2 = 0;
r2TPyP = cell(ncntrs+1,6);
r2TPyP(1,:) = {'' 'yP1' 'yP10' 'TP1' 'TP10' 'yP10-USTP10'};
pc1res = cell(6,2);
pc1res(2:end,1) = {'yP1' 'yP10' 'TP1' 'TP10' 'yP10-USTP10'};
grp = 'AE';                                         % 'EM' or 'AE'
if strcmp(grp,'EM'); n1 = 1; nN = nEMs; else; n1 = nEMs+1; nN = ncntrs; end
dateskey = {'1-Jan-2008','1-Sep-2008'};                 % {'1-Jan-2008','1-Sep-2008'} all countries after GFC
datestrt = datenum(dateskey{1});                        % select countries based on date of first observation
datecmmn = datenum(dateskey{2});                        % select sample period for selected countries
for k0 = n1:nN
    k2 = k2 + 1;
    r2TPyP{k2+1,1} = S(k0).iso;
    if strcmp(grp,'EM')                                	% for EMs synthetic, distinguish those w/ surveys
        if ~isempty(S(k0).ssb_tp)
            fldname = {'ssb_yP','ssb_tp'};
        else
            fldname = {'sy_yP','sy_tp'};
        end
    else                                            	% for AEs nominal
        fldname = {'ny_yP','ny_tp'};
    end
    
    if datenum(S(k0).s_dateb,'mmm-yyyy') <= datestrt
%     if ismember(S(k0).iso,{'BRL','HUF','KRW','MXN','MYR','PHP','PLN','THB'}) % EM TP < 0
%     if ismember(S(k0).iso,currEM(~contains(currEM,{'ILS','ZAR'})))           % EM w/ surveys
    
        [~,datayp,uskwypk0] = syncdatasets(S(k0).(fldname{1}),uskwyp);
        [~,datatp,uskwtpk0] = syncdatasets(S(k0).(fldname{2}),uskwtp);
       
        datayp10 = datayp(datayp(:,1) >= datecmmn,datayp(1,:) == 10);
        datayp01 = datayp(datayp(:,1) >= datecmmn,datayp(1,:) == 1);
        datatp10 = datatp(datatp(:,1) >= datecmmn,datatp(1,:) == 10);
        datatp01 = datatp(datatp(:,1) >= datecmmn,datatp(1,:) == 1);
        usyp10   = uskwypk0(uskwypk0(:,1) >= datecmmn,uskwypk0(1,:) == 10);
        usyp01   = uskwypk0(uskwypk0(:,1) >= datecmmn,uskwypk0(1,:) == 1);
        ustp10   = uskwtpk0(uskwtpk0(:,1) >= datecmmn,uskwtpk0(1,:) == 10);
        ustp01   = uskwtpk0(uskwtpk0(:,1) >= datecmmn,uskwtpk0(1,:) == 1);

        mdlRSyp01 = fitlm(usyp01,datayp01);
        resyp01   = mdlRSyp01.Residuals.Raw;
        r2TPyP{k2+1,2} = mdlRSyp01.Rsquared.Ordinary;

        mdlRSyp10 = fitlm(usyp10,datayp10);
        resyp10   = mdlRSyp10.Residuals.Raw;
        r2TPyP{k2+1,3} = mdlRSyp10.Rsquared.Ordinary;

        mdlRStp01 = fitlm(ustp01,datatp01);
        restp01   = mdlRStp01.Residuals.Raw;
        r2TPyP{k2+1,4} = mdlRStp01.Rsquared.Ordinary;

        mdlRStp10 = fitlm(ustp10,datatp10);
        restp10   = mdlRStp10.Residuals.Raw;
        r2TPyP{k2+1,5} = mdlRStp10.Rsquared.Ordinary;
        
        mdlRSyptp10 = fitlm(ustp10,datayp10);
        resyptp10   = mdlRSyptp10.Residuals.Raw;
        r2TPyP{k2+1,6} = mdlRSyptp10.Rsquared.Ordinary;
        
        if k2 == 1
            ttyp01   = [nan 1; datayp(datayp(:,1) >= datecmmn,1) resyp01];
            ttyp10   = [nan 10;datayp(datayp(:,1) >= datecmmn,1) resyp10];
            tttp01   = [nan 1; datatp(datatp(:,1) >= datecmmn,1) restp01];
            tttp10   = [nan 10;datatp(datatp(:,1) >= datecmmn,1) restp10];
            ttyptp10 = [nan 10;datayp(datayp(:,1) >= datecmmn,1) resyptp10];
        else
            ttyp01 = syncdatasets(ttyp01,...
                [nan 1; datayp(datayp(:,1) >= datecmmn,1) resyp01],'union');
            ttyp10 = syncdatasets(ttyp10,...
                [nan 10;datayp(datayp(:,1) >= datecmmn,1) resyp10],'union');
            tttp01 = syncdatasets(tttp01,...
                [nan 1; datatp(datatp(:,1) >= datecmmn,1) restp01],'union');
            tttp10 = syncdatasets(tttp10,...
                [nan 10;datatp(datatp(:,1) >= datecmmn,1) restp10],'union');
            ttyptp10 = syncdatasets(ttyptp10,...
                [nan 10;datayp(datayp(:,1) >= datecmmn,1) resyptp10],'union');
        end
    end
end

fltrbln = find(any(isnan(ttyp01),2),1,'last') + 1;                  % first date w/ balanced panel
ttyp01  = ttyp01(fltrbln:end,:);                                    % no headers, sample w/ no NaNs
[~,~,~,~,explndyp01] = pca(ttyp01(ttyp01(:,1) >= datecmmn,2:end));  % factors after common date

fltrbln = find(any(isnan(ttyp10),2),1,'last') + 1;
ttyp10  = ttyp10(fltrbln:end,:);
[~,~,~,~,explndyp10] = pca(ttyp10(ttyp10(:,1) >= datecmmn,2:end));

fltrbln = find(any(isnan(tttp01),2),1,'last') + 1;
tttp01  = tttp01(fltrbln:end,:);
[~,~,~,~,explndtp01] = pca(tttp01(tttp01(:,1) >= datecmmn,2:end));

fltrbln = find(any(isnan(tttp10),2),1,'last') + 1;
tttp10  = tttp10(fltrbln:end,:);
[~,~,~,~,explndtp10] = pca(tttp10(tttp10(:,1) >= datecmmn,2:end));


fltrbln   = find(any(isnan(ttyptp10),2),1,'last') + 1;
ttyptp10  = ttyptp10(fltrbln:end,:);
[~,~,~,~,explndyptp10] = pca(ttyptp10(ttyptp10(:,1) >= datecmmn,2:end));


pc1res(1,:)     = {'' [num2str(k2) '-' datestr(datecmmn,'mm/yy')]};
pc1res(2:end,2) = {explndyp01(1); explndyp10(1); explndtp01(1); explndtp10(1); explndyptp10(1)};
