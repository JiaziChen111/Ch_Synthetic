%% Retrieve Historical Data from Bloomberg
% This code retrieves data from Bloomberg in cell array form. It assumes 
% that read_tickers_v4.m has already been run.
%
% Pavel Solís (pavel.solis@gmail.com), March 2018
%%
tckrs    = hdr_blp(2:end,3); % Tickers in col 3, row 1 is the header
fields   = {'LAST_PRICE'};   % Retrieve data for closing quotes
dateFrom = '1/01/2005';      % Start date
dateEnd  = '12/31/2014';     % End date
frequcy  = 'daily';          % Retrieve daily data
missing  = 'previous_value'; % What to use for dates without trading activity
c = blp;                     % Create the Bloomberg connection object c
[data,sec_list] = history(c,tckrs,fields,dateFrom,dateEnd,{frequcy,missing});
close(c)                     % Close the Bloomberg connection
save blp_data.mat data_blp