function [dtmn,dtmx] = datesminmax(S,k0)
% DATESMINMAX Return the first dates of the balanced panels for nominal
% and synthetic yields

% Pavel Solís (pavel.solis@gmail.com), June 2020
%%
date1 = datenum(S(k0).mn_dateb,'mmm-yyyy');
date2 = datenum(S(k0).ms_dateb,'mmm-yyyy');
dtmn  = min(date1,date2); 
dtmx  = max(date1,date2);