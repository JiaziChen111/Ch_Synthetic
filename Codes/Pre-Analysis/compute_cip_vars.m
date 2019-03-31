function [CIPvars,CIPhdr] = compute_cip_vars(LC,ccy_type,header,dataset)
% This function computes interest rate differentials of local currency (LC)
% and foreign currency (FC) sovereign bonds with respect to the U.S., LC
% synthetic yield curves and deviations from covered interest parity (CIP).
% Note: Variables are extracted in pairs since tenors differ.
% m-files called: extractvars.m, construct_hdr.m
%
%     INPUTS
% char: LC         - country for which the variables will be computed
% double: ccy_type - 1 for LC and 2 for FC
% cell: header     - contains information about the tickers (e.g. currency, type, tenor)
% double: dataset  - dataset with historic values of all the tickers
% 
%     OUTPUT
% double: CIPvars - matrix of historic LC synthetic yield curves, spreads
%                   and CIP deviations (rows) for different tenors (cols)
% cell: CIPhdr    - header ready to be appended (i.e. NO extra first row with titles)
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
switch ccy_type
    case 1  % LC case     
        % Synthetic LC yield curve
        currencies = {'USD',LC};
        types      = {'HC','RHO'};
        [vars,tnrLCsynt] = extractvars(currencies,types,header,dataset);
        y_US = vars{1};   FP = vars{2};
        y_LCsynt = y_US + FP;
        name_LCsynt = strcat(LC,' SYNTHETIC LC YIELD CURVE',{' '},tnrLCsynt,' YR');
        hdr_LCsynt  = construct_hdr(LC,'LCSYNT','N/A',name_LCsynt,tnrLCsynt,' ',' ');
        
        % LC-US interest rate spread
        currencies = {LC,'USD'};
        types      = {'LC','HC'};
        [vars,tnrLCsprd] = extractvars(currencies,types,header,dataset);
        y_LC = vars{1};   y_US = vars{2};
        y_LCsprd = y_LC - y_US;
        name_LCsprd = strcat(LC,' LC INTEREST RATE SPREAD',{' '},tnrLCsprd,' YR');
        hdr_LCsprd  = construct_hdr(LC,'LCSPRD','N/A',name_LCsprd,tnrLCsprd,' ',' ');
        
        vars_aux = [dataset, y_LCsynt, y_LCsprd];
        hdr_aux  = [header; hdr_LCsynt; hdr_LCsprd];
        
        % Deviations from CIP
        currencies = {LC,LC};
        types      = {'LC','LCSYNT'};
        [vars,tnrCIPdev] = extractvars(currencies,types,hdr_aux,vars_aux);
        y_LC = vars{1};   y_LCsynt = vars{2};
        cip_dev = y_LC - y_LCsynt;
        name_CIPdev = strcat(LC,' CIP DEVIATION',{' '},tnrCIPdev,' YR');
        hdr_CIPdev  = construct_hdr(LC,'CIPDEV','N/A',name_CIPdev,tnrCIPdev,' ',' ');
        
        % Append all variables and stack the headers
        CIPvars = [y_LCsynt, y_LCsprd, cip_dev];        
        CIPhdr  = [hdr_LCsynt; hdr_LCsprd; hdr_CIPdev];
        
    case 2  % FC case
        % FC interest rate differential
        currencies = {LC,'USD'};
        types      = {'USD','HC'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        y_FC = vars{1};  y_US = vars{2};
        y_FCsprd = y_FC - y_US;
        name_FCsprd = strcat(LC,' FC INTEREST RATE SPREAD',{' '},tnr,' YR');
        CIPhdr = construct_hdr(LC,'FCSPRD','N/A',name_FCsprd,tnr,' ',' ');
        
        CIPvars = y_FCsprd;

    otherwise
        disp('Cannot compute the credit spread.')
end
