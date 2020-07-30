function S = add_macroNsvys(S,currEM)
% ADD_MACRONSVYS Add macro variables and survey data to structure S

% m-files called: read_macrovars, read_surveys, read_spf, datesminmax
% Pavel Solís (pavel.solis@gmail.com), July 2020
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
tenors  = cellfun(@str2double,regexp(hdr_svys,'\d*','Match'),'UniformOutput',false);%tnrs in hdr_svys
fltrSVY = ~contains(hdr_svys,{'00Y','02Y','03Y','04Y'});             	% exclude current year and 2 to 4 years
macrovr = {'CPI','GDP'};
for k0  = 1:2
    for k1 = 1:nEMs
        fltrCTY   = contains(hdr_svys,{S(k1).iso,'DATE'}) & fltrSVY; 	% include dates
        macrodata = data_svys(:,fltrCTY);                               % extract variables
        macroname = hdr_svys(fltrCTY);                               	% extract headers
        macrotnr  = unique(cell2mat(tenors(fltrCTY)));                  % extract unique tnrs as doubles
        macroVAR  = macrodata(:,contains(macroname,macrovr{k0}));
        
        dtmn = datesminmax(S,k1);                                       % relevant starting date for surveys
        if sum(fltrCTY) > 1                                             % country w/ survey data
            fltrDT = any(~isnan(macroVAR),2) & macrodata(:,1) >= dtmn;  % svy obs after first yld obs
            S(k1).(['s' lower(macrovr{k0})]) = [nan macrotnr;           % store survey data on macro vars
                                                  macrodata(fltrDT,1) macroVAR(fltrDT,:)];
            
            % Implied CBP forecasts only survey data on inflation
            if contains(macrovr{k0},'CPI')
                % Match surveys of real rates & inflation
                varname = erase(macroname(contains(macroname,macrovr{k0})),{S(k1).iso,'_'});
                TTcpi   = array2timetable(macroVAR(fltrDT,:),...
                    'RowTimes',datetime(macrodata(fltrDT,1),'ConvertFrom','datenum'),'VariableNames',varname);
                TTsvy   = synchronize(TT_rr,TTcpi,'intersection');
                
                % Calculate implied CBP forecasts under SOE assumption
                TTsvy.CBP01Y = TTsvy.USRR01Y + TTsvy.CPI01Y;
                TTsvy.CBP05Y = TTsvy.USRR05Y + TTsvy.CPI05Y;
                TTsvy.CBP10Y = TTsvy.USRR10Y + TTsvy.CPI10Y;
                S(k1).('scbp') = [nan macrotnr;                         % store implied CBP forecasts
                                    datenum(TTsvy.Time) TTsvy.CBP01Y TTsvy.CBP05Y TTsvy.CBP10Y];
                S(k1).('usrr')   = [nan macrotnr;                       % store US real rates
                                    datenum(TTsvy.Time) TTsvy.USRR01Y TTsvy.USRR05Y TTsvy.USRR10Y];
            end
        end
    end
end