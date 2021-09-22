function [paneltp,tnrs] = construct_panel(dataset_mth_rf,header_mth_rf,data_macro,hdr_macro,...
    data_usrp,hdr_usrp,ctrsNcods_rf)
% This function creates a panel of term premia and macro-financial variables.
% Inefficient way to construct the panel, but effective.
% Calls to m-files: none
%
%     INPUTS
% dataset_mth_* - matrix with monthly obs of N-S curves as rows, col1 has dates
% header_mth_*  - cell with names for the columns of data_monthly
% data_macro    - matrix with daily obs as rows (top-down is first-last obs), col1 has dates
% hdr_macro     - cell with names for the columns of data_macro
% data_usrp
% hdr_usrp
% ctrsNcods_*   - cell with countries (and their IMF codes) to plot
% 
%     OUPUT
% paneltp - table with the panel of data
% 
% Pavel Solís (pavel.solis@gmail.com), October 2018
%%
fltrSPX   = ismember(hdr_macro(:,2),'STX') & ismember(hdr_macro(:,1),'USD');
fltrVIX   = ismember(hdr_macro(:,2),'VIX');
fltrFFR   = ismember(hdr_macro(:,2),'FFR');
fltrOIL   = ismember(hdr_macro(:,2),'OIL');
fltrUS    = ismember(hdr_usrp(:,1),'USRP');
fltrRP    = ismember(header_mth_rf(:,1),'LCRFRP');
tnrs      = header_mth_rf(fltrRP,end);
names_dni = {'DATE';'CODE'};
names_tp  = strcat('TP',tnrs);
names_var = {'VIX';'FFR';'SPX';'OIL';'CCY';'STX';'INF';'UNE';'IP'};
names_rtn = {'RSP';'ROI';'RFX';'RSX';};
names_us  = strcat('USTP',tnrs);
names     = [names_dni;names_tp;names_var;names_rtn;names_us];
IDs       = cell2mat(ctrsNcods_rf(:,2));
ctrsLC    = ctrsNcods_rf(:,1);
dates_macro = data_macro(:,1);

% Add country information to the panel
data_panel = [];
for k = 1:numel(IDs)
    fltrCTY  = dataset_mth_rf(:,2) == IDs(k);
    datesNid = dataset_mth_rf(fltrCTY,1:2);
    data     = dataset_mth_rf(fltrCTY,fltrRP);
    
    fltrCTY = ismember(hdr_macro(:,1),ctrsLC{k});
    fltrDTS = ismember(dates_macro,datesNid(:,1));          % Extract only monthly dates
    vars    = data_macro(fltrDTS,:);
    vix = vars(:,fltrVIX); 
    ffr = vars(:,fltrFFR);
    spx = vars(:,fltrSPX);
    oil = vars(:,fltrOIL);
    ccy = vars(:,ismember(hdr_macro(:,2),'CCY') & fltrCTY);  
    stx = vars(:,ismember(hdr_macro(:,2),'STX') & fltrCTY);
    inf = vars(:,ismember(hdr_macro(:,2),'INF') & fltrCTY);  
    une = vars(:,ismember(hdr_macro(:,2),'UNE') & fltrCTY);  
    ip  = vars(:,ismember(hdr_macro(:,2),'IP')  & fltrCTY);
    rsp = [NaN; diff(log(spx))*100];            % Monthly return of stock market
    roi = [NaN; diff(log(oil))*100];            % Monthly return of oil
    rfx = [NaN; diff(log(ccy))*100];            % Monthly return of the exchange rate
    rsx = [NaN; diff(log(stx))*100];            % Monthly return of stock market
    if size(une,2) > 1; une = une(:,1); end     % Hungary has 2 UNE series
    
    tpus = dataset_in_range(data_usrp,min(datesNid(:,1)),max(datesNid(:,1))); % Trim to EM TP range
    tpus = tpus(:,fltrUS);
    
    data_panel = [data_panel; datesNid data vix ffr spx oil ccy stx inf une ip rsp roi rfx rsx tpus];
end

