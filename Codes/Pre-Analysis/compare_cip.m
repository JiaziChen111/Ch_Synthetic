%% Compare CIP Calculations
% This code compares my CIP variables with those of Du, Im & Schreger (2018).
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
if ~exist('T_cip','var')                                      % Run code if T_cip is not in the workspace
    run read_cip.m
end

[~,all_currencies] = findgroups(T_cip.currency);              % Find all currencies
[~,~,currencies]   = findgroups(T_cip.group,T_cip.currency);  % Currencies ordered by group of countries
S = cell2struct(cellstr(currencies)','ccy');                  % For field ccy, assign a country to a structure

[~,all_tenors] = findgroups(T_cip.tenor);           % Find the tenors as categorical variable
tenors = cellstr(all_tenors);                       % Convert to cell array
tenors{contains(tenors,'3m')} = '0.25y';            % Express all tenors in years
tenors = strrep(tenors,'y','');                     % Remove 'y' from all tenors
tenors = cellfun(@str2num,tenors);                  % Convert cell array to numbers
[tenors,idx] = sort(tenors);                        % Sort all tenors
all_tenors   = all_tenors(idx);                     % Reorder all tenors in ascending order

for k = 1:length(currencies)
    diffs = []; correls = [];
    for l = 2:length(all_tenors)
        tnryr= char(all_tenors(l));
        curr = char(currencies(k));

        % TTdis = table2timetable(table(T_cip.date(rows),T_cip{rows,'rho'}));
        rows  = T_cip.currency==currencies(k) & T_cip.tenor==all_tenors(l);
        z1    = table(T_cip.date(rows),T_cip{rows,'rho'},'VariableNames',{'date',['dis' tnryr]});
        TTdis = table2timetable(z1);                % Create timetable for DIS rho
        
        hdr  = header_daily;
        fltr = ismember(hdr(:,1),currencies(k)) & ismember(hdr(:,2),'RHO') & ...
            ismember(hdr(:,5),num2str(tenors(l)));
        if sum(fltr) > 0                            % Proceed if tenor was calculated (data was available)
            % TTown = table2timetable(table(t,dataset_daily(:,fltr)));
            t  = datetime(dataset_daily(:,1),'ConvertFrom','datenum');
            z1 = table(t,dataset_daily(:,fltr),'VariableNames',{'date',['own' tnryr]});
            TTown = table2timetable(z1);            % Create timetable for own rho
            
            TT    = synchronize(TTdis,TTown,'intersection');    % Match values of rho in time
            TT.diff = TT.(['dis' tnryr]) - TT.(['own' tnryr]);  % Calculate daily difference in rhos
            diffs   = [diffs; tenors(l), mean(TT.diff,'omitnan')];
            correls = [correls; tenors(l), corr(TT.(['dis' tnryr]),TT.(['own' tnryr]),'Rows','complete')];
        end

        % figure
%         f = figure;
%         plot(T_cip.date(rows),T_cip{rows,'rho'})
%         if sum(fltr) > 0                            % Proceed if tenor was calculated (data was available)
%             hold on
%             plot(t,dataset_daily(:,fltr))
%             legend('DIS','Own')
%         else
%             legend('DIS')
%         end
%         title([curr ' ' tnryr])
%         datetick('x','yy','keeplimits')
%         tmr = timer('ExecutionMode','singleShot','StartDelay',1,'TimerFcn',@(~,~)close(f));
%         start(tmr)
    end
%     input([curr ' is displayed. Press Enter key to continue.'])
    S(k).rhodiff = diffs;
    S(k).rhocorr = correls;
end

clear idx f t tmr fltr TTdis TTown TT tnryr curr diffs correls
