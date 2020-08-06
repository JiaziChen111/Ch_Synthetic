function [dataset,headers] = append_dataset(dataset1,dataset2,hdrs1,hdrs2)
% APPEND_DATASET Dataset2 is appended to the right of dataset1 and hdrs2
% is added to the bottom of hdrs1. Inputs need to be consistent (see below)
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
% Pavel Solís (pavel.solis@gmail.com), August 2020
%%
% dates1 = dataset1(:,1);
% dates2 = dataset2(:,1);

% if ~isempty(setdiff(dates1,dates2))     % If dates are not equal, error
%     error('The two datasets must have the same dates.')
% end

if size(hdrs1,2) ~= size(hdrs2,2)       % If columns of headers differ, error
    error('The two headers must have the same number of columns.')
end

% The number of variables and headers must match (recall dataset2 col 1 has dates)
if (size(hdrs1,1) + size(hdrs2,1)) ~= (size(dataset1,2) + size(dataset2,2) - 1)
    error('The variables and the headers must match.')
end

% dataset = [dataset1, dataset2(:,2:end)]; % Col 1 of dataset2 (dates) not included

TT1 = array2timetable(dataset1(:,2:end),'RowTimes',datetime(dataset1(:,1),'ConvertFrom','datenum'));
TT2 = array2timetable(dataset2(:,2:end),'RowTimes',datetime(dataset2(:,1),'ConvertFrom','datenum'));
TT3 = synchronize(TT1,TT2,'union');

dataset = [datenum(TT3.Time) TT3{:,:}];
headers = [hdrs1; hdrs2];