paneltp = array2table(data_panel,'VariableNames',names');
paneltp.DATE = cellfun(@datestr,num2cell(paneltp.DATE),'UniformOutput',false); % from datenum to datestr

%     % Run the regressions
%     lm = struct('mdl',{});
%     lm(1).mdl = fitlm(lvix,rp(k).data);
%     lm(2).mdl = fitlm(ffr,rp(k).data);
%     lm(3).mdl = fitlm(roi,rp(k).data);
%     lm(4).mdl = fitlm(rfx,rp(k).data);
%     lm(5).mdl = fitlm(ret,rp(k).data);
%     
%     % Exceptions for macro variables
%     if     ismember(rp(k).cty,{'PHP'})              % Cases with no inf
%         lm(6).mdl = fitlm([une ip],rp(k).data);
%     elseif ismember(rp(k).cty,{'BRL','ILS','PLN','ZAR'})  % Cases with no une
%         lm(6).mdl = fitlm([inf ip],rp(k).data);
%     elseif ismember(rp(k).cty,{'IDR','MYR','THB'})  % Cases with no ip
%         lm(6).mdl = fitlm([inf une],rp(k).data);
%     else 
%         lm(6).mdl = fitlm([inf une ip],rp(k).data);
%     end
%     
%     % Save the results of the regressions
%     for l = 1:6
%         beta = lm(l).mdl.Coefficients.Estimate;
%         stdb = lm(l).mdl.Coefficients.SE;
%         pval = lm(l).mdl.Coefficients.pValue;
%         nobs = lm(l).mdl.NumObservations;
%         r2   = lm(l).mdl.Rsquared.Ordinary;
%         
%         if l < 6
%             aux  = [beta(2); stdb(2); pval(2); nobs; r2];
%             matrix_1reg(:,k,l) = aux;
%         else                                                % Macro variables case
%             aux = [beta(2:end) stdb(2:end) pval(2:end)];
%             if     ismember(rp(k).cty,{'PHP'})             % Cases with no inf
%                 aux = [nan(3,1); reshape(aux',[numel(aux),1]); nobs; r2];
%             elseif ismember(rp(k).cty,{'ILS','PLN','ZAR'}) % Cases with no une
%                 aux = reshape(aux',[numel(aux),1]);
%                 aux = [aux(1:3); nan(3,1); aux(4:end); nobs; r2];
%             elseif ismember(rp(k).cty,{'IDR','MYR','THB'}) % Cases with no ip
%                 aux = [reshape(aux',[numel(aux),1]); nan(3,1); nobs; r2];
%             else 
%                 aux = [reshape(aux',[numel(aux),1]); nobs; r2];
%             end
%             matrix_3reg(:,k) = aux;
%         end
%     end

% A = num2cell(matrix_3reg);                      % Convert matrix to cell
% A = cellfun(@num2str,A,'UniformOutput',false);  % Convert doubles to strings

%% Tables
% names        = {'lvix','ffr','oil','rfx','stx'};
% columnLabels = ctrsLC';
% rowLabels    = {'Coeff.','S.E.','pVal','Obs','R2'};
% 
% for l = 1:5
%     filename = fullfile('..','..','Docs','Tables',['rp_reg_' names{l} '1.tex']);
%     matrix2latex(matrix_1reg(:,:,l),filename,'rowLabels',rowLabels,'columnLabels',columnLabels,...
%         'alignment','c','format','%4.2f');
% end
% 
% filename  = fullfile('..','..','Docs','Tables','rp_reg_macro1.tex');
% rowLabels = {'Inf.','S.E.','pVal','Une.','S.E.','pVal','IP','S.E.','pVal','Obs','R2'};
% matrix2latex(matrix_3reg,filename,'rowLabels',rowLabels,'columnLabels',columnLabels,...
%     'alignment','c','format','%4.2f');

% clear k l filename* fltr* txt vars lvix ffr spx oil ccy stx inf une ip names
% clear beta stdb pval nobs r2 aux columnLabels rowLabels

% fltrGBL = ismember(hdr_macro(:,2),{'VIX','FFR','OIL'}) | fltrSPX;
% fltrDOM = ismember(hdr_macro(:,2),var_dom) & fltrCTY;

% matrix_1reg = nan(5,numel(IDs),5); % 5 matrices of 5xnumel(IDs)
% matrix_3reg = nan(11,numel(IDs));  % 1 matrix of 11xnumel(IDs)
% rp = 1;
%% Sources

% Add parenthesis [not used but may use it later]
% https://www.mathworks.com/matlabcentral/answers/...
% 359415-how-can-i-convert-matrix-to-cell-array-of-strings