function [lm_ols,lm_fe,lm_re,tbl] = rp_panel_reg(paneltp,tnrs)
% This function runs panel regressions of term premia with different
% specifications (per maturity).
% Calls to m-files: none
%
%     INPUTS
% paneltp - table with the data
% tnrs    - cell with tenors of term premia
% 
%     OUPUT
% lm_* - structures with results of models (rows: tenor, cols: model version)
% tbl  - cell array with output tables, 3D: tenors
% 
% Pavel Solís (pavel.solis@gmail.com), October 2018
%
%% Pre-process data
% Convert DATE and ID to categorical variables
paneltp.DATE = categorical(paneltp.DATE);
paneltp.CODE = categorical(paneltp.CODE);

% Transform variables
paneltp = [paneltp varfun(@log,paneltp(:,{'VIX'}))];
tps     = strcat('TP',tnrs);
tpus    = strcat('USTP',tnrs);
lm_ols  = struct('mdl1',{});
lm_fe   = struct('mdl1',{},'mdl2',{},'mdl3',{},'mdl4',{},'mdl5',{},...
                 'mdl6',{},'mdl7',{},'mdl8',{},'mdl9',{});
lm_re   = struct('mdl1',{});

%% Regressions
for l = 1:numel(tnrs)
    depvar = tps{l};
    USTP   = tpus{l};
    
    % Pooled OLS regressions
    lm_ols(l).mdl1 = fitlm(paneltp,...
    [depvar ' ~ 1 + log_VIX + FFR + SPX + CCY + STX + INF + UNE + IP']);
%     figure % To see whether within group observations are correlated with each other
%     boxplot(lm_ols(l).mdl1.Residuals.Raw,paneltp.CODE)
%     title(['Dep Var: ' depvar ' - Pooled OLS'])
%     ylabel('OLS Residuals')
    
    % Country fixed-effects models
    lm_fe(l).mdl1  = fitlm(paneltp,...
    [depvar ' ~ 1 + log_VIX + FFR + SPX + CCY + STX + INF + UNE + IP + CODE']);

    lm_fe(l).mdl2  = fitlm(paneltp,...
    [depvar ' ~ 1 + log_VIX + FFR + RSP + RFX + RSX + INF + UNE + IP + CODE']);

    lm_fe(l).mdl3  = fitlm(paneltp,...
    [depvar ' ~ 1 + log_VIX + FFR + SPX + OIL + CCY + STX + INF + UNE + IP + CODE']);
    % [depvar ' ~ 1 + log_VIX + FFR + SPX + ROI + RFX + RSX + INF + UNE + IP + CODE']);

    lm_fe(l).mdl4  = fitlm(paneltp,...
    [depvar ' ~ 1 + log_VIX + FFR + ' USTP ' + CCY + STX + INF + UNE + IP + CODE']);
    % [depvar ' ~ 1 + log_VIX + FFR + ' USTP ' + SPX + RFX + RSX + INF + UNE + IP + CODE']);

    lm_fe(l).mdl5  = fitlm(paneltp,...
    [depvar ' ~ 1 + log_VIX + FFR + SPX + OIL + CODE']);

    lm_fe(l).mdl6  = fitlm(paneltp,...
    [depvar ' ~ 1 + log_VIX + FFR + ' USTP ' + SPX + OIL + CODE']);

    lm_fe(l).mdl7  = fitlm(paneltp,...
    [depvar ' ~ 1 + CCY + STX + INF + UNE + IP + CODE']);

    lm_fe(l).mdl8  = fitlm(paneltp,...
    [depvar ' ~ 1 + RFX + RSX + INF + UNE + IP + CODE']);

    lm_fe(l).mdl9  = fitlm(paneltp,...
    [depvar ' ~ 1 + INF + UNE + IP + CODE']);

    % Country random-effects models
    lm_re(l).mdl1 = fitlme(paneltp,...
    [depvar ' ~ 1 + log_VIX + FFR + SPX + CCY + STX + INF + UNE + IP + (1 | CODE)'],'FitMethod','REML');
end

%% Output table
fields    = fieldnames(lm_fe);
fields    = fields([5 6 7 2 3 4]);              % Models and order to report them
tnrs2rprt = [5 10];
aux1 = {'Country FE','Yes'};
aux2 = {'Observations';'Countries';'R-squared'};

% Constructs column with names sorted as desired
tblnms = [];
for l  = tnrs2rprt
    for m = 1:numel(fields)
        nms = lm_fe(l).(fields{m}).PredictorNames;
        nms = nms(~strcmp(nms(:),'CODE'));      % Regressors excluding dummies
        tblnms = [tblnms; nms];
    end
