function [params,rmse] = bestNSfit(init_vals,tnrs1,ydata,lb,ub,options)
% This function tries different initial values to estimate (by non-linear
% least squares) the Nelson-Siegel model and returns the estimated parameters
% that minimize the root mean square fitting error.
% 
%     INPUTS
% double: init_vals - matrix, each row is a set of initial parameters beta0 to beta2 and tau
% double: tnrs1     - tenors for which there is data
% double: ydata     - set of actual yields used for the estimation
% double: lb        - lower bound for the parameters
% double: ub        - upper bound for the parameters
% object: options   - used by lsqcurvefit
% 
%     OUTPUT
% double: params - estimated parameters with min(ssr) for the initial values provided
% double: rmse   - root mean square fitting error
%
% Pavel Solís (pavel.solis@gmail.com), April/October 2018
%%
[reps,nparam] = size(init_vals);
vparams       = zeros(reps,nparam);
vssr          = zeros(reps,1);
vrmse         = zeros(reps,1);

for k = 1:reps
    aux               = init_vals(k,:);
    [aux,vssr(k),res] = lsqcurvefit(@y_NS,aux,tnrs1,ydata,lb,ub,options);
    vparams(k,:)      = aux;
    vrmse(k)          = sqrt(mean(res.^2));
end

%[ssr,idx] = min(vssr);
[rmse,idx] = min(vrmse);
params     = vparams(idx,:);
 