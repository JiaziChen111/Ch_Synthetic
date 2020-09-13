TT_rr = read_spf();
[TTtips,THtips] = read_tips();

rr1y  = synchronize(TT_rr(:,1),TTtips(:,1),'intersection');
rr5y  = synchronize(TT_rr(:,2),TTtips(:,2),'intersection');
rr10y = synchronize(TT_rr(:,3),TTtips(:,3),'intersection');

rr1y  = rmmissing(rr1y);
rr5y  = rmmissing(rr5y);
rr10y = rmmissing(rr10y);

plot(rr1y.Time, [rr1y.(1)  rr1y.(2)])
plot(rr5y.Time, [rr5y.(1)  rr5y.(2)])
plot(rr10y.Time,[rr10y.(1) rr10y.(2)])

corr(rr1y.(1),  rr1y.(2))
corr(rr5y.(1),  rr5y.(2))
corr(rr10y.(1), rr10y.(2))
mean([rr1y.(1)  rr1y.(2)])
mean([rr5y.(1)  rr5y.(2)])
mean([rr10y.(1) rr10y.(2)])