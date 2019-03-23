%% Compare CIP Calculations
% This code compares my CIP variables with those of Du, Im & Schreger (2018).
% m-files called: compute_fp_long.m, remove_NaNcols.m
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
% run read_cip.m

[~,all_currencies] = findgroups(T_cip.currency);              % Find all currencies
[~,~,currencies]   = findgroups(T_cip.group,T_cip.currency);  % Currencies ordered by group of countries

[~,all_tenors] = findgroups(T_cip.tenor);           % Find the tenors as categorical variable
tenors = cellstr(all_tenors);                       % Convert to cell array
tenors{contains(tenors,'3m')} = '0.25y';            % Express all tenors in years
tenors = strrep(tenors,'y','');                     % Remove 'y' from all tenors
tenors = cellfun(@str2num,tenors);                  % Convert cell array to numbers
[tenors,idx] = sort(tenors);                        % Sort all tenors
all_tenors   = all_tenors(idx);                     % Reorder all tenors in ascending order

for k = 1:length(currencies)
    for l = 2:length(all_tenors)
        rows = T_cip.currency==currencies(k) & T_cip.tenor==all_tenors(l);

        hdr  = header_daily;
        fltr = ismember(hdr(:,1),currencies(k)) & ismember(hdr(:,2),'RHO') & ...
            ismember(hdr(:,5),num2str(tenors(l)));
        t    = datetime(dataset_daily(:,1),'ConvertFrom','datenum');

        figure
%         plot(T_cip.date(rows),T_cip{rows,'rho'},t,dataset_daily(:,fltr))
        plot(T_cip.date(rows),T_cip{rows,'rho'})
        if sum(fltr) > 0                            % If data is not available, tenor is not calculated
            hold on
            plot(t,dataset_daily(:,fltr))
        end
        legend('DIS','Own')
        title([char(currencies(k)) ' ' char(all_tenors(l))])
        datetick('x','yy','keeplimits')
    end
    input([char(currencies(k)) ' has finished.'])
end

% clear idx t fltr
