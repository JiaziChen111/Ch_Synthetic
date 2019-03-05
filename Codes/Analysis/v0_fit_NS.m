%% Fit Nelson-Siegel Model
% This code fits the Nelson-Siegel model to points of the local currency (LC)
% default-free yield curve.
% Assumes that read_data.m has already been run.
% Calls to m-files: y_NS.m, y_NSS.m, bestNSfit.m, special_cases.m, curr2imf.m
%
% Pavel Solís (pavel.solis@gmail.com), April/September 2018
%%
% Filters 
options    = optimoptions('lsqcurvefit','Display','off'); lb = []; ub = [];
options1   = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt','Display','off');
fltrLCRF   = ismember(header_daily(:,2),'LCRF');      % 1 if LCRF data, even if no LC data (BRL)
fltrPRM    = ismember(header_daily(:,2),'PARAMETER'); % 1 for US NSS model parameters
tnrmax     = 10;                                      % Maximum tenor needed is 10yrs
maturities = [0.25 1:tnrmax];                         % Maturities wanted
ncountries = numel(ctrsLC);
times      = linspace(0,tnrmax);

% Construct the database of risk-free LC yield curves
dataset_lcrf = [];
for k = 1:ncountries                           % When working with a particular country, adjust here
    crncy  = ctrsLC{k};
    id     = curr2imf(crncy);                   % Need numeric values to reference countries
    dataset_aux = [];  flag_rmse = [];  flag_3mo = [];

    % Available tenors per country
    fltrYLD  = ismember(header_daily(:,1),crncy) & fltrLCRF; % Country + LC data
    tnrs     = header_daily(fltrYLD,5);
    tnrs     = cellfun(@str2num,tnrs,'UniformOutput',false);
    tnrs     = cell2mat(tnrs);                      % Tenors available

    % End of month data (FOR LATER: Do the same to extract monthly LCCS and append it to dataset_lcrf)
    idxDates = sum(~isnan(dataset_daily(:,fltrYLD)),2) > 4; 
    data_lc  = dataset_daily(idxDates,:);                 % Rows with at least 5 data points for NS
%     idxEndMo = [diff(day(data_lc(:,1))); -1] < 0;         % Can be deleted
%     data_lc  = data_lc(idxEndMo,:);                       % Can be deleted
    data_lc  = end_of_month(data_lc);
    nobs     = size(data_lc,1);

    % Address special cases
    [data_lc,dropped] = special_cases(fltrYLD,data_lc,tnrs,crncy);

    for l = 1:nobs                                  % When working in a particular month, adjust here
        % Available data may fluctuate between 5 and numel(tnrs)
        date      = data_lc(l,1);
        ydataLC   = data_lc(l,fltrYLD)';            % Column vector
        idxY      = ~isnan(ydataLC);                % sum(idxY) >= 5, see above
        ydataLC   = ydataLC(idxY);
        tnrs1     = tnrs(idxY);                     % Tenors for which there is data
        % if ydataLC(end-1) <= 0; disp(l); end      % To identify values close to zero

        % Get initial values
        params0   = data_lc(l,fltrPRM);             % Initial values from US NSS model
        params1   = params0([1:3 5]);               % Only need beta0 to beta2 and tau1
        if numel(tnrs1) >= 6
            params2   = lsqcurvefit(@y_NSS,params0,tnrs1,ydataLC,lb,ub,options);
        else
            params2   = lsqcurvefit(@y_NSS,params0,tnrs1,ydataLC,lb,ub,options1); 
        end
        params2   = params2([1:3 5]);               % Initial values from LC NSS model
        params3   = [mean(ydataLC) params1(2:end)]; % Use mean instead of params1(1)
        %init_vals = [params1; params2; params3];
        init_vals = [params0(1:4); params1; params2; params3];

        % Best fit of NS model based on the initial values
        [params,rmse] = bestNSfit(init_vals,tnrs1,ydataLC,lb,ub,options);

        % Extract implied yields from estimated NS model and save them
        yields      = y_NS(params,maturities);
        dataset_aux = [dataset_aux; date, id, yields, params, rmse];

% Uncomment to address special cases
        % Flag special cases and suggest potential solutions
        if rmse > 5                               % Potential outliers
            yrs2drop = suggest_yrs2drop(init_vals,tnrs1,ydataLC,lb,ub,options);
            flag_rmse = [flag_rmse; l yrs2drop]; 
        end  
        if (yields(1) < 0) || (yields(1) > 40)    % Abnormal 3m implied yield, can adjust limits
            yrs2drop = suggest_yrs2drop(init_vals,tnrs1,ydataLC,lb,ub,options);
            flag_3mo = [flag_3mo; l yrs2drop]; 
        end

        % Plot yields: actual, dropped, LC NS, US NSS
        plot(tnrs1,ydataLC,'ko',dropped(l,1),dropped(l,2),'go',...
            times,y_NS(params,times),'r-',times,y_NSS(params0,times),'b-')
        title([crncy '  ' datestr(date)])
        H(l) = getframe(gcf);                     % To see frames individually use: imshow(H(2).cdata)
    end
    dataset_lcrf = [dataset_lcrf; dataset_aux];
end

% Earliest date per country (Comment section when addressing special cases)
IDs      = unique(dataset_lcrf(:,2),'stable');  % Countries in the database
idx1stMo = [1; diff(dataset_lcrf(:,2))] ~= 0;   % Find first month per country
init_mo  = dataset_lcrf(idx1stMo,1);            % First months as datenum
first_mo = [ctrsLC cellstr(datestr(init_mo))];  % Countries + First months

% Headers
ctrsNcods = [ctrsLC cellstr(num2str(IDs))];     % Countries and their codes
tnrs      = pnum2cell(maturities(2:end));       % Cell with all the tenors (starting 1yr) as strings
tnrs3mo   = [{'0.25'}; tnrs];
name_ycrf = strcat('DEFAULT-FREE LC N-S YIELD CURVE',{' '},tnrs3mo,' YR');
paramsNS  = {'BETA0';'BETA1';'BETA2';'TAU'};
hdr_ycrf  = construct_hdr('LCRFNS',name_ycrf,tnrs3mo);
hdr_param = construct_hdr('PARAMLCRF','DEFAULT-FREE LCRF N-S YIELD CURVE',paramsNS);
hdr_rmse1 = construct_hdr('RMSELCRF','DEFAULT-FREE LCRF N-S FIT RMSE','X');
hdr_lcrf  = [{'type','description','tenor'; 'IMFC','IMF CODE','X'};
            hdr_ycrf; hdr_param; hdr_rmse1];

clear k l lb ub id fltr* tnrs1 params* idx* fig date options* times maturities y* crncy
clear dataset_aux dropped init_* ncountries nobs name_* hdr_y* hdr_p* hdr_rm* paramsNS
clear flag_* rmse tnrmax                         % Uncomment only after done addressing special cases
beep
%% Sources
%
% Last available trading day per month
% https://www.mathworks.com/matlabcentral/answers/...
% 389091-how-to-remove-daily-data-and-leave-the-last-day-of-each-month