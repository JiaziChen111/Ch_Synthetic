function hdr_monthly = construct_monthly_hdr(maturities,YCtype,HDRtype)
% This function constructs the header for a monthly dataset, which contains 
% titles of the columns only when HDRtype = 1 or 3.
% Calls to m-files: pnum2cell.m, construct_hdr.m
%
%     INPUT
% maturities - vector with all maturities wanted (0.25, 1, 2, ..., 10)
% YCtype     - char with the type of LC yield curve to fit (ie risky or risk-free)
% HDRtype    - double indicating the type of header (1-NS, 2-decomposition, 3-USD, 4-Res)
%
%     OUTPUT
% hdr_monthly - cell with names for the columns of the monthly dataset
%
% Pavel Solís (pavel.solis@gmail.com), October 2018
%%
tnrs3mo  = pnum2cell(maturities);
tnrs     = pnum2cell(maturities(2:end));            % Cell with all the tenors (starting 1yr) as strings

if     strcmp(YCtype,'LCRF')
    adj1 = 'LCRF';   adj2 = 'DEFAULT-FREE';         % Values when sythetic yield curve
elseif strcmp(YCtype,'LC') || strcmp(YCtype,'LCRK')
    adj1 = 'LCRK';   adj2 = 'NON-DEFAULT-FREE';     % Values when observed yield curve
end

switch HDRtype
    case 1      % NS case (includes column titles)
        name_yc   = strcat([adj2 ' LC N-S YIELD CURVE'],{' '},tnrs3mo,' YR');
        paramsNS  = {'BETA0';'BETA1';'BETA2';'TAU'};
        hdr_yc    = construct_hdr([adj1 'NS'],name_yc,tnrs3mo);
        hdr_param = construct_hdr([adj1 'PARAM'],[adj2 ' LC N-S YIELD CURVE'],paramsNS);
        hdr_rmse1 = construct_hdr([adj1 'RMSENS'],[adj2 ' LC N-S FIT RMSE'],'X');
        hdr_monthly = [{'type','description','tenor'; 'IMFC','IMF CODE','X'};
                    hdr_yc; hdr_param; hdr_rmse1];
    
    case 2      % Decompostion case (does NOT includes column titles)
        name_yE   = strcat([adj2 ' EXPECTED SHORT RATE IN'],{' '},tnrs,' YR');
        name_yQ   = strcat([adj2 ' RISK NEUTRAL YIELD'],{' '},tnrs,' YR');
        name_yP   = strcat([adj2 ' PHYSICAL YIELD'],{' '},tnrs,' YR');
        name_rp   = strcat([adj2 ' RISK PREMIUM'],{' '},tnrs,' YR');             
        hdr_yE    = construct_hdr([adj1 'YE'],name_yE,tnrs);
        hdr_yQ    = construct_hdr([adj1 'YQ'],name_yQ,tnrs);
        hdr_yP    = construct_hdr([adj1 'YP'],name_yP,tnrs);
        hdr_rp    = construct_hdr([adj1 'RP'],name_rp,tnrs);
        hdr_rmse2 = construct_hdr([adj1 'RMSEATSM'],[adj2 ' LC ATSM FIT RMSE'],'X');
        hdr_monthly = [hdr_yE; hdr_yQ; hdr_yP; hdr_rp; hdr_rmse2];    % Ready to be appended
        
    case 3      % USD case
        name_us   = strcat('USD ZERO-COUPON YIELD',{' '},tnrs3mo,' YR');
        paramsNSS = {'BETA0';'BETA1';'BETA2';'BETA3';'TAU1';'TAU2'};
        name_yE   = strcat('USD EXPECTED SHORT RATE IN',{' '},tnrs,' YR');
        name_yQ   = strcat('USD RISK NEUTRAL YIELD',{' '},tnrs,' YR');
        name_yP   = strcat('USD PHYSICAL YIELD',{' '},tnrs,' YR');
        name_rp   = strcat('USD RISK PREMIUM',{' '},tnrs,' YR');
        hdr_ycus  = construct_hdr('USZC',name_us,tnrs3mo);
        hdr_param = construct_hdr('PARAMETER','USD N-S-S YIELD CURVE',paramsNSS);
        hdr_yE    = construct_hdr('USYE',name_yE,tnrs);
        hdr_yQ    = construct_hdr('USYQ',name_yQ,tnrs);
        hdr_yP    = construct_hdr('USYP',name_yP,tnrs);
        hdr_rpus  = construct_hdr('USRP',name_rp,tnrs);
        hdr_rmseu = construct_hdr('USRMSEATSM','USD ATSM FIT RMSE','X');
        hdr_monthly = [{'type','description','tenor'; 'IMFC','IMF CODE','X'};
                    hdr_ycus; hdr_param; hdr_yE; hdr_yQ; hdr_yP; hdr_rpus; hdr_rmseu];
                
    case 4      % Resdiuals case
        name_resd   = strcat('RESIDUAL REGRESSION EM TP ON US TP',{' '},tnrs,' YR');
        hdr_monthly = construct_hdr([YCtype 'RESRP'],name_resd,tnrs);
end     
        