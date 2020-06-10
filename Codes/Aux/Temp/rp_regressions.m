%% Correlations of Risk Premia with Macro-Financial Variables
% This code regress the risk premia on different macroeconomic and financial
% variables and report the results.
% Assumes plot_rp.m and read_macro_vars.m have already been run.
% Calls to m-files: none
%
% Pavel Solís (pavel.solis@gmail.com), April 2018
%%
fltrVIX = ismember(hdr_macro(:,2),'VIX');
fltrFFR = ismember(hdr_macro(:,2),'FFR');
fltrOIL = ismember(hdr_macro(:,2),'OIL');
% fltrSPX = ismember(hdr_macro(:,2),'STX') & ismember(hdr_macro(:,1),'USD');

matrix_1reg = nan(5,numel(IDs),5); % 5 matrices of 5xnumel(IDs)
matrix_3reg = nan(11,numel(IDs));  % 1 matrix of 11xnumel(IDs)
rp = 1;
%%
for k = 1:numel(IDs)
    fltrDTS = ismember(dates_macro,rp(k).dates);
    vars    = data_macro(fltrDTS,:);
    
    vix = vars(:,fltrVIX); lvix = log(vix); ffr = vars(:,fltrFFR); oil = vars(:,fltrOIL);
    
    fltrCTY = ismember(hdr_macro(:,1),rp(k).cty);
    ccy = vars(:,ismember(hdr_macro(:,2),'CCY') & fltrCTY);  
    stx = vars(:,ismember(hdr_macro(:,2),'STX') & fltrCTY);
    inf = vars(:,ismember(hdr_macro(:,2),'INF') & fltrCTY);  
    une = vars(:,ismember(hdr_macro(:,2),'UNE') & fltrCTY);  
    ip  = vars(:,ismember(hdr_macro(:,2),'IP')  & fltrCTY);

    if size(une,2) > 1; une = une(:,1); end     % Hungary case (2 UNE series)
    roi = [nan(1); diff(log(oil))*100];         % Monthly return of oil
    rfx = [nan(1); diff(log(ccy))*100];         % Monthly return of the exchange rate
    ret = [nan(1); diff(log(stx))*100];         % Monthly return of stock market
    
    % Run the regressions
    lm = struct('mdl',{});
    lm(1).mdl = fitlm(lvix,rp(k).data);
    lm(2).mdl = fitlm(ffr,rp(k).data);
    lm(3).mdl = fitlm(roi,rp(k).data);
    lm(4).mdl = fitlm(rfx,rp(k).data);
    lm(5).mdl = fitlm(ret,rp(k).data);
    
    % Exceptions for macro variables
    if     ismember(rp(k).cty,{'PHP'})              % Cases with no inf
        lm(6).mdl = fitlm([une ip],rp(k).data);
    elseif ismember(rp(k).cty,{'ILS','PLN','ZAR'})  % Cases with no une
        lm(6).mdl = fitlm([inf ip],rp(k).data);
    elseif ismember(rp(k).cty,{'IDR','MYR','THB'})  % Cases with no ip
        lm(6).mdl = fitlm([inf une],rp(k).data);
    else 
        lm(6).mdl = fitlm([inf une ip],rp(k).data);
    end
    
    % Save the results of the regressions
    for l = 1:6
        beta = lm(l).mdl.Coefficients.Estimate;
        stdb = lm(l).mdl.Coefficients.SE;
        pval = lm(l).mdl.Coefficients.pValue;
        nobs = lm(l).mdl.NumObservations;
        r2   = lm(l).mdl.Rsquared.Ordinary;
        
        if l < 6
            aux  = [beta(2); stdb(2); pval(2); nobs; r2];
            matrix_1reg(:,k,l) = aux;
        else                                                % Macro variables case
            aux = [beta(2:end) stdb(2:end) pval(2:end)];
            if     ismember(rp(k).cty,{'PHP'})             % Cases with no inf
                aux = [nan(3,1); reshape(aux',[numel(aux),1]); nobs; r2];
            elseif ismember(rp(k).cty,{'ILS','PLN','ZAR'}) % Cases with no une
                aux = reshape(aux',[numel(aux),1]);
                aux = [aux(1:3); nan(3,1); aux(4:end); nobs; r2];
            elseif ismember(rp(k).cty,{'IDR','MYR','THB'}) % Cases with no ip
                aux = [reshape(aux',[numel(aux),1]); nan(3,1); nobs; r2];
            else 
                aux = [reshape(aux',[numel(aux),1]); nobs; r2];
            end
            matrix_3reg(:,k) = aux;
        end
    end
end

% A = num2cell(matrix_3reg);                      % Convert matrix to cell
% A = cellfun(@num2str,A,'UniformOutput',false);  % Convert doubles to strings

%% Tables
names        = {'lvix','ffr','oil','rfx','stx'};
columnLabels = ctrsLC';
rowLabels    = {'Coeff.','S.E.','pVal','Obs','R2'};

for l = 1:5
    filename = fullfile('..','..','Docs','Tables',['rp_reg_' names{l} '1.tex']);
    matrix2latex(matrix_1reg(:,:,l),filename,'rowLabels',rowLabels,'columnLabels',columnLabels,...
        'alignment','c','format','%4.2f');
end

filename  = fullfile('..','..','Docs','Tables','rp_reg_macro1.tex');
rowLabels = {'Inf.','S.E.','pVal','Une.','S.E.','pVal','IP','S.E.','pVal','Obs','R2'};
matrix2latex(matrix_3reg,filename,'rowLabels',rowLabels,'columnLabels',columnLabels,...
    'alignment','c','format','%4.2f');

% clear k l filename* fltr* txt vars lvix ffr spx oil ccy stx inf une ip names
% clear beta stdb pval nobs r2 aux columnLabels rowLabels

%% Sources

% Add parenthesis [not used but may use it later]
% https://www.mathworks.com/matlabcentral/answers/...
% 359415-how-can-i-convert-matrix-to-cell-array-of-strings