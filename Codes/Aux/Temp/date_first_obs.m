function date_list = date_first_obs(dataset)
% This function returns the dates of the first observation of each country
% in dataset. Uses the change in ID to identify the first observation.
% Note: The code keeps date of first observation in dataset
%
%     INPUT
% matrix: dataset - matrix with observations as rows (top-down is first-last obs) 
%                   col1 has dates, col2 has country codes
%
%     OUTPUT
% matrix: date_list - matrix with datenum of first observation per country
%
% Pavel Solís (pavel.solis@gmail.com), September 2018
%%
idx1stdate = [1; diff(dataset(:,2))] ~= 0;  % Find first month per country
date_list  = dataset(idx1stdate,1);         % First months as datenum