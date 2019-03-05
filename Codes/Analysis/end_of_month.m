function dataset_monthly = end_of_month(dataset_daily)
% This function returns end-of-month observations from a dataset containing
% daily observations. The code preserves all the columns.
% Note: The code keeps the last observation (ie assumes it is end of month).
%
%     INPUT
% dataset_daily - matrix with daily observations as rows (top-down is first-last obs), col1 has dates
%
%     OUTPUT
% dataset_monthly - matrix with end-of-month observations
%
% Pavel Solís (pavel.solis@gmail.com), September 2018
%%
idxEndMo = [diff(day(dataset_daily(:,1))); -1] < 0;   % 1 if last day of month; keep last obs
dataset_monthly = dataset_daily(idxEndMo,:);          % Last available trading day per month

%% Source
%
% Last available trading day per month
% https://www.mathworks.com/matlabcentral/answers/...
% 389091-how-to-remove-daily-data-and-leave-the-last-day-of-each-month