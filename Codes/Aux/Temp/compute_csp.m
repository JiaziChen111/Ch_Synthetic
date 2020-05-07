function [CS,hdr] = compute_csp(LC,CStype,header,dataset)
% This function computes local currency (LC) and foreign currency (FC)
% credit spreads (CS).
% Calls to m-files: extractvars.m, construct_hdr.m
%
%     INPUTS
% char: LC        - country for which the CS will be computed
% double: CStype  - 1 for LC and 2 for FC
% cell: header    - contains information about the tikcers (eg currency, type, tenor)
% double: dataset - dataset with historic values of all the tickers
% 
%     OUTPUT
% double: CS - matrix of historic CS (rows) for different tenors (cols)
% cell: hdr  - header ready to be appended (ie NO extra first row with titles)
%
% Pavel Solís (pavel.solis@gmail.com), March/September 2018
%%
switch CStype
    case 1  % LC case
        if strcmp(LC,'BRL')              % For the moment, no LC yield curve data for Brazil
            currencies = {'USD',LC};
            types      = {'HC','RHO'};   % Even though RHO & RHO2 for BRL, only RHO is used
            [vars,tnr] = extractvars(currencies,types,header,dataset);
            y_rf = vars{1};   ccs = vars{2};

            LCrf = y_rf + ccs;           % Default-free LC yield curve
            CS   = LCrf;

            % Header
            name_lcrf = strcat(LC,' RISK-FREE LC YIELD CURVE',{' '},tnr,' YR');
            hdr_lcrf  = construct_hdr(LC,'LCRF','N/A',name_lcrf,tnr);
            hdr       = hdr_lcrf;
        else
            currencies = {LC,'USD',LC};
            types      = {'LC','HC','RHO'};
            [vars,tnr] = extractvars(currencies,types,header,dataset);
            y_lc = vars{1};   y_rf = vars{2};   ccs = vars{3};

            LCUS = y_lc - y_rf;          % LC-US spread
            LCrf = y_rf + ccs;           % Default-free LC yield curve
            LCCS = y_lc - LCrf;          % LC credit spread
            CS   = [LCrf, LCUS, LCCS];   % Append all variables

            % Header
            name_lcrf = strcat(LC,' RISK-FREE LC YIELD CURVE',{' '},tnr,' YR');
            name_lcus = strcat(LC,' LC YIELD OVER US YIELD',{' '},tnr,' YR');
            name_lccs = strcat(LC,' LC CREDIT SPREAD',{' '},tnr,' YR');
            hdr_lcrf  = construct_hdr(LC,'LCRF','N/A',name_lcrf,tnr);
            hdr_lcus  = construct_hdr(LC,'LCUS','N/A',name_lcus,tnr);
            hdr_lccs  = construct_hdr(LC,'LCCS','N/A',name_lccs,tnr);
            hdr  = [hdr_lcrf; hdr_lcus; hdr_lccs]; % Stack the headers
        end
        
    case 2  % FC case
        currencies = {LC,'USD'};
        types      = {'USD','HC'};
        [vars,tnr] = extractvars(currencies,types,header,dataset);
        y_fc = vars{1};  y_rf = vars{2};

        FCCS = y_fc - y_rf;          % FC credit spread
        CS   = FCCS;
        
        % Header
        name_fccs = strcat(LC,' FC CREDIT SPREAD',{' '},tnr,' YR');
        hdr  = construct_hdr(LC,'FCCS','N/A',name_fccs,tnr);
        
    otherwise
        disp('Cannot compute the credit spread.')
end
