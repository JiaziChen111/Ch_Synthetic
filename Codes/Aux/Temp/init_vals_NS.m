function init_vals = init_vals_NS(YCtype,params0,tnrs1,ydataLC,options,...
    id,date,data_month,hdr_month)
% This function gives initial values to fit the Nelson-Siegel model to local 
% currency (LC) yield curves (used by bestNSfit.m).
% Note: Assumes lb = ub = []. If this change in fit_NS.m, needs to change in here.
% Calls to m-files: none
%
%     INPUTS
% YCtype     - char with the type of LC yield curve to fit (ie risky or risk-free)
% params0    - initial values from US NSS model
% tnrs1      - tenors with data on date l
% ydataLC    - vector of values for different tenors
% options    - options when NSS
% Optional inputs, only when YCtype == 'LCRK'
% id         - IMF code of country
% date       - date for which NS will be used
% data_month - matrix with monthly obs of N-S curves as rows, col1 has dates
% hdr_month  - cell with names for the columns of data_monthly
%
%     OUTPUT
% init_vals  - matrix with initial values for N-S; different values (rows) for all parameters (cols)
%
% Pavel Solís (pavel.solis@gmail.com), October 2018
%%
options1  = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt','Display','off');
params1   = params0([1:3 5]);                                 % Only need beta0 to beta2 and tau1
beta0_alt = mean(ydataLC);
switch YCtype
    case 'LCRF'
        if numel(tnrs1) >= 6                                % Fit NSS model to LC data
            params2 = lsqcurvefit(@y_NSS,params0,tnrs1,ydataLC,[],[],options);
        else
            params2 = lsqcurvefit(@y_NSS,params0,tnrs1,ydataLC,[],[],options1); 
        end
        params2   = params2([1:3 5]);                       % Initial values from LC NSS model
        params3   = [beta0_alt params1(2:end)];                   % Use mean instead of params1(1)
        init_vals = [params0(1:4); params1; params2; params3]; % Alt: [params1; params2; params3];
    case 'LC'
        fltrPRM   = ismember(hdr_month(:,1),'LCRFPARAM');   % Use parameters from risk-free LC
        fltrCTY   = data_month(:,2) == id;
        params    = data_month(fltrCTY,fltrPRM);            % Used for plots
        [~,l]     = min(abs(data_month(fltrCTY,1) - date)); % Closest datenum to 'date'
        params2   = params(l,:);
        params3   = [beta0_alt params2(2:end)];
        init_vals = [params2; params3];
        if id == 578
%             init_vals = [[beta0_alt params1(2:end)]; init_vals];
            init_vals = [[beta0_alt params1(2:end)]; params2];
        end
end