function S = append_surveys(S,currEM)
% APPEND_SURVEYS Append survey forecasts for the policy rate to yield data
% of emerging markets; only yield data for advanced countries
% 
% Pavel Solís (pavel.solis@gmail.com), June 2020
%%
ncntrs = length(S);
nEMs   = length(currEM);
fnames = fieldnames(S);
prefix = {'n_','s_'};
for k0 = 1:2
    fnameb = fnames{contains(fnames,[prefix{k0} 'blncd'])};
    for k1 = 1:nEMs
        hdry  = S(k1).(fnameb)(1,:);                                % yield maturities (include first column)
        hdrv  = S(k1).svys(1,2:end);                                % survey maturities
        ylds  = S(k1).(fnameb)(2:end,2:end);                        % yields already in decimals
        svys  = S(k1).svys(2:end,2:end)/100;                        % survey forecasts in decimals
        datey = S(k1).(fnameb)(2:end,1);                            % dates of yields
        datev = S(k1).svys(2:end,1);                                % dates of surveys
        fltrd = datev >= datey(1);                                  % survey data in sample period
        datev = datev(fltrd);                                       % keep survey data within sample period
        svys  = svys(fltrd,:);
        TTy   = array2timetable(ylds,'RowTimes',datetime(datey,'ConvertFrom','datenum'));
        TTs   = array2timetable(svys,'RowTimes',datetime(datev,'ConvertFrom','datenum'));
        TT    = synchronize(TTy,TTs,'union');
        S(k1).([prefix{k0} 'ylds']) = [hdry hdrv; datenum(TT.Time) TT{:,:}];
    end
    for k2 = nEMs+1:ncntrs
        S(k2).([prefix{k0} 'ylds']) = S(k2).(fnameb);
    end
end