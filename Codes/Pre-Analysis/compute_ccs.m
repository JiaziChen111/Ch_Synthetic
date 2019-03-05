function [CCS,hdr] = compute_ccs(LC,formula,header,dataset)
% This function uses the formulas in the online spreadsheet of Du & 
% Schreger (2016) to compute cross-currency swaps for local currencies (LC).
% Calls to m-files: extractvars.m, construct_hdr.m
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
% Pavel Solís (pavel.solis@gmail.com), March 2018
%%
switch formula
    case 1  % Formula 1
        currencies = {LC,'USD','USD'};
        types      = {'NDS','USD_TBS3v6','USD_IRS'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        NDS = vars{1};   USD_TBS3v6 = vars{2};   USD_IRS = vars{3};

        CCS = NDS - USD_TBS3v6./100 - USD_IRS;
    
    case 2  % Formula 2
        currencies = {LC,LC,'EUR','USD'};
        types      = {'IRS','BS','BSEUR','USD_IRS'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        IRS = vars{1};  BS = vars{2};  BSEUR = vars{3}; USD_IRS = vars{4};

        CCS = IRS + BS./100 + BSEUR./100 - USD_IRS;

    case 3  % Formula 3
        currencies = {LC,LC,'USD'};
        types      = {'IRS','BS','USD_IRS'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        IRS = vars{1};  BS = vars{2}; USD_IRS = vars{3};

        CCS = IRS + BS./100 - USD_IRS;

    case 4  % Formula 4
        currencies = {LC,LC,'USD','USD'};
        types      = {'IRS','BS','USD_TBS1v3','USD_IRS'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        IRS = vars{1};  BS = vars{2}; USD_TBS1v3 = vars{3};  USD_IRS = vars{4};

        CCS = IRS - BS./100 + USD_TBS1v3./100 - USD_IRS;

    case 5  % Formula 5
        currencies = {LC,LC,'USD','USD'};
        types      = {'IRS','BS','USD_TBS3v6','USD_IRS'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        IRS = vars{1};  BS = vars{2}; USD_TBS3v6 = vars{3};  USD_IRS = vars{4};

        CCS = IRS + BS./100 - USD_TBS3v6./100 - USD_IRS;

    case 6  % Formula 6
        currencies = {LC,LC};
        types      = {'IRS','CC'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        IRS = vars{1};  CC = vars{2};

        CCS = IRS - CC;

    case 7  % Formula 7
        currencies = {LC,'USD'};
        types      = {'CCS','USD_IRS'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        CCS = vars{1};  USD_IRS = vars{2};

        CCS = CCS - USD_IRS;

    case 8  % Formula 8
        currencies = {LC,'USD'};
        types      = {'NDS','USD_IRS'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        NDS = vars{1};  USD_IRS = vars{2};

        CCS = NDS - USD_IRS;
    
    otherwise
        disp('Cannot compute the CCS.')
end

% Header
name = strcat(LC,' CROSS-CURRENCY SWAP',{' '},tnr,' YR');
hdr  = construct_hdr(LC,'RHO','N/A',name,tnr);         % No extra row 1

if formula == 6     % Special case for Brazil since 2 ways to compute CCS
    hdr  = construct_hdr(LC,'RHO2','N/A',name,tnr);
end

%%
% % Formula 1
% BRL	NDS-USD_TBS3v6/100-USD_IRS
% COP	NDS-USD_TBS3v6/100-USD_IRS
% IDR	NDS-USD_TBS3v6/100-USD_IRS
% PEN	NDS-USD_TBS3v6/100-USD_IRS
% PHP	NDS-USD_TBS3v6/100-USD_IRS
% KRW	NDS-USD_TBS3v6/100-USD_IRS
% 
% % Formula 2
% HUF	IRS+BS/100+BSEUR/100-USD_IRS
% PLN	IRS+BS/100+BSEUR/100-USD_IRS
% 
% % Formula 3
% ILS	IRS+BS/100-USD_IRS
% MYR	IRS+BS/100-USD_IRS
% ZAR	IRS+BS/100-USD_IRS
% 
% % Formula 4
% MXN	IRS-BS/100+USD_TBS1v3/100-USD_IRS
% 
% % Formula 5
% THB	IRS+BS/100-USD_TBS3v6/100-USD_IRS
% 
% % Formula 6
% BRL	IRS-CC
% 
% % Formula 7
% TRY	CCS-USD_IRS
% 
% % Formula 8
% RUB	NDS-USD_IRS