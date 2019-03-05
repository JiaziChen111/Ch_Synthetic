function [dataset,headers] = append_dataset(dataset1,dataset2,hdrs1,hdrs2)
% This function appends dataset 2 to the right of dataset 1 (without dates)
% and headers 2 at the bottom of headers 1.
% Datasets and headers have to be consistent (see conditionals below).
%
%     INPUTS
% double: dataset1 - matrix with historic values, col 1 has dates (in datenum)
% double: dataset2 - matrix with historic values, col 1 has dates (in datenum)
% cell: hdrs1 - contains headers for dataset1, row 1 has titles
% cell: hdrs2 - contains headers for dataset2 (row 1 has NO titles!)
%
%     OUTPUT
% double: dataset - matrix with historic values for all variables, col 1 has dates
% cell: headers   - contains headers for all variables, row 1 has titles
%
% Pavel Solís (pavel.solis@gmail.com), March 2018
%%
dates1 = dataset1(:,1);
dates2 = dataset2(:,1);

if ~isempty(setdiff(dates1,dates2))     % If dates are not equal, error
    error('The two datasets must have the same dates.')
end

if size(hdrs1,2) ~= size(hdrs2,2)       % If columns of headers differ, error
    error('The two headers must have the same number of columns.')
end

% The number of variables and headers must match (recall dataset2 col 1 has dates)
if (size(hdrs1,1) + size(hdrs2,1)) ~= (size(dataset1,2) + size(dataset2,2) - 1)
    error('The variables and the headers must match.')
end

dataset = [dataset1, dataset2(:,2:end)]; % Col 1 of dataset2 (dates) not included
headers = [hdrs1; hdrs2];
