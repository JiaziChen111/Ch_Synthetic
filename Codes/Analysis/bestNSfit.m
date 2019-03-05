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
    try         % If error in lsqcurvefit due to init_vals, exagerate rmse
        aux                = init_vals(k,:);
        [bhat,vssr(k),res] = lsqcurvefit(@y_NS,aux,tnrs1,ydata,lb,ub,options);
        vparams(k,:)       = bhat;
        vrmse(k)           = sqrt(mean(res.^2));
    catch
        vparams(k,:)       = init_vals(k,:);
        vrmse(k)           = 1e9;
    end
end

%[ssr,idx] = min(vssr);
[rmse,idx] = min(vrmse);
params     = vparams(idx,:);

%% Source
%
% Continue to next iteration in loop if there is an error
% https://www.mathworks.com/matlabcentral/answers/...
% 224369-how-do-i-force-the-next-loop-iteration-if-error-occurs-within-the-loop