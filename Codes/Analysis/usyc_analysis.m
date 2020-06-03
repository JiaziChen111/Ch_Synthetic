function usyc_analysis()
% USYC_ANALYSIS Reproduce analysis of Guimaraes (2014)

% m-files called: y_NSS, Kfs
% Pavel Solís (pavel.solis@gmail.com), May 2020
% 
%% Load data
% TTycsv = usycsvy_data ();
% y = TTycsv{:,:}./100;
% [tableA1,tableA3] = tpunrestricted();

y     = readmatrix(fullfile(fullfile(pwd,'..','..','Data','Aux'),'USYCSVYdata.xlsx'),'Sheet',1);
dates = x2mdate(y(:,1));
y     = y(:,2:end)./100;                                                            % ylds as decimals
ylds  = y(:,1:8);
% svys   = y(:,9:end);

% Preliminary analysis
% table1 = [mean(ylds,'omitnan'); std(ylds,'omitnan')];                        	% table 1a
% plot(ylds)                                                                      % figure 1a
% plot(svys,'*')                                                                  % figure 1b

%% ATSM estimation: Yields only
addpath(genpath('jsz_code'))
p     = 3;
dt    = 1/12;
matsY = [0.25 1:5 7 10];
nobs  = size(ylds,1);
Ip    = eye(p);
W     = pca(ylds,'NumComponents',p);                                          % W': N*length(mats);

