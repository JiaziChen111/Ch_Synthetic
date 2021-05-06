%% Estimate Risk Premia using Risk-Free LC Yield Curves
% This code estimates risk premia using the synthetic yield curves generated
% by fit_NS.m (assumes that code has already been run).
% Calls to m-files: fit_ATSM.m
%
% Pavel Solís (pavel.solis@gmail.com), April/September 2018
%%
fltrYLD     = ismember(hdr_lcrf(:,1),'LCRFNS');
fltrPRM     = ismember(hdr_lcrf(:,1),'PARAMLCRF');
maturities  = [0.25 1:10];                      % Maturities used
maturities1 = 1:10;                             % Number of yields to be estimated
times       = linspace(0,10);                   % Used for plots
pc_exp_aux  = [];
%rp5yr_stats = [];                              % Can be deleted
% dataset_rp = [];                              % Can be deleted

dataset_monthly = [];
for k = 1:numel(IDs)
    id      = IDs(k);
    cty     = ctrsLC{k};                                % May be deleted
    fltrCTY = dataset_lcrf(:,2) == id;
%     fltrYLD = ismember(hdr_lcrf(:,1),'LCRFNS');       % Can be deleted
%     fltrPRM = ismember(hdr_lcrf(:,1),'PARAMLCRF');    % Can be deleted
    ydata   = dataset_lcrf(fltrCTY,fltrYLD);
    params  = dataset_lcrf(fltrCTY,fltrPRM);      % Used for plots
    date    = dataset_lcrf(fltrCTY,1);
    
    % ATSM fitted yields
    [yieldsQ,yieldsP,yieldsE,rmse,explained] = fit_ATSM(maturities1,ydata);
    %risk_premia = yieldsQ - yieldsP;   % obs x maturities1!
    risk_premia = ydata - yieldsE; %= ydata(:,2:end) - yieldsE; When update fit_ATSM ie 10 mats in yields
%     dataset_rp = [dataset_rp; date, repmat(id,size(ydata,1),1), risk_premia];
    dataset_monthly = [dataset_monthly; dataset_lcrf(fltrCTY,:),...
                      yieldsE(:,2:end),yieldsQ,yieldsP,risk_premia(:,2:end),rmse];
    pc_exp_aux      = [pc_exp_aux explained];
    
    % Plot yields: N-S v. Expected v. ATSM
    for l = 1:size(ydata,1)
        plot(times,y_NS(params(l,:),times),'r-',...
            maturities1,yieldsQ(l,:),'c*',maturities1,yieldsP(l,:),'b--o',...
            maturities,yieldsE(l,:),'mx') % [!]
        title([num2str(id) '  ' datestr(date(l))])
        H(l) = getframe(gcf);
    end
    clear H
    close
end

% Header
name_yE   = strcat('DEFAULT-FREE EXPECTED SHORT RATE IN',{' '},tnrs,' YR');
name_yQ   = strcat('DEFAULT-FREE RISK NEUTRAL YIELD',{' '},tnrs,' YR');
name_yP   = strcat('DEFAULT-FREE PHYSICAL YIELD',{' '},tnrs,' YR');
name_rp   = strcat('DEFAULT-FREE RISK PREMIUM',{' '},tnrs,' YR');             
hdr_yE    = construct_hdr('LCRFYE',name_yE,tnrs);
hdr_yQ    = construct_hdr('LCRFYQ',name_yQ,tnrs);
hdr_yP    = construct_hdr('LCRFYP',name_yP,tnrs);
hdr_rprf  = construct_hdr('LCRFRP',name_rp,tnrs);
hdr_rmse2 = construct_hdr('RMSEATSMLCRF','DEFAULT-FREE LCRF ATSM FIT RMSE','X');
header_monthly  = [hdr_lcrf; hdr_yE; hdr_yQ; hdr_yP; hdr_rprf; hdr_rmse2];

% Statistics
fltrYC  = ismember(header_monthly(:,1),'LCRFNS') & ~ismember(header_monthly(:,3),'0.25');
fltrRP  = ismember(header_monthly(:,1),'LCRFRP');
tnrs_rp = cellfun(@str2num,header_monthly(fltrRP,3)); % Convert str into double

for k = 1:numel(IDs)                        % To report all maturities per country
    id      = IDs(k);
    fltrCTY = dataset_lcrf(:,2) == id;
    y       = dataset_monthly(fltrCTY,fltrYC);
    z       = dataset_monthly(fltrCTY,fltrRP);
    stats_rp_cty(:,:,k) = [tnrs_rp'; mean(y); std(y); mean(z); std(z); max(z); min(z); 
               repmat(size(z,1),1,size(z,2))];
end
stats_rp_cty  = round(stats_rp_cty,2);

for l = 1:numel(tnrs_rp)                    % To report all countries per maturity
    stats_rp_mat(:,:,l) = squeeze(stats_rp_cty(:,l,:));
end

pc_exp          = [ctrsLC'; num2cell(round(pc_exp_aux(1:3,:),2));
                  num2cell(round(sum(pc_exp_aux(1:3,:)),2))];
pc_exp(2:end,:) = cellfun(@num2str,pc_exp(2:end,:),'UniformOutput',false); % All entries are strings

clear k l cty date explained fltr* id maturities* params rmse times x y* z
clear name_* hdr_yE hdr_yQ hdr_yP hdr_rprf hdr_rmse2 tnrs_rp risk_* pc_exp_*
