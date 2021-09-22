function [dataset_lc,hdr_lc,ctrsNcods,first_mo,flag_rmse,flag_3mo] = fit_NS(dataset_daily,...
    header_daily,YCtype,data_month,hdr_month)
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
% data_month    - either data_month or dataset_mth, only needed for init_vals_NS.m
% hdr_month     - cell with names for data_month
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
options    = optimoptions('lsqcurvefit','Display','off'); lb = []; ub = [];
% options1   = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt','Display','off');
fltrLC     = ismember(header_daily(:,2),YCtype);      % 1 if LC/LCRF data
fltrPRM    = ismember(header_daily(:,2),'PARAMETER'); % 1 for US NSS model parameters
ctrsLC     = unique(header_daily(fltrLC,1),'stable'); % Countries with LC data
ncountries = numel(ctrsLC);
tnrmax     = 10;                                      % Maximum tenor needed is 10yrs
maturities = [0.25 1:tnrmax];                         % Maturities wanted for N-S
times      = linspace(0,tnrmax);                      % Used for plots

% Construct the database of LC yield curves
dataset_lc = [];
for k = 1:ncountries                                  % Adjust here when working with one country
    crncy = ctrsLC{k};
    id    = curr2imf(crncy);                          % Need numeric values to reference countries

    % Available tenors per country
    fltrYLD  = ismember(header_daily(:,1),crncy) & fltrLC; % Country + LC data
    tnrs     = header_daily(fltrYLD,5);
    tnrs     = cellfun(@str2num,tnrs,'UniformOutput',false);
    tnrs     = cell2mat(tnrs);                        % Tenors available

    % End of month data
    idxDates = sum(~isnan(dataset_daily(:,fltrYLD)),2) > 4; 
    data_lc  = dataset_daily(idxDates,:);             % Rows with at least 5 data points for NS
    data_lc  = end_of_month(data_lc);
    nobs     = size(data_lc,1);

    % Address special cases
    if strcmp(YCtype,'LCRF')
        [data_lc,dropped] = special_cases_rf(fltrYLD,data_lc,tnrs,crncy);
    elseif strcmp(YCtype,'LC')
        [data_lc,dropped] = special_cases_rk(fltrYLD,data_lc,tnrs,crncy);
    end
    
    % Fit NS curve per date
    dataset_aux = [];  flag_rmse = [];  flag_3mo = [];
    for l = 1:nobs                                  % Adjust here when working in one month
        % Available data may fluctuate between 5 and numel(tnrs)
        date      = data_lc(l,1);
        ydataLC   = data_lc(l,fltrYLD)';            % Column vector
        idxY      = ~isnan(ydataLC);                % sum(idxY) >= 5, see above
        ydataLC   = ydataLC(idxY);
        tnrs1     = tnrs(idxY);                     % Tenors with data on date l

        % Get initial values
        params0   = data_lc(l,fltrPRM);             % Initial values from US NSS model
        if     strcmp(YCtype,'LCRF')
            init_vals = init_vals_NS(YCtype,params0,tnrs1,ydataLC,options);
        elseif strcmp(YCtype,'LC')
            init_vals = init_vals_NS(YCtype,params0,[],ydataLC,[],id,date,data_month,hdr_month);
        end

        % Best fit of NS model based on the initial values
        [params,rmse] = bestNSfit(init_vals,tnrs1,ydataLC,lb,ub,options);

        % Extract implied yields from estimated NS model and save them
        yields      = y_NS(params,maturities);
        dataset_aux = [dataset_aux; date, id, yields, params, rmse];

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

        % Plot yields: actual, dropped, LC NS, US NSS
        plot(tnrs1,ydataLC,'ko',dropped(l,1),dropped(l,2),'go',...
            times,y_NS(params,times),'r-',times,y_NSS(params0,times),'b-')
        title([crncy '  ' datestr(date)])
        H(l) = getframe(gcf);                     % To see individual frames: imshow(H(2).cdata)
% %%
    end
    dataset_lc = [dataset_lc; dataset_aux];
end

% Comment next lines when addresing special cases
% Header
hdr_lc    = construct_monthly_hdr(maturities,YCtype,1);

% Countries in the database and codes
IDs       = unique(dataset_lc(:,2),'stable');
ctrsNcods = [ctrsLC num2cell(IDs)];

% Earliest date per country (Comment section when addressing special cases)
init_mo   = date_first_obs(dataset_lc);
first_mo  = [ctrsLC cellstr(datestr(init_mo))];  % Countries + First months

beep
%% Sources
%
% Last available trading day per month
% https://www.mathworks.com/matlabcentral/answers/...
% 389091-how-to-remove-daily-data-and-leave-the-last-day-of-each-month

%     dropped  = nan(nobs,2);                         % Needed while no special_cases_rk.m
%         params1   = params0([1:3 5]);               % Only need beta0 to beta2 and tau1
%         if numel(tnrs1) >= 6                        % Fit NSS model to LC data
%             params2 = lsqcurvefit(@y_NSS,params0,tnrs1,ydataLC,lb,ub,options);
%         else
%             params2 = lsqcurvefit(@y_NSS,params0,tnrs1,ydataLC,lb,ub,options1); 
%         end
%         params2   = params2([1:3 5]);               % Initial values from LC NSS model
%         params3   = [mean(ydataLC) params1(2:end)]; % Use mean instead of params1(1)
%         init_vals = [params0(1:4); params1; params2; params3]; % Alt: [params1; params2; params3];

% idx1stMo  = [1; diff(dataset_lc(:,2))] ~= 0;     % Find first month per country
% init_mo   = dataset_lc(idx1stMo,1);              % First months as datenum

