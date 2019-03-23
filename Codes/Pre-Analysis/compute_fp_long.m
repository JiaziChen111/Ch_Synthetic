function [CCS,hdr] = compute_fp_long(LC,header,dataset)
% This function uses the formulas in 'AE_EM_Curves_Tickers.xlsx' to compute
% fixed-for-fixed cross-currency swaps for local currencies (LC). See 
% Du & Schreger (2016) and Du, Im & Schreger (2018).
% m-files called: extractvars.m, construct_hdr.m
%
%     INPUTS
% char: LC        - local currency for which CCS will be computed
% double: formula - number of formula needed to compute the CCS (see bottom)
% cell: header    - contains information about the tikcers (eg currency, type, tenor)
% double: dataset - dataset with historic values of all the tickers
% 
%     OUTPUT
% double: CCS - matrix of historic CCS (rows) for different tenors (cols)
% cell: hdr   - header ready to be appended (NO extra first row with titles)
%
% Pavel Sol�s (pavel.solis@gmail.com), March 2019
%%
ccy_AE = {'AUD','CAD','CHF','DKK','EUR','GBP','JPY','NOK','NZD','SEK'};
switch LC
    case {'BRL','COP','IDR','PEN','PHP','KRW'}%1  % Formula 1
        currencies = {LC,'USD','USD'};
        types      = {'NDS','TBS3v6_USD','IRS_USD'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        NDS = vars{1};   TBS3v6_USD = vars{2};   IRS_USD = vars{3};

        CCS = NDS - TBS3v6_USD./100 - IRS_USD;
    
    case {'HUF', 'PLN'}%2  % Formula 2
        currencies = {LC,LC,'EUR','USD'};
        types      = {'IRS','BS','BS_EUR','IRS_USD'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        IRS = vars{1};  BS = vars{2};  BS_EUR = vars{3}; IRS_USD = vars{4};

        CCS = IRS + BS./100 + BS_EUR./100 - IRS_USD;

    case ['ILS', 'MYR', 'ZAR', ccy_AE]%3  % Formula 3
        currencies = {LC,LC,'USD'};
        types      = {'IRS','BS','IRS_USD'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        IRS = vars{1};  BS = vars{2}; IRS_USD = vars{3};
        
        CCS = IRS + BS./100 - IRS_USD;

    case 'MXN'%4  % Formula 4
        currencies = {LC,LC,'USD','USD'};
        types      = {'IRS','BS','TBS1v3_USD','IRS_USD'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        IRS = vars{1};  BS = vars{2}; TBS1v3_USD = vars{3};  IRS_USD = vars{4};

        CCS = IRS - BS./100 + TBS1v3_USD./100 - IRS_USD;

    case 'THB'%5  % Formula 5
        currencies = {LC,LC,'USD','USD'};
        types      = {'IRS','BS','TBS3v6_USD','IRS_USD'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        IRS = vars{1};  BS = vars{2}; TBS3v6_USD = vars{3};  IRS_USD = vars{4};

        CCS = IRS + BS./100 - TBS3v6_USD./100 - IRS_USD;

    case 'TRY'%7  % Formula 7
        currencies = {LC,'USD'};
        types      = {'CCS','IRS_USD'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        CCS = vars{1};  IRS_USD = vars{2};

        CCS = CCS - IRS_USD;

    case 'RUB'%8  % Formula 8
        currencies = {LC,'USD'};
        types      = {'NDS','IRS_USD'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        NDS = vars{1};  IRS_USD = vars{2};

        CCS = NDS - IRS_USD;

%     case 'BRL2'%6  % Formula 6
%         currencies = {LC,LC};
%         types      = {'IRS','CC'};
%         [vars,tnr] = extractvars(currencies,types,header,dataset);
%         IRS = vars{1};  CC = vars{2};
% 
%         CCS = IRS - CC;
        
    otherwise
        disp('Cannot compute the CCS.')
end

% Special cases
if strcmp(LC,'JPY') || strcmp(LC,'NOK')
    CCS1 = CCS; tnr1 = tnr;
    
    currencies   = {LC,LC,LC,'USD'};
    types        = {'IRS','TBS','BS','IRS_USD'};
    [vars2,tnr2] = extractvars(currencies,types,header,dataset);
    IRS = vars2{1}; TBS = vars2{2}; BS = vars2{3}; IRS_USD = vars2{4};

    CCS2 = IRS - TBS + BS./100 - IRS_USD;

    [CCS,tnr] = split_merge_vars(LC,CCS1,CCS2,tnr1,tnr2,dataset);
end

% Header
name = strcat(LC,' CROSS-CURRENCY SWAP',{' '},tnr,' YR');
hdr  = construct_hdr(LC,'RHO','N/A',name,tnr,' ',' ');         % No extra row 1

% if strcmp(LC,'BRL2')     % Special case for Brazil since 2 ways to compute CCS
%     hdr  = construct_hdr(LC,'RHO2','N/A',name,tnr,' ',' ');
% end

%% Formulas
% 
% % Formula 1
% BRL	NDS-TBS3v6_USD/100-IRS_USD
% COP	NDS-TBS3v6_USD/100-IRS_USD
% IDR	NDS-TBS3v6_USD/100-IRS_USD
% PEN	NDS-TBS3v6_USD/100-IRS_USD
% PHP	NDS-TBS3v6_USD/100-IRS_USD
% KRW	NDS-TBS3v6_USD/100-IRS_USD
% 
% % Formula 2
% HUF	IRS+BS/100+BS_EUR/100-IRS_USD
% PLN	IRS+BS/100+BS_EUR/100-IRS_USD
% 
% % Formula 3
% ILS	IRS+BS/100-IRS_USD
% MYR	IRS+BS/100-IRS_USD
% ZAR	IRS+BS/100-IRS_USD
% 
% % Formula 4
% MXN	IRS-BS/100+TBS1v3_USD/100-IRS_USD
% 
% % Formula 5
% THB	IRS+BS/100-TBS3v6_USD/100-IRS_USD
% 
% % Formula 6
% BRL	IRS-CC
% 
% % Formula 7
% TRY	CCS-IRS_USD
% 
% % Formula 8
% RUB	NDS-IRS_USD