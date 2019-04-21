function [dataset_lc,hdr_lc,ctrsNcods,first_mo,flag_rmse,flag_3mo] = daily2monthly(dataset_daily,...
    header_daily,YCtype,S)
% This function fits the Nelson-Siegel model to local currency (LC) yield
% curves (for different dates and for different countries).
% Assumes that read_data.m has already been run.
% Calls to m-files: init_vals_NS.m, y_NS.m, y_NSS.m, bestNSfit.m, special_cases.m,
% curr2imf.m, construct_monthly_hdr.m, date_first_obs.m
%
%     INPUTS
% dataset_daily - matrix with daily obs as rows (top-down is first-last obs), col1 has dates
% header_daily  - cell with names for the columns of dataset_daily
% YCtype        - char with the type of LC yield curve to fit (ie risky or risk-free)
% S - structure with names of countries and currencies, letter and digit codes
%
%     OUTPUT
% dataset_lc - matrix with end-of-month fitted yields for specified maturities
% hdr_lc     - cell with names for the columns of dataset_lc
% ctrsNcods  - cell with countries (with estimated NS curve) and respective IMF codes
% first_mo   - cell with first month of data per country
% flag_*     - flags are useful when addressing special cases
%
% Pavel Solís (pavel.solis@gmail.com), April/October 2018
%%
% Filters and variables
% options    = optimoptions('lsqcurvefit','Display','off'); lb = []; ub = [];
% options1   = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt','Display','off');
fltrLC     = ismember(header_daily(:,2),YCtype);      % 1 if LC/LCSYNT data
% fltrPRM    = ismember(header_daily(:,2),'PARAMETER'); % 1 for US NSS model parameters
% aux1 = struct2cell(S)';
% aux2 = fieldnames(S);
% curncs = aux1(:,strcmp(aux2,'iso'));              % Extract iso currency codes
ncntrs = length(S);%numel(curncs);

tnrs_all    = [0; cellfun(@str2num,header_daily(2:end,5))];
% fltrMTY = ~ismember(header_daily(:,2),'OIS') & ~ismember(header_daily(:,2),'FFF') & ...
%     ~isnan(tnrs_all) & tnrs_all > 0;
% mtrts   = unique(tnrs_all(fltrMTY));
% times   = linspace(0,max(tnrs_all));                      % Used for plots

% Construct the database of LC yield curves
dataset_lc = [];
for k = 1:ncntrs                                  % Adjust here when working with one country
    crncy = S(k).iso;
%     id = S(k).imf;

    % Available tenors per country
    fltrYLD = ismember(header_daily(:,1),crncy) & fltrLC;   % Country + LC data
    tnrs    = tnrs_all(fltrYLD);                            % Tenors available

    % End-of-month data
    idxDates = sum(~isnan(dataset_daily(:,fltrYLD)),2) > 4; 
    fltrYLD(1) = true;                                      % To include dates
    data_lc  = dataset_daily(idxDates,fltrYLD);             % Keep rows with at least 5 observations
    [data_lc,first_obs] = end_of_month(data_lc);            % Keep end-of-month observations
    S(k).start = datestr(first_obs,'mmm-yyyy');             % First monthly observation
    S(k).lcsynt = [0 tnrs'; data_lc];

    % dates = data_lc(:,1);
% yields = data_lc(:,2:end);
% 
% dates = dates(80:end);
% yields = yields(80:end,:);
% nobs = size(yields,1);
% mats = tnrs';

[coeff1,score1,~,~,~,mu1] = pca(yields,'algorithm','als');
reconstrct = score1*coeff1' + repmat(mu1,nobs,1);
% W = coeff1;

%     % Address special cases
%     if strcmp(YCtype,'LCRF')
%         [data_lc,dropped] = special_cases_rf(fltrYLD,data_lc,tnrs,crncy);
%     elseif strcmp(YCtype,'LC')
%         [data_lc,dropped] = special_cases_rk(fltrYLD,data_lc,tnrs,crncy);
%     end
    
    % Fit NS curve per date
%     dataset_aux = [];  flag_rmse = [];  flag_3mo = [];
    for l = 1:nobs                                  % Adjust here when working in one month
        % Tenors available may fluctuate between 5 and numel(tnrs)
        date    = data_lc(l,1);
        ydataLC = data_lc(l,fltrYLD)';                      % Column vector
        idxY    = ~isnan(ydataLC);                          % sum(idxY) >= 5, see above
        ydataLC = ydataLC(idxY);
        tnrs1   = tnrs(idxY);                               % Tenors with data on date l
        ntnrs(l)= numel(tnrs1);
        if     l == 1
            S(k).ntnrsI = numel(tnrs1);
        elseif l == nobs
            S(k).ntnrsL = numel(tnrs1);
        end

%         % Get initial values
%         params0   = data_lc(l,fltrPRM);             % Initial values from US NSS model
%         if     strcmp(YCtype,'LCRF')
%             init_vals = init_vals_NS(YCtype,params0,tnrs1,ydataLC,options);
%         elseif strcmp(YCtype,'LC')
%             init_vals = init_vals_NS(YCtype,params0,[],ydataLC,[],id,date,data_month,hdr_month);
%         end
% 
%         % Best fit of NS model based on the initial values
%         [params,rmse] = bestNSfit(init_vals,tnrs1,ydataLC,lb,ub,options);
% 
%         % Extract implied yields from estimated NS model and save them
%         yields      = y_NS(params,mtrts);
%         dataset_aux = [dataset_aux; date, id, yields, params, rmse];
% 
% % Uncomment to address special cases
%         hdr_lc = []; ctrsNcods = []; first_mo = [];
%         % Flag special cases and suggest potential solutions
%         if rmse > 3                               % Potential outliers, can adjust limit
%             yrs2drop  = suggest_yrs2drop(init_vals,tnrs1,ydataLC,lb,ub,options);
%             flag_rmse = [flag_rmse; l yrs2drop]; 
%         end  
%         if (yields(1) < 0) || (yields(1) > 30)    % Abnormal 3m implied yield, can adjust limits
%             yrs2drop = suggest_yrs2drop(init_vals,tnrs1,ydataLC,lb,ub,options);
%             flag_3mo = [flag_3mo; l yrs2drop]; 
%         end

%         % Plot yields: actual, dropped, LC NS, US NSS
%         plot(tnrs1,ydataLC)
% %         plot(tnrs1,ydataLC,'ko',dropped(l,1),dropped(l,2),'go',...
% %             times,y_NS(params,times),'r-',times,y_NSS(params0,times),'b-')
%         title([crncy '  ' datestr(date)]), ylabel('%'), xlabel('Maturity')
        plot(mats,yields(l,:)','o',mats,yields_mKF(l,:)','x')
        title([crncy '  ' datestr(dates(l))]), ylabel('%'), xlabel('Maturity')
        H(l) = getframe(gcf);                               % To see individual frames: imshow(H(2).cdata)
    end
%     dataset_lc = [dataset_lc; dataset_aux];
% figure
% plot(ntnrs)
% title(S(k).cty)
end

% Comment next lines when addresing special cases
% Header
% hdr_lc    = construct_monthly_hdr(mtrts,YCtype,1);

% beep

% S = rmfield(S,{'tnrsF','tnrsL'});