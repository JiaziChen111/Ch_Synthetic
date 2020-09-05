function S = atsm_estimation(S,matsout,sgmSfree,simplex)
% ATSM_ESTIMATION Estimate affine term structure model with monthly data
% and 3 pricing factors
% 
%	INPUTS
% S        - structure with fields mn_ylds and ms_ylds containing nominal 
%            and synthetic bond yields and survey forecasts if available
% matsout  - bond maturities (in years) to be reported
% sgmSfree - logical for whether to estimate sgmS (o/w fixed at 75 bp)
% simplex  - logical for whether to estimate using fminsearch (default) or fminunc
%
%	OUTPUT
% S - structure includes estimated yields under Q and P measures, estimated
% term premia, estimated parameters for nominal and synthetic yield curves
%
% m-files called: estimation_jsz, estimation_svys
% Pavel Solís (pavel.solis@gmail.com), September 2020
%%
addpath(genpath('jsz_code'))
if nargin < 4; simplex = true; end                                          % set fminsearch as default solver
p       = 3;                                                                % number of state vectors
dt      = 1/12;                                                             % time period in years
ncntrs  = length(S);
prefix  = {'mn','ms'};
if sgmSfree; sgmtype = 'f'; else; sgmtype = 'b'; end                        % free vs baseline case

for k0 = 1:length(prefix)
    fldname = [prefix{k0} '_ylds'];
    for k1  = 1:ncntrs
        % Split yields & surveys
        dates  = S(k1).(fldname)(2:end,1);
        ynsvys = S(k1).(fldname)(2:end,2:end);
        mats   = S(k1).(fldname)(1,:);                                      % include first column
        startS = find(mats(2:end) - mats(1:end-1) < 0);                     % position where survey data starts
        mats   = mats(2:end);                                               % remove extra first column
        if isempty(startS)                                                  % only yields in dataset
            matsY = mats(1:end);   matsS = [];
            yonly = ynsvys;
        else
            matsY = mats(1:startS-1);                                       % yield maturities in years
            matsS = mats(startS:end);                                       % survey maturities in years
            yonly = ynsvys(:,1:startS-1);                                   % extract yields
        end
        
        if ~isfield(S,[prefix{k0} 'y_pr'])                                  % JSZ only if not already done
            % Estimate the model using yields only (all countries)
            [ylds_Q,ylds_P,termprm,params0] = estimation_jsz(yonly,matsY,matsout,dt,p);
            S(k1).([prefix{k0} 'y_yQ']) = [nan matsout; dates ylds_Q];
            S(k1).([prefix{k0} 'y_yP']) = [nan matsout; dates ylds_P];
            S(k1).([prefix{k0} 'y_tp']) = [nan matsout; dates termprm];
            S(k1).([prefix{k0} 'y_pr']) = params0;
        else
            params0 = S(k1).([prefix{k0} 'y_pr']);                          % initial values from JSZ
        end
        
        % Estimate the model using yields and surveys
        if ~isempty(matsS)                                                  % only for EMs w/ survey data
            [ylds_Q,ylds_P,termprm,params] = estimation_svys(ynsvys,matsY,matsS,matsout,dt,...
                                                             params0,sgmSfree,simplex);
            
            S(k1).([prefix{k0} 's' sgmtype '_yQ']) = [nan matsout; dates ylds_Q];
            S(k1).([prefix{k0} 's' sgmtype '_yP']) = [nan matsout; dates ylds_P];
            S(k1).([prefix{k0} 's' sgmtype '_tp']) = [nan matsout; dates termprm];
            S(k1).([prefix{k0} 's' sgmtype '_pr']) = params;
        end
        disp(['Estimation for ' S(k1).cty ' has finished.'])
    end
end