function [curncs,currEM,currAE] = read_currencies(T_cip)
% This function reads the currencies of the countries included in the sample.
% 
%     INPUTS
% table: T_cip - [Optional] CIP data calculated by Du, Im & Schreger (2018)
% 
%     OUTPUT
% cell: curncs - contains all currencies ordered by group of countries (EMs followed by AEs)
% cell: currEM - contains all EM currencies in ascending order
% cell: currAE - contains all AE currencies in ascending order
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
if nargin == 0                                                % Run code if T_cip is not provided
    run read_cip.m
end

[~,grp,currencies] = findgroups(T_cip.group,T_cip.currency);  % Currencies ordered by group of countries
fltrEM = logical(mod(findgroups(grp),2));                     % Convert grp into a logical for EMs and AEs
currEM = cellstr(currencies(fltrEM));                         % Identify EM currencies as cell array
currAE = cellstr(currencies(~fltrEM));
curncs = cellstr(currencies);

%% Alternative Approach
% LCs = unique(TH_daily.Currency,'stable');
% LCs(ismember(LCs,'USD')) = [];            % Countries in the dataset other than the U.S.
% if ~any(strcmp(LCs,'GBP'))                % If no advanced countries, omit 'EUR' (from HUF and PLN)
%     LCs(ismember(LCs,'EUR')) = []; 
% else                                      % Otherwise, relocate 'EUR'
%     idxEUR = find(strcmp(LCs,'EUR'));
%     idxGBP = find(strcmp(LCs,'GBP'));
%     LCs    = LCs([1:idxEUR-1, idxEUR+1:idxGBP-1, idxEUR, idxGBP:end]);
% end