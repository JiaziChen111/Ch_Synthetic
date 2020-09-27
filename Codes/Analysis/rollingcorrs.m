function rollingcorrs(S)

fname = {'d_yQ','d_yP','d_tp','d_cr'};
for j0 = 1:length(fname)
    rollcorr = rolling(S,fname{j0},10);
    plot(rollcorr(:,1),rollcorr(:,2)); hold on
end
hold off
datetick('x','yy')

end

function rollcorr = rolling(S,fname,tnr)
% ROLLINGCORRS Returns the average rolling correlations

% Pavel Solís (pavel.solis@gmail.com), September 2020
%%
for k1 = 1:15
    fltrTNR = ismember(S(k1).(fname)(1,:),tnr);
    datesd  = S(k1).(fname)(2:end,1);
    dseries = S(k1).(fname)(2:end,fltrTNR);
    dchange = dseries(2:end) - dseries(1:end-1);                        % series of daily changes
    dtstaux = [nan tnr; datesd(2:end) dchange];                         % include header and dates
    if k1 == 1
        dtst = dtstaux;
    else
        dtst = syncdatasets(dtst,dtstaux,'union');                      % append series
    end
end
fltrCTR = [true; sum(isnan(dtst(2:end,2:end)),2) <= 10];                % at least 5 countries with data
fltrDT  = dtst(:,1) > datenum('31-Jan-2019');                           % out of sample observations
dtst    = dtst(fltrCTR & ~fltrDT,:);                                    % adjust dataset
datemin = dtst(2,1) + 365;                                              % one year after first observation
dates   = dtst(dtst(:,1) >= datemin,1);                                 % dates for rolling windows
nobs    = size(dates,1);
rollcorr = nan(nobs,2);
for k2  = 1:nobs
    fltrRL = (dtst(:,1) >= dates(k2) - 365) & (dtst(:,1) <= dates(k2));
    rho    = corr(dtst(fltrRL,2:end),'Rows','pairwise');                % correlations within the window
    rollcorr(k2,:) = [dates(k2) mean(rho(tril(ones(size(rho)),-1) == 1),'omitnan')]; % average correlation
end

end