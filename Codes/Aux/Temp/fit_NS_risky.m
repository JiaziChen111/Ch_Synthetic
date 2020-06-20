%% Fit Nelson-Siegel Model
% This code fits the Nelson-Siegel model to points of the local currency (LC)
% yield curve WITH default risk.
% Assumes that read_data.m has already been run
% Calls to m-files: y_NS.m, y_NSS.m, bestNSfit.m, special_cases.m, curr2imf.m
%
Need to be done:
ensure same dates in in dataset_lcrsky as in dataset_lcrf
use as params2 here the params2 from fit_NS.m (instead of using US NSS to yields_blp)
plot the US yc, the rf LC yc, the risky LC yc
identify special cases in risky LC yc



% Pavel Solís (pavel.solis@gmail.com), April 2018
%%
% Filters 
options    = optimoptions('lsqcurvefit','Display','off'); lb = []; ub = [];
options1   = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt','Display','off');
fltrLCrsky   = ismember(header(:,2),'LC');      % 1 for countries with LC data
fltrPRM    = ismember(header(:,2),'PARAMETER'); % 1 for US NSS model parameters
maturities = [0.25 1:10];                       % Maturities wanted
ncountries = numel(ctrsLC);
times      = linspace(0,10);

dataset_lcrsky = [];
for k = 1:ncountries
    crncy  = ctrsLC{k};
    id     = curr2imf(crncy);
    dataset_aux = [];  flag_ssr = [];  flag_3mo = [];

    % Available tenors per country
    fltrYLD  = ismember(header(:,1),crncy) & fltrLCrsky; % Country + LC data
    tnrs     = header(fltrYLD,5);
    tnrs     = cellfun(@str2num,tnrs,'UniformOutput',false);
    tnrs     = cell2mat(tnrs);                      % Tenors available

    % End of month data
    idxDates = sum(~isnan(dataset(:,fltrYLD)),2) > 4; 
    data_lc_blp  = dataset(idxDates,:);                 % Rows with at least 5 data points for NS
    idxEndMo = [diff(day(data_lc_blp(:,1))); -1] < 0;   % 1 if last day of month; keep last obs
    data_lc_blp  = data_lc_blp(idxEndMo,:);                 % Last available trading day per month
    nobs     = size(data_lc_blp,1);

%     % Address special cases
%     [data_lc_blp,dropped] = special_cases(fltrYLD,data_lc_blp,tnrs,crncy);

    for l = 1:nobs
        % Available data may fluctuate between 5 and numel(tnrs)
        date      = data_lc_blp(l,1);
        ydataLCrsky   = data_lc_blp(l,fltrYLD)';            % Column vector
        idxY      = ~isnan(ydataLCrsky);                % sum(idxY) >= 5, see above
        ydataLCrsky   = ydataLCrsky(idxY);
        tnrs1     = tnrs(idxY);                     % Tenors for which there is data

        % Get initial values
        params0   = data_lc_blp(l,fltrPRM);             % Initial values from US NSS model
        params1   = params0([1:3 5]);               % Only need beta0 to beta2 and tau1
        if numel(tnrs1) >= 6
            params2   = lsqcurvefit(@y_NSS,params0,tnrs1,ydataLCrsky,lb,ub,options);
        else
            params2   = lsqcurvefit(@y_NSS,params0,tnrs1,ydataLCrsky,lb,ub,options1); 
        end
        params2   = params2([1:3 5]);               % Initial values from LC NSS model
        params3   = [mean(ydataLCrsky) params1(2:end)]; % Use mean instead of params1(1)
        init_vals = [params1; params2; params3];

        % Best fit of NS model based on the initial values
        [params,rmse] = bestNSfit(init_vals,tnrs1,ydataLCrsky,lb,ub,options);

        % Extract implied yields from estimated NS model and save them
        yields      = y_NS(params,maturities);
        dataset_aux = [dataset_aux; date, id, yields, params, rmse];

        % Flag special cases and suggest potential solutions
        if rmse > sqrt(5/nobs)                                  % Potential outliers
            yrs2drop = suggest_yrs2drop(init_vals,tnrs1,ydataLCrsky,lb,ub,options);
            flag_ssr = [flag_ssr; l yrs2drop]; 
        end  
        if (yields(1) < -10) || (yields(1) > 40)    % Abnormal 3m implied yield
            yrs2drop = suggest_yrs2drop(init_vals,tnrs1,ydataLCrsky,lb,ub,options);
            flag_3mo = [flag_3mo; l yrs2drop]; 
        end

        % Plot yields: actual, dropped, LC NS, US NSS
        plot(tnrs1,ydataLCrsky,'ko',...
            times,y_NS(params,times),'r-',times,y_NSS(params0,times),'b-')
        title([crncy '  ' datestr(date)])
        H(l) = getframe(gcf);                       % Save plots to see them in sequence
    end
    dataset_lcrsky = [dataset_lcrsky; dataset_aux];
end

% Earliest date per country
IDsrsky      = unique(dataset_lcrsky(:,2),'stable');  % Countries in the database
idx1stMoRsky = [1; diff(dataset_lcrsky(:,2))] ~= 0;   % Find first month per country
init_mo_rsky  = dataset_lcrsky(idx1stMoRsky,1);            % First months as datenum
first_mo_rsky = [ctrsLC cellstr(datestr(init_mo_rsky))];  % Countries + First months

clear k l lb ub id fltr* tnrs* params* ssr* idx* fig date options* times
clear maturities dataset_aux crncy dropped init_* ncountries nobs %y*
beep
%% Sources
%
% Last available trading day per month
% https://www.mathworks.com/matlabcentral/answers/...
% 389091-how-to-remove-daily-data-and-leave-the-last-day-of-each-month