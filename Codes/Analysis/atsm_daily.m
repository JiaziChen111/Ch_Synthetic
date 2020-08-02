function [S,fitrprt] = atsm_daily(S,matsout,currEM,currAE,plotfit)
% ATSM_DAILY Estimate affine term structure model with daily data
% 
%	INPUTS
% S        - structure with fields bsl_pr, s, n, ds, dn
% matsout  - bond maturities in years to be reported
% currEM   - emerging market countries
% currAE   - advanced countries
% plotfit  - logical indicating whether to show a plot of the fit
%
%	OUTPUT
% S - structure includes estimated yields under Q and P measures, estimated term premia

% m-files called: none
% Pavel Solís (pavel.solis@gmail.com), June 2020
%%
ncntrs  = length(S);
nEMs    = length(currEM);
matsall = [0.25 0.5 1:10];                                      % all possible maturities
mtxmae  = nan(ncntrs,length(matsall));  mtxsae = nan(ncntrs,length(matsall)); %fit using absolute errors
fitrprt = cell(2*ncntrs+1,length(matsall)+1);
fnames  = fieldnames(S);
fnameq  = fnames{contains(fnames,'bsl_pr')};                    % field containing estimated parameters
dt      = 1/12;                                                 % period length in years
prefix  = 'd';                                                  % prefix for fields storing the results
intctrs = setdiff(currEM,{'ILS','ZAR'});                        % countries w/ intercept

for k0 = 1:ncntrs
    % Prefixes for monthly and daily fields
    if ismember(S(k0).iso,currEM)
        prfxM  = 'ms';   prfxD  = 'ds';
    else
        prfxM  = 'mn';   prfxD  = 'dn';
    end
    
    % Monthly data
    fldname = fnames{contains(fnames,[prfxM '_blncd'])};        % field for monthly data
    mats    = S(k0).(fldname)(1,2:end);                       	% original maturities
    yieldsM = S(k0).(fldname)(2:end,2:end);                     % monthly yields
    nobsM   = size(yieldsM,1);                                  % #monthly observations
    
    % Smoothed state
    xsM = S(k0).(fnameq).xs;
    if size(xsM,2) == nobsM; xsM = xsM'; end                    % ensure xs dimensions are the same as yields
    
    % Implied monthly weights from smoothed state using least squares
    if ~ismember(S(k0).iso,intctrs)
        Wm   = (yieldsM'*yieldsM)\yieldsM'*xsM;                	% no intercept
    else
        X    = [ones(nobsM,1) yieldsM];
        Wmls = (X'*X)\X'*xsM;
        Wmc  = Wmls(1,:);                                       % intercepts
        Wm   = Wmls(2:end,:);
    end
    
    % Estimate daily pricing factors using monthly weights
    fldname = fnames{contains(fnames,[prfxD '_blncd'])};        % field for daily data
    datesD  = S(k0).(fldname)(2:end,1);                        	% daily dates
    yieldsD = S(k0).(fldname)(2:end,2:end);                     % daily yields
    nobsD   = size(yieldsD,1);                                	% #daily observations
    if ~ismember(S(k0).iso,intctrs)
        xsD = yieldsD*Wm;
    else
        xsD = repmat(Wmc,nobsD,1) + yieldsD*Wm;
    end
    
    % Fit yields and estimate the term premium
    cSgm  = S(k0).(fnameq).cSgm;    Hcov  = cSgm*cSgm';       	% estimated parameters
    mu_xQ = S(k0).(fnameq).mu_xQ;   PhiQ  = S(k0).(fnameq).PhiQ;
    mu_xP = S(k0).(fnameq).mu_xP;   PhiP  = S(k0).(fnameq).PhiP;
    rho0  = S(k0).(fnameq).rho0;    rho1  = S(k0).(fnameq).rho1;
    [AnQ,BnQ] = loadings(mats,mu_xQ,PhiQ,Hcov,rho0,rho1,dt);	% loadings using original maturities 
    [AnP,BnP] = loadings(mats,mu_xP,PhiP,Hcov,rho0,rho1,dt);
    ylds_Q    = ones(nobsD,1)*AnQ + xsD*BnQ;                    % fitted daily yields in decimals
    ylds_P    = ones(nobsD,1)*AnP + xsD*BnP;                    % risk neutral yields
    termprm   = ylds_Q - ylds_P;                                % in decimals
    
    % Assess fit of the model
    mtxmae(k0,ismember(matsall,mats)) = mean(abs(yieldsD - ylds_Q))*10000;  % mean absolute errors in bp
    mtxsae(k0,ismember(matsall,mats)) = std(abs(yieldsD - ylds_Q))*10000;   % std of absolute errors in bp
    
    % Store variables
    fltr = ismember(mats,matsout);
    S(k0).([prefix '_yQ']) = [nan matsout; datesD ylds_Q(:,fltr)];
    S(k0).([prefix '_yP']) = [nan matsout; datesD ylds_P(:,fltr)];
    S(k0).([prefix '_tp']) = [nan matsout; datesD termprm(:,fltr)];
    S(k0).([prefix '_rmse']) = sqrt(mean(mean(10000*(yieldsD - ylds_Q).^2)));% RMSE
    
    if plotfit
        if ismember(S(k0).iso,currEM)
            if k0 == 1; figure; end
            subplot(3,5,k0);
            plot(datesD,yieldsD(:,end),datesD,ylds_Q(:,end))
            title(S(k0).cty); datetick('x','yy'); yline(0); ylabel('%');
        else
            if k0 == nEMs+1; figure; end
            subplot(2,5,k0-nEMs);
            plot(datesD,yieldsD(:,end),datesD,ylds_Q(:,end))
            title(S(k0).cty); datetick('x','yy'); yline(0); ylabel('%');
        end 
    end
end

% Report means and standard deviations of absolute errors
fitrprt(1,2:end) = num2cell(matsall);                                       % maturities
fitrprt(2:2:2*nEMs+1,1) = currEM;                                           % names of EMs
fitrprt(2*nEMs+2:2:2*ncntrs+1,1) = currAE;                                  % names of AEs
fitrprt(2:2:2*ncntrs+1,2:end) = num2cell(mtxmae);                           % mean absolute errors
fitrprt(3:2:2*ncntrs+1,2:end) = num2cell(mtxsae);                           % std of absolute errors
fitrprt(:,[false,ismember(matsall,[6 8 9])]) = [];                          % delete maturities 6Y-8Y-9Y