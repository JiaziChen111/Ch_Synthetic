ncntrs  = length(S);
nEMs    = length(currEM);
matsall = [0.25 0.5 1:10];                                      % all possible maturities
mtxmae  = nan(ncntrs,length(matsall));  mtxsae = nan(ncntrs,length(matsall)); %fit using absolute errors
fnames  = fieldnames(S);
fnameq  = fnames{contains(fnames,'bsl_pr')};                    % field containing estimated parameters
p       = 3;                                                    % number of pricing factors
nolscts = setdiff(currEM,{'ILS','ZAR'});%{'HUF','MYR','PHP','THB','TRY'};                      % countries using W not from least squares

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
    % plot(yieldsM(:,1),xsM(:,1),'o') % relationship b/w short rate and PC1 is highly linear when no surveys
    
    % Principal components of smoothed state
    [xsMW,xsMPC,~,~,xsMpcaExp] = pca(xsM);
    xsMPC2 = xsM*xsMW - repmat(mean(xsM),nobsM,1)*xsMW;         % xsMPC2 == xsMPC
    xsM2   = xsMPC*xsMW' + repmat(mean(xsM),nobsM,1);           % xsM2   == xsM
    xsMPCd = xsMPC*xsMW';                                       % demeaned
    % subplot(3,1,1); plot(datesM,xsM2(:,1),datesM,xsM(:,1))
    % subplot(3,1,2); plot(datesM,xsM2(:,2),datesM,xsM(:,2))
    % subplot(3,1,3); plot(datesM,xsM2(:,3),datesM,xsM(:,3))
    % plot(yieldsM(:,1),xsMPC(:,1),'o') % relationship b/w short rate and PCPC1 is linear when survey data
    
    % Implied weights from smoothed state
    if ~ismember(S(k0).iso,nolscts)
        % Wm2 = pinv(yieldsM)*xsM;                              % Moore-Penrose inverse, same as LS
        % Wm2 = (yieldsM'*yieldsM)\yieldsM'*(xsMPC*xsMW'+repmat(mean(xsM),nobsM,1));%same as LS (xsM2==xsM)
        Wm2 = (yieldsM'*yieldsM)\yieldsM'*xsM;                	% least-squares using smoothed state
    else
        X = [ones(nobsM,1) yieldsM];
        Wm2ls = (X'*X)\X'*xsMPCd;
%         Wm2 = (yieldsM'*yieldsM)\yieldsM'*(xsMPC*xsMW');        % least-squares using PCs of smoothed state
%         Wm21 = fitlm(yieldsM,xsMPCd(:,1));
%         Wm22 = fitlm(yieldsM,xsMPCd(:,2));
%         Wm23 = fitlm(yieldsM,xsMPCd(:,3));
%         Wm2  = [Wm21.Coefficients{2:end,1} Wm22.Coefficients{2:end,1} Wm23.Coefficients{2:end,1}];
%         Wm2c = [Wm21.Coefficients{1,1} Wm22.Coefficients{1,1} Wm23.Coefficients{1,1}]; % constants
        Wm2 = Wm2ls(2:end,:);
        Wm2c = Wm2ls(1,:);
%         plot(f,yieldsM(:,1),xsMPC*xsMW'(:,1))
    end
    
    % Daily pricing factors
    fldname = fnames{contains(fnames,[prfxD '_blncd'])};        % field for daily data
    datesD  = S(k0).(fldname)(2:end,1);                        	% daily dates
    yieldsD = S(k0).(fldname)(2:end,2:end);                     % daily yields
    nobsD   = size(yieldsD,1);                                	% #daily observations
    if ~ismember(S(k0).iso,nolscts)
        xsD2 = yieldsD*Wm2;
    else
        xsD2 = repmat(Wm2c,nobsD,1) + yieldsD*Wm2 + repmat(mean(xsM),nobsD,1);
    end
    
    % Fitted yields
    cSgm  = S(k0).(fnameq).cSgm;    Hcov  = cSgm*cSgm';       	% estimated parameters
    mu_xQ = S(k0).(fnameq).mu_xQ;   PhiQ  = S(k0).(fnameq).PhiQ;
    rho0  = S(k0).(fnameq).rho0;    rho1  = S(k0).(fnameq).rho1;
    [AnQ,BnQ] = loadings(mats,mu_xQ,PhiQ,Hcov,rho0,rho1,1/12);	% loadings using original maturities 
    yieldsQ   = (ones(nobsD,1)*AnQ + xsD2*BnQ)*100;          	% fitted daily yields in percent
    yieldsD   = yieldsD*100;                                    % observed daily yields in percent
    
    % Fit of the model
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

%%
% % PCs
% mumtxM  = repmat(muM,nobsM,1);
% Zm      = yieldsM - mumtxM;                                   % demeaned monthly yields
% [Wm1,aux] = pca(yieldsM,'NumComponents',p);
% PCs = aux + mumtxM*Wm1;                                       % non-demeaned PCs
% Wm2 = pinv(Zm)*xsM;
% Wm2 = yieldsM\xsM;

% % Compare PCs from PCA vs implied by smoothed state
% if plotfit
%     if ismember(S(k0).iso,currEM)
%         if k0 == 1; figure; end
%         subplot(3,5,k0);
%         plot(datesM,PCs(:,1),datesM,xsM(:,1))
%         title(S(k0).cty); datetick('x','yy'); yline(0);
%     else
%         if k0 == nEMs+1; figure; end
%         subplot(2,5,k0-nEMs);
%         plot(datesM,PCs(:,1),datesM,xsM(:,1))
%         title(S(k0).cty); datetick('x','yy'); yline(0);
%     end 
% end
% % Conclusion: PCs from pca (non-demeaned) == PCs from estimation

% % Compare weights from PCA vs implied by smoothed state
% nmats = length(mats);
% if plotfit
%     if ismember(S(k0).iso,currEM)
%         if k0 == 1; figure; end
%         subplot(3,5,k0);
%         plot(1:nmats,Wm1(:,3),1:nmats,Wm2(:,3))
%         title(S(k0).cty); yline(0);
%     else
%         if k0 == nEMs+1; figure; end
%         subplot(2,5,k0-nEMs);
%         plot(1:nmats,Wm1(:,3),1:nmats,Wm2(:,3))
%         title(S(k0).cty); yline(0);
%     end 
% end
% % Conclusion: weights from pca != weights from estimation, ~= for AEs but != for EMs

% % Compare reconstructed PCs from Wm2 vs xsM
% PCs2 = yieldsM*Wm2;     % when Wm2 = pinv(yieldsM)*xsM;
% PCs2 = yieldsM*((yieldsM'*yieldsM)\yieldsM'*(xsMPC*xsMW'+repmat(mean(xsM),nobsM,1)));%same as yieldsM*Wm2
% PCs2 = yieldsM*((yieldsM'*yieldsM)\yieldsM'*(xsMPC*xsMW')) + repmat(mean(xsM),nobsM,1); % PCs2 == xsM
% nPC = 1;
% if plotfit
%     if ismember(S(k0).iso,currEM)
%         if k0 == 1; figure; end
%         subplot(3,5,k0);
%         plot(datesM,PCs2(:,nPC),datesM,xsM(:,nPC))
%         title(S(k0).cty); datetick('x','yy'); yline(0);
%     else
%         if k0 == nEMs+1; figure; end
%         subplot(2,5,k0-nEMs);
%         plot(datesM,PCs2(:,nPC),datesM,xsM(:,nPC))
%         title(S(k0).cty); datetick('x','yy'); yline(0);
%     end 
% end
% % Conclusion: reconstructed PCs from Wm2 ~= xsM when Wm2 = pinv(yieldsM)*xsM; 
% need to find Wm2 so that reconstructed PCs == xsM
% % when Wm2 is calculated using the PCs from xsM, reconstructed PCs == xsM

% Daily estimates of pricing factors
% mumtxD  = repmat(muM,nobsD,1);
% xsD1     = yieldsD*Wm1 - mumtxD*Wm1;
% xsD1     = yieldsD*Wm1;              % works for nominal and synthetic yields when no survey data
% xsD2     = yieldsD*Wm2 - mumtxD*Wm2;
    
% Wpca = pca(yieldsD,'NumComponents',p);
% xsD2 = yieldsD*Wpca;