end
tblnms  = unique(tblnms);
ordrvar = [14 2 13 12 9 7 3 11 4 1 5 10 8 6];   % Adjust if want different order, or # of vars change
tblnms  = tblnms(ordrvar);
spcs    = cell(size(tblnms));
spcs(:) = {' '};
nmsaux  = [tblnms'; spcs'];
tblnms  = nmsaux(:);

% Extract the information from the regressions and paste it in a printable table
nrgrss  = size(tblnms,1);
nrows   = nrgrss + numel(aux1) - 1 + numel(aux2);
tbl     = {};
for k = 1:numel(tnrs2rprt)
    l = tnrs2rprt(k);
    tblaux  = cell(nrows,numel(fields));
    for m = 1:numel(fields)
        names = lm_fe(l).(fields{m}).PredictorNames;
        names = names(~strcmp(names(:),'CODE')); % Regressors excluding dummies
        [~,idx] = ismember(tblnms,names);        % idx to reorder names, but note dim(idx) = dim(tblnms)
        names   = names(idx(idx ~= 0));          % Vars in names will have same order as vars in tblnms
        coeftbl = lm_fe(l).(fields{m}).Coefficients;
        beta = cellstr(num2str(coeftbl(names,1).Variables,'%.3f'));
        stdb = cellstr(strcat('(',num2str(coeftbl(names,2).Variables,'%.2f'),')'));
        pval = coeftbl(names,4).Variables;
        fltr1str = pval >= 0.05 & pval < 0.1;
        fltr2str = pval >= 0.01 & pval < 0.05;
        fltr3str = pval < 0.01;
        beta(fltr1str) = strcat(beta(fltr1str),'*');
        beta(fltr2str) = strcat(beta(fltr2str),'**');
        beta(fltr3str) = strcat(beta(fltr3str),'***');
        mtrx  = [beta'; stdb'];
        nobs  = cellstr(num2str(lm_fe(l).(fields{m}).NumObservations));
        nctrs = cellstr(num2str(lm_fe(l).(fields{m}).NumEstimatedCoefficients - numel(names)));
        r2    = cellstr(num2str(round(lm_fe(l).(fields{m}).Rsquared.Adjusted,3)));
        
        % Where to paste coefficients in tblaux
        idxLOC = [find(ismember(tblnms,names))'; find(ismember(tblnms,names))'+1]; % With extra row
        
        spcs    = cell(size(names));
        spcs(:) = {' '};
        nmsaux  = [names'; spcs'];
        tblbtm  = [aux1; aux2 [nobs; nctrs; r2]];
        tblreg  = [nmsaux(:) mtrx(:)];          % Order names, betas and stds vertically
        tblaux(idxLOC(:),2*m-1:2*m) = tblreg;   % Col indexes move in steps of two
        tblaux(end-size(tblbtm,1)+1:end,2*m-1:2*m) = tblbtm;
    end
%     tblnms(strcmp(tblnms,'log_VIX')) = {'log(VIX)'};
    tblaux(1:nrgrss,1) = tblnms;                % Substitute first column
    tblaux(:,3:2:end)  = [];                    % Delete extra cols (were useful for verification)
    tblaux(sum(cellfun(@isempty,tblaux),2) == size(tblaux,2)-1,:) = []; % Delete blank spaces
    tbl(:,:,k) = tblaux;
end
tbl(1,1,:) = {'log(VIX)'};                      % Otherwise Latex sends an error
tbl([9,10,17:26],:,:) = [];                     % Non-significant controls (local financial variables)

% Save tables in latex format
for k = 1:numel(tnrs2rprt)
    filename = fullfile('..','..','Docs','Tables',['rp_pnlreg_' num2str(tnrs2rprt(k)) 'yr_v0.tex']);
    matrix2latex(tbl(:,[1:4 6:7],k),filename,'alignment','c','size','tiny');
    % matrix2latex(tbl(:,:,k),filename,'alignment','c','size','tiny'); % when not excluding mdl(2)
end

%% Sources

% Panel data models in Matlab
% https://www.mathworks.com/matlabcentral/fileexchange/...
% 46515-multilevel-mixed-effects-modeling-using-matlab

% Access data in table
% https://www.mathworks.com/help/matlab/matlab_prog/access-data-in-a-table.html

% Iterating through field names in structure
% https://stackoverflow.com/questions/2803962/iterating-through-struct-fieldnames-in-matlab

% Sorting a cell array in terms of another
% https://www.mathworks.com/matlabcentral/answers/...
% 1820-sorting-a-cell-array-of-string-based-on-the-order-of-another

% Indexing by jumping in steps
% https://www.mathworks.com/matlabcentral/answers/...
% 167100-taking-every-nth-element-from-each-column-in-a-matrix

% To report decimals in table as strings
% https://www.mathworks.com/matlabcentral/answers/...
% 304764-how-to-pad-zeros-in-the-front-of-the-number-using-num2str