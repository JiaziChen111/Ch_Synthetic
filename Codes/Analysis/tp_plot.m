    
for k = 1:ncntrs
    % Cross section
    for l = 1:nobs
        plot(mats,yields(l,:)','o',mats,yields_Q(l,:)','x',mats,yields_P(l,:),'+')
        title([S(k).ccy '  ' datestr(dates(l))]), xlabel('Maturity')
        legend('Synthetic','Fitted','Expected')
        H(l) = getframe(gcf);
    end
    % No good fits: BRL, IDR, PEN, PHP

    % Time series
    for l = 1:length(mats)
        plot(dates,yields(:,l)','o',dates,yields_Q(:,l)','x',dates,yields_P(:,l),'+')
        title([S(k).ccy '  ' num2str(mats(l)) ' YR'])
        legend('Synthetic','Fitted','Expected') % Change first to Synthetic or Nominal
        datetick('x','YYQQ')
                                                % xtick to have years
        H(l) = getframe(gcf);
    end
end