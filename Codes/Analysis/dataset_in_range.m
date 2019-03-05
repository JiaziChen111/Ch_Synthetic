function trimmed_dataset = dataset_in_range(whole_dataset,date1,date2)
% This function returns a dataset containing observations within date1 and date2
% (may include date1 and/or date2). 
% Note: The code preserves all the columns.
%
%     INPUT
% whole_dataset - matrix with observations as rows, col1 has dates
%
%     OUTPUT
% trimmed_dataset - matrix with observations within date1 and date2
%
% Pavel Solís (pavel.solis@gmail.com), September 2018
%%
dateIdx  = (whole_dataset(:,1) >= date1) & (whole_dataset(:,1) <= date2); % Logical
trimmed_dataset = whole_dataset(dateIdx,:);  % Limit the dataset to the sample dates