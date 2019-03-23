function [vars,tenors] = extractvars(currencies,types,header,dataset)
% This function extracts from the dataset the tickers (and the corresponding 
% tenors) specified in currencies and types.
% Assumes ctrs_struct.m has already been run.
% m-files called: fltr4types.m, matchtnrs.m
% 
%     INPUTS
% cell: currencies - currencies of the tickers to be extracted
% cell: types      - types of tickers (e.g. IRS, NDS, BS, etc.) to be extracted
% cell: header     - contains information about the tikcers (eg currency, type, tenor)
% double: dataset  - contains historic values of all the tickers
% 
%     OUTPUT
% double: vars - contains the variables extracted from the dataset, with matched tenors
% cell: tenors - useful to construct the header for the extracted variables
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
ncur = numel(currencies);
ntyp = numel(types);
if ncur ~= ntyp
    error('The number of elements in currencies and types must match.')
end

% Filters
floatleg = ''; nloops = 0;
while nloops <= 0                               % Need to run it at least once; if IRS case, two more times
    fltr = {}; tnr = {}; idx = {}; ntnr = [];   % Initialize
    for k = 1:ntyp                              % Identify tickers, as well as their tenors and positions
        [fltr_temp,tnr_temp,idx_temp] = fltr4types(currencies{k},types{k},floatleg,header);
        fltr = [fltr,fltr_temp];
        tnr  = [tnr,{tnr_temp}];
        idx  = [idx,idx_temp];
        ntnr = [ntnr,numel(tnr_temp)];
    end

    fltr = matchtnrs(fltr,tnr,idx,ntnr);

    % Extract Information
    for k = 1:ntyp
        vars{k} = dataset(:,fltr{k});           % Extract the history of the tickers needed
    end

    % Save tenors
    tenors = header(fltr{1},5);                 % tenors are in col 5, all vars have same tenors (so use var{1})
    
    nloops = nloops + 1;                        % Exit while loop the first time for EMs and G10 w/o cutoff date

    if numel(vars) > 1                          % IRS case only arises when extracting more than 1 variable
        if size(vars{1},2) ~= size(vars{2},2)   % Case of IRS convention for G10 (assumes IRS is var{1})
            nloops = -1;                        % Need to run the while loop two more times (cases: 3M and 6M)
        end
    end

    if  nloops == -1                            % First repetition for 6M
        floatleg = '6M';
    elseif nloops == 0                          % Second repetition for 3M
        vars1    = vars;                        % Save vars and tenors for 6M
        tenors1  = tenors;
        floatleg = '3M';
    end
end

% When IRS is in types, merge variables using a cutoff date
if exist('vars1','var') == 1                    % If variable vars1 exist, deal with IRS case
    vars2   = vars;                             % Save vars and tenors for 3M
    tenors2 = tenors;

    LC = currencies{1};                         % First currency is always the local currency
    [vars,tenors] = split_merge_vars(LC,vars1,vars2,tenors1,tenors2,dataset);
end
