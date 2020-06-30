ncntrs  = length(S);
nEMs    = length(currEM);
matsall = [0.25 0.5 1:10];                                      % all possible maturities
mtxmae  = nan(ncntrs,length(matsall));  mtxsae = nan(ncntrs,length(matsall)); %fit using absolute errors
fnames  = fieldnames(S);
fnameq  = fnames{contains(fnames,'bsl_pr')};                    % field containing estimated parameters
p       = 3;                                                    % number of pricing factors
intctrs = setdiff(currEM,{'ILS','ZAR'});                        % countries w/ intercept

for k0 = 1:ncntrs
    % Prefixes for monthly and daily fields
    if ismember(S(k0).iso,currEM)
        prfxM  = 's';   prfxD  = 'ds';
    else
        prfxM  = 'n';   prfxD  = 'dn';
    end
    
    % Monthly data
    fldname = fnames{contains(fnames,[prfxM '_blncd'])};        % field for monthly data
    mats    = S(k0).(fldname)(1,2:end);                       	% original maturities
    datesM  = S(k0).(fldname)(2:end,1);                         % monthly dates
    yieldsM = S(k0).(fldname)(2:end,2:end);                     % monthly yields
    nobsM   = size(yieldsM,1);                                  % #monthly observations
    muM     = mean(yieldsM);                                    % average of monthly yields per maturity
    
    % Smoothed state
    xsM = S(k0).(fnameq).xs;
    if size(xsM,2) == nobsM; xsM = xsM'; end                    % ensure xs dimensions are the same as yields
    
    % Implied weights from smoothed state using least-squares
    if ~ismember(S(k0).iso,intctrs)
        Wm   = (yieldsM'*yieldsM)\yieldsM'*xsM;                	% no intercept
    else
        X    = [ones(nobsM,1) yieldsM];
        Wmls = (X'*X)\X'*xsM;
        Wmc  = Wmls(1,:);                                       % intercepts
        Wm   = Wmls(2:end,:);
    end
    
    % Daily pricing factors
    fldname = fnames{contains(fnames,[prfxD '_blncd'])};        % field for daily data
    datesD  = S(k0).(fldname)(2:end,1);                        	% daily dates
    yieldsD = S(k0).(fldname)(2:end,2:end);                     % daily yields
    nobsD   = size(yieldsD,1);                                	% #daily observations
    if ~ismember(S(k0).iso,intctrs)
        xsD2 = yieldsD*Wm;
    else
        xsD2 = repmat(Wmc,nobsD,1) + yieldsD*Wm;
    end
    
    % Fitted yields
    cSgm  = S(k0).(fnameq).cSgm;    Hcov  = cSgm*cSgm';       	% estimated parameters
    mu_xQ = S(k0).(fnameq).mu_xQ;   PhiQ  = S(k0).(fnameq).PhiQ;
    rho0  = S(k0).(fnameq).rho0;    rho1  = S(k0).(fnameq).rho1;
    [AnQ,BnQ] = loadings(mats,mu_xQ,PhiQ,Hcov,rho0,rho1,1/12);	% loadings using original maturities 
    yieldsQ   = (ones(nobsD,1)*AnQ + xsD2*BnQ)*100;          	% fitted daily yields in percent
    yieldsD   = yieldsD*100;                                    % observed daily yields in percent
    
    % Assess fit of the model
    mtxmae(k0,ismember(matsall,mats)) = mean(abs(yieldsD - yieldsQ))*100;   % mean absolute errors in bp
    mtxsae(k0,ismember(matsall,mats)) = std(abs(yieldsD - yieldsQ))*100;    % std of absolute errors in bp
    S(k0).('db_rmse') = sqrt(mean(mean((yieldsD - yieldsQ).^2)));           % RMSE
    
    if plotfit
        if ismember(S(k0).iso,currEM)
            if k0 == 1; figure; end
            subplot(3,5,k0);
            plot(datesD,yieldsD(:,end),datesD,yieldsQ(:,end))
            title(S(k0).cty); datetick('x','yy'); yline(0); ylabel('%');
        else
            if k0 == nEMs+1; figure; end
            subplot(2,5,k0-nEMs);
            plot(datesD,yieldsD(:,end),datesD,yieldsQ(:,end))
            title(S(k0).cty); datetick('x','yy'); yline(0); ylabel('%');
        end 
    end
end
