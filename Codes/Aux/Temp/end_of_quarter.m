function dataset_qrtrly = end_of_quarter(dataset_monthly)
% This function returns end-of-quarter observations from a dataset containing
% monthly observations. All columns are preserved.
%
%     INPUT
% dataset_monthly - monthly observations as rows (top-down is first-last obs), col1 has dates
%
%     OUTPUT
% dataset_qrtrly - end-of-quarter observations as rows, same columns as input
%
% Pavel Solís (pavel.solis@gmail.com), May 2019
%%
dates          = dataset_monthly(:,1);
mnths          = month(dates);
idxEndQt       = any(mnths == [3 6 9 12],2);
dataset_qrtrly = dataset_monthly(idxEndQt,:);
 