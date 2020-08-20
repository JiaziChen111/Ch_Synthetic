%% US TP
ynsvys = readmatrix(fullfile(fullfile(pwd,'..','..','Data','Aux','USYCSVY'),...
    'USYCSVYdata.xlsx'),'Sheet',1);
dates  = x2mdate(ynsvys(:,1));                                  	% dates as datenum
ynsvys = ynsvys(:,2:end)./100;                                   	% data in decimals
yonly  = ynsvys(:,1:8);                                          	% yield data
matsY  = [0.25 1:5 7 10];                                           % yield maturities in years
matsS  = [0.25:0.25:1 10];
p      = 3;                                                       	% number of state vectors
dt     = 1/12;                                                     	% monthly periods
matout = [1 5 10];

[ylds_Qjsz,ylds_Pjsz,tpjsz,params0] = estimation_jsz(yonly,matsY,matout,dt,p);
[ylds_Q,ylds_P,termprm,params] = estimation_svys(ynsvys,matsY,matsS,matout,dt,params0);

figure; plot(dates,yonly(:,end),dates,ylds_Qjsz(:,end),dates,ylds_Q(:,end))
figure; plot(dates,termprm(:,end),dates,tpjsz(:,end))
svys  = ynsvys(:,9:end);
figure; plot(dates(240:end),ylds_P(240:end,end),dates(240:end),ylds_Pjsz(240:end,end),...
             dates(240:end),svys(240:end,end),'*')
