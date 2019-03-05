function [vars,tenors] = extractvars(currencies,types,header,dataset)
% This function extracts from the dataset the tickers (and the corresponding 
% tenors) specified in currencies and types.
% Calls to m-files: pfilter.m, matchtnr.m
% 
%     INPUTS
% cell: currencies - currencies of the tickers to be extracted
% cell: types      - types of tickers (e.g. IRS, NDS, BS, etc.) to be extracted
% cell: header     - contains information about the tikcers (eg currency, type, tenor)
% double: dataset  - contains historic values of all the tickers
% 
%     OUTPUT
% double: vars - contains the variables extracted from the dataset, with same tenors
% cell: tenors - useful to construct the header for the extracted variables
%
% Pavel Solís (pavel.solis@gmail.com), March 2018
%%
ncur = numel(currencies);
ntyp = numel(types);
if ncur ~= ntyp
    error('The number of elements in currencies and types must match.')
end

%% Filters
% Identify tickers, as well as their tenors and positions
fltr = {}; tnr = {}; idx = {}; ntnr = [];
for k = 1:ntyp
    [fltr_temp,tnr_temp,idx_temp] = pfilter(currencies{k},types{k},header);
    fltr = [fltr,fltr_temp];
    tnr  = [tnr,{tnr_temp}];
    idx  = [idx,idx_temp];
    ntnr = [ntnr,numel(tnr_temp)];
end

% If necessary, adjust filters so that all tenors coincide
[tnrmin, minpos] = min(ntnr);           % Find min and max tenors
tnrmax = max(ntnr);
if tnrmin ~= tnrmax                     % Stop if all have same tenors (tnrmin=tnrmax)
    tnrshigh = ~ismember(ntnr,tnrmin);  % Logical of high tenors
    tnrshpos = find(tnrshigh);          % Position of high tenors
    for k = tnrshpos                    % Match tenors to the minimum
        fltr{k} = matchtnr(tnr{k},tnr{minpos},idx{k},fltr{k});
    end
end

% Flag cases with same tnrmin but different elements (eg [1,3,4] & [2,3,4]), if any
if sum(ntnr(:) == tnrmin) > 1          % Only if at least 2 have tnrmin
    tnrmins = find(ntnr(:) == tnrmin); % Positions of tenors with same tnrmin
    for k = tnrmins(2:end)'            % By if condition, there are at least 2
        coincident = matchtnr(tnr{k},tnr{tnrmins(1)},idx{k},fltr{k});
        if sum(coincident) < tnrmin
            warning('Types %s and %s have different tenors.',types{tnrmins(1)},types{k})
        end
    end
end 

%% Extract Information
% Extract the history of the tickers needed
for k = 1:ntyp
    vars{k} = dataset(:,fltr{k});
end

% Save tenors
tenors = header(fltr{1},5); % tenors are in col 5, all vars have same tenors
