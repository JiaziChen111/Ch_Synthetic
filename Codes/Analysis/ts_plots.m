
% g = [2 7 11; 3 14 9; 8 15 4; 10 1 13; 6 5 12];
ncntrs  = length(S);
nEMs    = length(currEM);
nAEs    = length(currAE);

%% Plot surveys
% whole period
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).svys)
        subplot(3,5,k0)
        plot(S(k0).svys(2:end,1),S(k0).svys(2:end,2:end))
        title(S(k0).cty)
        datetick('x','yy'); ylabel('%'); yline(0);
    end
end

% within sample period
figure
fldname = 'n_ylds';
for k0 = 1:nEMs
    if ~isempty(S(k0).svys)
        mats   = S(k0).(fldname)(1,:);                                      % include first column
        startS = find(mats(2:end) - mats(1:end-1) < 0);
        svys   = S(k0).(fldname)(2:end,2:end)*100;
        fltrS  = any(~isnan(svys(:,startS:end)),2);
        subplot(3,5,k0)
        plot(S(k0).(fldname)([false;fltrS],1),svys(fltrS,startS:end))
        title(S(k0).cty)
        datetick('x','yy'); ylabel('%'); yline(0);
    end
end

%% Plot TP: ny, ns, sy, ss
fldname = 'ssb_tp';
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,end))
        title([S(k0).cty ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP']); 
        datetick('x','yy'); yline(0);
    end
end

%% Compare TP (different types, same variable): ny, ns, sy, ss
fldtype1 = 'ssf_';   fldvar = 'tp';
fldtype2 = 'ssb_';   fldname = [fldtype2 fldvar];
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        h = plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).cty ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == 1
            lh = legend(h,'location','best');
            legend([fldtype1 fldvar],[fldtype2 fldvar],'AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end

%% Compare TP (different types, different variables): ny, ns, sy, ss
fldtype1 = 's_';	 fldvar1 = 'ylds';  fldname1 = [fldtype1 fldvar1];
fldtype2 = 'ssb_';   fldvar2 = 'yQ';    fldname2 = [fldtype2 fldvar2];
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname1)) && ~isempty(S(k0).(fldname2))
        subplot(3,5,k0)
        fltr = find(S(k0).([fldtype1 fldvar1])(1,:) == 10);
        plot(S(k0).([fldtype1 fldvar1])(2:end,1),S(k0).([fldtype1 fldvar1])(2:end,fltr),...
             S(k0).([fldtype2 fldvar2])(2:end,1),S(k0).([fldtype2 fldvar2])(2:end,end))
        title([S(k0).cty ' ' num2str(S(k0).(fldname1)(1,end))])
        legend([fldtype1 fldvar1],[fldtype2 fldvar2],'AutoUpdate','off')
        datetick('x','yy');yline(0);
    end
end

%% Compare 3 series
fldname1 = 'n_ylds';
fldname2 = 'c_data';
fldname3 = 'ssb_tp';
for k0 = 1:nEMs
    subplot(3,5,k0)
    fltr1 = find(S(k0).(fldname1)(1,:) == 10,1,'first');
    fltr2 = find(S(k0).(fldname2)(1,:) == 10);
    plot(S(k0).(fldname1)(2:end,1),S(k0).(fldname1)(2:end,fltr1),...
         S(k0).(fldname2)(2:end,1),S(k0).(fldname2)(2:end,fltr2))
    hold on
    if ~isempty(S(k0).(fldname3))
        plot(S(k0).(fldname3)(2:end,1),S(k0).(fldname3)(2:end,end))
    else
        plot(S(k0).('sy_tp')(2:end,1),S(k0).('sy_tp')(2:end,end))
    end
    hold off
    title(S(k0).cty)
    legend('Yield','LCCS','TP','AutoUpdate','off')
    datetick('x','yy'); yline(0);
end

%% Quick loop
fldname = 'ssf_pr';
aux = [];
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        aux = [aux; k0 S(k0).(fldname).sgmS];
    end
end

%% US TP
ynsvys = readmatrix(fullfile(fullfile(pwd,'..','..','Data','Aux','USYCSVY'),'USYCSVYdata.xlsx'),'Sheet',1);
dates  = x2mdate(ynsvys(:,1));                                              % dates as datenum
ynsvys = ynsvys(:,2:end)./100;                                              % data in decimals
yonly  = ynsvys(:,1:8);                                                 	% yield data
matsY  = [0.25 1:5 7 10];                                                   % yield maturities in years
matsS  = [0.25:0.25:1 10];
p      = 3;                                                               	% number of state vectors
dt     = 1/12;                                                          	% monthly periods
matout = [1 5 10];

[ylds_Qjsz,ylds_Pjsz,tpjsz,params0] = estimation_jsz(yonly,matsY,matout,dt,p);
[ylds_Q,ylds_P,termprm,params] = estimation_svys(ynsvys,matsY,matsS,matout,dt,params0);

figure; plot(dates,yonly(:,end),dates,ylds_Qjsz(:,end),dates,ylds_Q(:,end))
figure; plot(dates,termprm(:,end),dates,tpjsz(:,end))
svys  = ynsvys(:,9:end);
figure; plot(dates(240:end),ylds_P(240:end,end),dates(240:end),ylds_Pjsz(240:end,end),...
             dates(240:end),svys(240:end,end),'*')
