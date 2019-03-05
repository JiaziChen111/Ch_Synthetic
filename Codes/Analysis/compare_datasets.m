% This code compares dataset_lcrf at the time of the proposal with it today
% in order to find out what is causing the difference in results (risk premia)
% It also compares plots of N-S fits (current vs previous)
% Conclusion: The N-S fit changed for some reason and new special issues
% arised, they have to be dealt with later
% September 2018


% % Compare datasets of CCS
% ccs_data_new = data_ccs(1306:3913,:);
% sum(ccs_data_new - ccs_data_old,'omitnan')

% %Compare whole datasets excluding BRL LCRF from newest dataset
% Anew = dataset(:,1:592);
% Aold = dataset_old(:,1:592);
% mean(sum(Anew - Aold,'omitnan'))
% sum(Anew - Aold,'omitnan');
% 
% Bnew = dataset(:,600:end);
% Bold = dataset_old(:,593:end);
% mean(sum(Bnew - Bold,'omitnan'))
% sum(Bnew - Bold,'omitnan');


maturities = [0.25 1:10];
times      = linspace(0,10);

for k = 12%1:numel(IDs_old)              % Notice the use of IDs_old not of IDs as in fit_NS
    id             = IDs_old(k);
    
    % Compare NS fitted risk-free curves
    fltrCTY_old    = dataset_lcrf_old(:,2) == id;         % specific rows
    fltrCTY_tdy    = dataset_lcrf(:,2) == id;             % specific rows differ
    panel_lcrf_old = dataset_lcrf_old(fltrCTY_old,1:13);  % it has dates, id, 3mo-10yr yields
    panel_lcrf_tdy = dataset_lcrf(fltrCTY_tdy,1:13);
    params_old     = dataset_lcrf_old(fltrCTY_old,14:17);
    params_tdy     = dataset_lcrf(fltrCTY_tdy,14:17);
    mean(panel_lcrf_tdy - panel_lcrf_old);
    
% Lines from fit_NS.m
    % Available tenors per country
    fltrYLD  = ismember(header(:,1),crncy) & fltrLCRF; % Country + LC data
    tnrs     = header(fltrYLD,5);
    tnrs     = cellfun(@str2num,tnrs,'UniformOutput',false);
    tnrs     = cell2mat(tnrs);                      % Tenors available

    % End of month data
    idxDates = sum(~isnan(dataset(:,fltrYLD)),2) > 4; 
    data_lc  = dataset(idxDates,:);                 % Rows with at least 5 data points for NS
    idxEndMo = [diff(day(data_lc(:,1))); -1] < 0;   % 1 if last day of month; keep last obs
    data_lc  = data_lc(idxEndMo,:);                 % Last available trading day per month
    nobs     = size(data_lc,1);

    % Address special cases
    [data_lc,dropped] = special_cases(fltrYLD,data_lc,tnrs,crncy);
% Lines from fit_NS.m
    
    nobs = size(panel_lcrf_old,1);
    nobs_fit = size(panel_lcrf_tdy,1);
    
    for l = 2%1:nobs
        
    % Lines from fit_NS.m
        ydataLC   = data_lc(l,fltrYLD)';            % Column vector
        idxY      = ~isnan(ydataLC);                % sum(idxY) >= 5, see above
        ydataLC   = ydataLC(idxY);
        tnrs1     = tnrs(idxY);                     % Tenors for which there is data
    % Lines from fit_NS.m
        
        date_old    = panel_lcrf_old(l,1);
        if nobs_fit == 1                % It holds when fit_NS run for one particular date
            date_tdy    = panel_lcrf_tdy(1,1);
        else
            date_tdy    = panel_lcrf_tdy(l,1);
        end
        if date_old ~= date_tdy; warning('dates are different'); end
        NSblue = y_NS(params_old(l,:),times);
        if nobs_fit == 1
            NSred  = y_NS(params_tdy(:),times);
        else
            NSred  = y_NS(params_tdy(l,:),times);
        end
        plot(tnrs1,ydataLC,'ko',dropped(l,1),dropped(l,2),'go',times,NSblue,'b-',times,NSred,'r-')
        title([ctrsLC_old{k} '  ' datestr(date_old)])
        H(l) = getframe(gcf);
        %if sum(abs(NSred - NSblue) > 0.5) > 0; disp('Press a key'); pause; end
    end
end
%close

% From datenum to string: datestr(732493)
% From string to datenum: datenum('30-Jun-2005')

% find(panel_lcrf_old(:,1) == datenum('30-Jun-2005'))
