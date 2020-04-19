function [fltr,tnr,idx] = pfilter(currency,type,header)
% This function identifies tickers, their tenors and location among all the 
% tickers in header based on currency and type.
%
%     INPUTS
% char: currency - currency of the ticker
% char: type     - type of ticker (e.g. IRS, NDS, BS, etc.)
% cell: header   - contains information about the tikcers (eg currency, type, tenor)
%
%     OUTPUT
% logical: fltr    - true when currency (col 1) and type (col 2) match
% cell/double: tnr - available tenors
% double: idx      - location in header (the space of tickers)
%
% Pavel Solís (pavel.solis@gmail.com), March 2018
%%
fltr = ismember(header(:,1),currency) & ismember(header(:,2),type);
tnr  = header(fltr,5);                  % Tenors are in col 5
idx  = find(fltr);

if currency == 'EUR'                    % 'EUR' variables appear twice
    tnr = tnr(1:sum(fltr)/2,:);
    idx = idx(1:sum(fltr)/2,:);
    fltr(:)   = 0;
    fltr(idx) = 1;
end