% Fit the curve with JSZ (use yields only)
[llks,AcP,BcP,AX,BX,kinfQ,K0P_cP,K1P_cP,sigma_e,K0Q_cP,K1Q_cP,rho0_cP,rho1_cP,cP, ...
    llkP,llkQ,K0Q_X,K1Q_X,rho0_X,rho1_X,Sigma_cP] = sample_estimation_fun(W',ylds,matsY,dt,false);
[llk,AcP,BcP,AX,BX,K0Q_cP,K1Q_cP,rho0_cP,rho1_cP,cP,yields_filtered,cP_filtered] = ...
    jszLLK_KF(ylds,W',K1Q_X,kinfQ,Sigma_cP,matsY,dt,K0P_cP,K1P_cP,sigma_e);
ylds_Qjsz = ones(nobs,1)*AcP + cP_filtered*BcP;                 % with cP_filtered is same as yields_filtered

%% ATSM estimation: Yields and surveys
% exitflag = 0;
% niter    = 1000;

% tic
% while exitflag == 0
% Use initial values from JSZ
mu_xP = K0P_cP;     PhiP = K1P_cP + Ip;  Hcov = Sigma_cP;
mu_xQ = K0Q_cP;     PhiQ = K1Q_cP + Ip;  cSgm = chol(Hcov,'lower');
rho0  = rho0_cP*dt;
rho1  = rho1_cP*dt;
lmbd0 = cSgm\(mu_xP - mu_xQ);
lmbd1 = cSgm\(PhiP - PhiQ);
sgmY  = sigma_e; % mean(std(ylds,'omitnan')); %0.1;
% sgmS  = mean(std(svys,'omitnan')); %0.2;
% par0  = [PhiP(:);cSgm(:);lmbd1(:);lmbd0(:);mu_xP(:);rho1(:);rho0;sgmY;sgmS];
par0  = [PhiP(:);cSgm(:);lmbd1(:);lmbd0(:);mu_xP(:);rho1(:);rho0;sgmY];%;sgmS];
% [PhiP9,cSgm9,lmbd19,lmbd09,mu_xP9,rho19,rho09,sgmY9,sgmS9] = parest2vars(par0);  % check parest2vars
x00   = (Ip - PhiP)\mu_xP;                                        	% p*1
P00   = reshape((eye(p^2)-kron(PhiP,PhiP))\reshape(Hcov,p^2,1),p,p);	% p*p
if any(isnan(P00),'all') || any(isinf(P00),'all') || any(~isreal(eig(P00))) || any(eig(P00) < 0)
    x00 = zeros(p,1);       P00 = Ip;                        	% in case the state is non-stationary
end

[mu_x0,mu_y0,Phi0,A0,Q0,R0] = atsm_params(par0,matsY,dt);                % check initial values
[loglk0,~,~,~,~,xs0,Ps0] = Kfs(ylds',mu_x0,mu_y0,Phi0,A0,Q0,R0,x00,P00);


% Estimate parameters (use yields and surveys)
tic
% maxitr = length(par0)*niter;
maxitr = length(par0)*200;
mats   = matsY;                                                 % maturities in years
% matsS  = [0.25:0.25:1 10];                                          % maturities of surveys
% mats   = [matsY matsS];                                             % maturities in years
optns  = optimset('MaxFunEvals',maxitr,'MaxIter',maxitr);
llkhd  = @(x)llkfn(x,ylds',x00,P00,mats,dt);                        	% handle to include vars in workspace
% llkhd  = @(x)llkfn(x,y',x00,P00,mats,dt);                        	% handle to include vars in workspace
parest = fminsearch(llkhd,par0,optns);                          % estimate parameters
% [parest,fval,exitflag] = fminsearch(llkhd,par0,optns);           	% estimate parameters
% if ~isinf(fval) && exitflag == 0;   niter = niter + 1000;   end
% end
toc

% Estimate state vector based on estimated parameters
[mu_x,mu_y,Phi,A,Q,R] = atsm_params(parest,mats,dt);                % get model parameters
[loglk,~,~,~,~,xs,Ps] = Kfs(ylds',mu_x,mu_y,Phi,A,Q,R,x00,P00);     	% smoothed state
% [loglk,~,~,~,~,xs,Ps] = Kfs(y',mu_x,mu_y,Phi,A,Q,R,x00,P00);     	% smoothed state

% Estimate the term premium (in percentage points)
% [PhiP,cSgm,lmbd1,lmbd0,mu_xP,rho1,rho0] = parest2vars(parest);
% Hcov      = cSgm*cSgm';
% mu_xQ     = mu_xP - chol(Hcov,'lower')*lmbd0;
% PhiQ      = PhiP  - chol(Hcov,'lower')*lmbd1;
% [AnQ,BnQ] = loadings(matsY,mu_xQ,PhiQ,Hcov,rho0,rho1,dt);            % , 
mu_xP = mu_x;                                                   % p*1
AnQ   = mu_y';                                                    % AnQ: 1*q
PhiP  = Phi;                                                    % p*p
BnQ   = A';                                                    % BnQ: p*q
Hcov  = Q;                                                      % p*p
[~,~,~,~,~,rho1,rho0] = parest2vars(parest);
[AnP,BnP] = loadings(matsY,mu_xP,PhiP,Hcov,rho0,rho1,dt);
ylds_Q    = ones(nobs,1)*AnQ + xs'*BnQ;
tpyldsvy  = ones(nobs,1)*(AnQ - AnP) + xs'*(BnQ - BnP);
tpyldsvy  = tpyldsvy*100;

[Ay,By] = loadings(matsY,K0P_cP,K1P_cP+Ip,Sigma_cP,rho0_cP*dt,rho1_cP*dt,dt);
ylds_Pjsz  = ones(nobs,1)*Ay + cP_filtered*By;                         % same cP as for yields_Q
tpylds  = (ylds_Qjsz - ylds_Pjsz)*100;

figure; plot(dates,ylds(:,end),dates,ylds_Qjsz(:,end),dates,ylds_Q(:,end))
figure; plot(dates,tpyldsvy(:,end),dates,tpylds(:,end))




% mats   = round([matsY matsS]/dt);                                   % maturities in months
% matsY     = round(matsY/dt);                                        % maturities in months
% [AnQ,BnQ] = loadings4ylds(matsY,mu_xQ,PhiQ,Sgm,rho0,rho1,dt);       % AnQ: 1*q, BnQ: p*q
% [AnP,BnP] = loadings4ylds(matsY,mu_xP,PhiP,Sgm,rho0,rho1,dt);
% [Ay,By] = loadings4ylds(matsY,K0P_cP,K1P_cP+Ip,Sigma_cP,rho0_cP*dt,rho1_cP*dt,dt);

end


function [tableA1,tableA3] = tpunrestricted()
% Load data
% addpath(genpath('jsz_code'))
y = readmatrix(fullfile(fullfile(pwd,'..','..','Data','Aux'),'USYCSVYdata.xlsx'),'Sheet',1);
y(:,1)     = x2mdate(y(:,1),0);                                 % Excel to Matlab dates
y(:,2:end) = y(:,2:end)./100;                                   % ylds as decimals

% Samples
years     = 1972:5:2002;
nsmpls    = length(years);
smplsdate = cell(1,nsmpls); smplsylds = cell(1,nsmpls); smplstp = cell(1,nsmpls);
tableA3   = nan(1,nsmpls);
for k1 = 1:nsmpls
    smplsdate{k1} = y(y(:,1) > datenum(['1-Jan-' num2str(years(k1))]),1);
    smplsylds{k1} = y(y(:,1) > datenum(['1-Jan-' num2str(years(k1))]),2:end);
end

p         = 3;                                                  % number of factors
dt        = 1/12;                                               % time period in years
matsY     = [0.25 1:5 7 10];
Ip        = eye(p);

for k0 = 1:nsmpls
    ylds  = smplsylds{k0}(:,1:8);
    nobs  = size(ylds,1);
    W     = pca(ylds,'NumComponents',p);                    	% W': N*length(mats);

    % Fit the curve with JSZ (use yields only)
    [llks,AcP,BcP,AX,BX,kinfQ,K0P_cP,K1P_cP,sigma_e,K0Q_cP,K1Q_cP,rho0_cP,rho1_cP,cP, ...
        llkP,llkQ,K0Q_X,K1Q_X,rho0_X,rho1_X,Sigma_cP] = sample_estimation_fun(W',ylds,matsY,dt,false);
    [llk,AcP,BcP,AX,BX,K0Q_cP,K1Q_cP,rho0_cP,rho1_cP,cP,yields_filtered,cP_filtered] = ...
        jszLLK_KF(ylds,W',K1Q_X,kinfQ,Sigma_cP,matsY,dt,K0P_cP,K1P_cP,sigma_e);
    ylds_Q = ones(nobs,1)*AcP + cP*BcP;                         % with cP_filtered is same as yields_filtered
    
    [AQ,BQ] = loadings(matsY,K0Q_cP,K1Q_cP+Ip,Sigma_cP,rho0_cP*dt,rho1_cP*dt,dt);
%     [AQ,BQ] = loadings4ylds(round(matsY/dt),K0Q_cP,K1Q_cP+Ip,Sigma_cP,rho0_cP*dt,rho1_cP*dt,dt);
    ylds_Q2  = ones(nobs,1)*AQ + cP*BQ;                         % check: same as ylds_Q
    
    % Mean absolute error (table A1)
    if k0 == 1
        mae = abs(ylds - ylds_Q)*10000;                         % in basis points
        mae2 = abs(ylds - ylds_Q2)*10000;
        tableA1 = [mean(mae); std(mae);...
                   mean(mae2); std(mae2)];
    end
    
    % Term premia
    [AP,BP] = loadings(matsY,K0P_cP,K1P_cP+Ip,Sigma_cP,rho0_cP*dt,rho1_cP*dt,dt);
%     [AP,BP] = loadings4ylds(round(matsY/dt),K0P_cP,K1P_cP+Ip,Sigma_cP,rho0_cP*dt,rho1_cP*dt,dt);
    ylds_P  = ones(nobs,1)*AP + cP*BP;                          % same cP as for yields_Q
    smplstp{k0} = (ylds_Q - ylds_P)*100;
    tableA3(k0) = mean(mean(ylds_P))*100;
end

plot(smplsdate{1},smplstp{1}(:,end),smplsdate{2},smplstp{2}(:,end),smplsdate{3},smplstp{3}(:,end),...
     smplsdate{4},smplstp{4}(:,end),smplsdate{5},smplstp{5}(:,end),smplsdate{6},smplstp{6}(:,end),...
     smplsdate{7},smplstp{7}(:,end))                             % figure 3 (unrestricted)
datetick('x','YY')
end


function TTycsv = usycsvy_data ()
pathc    = pwd;
pathd{1} = fullfile(pathc,'..','..','Data','Raw');                         % platform-specific file separators
pathd{2} = fullfile(pathc,'..','..','Data','Aux');
namefl   = {'US_Yield_Curve_Data.xlsx','Mean_TBILL_1Q-4Q-10Y.xlsx'};

for k = 1:2
    cd(pathd{k})
    opts = detectImportOptions(namefl{k});
    opts = setvartype(opts,opts.VariableNames(1),'datetime');
    opts = setvartype(opts,opts.VariableNames(2:end),'double');
    opts.VariableNames{1} = 'Date';
    if k == 1
        ttaux = readtimetable(namefl{k},opts);
    else
        ttsvy = readtimetable(namefl{k},opts);
    end
    cd(pathc)
end

% Yields
date1   = datetime(datenum('1-Jan-1972'),'ConvertFrom','datenum');
dateco  = datetime(datenum('1-Jan-1983'),'ConvertFrom','datenum');
date2   = datetime(datenum('1-Dec-2010'),'ConvertFrom','datenum');
ttaux   = ttaux(ttaux.Date >= date1,:);                                         % start of sample
TTgsw   = removevars(ttaux,~contains(ttaux.Properties.VariableNames,'SVENY'));	% keep zero-coupon yields
TTgsw   = TTgsw(:,[1:5 7 10]);                                                  % keep tenors 1Y:5Y, 7Y, 10Y
TTparm  = removevars(ttaux,~contains(ttaux.Properties.VariableNames,{'BETA','TAU'})); % keep NSS parameters
TTbill1 = array2timetable(y_NSS(TTparm{:,:},0.25),'RowTimes',TTparm.Date);      % 3M yields implied by GSW
TTbill1.Properties.VariableNames = {'M3YLD'};
TTbill1.Properties.DimensionNames{1} = 'Date';
TTbill1 = TTbill1(TTbill1.Date <= dateco,:);
TTbill2 = read_crsp();                                                          % 3M yields from CRSP
TTbill  = [TTbill1; TTbill2];                                                   % concatenate 3M yields
TTusyc  = synchronize(TTbill,TTgsw);                                            % merge yields (old-new)
TTusyc  = TTusyc(TTusyc.Date < date2,:);                                        % end of sample
datesdy = TTusyc.Date;
datesmh = unique(lbusdate(year(datesdy),month(datesdy)));                       % end-of-month dates
datesxc = datenum({'31-Dec-1992','30-Apr-1993','28-May-1999'});
datesmh(ismember(datesmh,datesxc)) = datesxc - 1;                               % deal w/ special dates
TTusyc  = TTusyc(ismember(datenum(datesdy),datesmh),:);                         % end-of-month dataset

% Surveys
ttsvy   = ttsvy(ttsvy.Date < date2,:);                                         	% end of sample
datesqt = ttsvy.Date;
datesqt = unique(lbusdate(year(datesqt),month(datesqt)));                       % end-of-month dates
datesqt(ismember(datesqt,datesxc(end))) = datesxc(end) - 1;                     % deal w/ special date
ttsvy.Date = datetime(datenum(datesqt),'ConvertFrom','datenum');

% Merged dataset
TTycsv = synchronize(TTusyc,ttsvy);                                             % merge yields and surveys
writetimetable(TTycsv,fullfile(pathd{2},'USYCSVYdata.xlsx'))
end


function TTcrsp = read_crsp()
% READ_CRSP Read U.S. Treasury bill yields from CRSP
%   TTcrsp: stores historical daily data in a timetable
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw');                            % platform-specific file separators
namefl = 'CRSP_TFZ_DLY_RF2.xlsx';                                       	% risk-free daily

cd(pathd)
opts  = detectImportOptions(namefl);
opts  = setvartype(opts,opts.VariableNames(contains(opts.VariableNames,'CALDT')),'datetime');
ttaux = readtimetable(namefl,opts);
ttaux.Properties.DimensionNames{1} = 'Date';
ttaux(isnat(ttaux.Date),:) = [];                                            % delete extra rows
ttaux.TYLDA = ttaux.TDYLD*365*100;                                          % annualized percent
TTcrsp = ttaux(ttaux.KYTREASNOX == 2000062,{'TYLDA'});
TTcrsp.Properties.VariableNames = {'M3YLD'};
cd(pathc)
end