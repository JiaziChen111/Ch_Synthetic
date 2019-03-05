function fltr1 = matchtnr(tnr1,tnr2,idx1,fltr1)
% This function adjusts (deletes 1's of) the filter of type 1 tickers based
% on the tenor availability of type 2 tickers. It assumes that tnr1 >= tnr2.
%
%     INPUTS
% char: tnr1     - vector of tenors of type 1 tickers
% char: tnr2     - vector of tenors of type 2 tickers
% double: idx1   - position of type 1 tickers in the space of tickers
% logical: fltr1 - true when there is a type 1 ticker in the space of tickers
%
%     OUTPUT
% logical: fltr1 - updated to match the tenors of type 2 tickers
%
% Pavel Solís (pavel.solis@gmail.com), March 2018
%%
tnrMatch = ismember(tnr1,tnr2); % Logical for tenors needed (tnr1 >= tnr2)
idx1     = idx1(tnrMatch);      % Identify location of tenors needed
fltr1(:) = 0;                   % Clean the filter (o/w some 1's remain)
fltr1(idx1) = 1;                % Chosse only tenors needed
