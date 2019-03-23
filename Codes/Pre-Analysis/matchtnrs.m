function fltr = matchtnrs(fltr,tnr,idx,ntnr)
% This function adjusts (deletes 1's of) the filter of type 1 tickers based
% on the tenor availability of type 2 tickers. It assumes that tnr1 >= tnr2.
%
%     INPUTS
% cell: fltr   - vectors of logicals with 1's indicating the location of a type
% cell: tnr    - vectors indicating the tenors available per type
% double: idx  - vectors with positions (rows) of the respective tickers
% double: ntnr - number of tenors available per type
%
%     OUTPUT
% cell: fltr   - corrected fltr with the same tenors for the different types
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
% If necessary, adjust filters so that all tenors coincide
[tnrmin, minpos] = min(ntnr);           % Find min and max tenors
tnrmax = max(ntnr);
if tnrmin ~= tnrmax                     % Stop if all have same tenors (tnrmin=tnrmax)
    tnrshigh = ~ismember(ntnr,tnrmin);  % Logical of high tenors
    tnrshpos = find(tnrshigh);          % Position of high tenors
    for k = tnrshpos                    % Remove tenors that will not be used
        fltr{k} = adjusttnr(tnr{k},tnr{minpos},idx{k},fltr{k});
    end
end

% Flag cases with same tnrmin but different elements (eg [1,3,4] & [2,3,4]), if any
if sum(ntnr(:) == tnrmin) > 1          % Only if at least 2 have tnrmin
    tnrmins = find(ntnr(:) == tnrmin); % Positions of tenors with same tnrmin
    for k = tnrmins(2:end)'            % By if condition, there are at least 2
        coincident = adjusttnr(tnr{k},tnr{tnrmins(1)},idx{k},fltr{k});
        if sum(coincident) < tnrmin
            % warning('Types %s and %s have different tenors.',types{tnrmins(1)},types{k})
            warning('Types have different tenors.')
        end
    end
end 

    function fltr1 = adjusttnr(tnr1,tnr2,idx1,fltr1)
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
        %
        tnrMatch = ismember(tnr1,tnr2); % Logical for tenors needed (tnr1 >= tnr2)
        idx1     = idx1(tnrMatch);      % Identify location of tenors needed
        fltr1(:) = 0;                   % Clean the filter (o/w some 1's remain)
        fltr1(idx1) = 1;                % Chosse only tenors needed
    end

end