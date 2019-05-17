function [S,weightsLT,wgtNames,outputLT,outputTR] = estimate_TR(S,currEM)
% This function estimates a Taylor rule for each emerging markets (EMs) and
% reports the output.
%
%	INPUTS
% struct: S    - contains names of countries/currencies, codes and YC data
% char: currEM - ISO currency codes of EM in the sample
%
%	OUTPUT
% struct: S         - adds end-ofmonth and end-of-quarter macro variables for each EM
% double: weightsLT - coefficients to apply to LT inflation and output growth forecasts
% cell: outputLT    - reports coefficients for LT inflation and output growth forecasts
% cell: outputTR    - reports coefficients for Taylor rules with smoothing
%
%   ASSUMPTIONS
% S in input is generated by tp_estimation.m
% m-files called: read_macro_vars.m, read_cbpol.m, construct_hdr.m, 
%                 end_of_month, end_of_quarter.m
% 
% Pavel Sol�s (pavel.solis@gmail.com), May 2019
%
%% Read and merge data from macro variables and policy rates

run read_macro_vars.m
run read_cbpol.m

% Merge (assumes both datasets start on the same month, keep dates from data_macro)
data_macro  = end_of_month(data_macro);
[nobs,idxD] = min([size(data_macro,1) size(data_cbpol,1)]);
if idxD == 2
    data_macro = [data_macro(1:nobs,:) data_cbpol(:,2:end)];
else
    data_macro = [data_macro data_cbpol(1:nobs,2:end)];
end
hdr_cbpol = construct_hdr(currEM,'CBP',tckr_cbpol,'CB Policy Rate','N/A','Monthly');
hdr_macro = [hdr_macro; hdr_cbpol];


%% Extract macro variables and estimate Taylor rules

nEMs     = length(currEM);
vars     = {'CCY','INF','UNE','IP','GDP','CBP'};                    % Variables to save in structure S
fltrMAC  = ismember(hdr_macro(:,2),vars);
outputTR = cell(11,nEMs);	  outputLT  = cell(4,nEMs);
hdr_cty  = cell(nEMs,1);      weightsLT = nan(4,nEMs);

for k = 1:nEMs
    % Monthly and quarterly frequency
    fltrCTY       = ismember(hdr_macro(:,1),S(k).iso) & fltrMAC;
    fltrCTY(1)    = true;                                           % Include dates
    S(k).macromth = data_macro(:,fltrCTY);                          % Monthly data
    S(k).macroqtr = end_of_quarter(S(k).macromth);                  % Quarterly data
    hdr_cty{k}    = hdr_macro(fltrCTY,2)';
    
    % If multiple matches, choose first appearance
    [~,idxUnq] = unique(hdr_macro(fltrCTY,2),'stable');
    idxUnq     = idxUnq(2:end);                                     % Exclude dates
    data_mvar  = S(k).macroqtr(:,idxUnq);
    hdr_mvar   = hdr_cty{k}(idxUnq);
    
    % Save data as table to report variable names after estimation
    TblQtr = array2table(data_mvar,'VariableNames',hdr_mvar);    
    if strcmp(S(k).iso,'MYR')                                       % Complement MYR GDP w/ Bloomberg survey data
        n1 = length(data_myr);                                      % From read_macro_vars.m
        n2 = sum(isnan(TblQtr.GDP));                                % Assumption: n2 >= n1
        TblQtr.GDP(n2-n1+1:n2) = data_myr;                          % corr = 0.84, results are similar
    end
    
    % Prepare variables for regression: CBP ~ 1 + CBPlag + INF + GDP
    idxTR  = ismember(TblQtr.Properties.VariableNames,{'INF','GDP','CBP'});
    idxCBP = ismember(TblQtr.Properties.VariableNames,{'CBP'});
    TblLag = TblQtr(1:end-1,idxCBP);
    TblLag.Properties.VariableNames{'CBP'} = 'CBPlag';
    TblTR = [TblQtr(2:end,idxTR) TblLag];
    TblTR = movevars(TblTR,'CBPlag','Before',1);    
    tTR   = sum(~any(ismissing(TblTR),2));                          % Remove NaNs to obtain sample size
    
%     % Plot the series
%     figure, plot(S(k).macroqtr(2:end,1),TblTR{:,2:end})
%     legend(TblTR.Properties.VariableNames{2:end})
%     title(S(k).cty), datetick('x','YYQQ')
    
    % Estimate Taylor Rule
    MdlTR = fitlm(TblTR);
    
%     % NW standard errors
%     plot([min(MdlTR.Fitted) max(MdlTR.Fitted)],[0 0],'k-'), hold on
%     plotResiduals(MdlTR,'fitted'), title([S(k).iso ' Residual Plot']), ylabel('Residuals')
%     resid  = MdlTR.Residuals.Raw(~isnan(MdlTR.Residuals.Raw)); autocorr(resid)
%     maxLag = floor(4*(tTR/100)^(2/9));                             % Lag for the NW HAC estimate
%     EstCov = hac(TblTR,'bandwidth',maxLag+1,'display','off');
    
    % Report output with smoothing
    aux1 = MdlTR.Coefficients{:,1:2}';                              % Extract estimates and SE
    aux1 = num2cell(round(aux1,2));                                 % Round and save them as cells
    aux1 = cellfun(@num2str,aux1,'UniformOutput',false);            % Store them as strings
    aux1(2,:) = strcat('(',aux1(2,:),')');                          % Add parenthesis to SE
    if strcmp(S(k).iso,'ZAR')                                       % No GDP data for ZAR 
        aux2    = cell(2,1);
        aux2(:) = {''};
        aux1    = [aux1 aux2];
    end
    outputTR(1,k)   = {S(k).iso};
    outputTR(2:9,k) = reshape(aux1,[],1);
    outputTR(10,k)  = {num2str(round(MdlTR.Rsquared.Ordinary,2),'%.2f')};
    outputTR(11,k)  = {num2str(MdlTR.NumObservations)};
    
    % Report output for long-term interest rates
    aux3  = MdlTR.Coefficients{:,1};                                % Extract estimates
    bsmth = aux3(2);
    brest = aux3([1 3:end]);
    aux3  = brest./(1-bsmth);                                       % Long-term transformation
    aux4  = num2cell(round(aux3,2));
    if strcmp(S(k).iso,'ZAR')                                       % No GDP data for ZAR
        aux3 = [aux3; 0];
        aux4 = [aux4; {''}];
    end
    weightsLT(1,k)     = S(k).imf;
    weightsLT(2:end,k) = aux3;
    outputLT(1,k)      = {S(k).iso};
    outputLT(2:end,k)  = cellfun(@num2str,aux4,'UniformOutput',false);
    
    % Save coefficient names
    if k == 1
        wgtNames = MdlTR.CoefficientNames';
        wgtNames = wgtNames([1 3:end]);
    end
end