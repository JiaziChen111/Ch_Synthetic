function yrs2drop = suggest_yrs2drop(init_vals,tnrs1,ydata1,lb,ub,options)
% This function suggest two years that if dropped produce the best Nelson-
% Siegel fit for: (1) the remaining points, and (2) all the points.
% Calls to m-files: bestNSfit.m
% 
%     INPUTS
% double: init_vals - matrix, each row is a set of initial parameters beta0 to beta2 and tau
% double: tnrs1     - tenors for which there is data
% double: ydata1    - set of actual yields used for the estimation
% double: lb        - lower bound for the parameters
% double: ub        - upper bound for the parameters
% object: options   - used by lsqcurvefit
% 
%     OUTPUT
% double: yr2drop - years that if dropped produce the 'best' (see below) fit
%
% Pavel Solís (pavel.solis@gmail.com), April 2018
%%
ntnrs   = size(tnrs1,1);
nparam  = size(init_vals,2);
vparams = zeros(ntnrs,nparam);
vssr1   = zeros(ntnrs,1);
vssr2   = zeros(ntnrs,1);

% Remove year by year
for m = 1:ntnrs
    tnrs2     = tnrs1;
    ydata2    = ydata1;
    tnrs2(m)  = [];
    ydata2(m) = [];
    [vparams(m,:),vssr1(m)] = bestNSfit(init_vals,tnrs2,ydata2,lb,ub,options);
    vssr2(m)  = sum((y_NS(vparams(m,:),tnrs1) - ydata1).^2); % ssr considering all points
end

% Select the year that minimizes ssr
[~,idx1] = min(vssr1);                  % Best fit for the remaining points
[~,idx2] = min(vssr2);                  % Best fit including the point dropped, may minimize
                                        % the effect of dropping the point
yrs2drop = [tnrs1(idx1) tnrs1(idx2)];
 