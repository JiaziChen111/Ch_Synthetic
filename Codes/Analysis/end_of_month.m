function [dataset_monthly, date_first_obs] = end_of_month(dataset_daily)
% This function returns end-of-month observations from a dataset containing
% daily observations. All columns are preserved.
%
%     INPUT
% dataset_daily - daily observations as rows (top-down is first-last obs), col1 has dates
%
%     OUTPUT
% dataset_monthly - end-of-month observations as rows, same columns as input
% date_first_obs  - date of the first monthly observation
%
% Pavel Solís (pavel.solis@gmail.com), April 2019
%%
dates   = dataset_daily(:,1);
lastobs = dates(end);                               % Last date in the dataset
lastmth = eomdate(lastobs);                         % Last date of the month
if (lastobs >= lastmth-4) && (lastobs <= lastmth)   % Compare allowing for long weekend
    last = -1;                                      % Keep last observation if it is end of month
else
    last = 0;
end

idxEndMo = [diff(day(dates)); last] < 0;            % 1 if last day of month
dataset_monthly = dataset_daily(idxEndMo,:);        % Last available trading day per month
date_first_obs  = dataset_monthly(1,1);

%% Source
%
% Last available trading day per month
% https://www.mathworks.com/matlabcentral/answers/...
% 389091-how-to-remove-daily-data-and-leave-the-last-day-of-each-month