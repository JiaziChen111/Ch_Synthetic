function S = add_macroNsvys(S,currEM)
% ADD_MACRONSVYS Add macro variables and survey data to structure S

% m-files called: read_macrovars, read_surveys, read_spf, trend_inflation, datesminmax
% Pavel Solís (pavel.solis@gmail.com), August 2020
%%
[data_macro,hdr_macro] = read_macrovars(S);                             % macro and policy rates
[data_svys,hdr_svys]   = read_surveys();                                % CPI and GDP forecasts
TT_rr = read_spf();                                                     % US real rates forecasts
nEMs  = length(currEM);

%% Store macro data
vars   = {'INF','UNE','IP','GDP','CBP'};
fnames = lower(vars);
for l  = 1:length(vars)
    fltrMAC = ismember(hdr_macro(:,2),vars{l});
    for k = 1:nEMs
        fltrCTY    = ismember(hdr_macro(:,1),S(k).iso) & fltrMAC;
        fltrCTY(1) = true;                                              % include dates
        data_mvar  = data_macro(:,fltrCTY);
        if size(data_mvar,2) > 1
            idxNaN = isnan(data_mvar(:,2));                             % assume once release starts, it continues
            S(k).(fnames{l}) = data_mvar(~idxNaN,:);
        end
    end
end

%% Store survey data
S = trend_inflation(S,currEM,{'ILS','ZAR'});                            % use trend inflation when no survey data

tenors  = cellfun(@str2double,regexp(hdr_svys,'\d*','Match'),'UniformOutput',false);%tnrs in hdr_svys
fltrSVY = ~contains(hdr_svys,{'00Y','02Y','03Y','04Y'});             	% exclude current year and 2 to 4 years
macrovr = {'CPI','GDP'};
varname = strcat('CPI',{'01Y','05Y','10Y'});
for k0  = 1:2
    for k1 = 1:nEMs
        fltrCTY = contains(hdr_svys,{'DATE',S(k1).iso}) & fltrSVY;      % include dates
        svydata = data_svys(:,fltrCTY);                                 % extract variables
        svyname = hdr_svys(fltrCTY);                                    % extract headers
        svytnrs = unique(cell2mat(tenors(fltrCTY)));                    % extract unique tnrs as doubles
        svyvar  = svydata(:,contains(svyname,macrovr{k0}));
        
        if sum(fltrCTY) > 1                                             % country w/ survey data
            dtmn   = datesminmax(S,k1);                              	% relevant starting date for surveys
            fltrDT = any(~isnan(svyvar),2) & svydata(:,1) >= dtmn;      % svy obs after first yld obs
            S(k1).(['s' lower(macrovr{k0})]) = [nan svytnrs;            % store survey data on macro vars
                                                svydata(fltrDT,1) svyvar(fltrDT,:)];
        end
        
        % Implied CBP forecasts (only need survey data on inflation)
        if strcmp(macrovr{k0},'CPI')
            % Match surveys for real rates & inflation
            svytnrs = S(k1).scpi(1,2:end);
            TTscpi  = array2timetable(S(k1).scpi(2:end,2:end),...
                'RowTimes',datetime(S(k1).scpi(2:end,1),'ConvertFrom','datenum'),'VariableNames',varname);
            TTsvy   = synchronize(TT_rr,TTscpi,'intersection');

            % Calculate implied CBP forecasts under SOE assumption
            TTsvy.CBP01Y = TTsvy.USRR01Y + TTsvy.CPI01Y;
            TTsvy.CBP05Y = TTsvy.USRR05Y + TTsvy.CPI05Y;
            TTsvy.CBP10Y = TTsvy.USRR10Y + TTsvy.CPI10Y;
            S(k1).('scbp') = [nan svytnrs;                         % store implied CBP forecasts
                              datenum(TTsvy.Time) TTsvy.CBP01Y TTsvy.CBP05Y TTsvy.CBP10Y];
            S(k1).('usrr') = [nan svytnrs;                       % store US real rates
                              datenum(TTsvy.Time) TTsvy.USRR01Y TTsvy.USRR05Y TTsvy.USRR10Y];
        end
    end
end