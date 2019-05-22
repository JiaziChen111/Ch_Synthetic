%% Test for Own KF

% Similar to Example 6.5 in Shumway & Stoffer
rng(1)
num = 50;
w  = randn(num+1,1);
v  = randn(num,1);
mu = cumsum(w);
mu = mu(2:end);
y  = mu + v;
[llk,atp1t,Ptp1t,att,Ptt,atT,PtT] = kfs(y',0,1,1,0,1,1);

time = 1:num;
subplot(3,1,1)
plot(time,mu,'o'), hold on
plot(time,atp1t'), hold on
plot(time,atp1t'+2*sqrt(squeeze(Ptp1t)),'--'), hold on
plot(time,atp1t'-2*sqrt(squeeze(Ptp1t)),'--'), hold off

subplot(3,1,2)
plot(time,mu,'o'), hold on
plot(time,att'), hold on
plot(time,att'+2*sqrt(squeeze(Ptt)),'--'), hold on
plot(time,att'-2*sqrt(squeeze(Ptt)),'--'), hold off

subplot(3,1,3)
plot(time,mu,'o'), hold on
plot(time,atT'), hold on
plot(time,atT'+2*sqrt(squeeze(PtT)),'--'), hold on
plot(time,atT'-2*sqrt(squeeze(PtT)),'--'), hold off


% Example 6.5 in Textbook

% mu = [-0.6264538	-0.4428105	-1.2784391	0.3168417	0.6463495	-0.1741189	0.3133101...
%     1.0516348	1.6274162	1.3220278	2.833809	3.2236522	2.6024116	0.3877118...
%     1.5126427	1.4677091	1.4515188	2.395355	3.2165762	3.8104775	4.7294549...
%     5.5115912	5.5861562	3.5968045	4.2166302	4.1605015	4.004706	2.5339536...
%     2.0558035	2.4737451	3.8324247	3.7296369	4.1173085	4.0635035	2.6864439...
%     2.2714494	1.8771594	1.817846	2.9178714	3.6810472	3.5165236	3.2631619...
%     3.9601252	4.5167884	3.8280328	3.1205376	3.4851196	4.2536525	4.1413063...
%     5.022414	5.4205199];
% mu = mu(2:end);
% y = [-1.05483688	-0.937319408	-0.812521393	2.079373177	1.806280989	-0.053911333...
%     0.007500222	2.197135828	1.186973209	5.235426742	3.184412215	3.292151	0.415713909...
%     0.769369459	1.656501359	-0.353439833	3.860909868	3.36982954	5.983089193	5.204964424...
%     4.801644765	6.196882532	2.662706851	2.962996831	4.451947727	3.561414111	2.535058952...
%     2.13014487	1.88422416	3.263755925	3.594458315	5.295395538	2.539936701	3.280390132...
%     2.604399752	2.940259264	1.513662107	3.287890212	3.948145942	2.974003524	4.47102968...
%     5.120527866	5.217002098	5.414866209	3.679024023	2.208527351	3.680387069	2.916693657...
%     4.549013362	4.800153201];
% [logllk,xp,Pp,xf,Pf,xs,Ps] = kfs(y,mu_y,A,R,mu_x,Phi,Q);
% mu_y = 0; A = 1; R = 1; mu_x = 0; Phi = 1; Q = 1;
% [logllk,xp,Pp,xf,Pf,xs,Ps] = kfs(y,0,1,1,0,1,1);

% Compare against Chen
Z = C;
C = zeros(2,1);
H = S;
D = zeros(3,1);
T = A;
Q = G;
a00 = mu0;
P00 = P0;
p = size(T,1);
y = x;
[q,N] = size(y);
% [llk,atp1t,Ptp1t,att,Ptt,atT,PtT] = kfs(y,C,Z,H,D,T,Q)
% [llk,atp1t,Ptp1t,att,Ptt,atT,PtT] = kfs(x,zeros(2,1),C,S,zeros(3,1),A,G);

% Compare against JSZ
% [x_tm1t, P_tm1t, x_tt, P_tt, K_t, llks] = kf(y, Phi, alpha, A, b, Q, R, x00, P00);
[x_tm1t, P_tm1t, x_tt, P_tt, K_t, llks] = kf(x, A, zeros(3,1), C, zeros(2,1), G, S, mu0, P0);


%% Compare EM_algo.m with script_demo.m in SPXEM

p = 3;
[logllk,mu_y,A,R,mu_x,Phi,Q,xs,Ps] = EM_algo(Y,p);
scatter(params.X(3,:),xs(3,:))
Yspxem = params.A + params.B*params.X;
yown = mu_y + A*xs;

[~,PCchen] = pca(Yspxem','NumComponents',p);
[~,PCsown] = pca(yown','NumComponents',p);
plot([PCchen(:,1) PCsown(:,1)])

l = 1; % l = 1, 2, ..., 10
plot([Yspxem(l,:),yown(l,:)])
corrcoef(Yspxem(l,:),yown(l,:))
scatter(Yspxem(l,:),yown(l,:))


%% Compare EM_algo.m with Example 6.8 in ASTSA

y = [-2.59812649	-0.320719	0.5351291	1.04055796	1.219738	0.32085266...
    -0.63880656	-2.67812664	-1.45002796	-0.84081963	-0.2730255	-1.61560705	0.17543835...
    -2.36007291	-2.04035971	-1.52963978	-1.94644488	-2.04883788	-2.39976274	-2.23872288...
    -0.15846856	-0.05532994	-0.07551095	0.6603639	1.57150402	1.47781865	0.65038867...
    0.99769674	1.13375776	1.57269715	-1.01821	-1.21081015	0.17759712	0.19598912...
    1.53609156	0.42982525	1.17053789	0.13294586	-0.44848732	-2.1361048	-0.30855829...
    -0.86710284	-0.57248573	0.95243452	0.3691917	1.12825663	0.78560276	-0.03529483...
    -0.6034708	-1.58118042	-0.27610934	-1.70997969	0.63782066	-0.27420433	-0.1045136...
    -2.31334478	-1.41120264	-1.94991989	-0.41327865	1.18065103	0.80120589	2.04530768...
    2.86883629	0.44435485	1.62997579	-0.62720584	1.77412792	0.83881532	-0.9245922...
    -1.0094511	0.13408006	-3.07751775	0.72319888	-1.04155172	-1.3654258	1.05971365...
    -1.71920838	-1.56730187	-0.66014813	-1.09825872	-2.59271482	-0.22317913	-3.17365379...
    -2.98702309	-5.3353737	-4.91623055	-2.83902187	-3.00231787	-0.05061561	-2.24796983...
    -0.35489788	-0.35210939	-1.88766166	-3.58840598	-4.3868552	-0.87709202	-3.57479724...
    0.66317866	0.98440079	-0.31336108];

maxIter = 2000;     tol = 1e-4;
logllk  = -inf(1,maxIter);

mu_y = 0;
A = 1;
R = 1.059089;
mu_x = 0;
Phi = 0.8097511;
Q = 0.2608199;

%% Compare EM_algo.m with Chen Code

% Change pre-specified dimensions in Chen's example from d = 2 to d = 3 and C
% Run Chen's code
p = 3;
[logllk,mu_y,A,R,mu_x,Phi,Q,xs,Ps] = EM_algo(x,p);
scatter(nu(3,:),xs(3,:))
ychen = tmodel.C*nu;
yown = mu_y + A*xs;

[~,PCchen] = pca(ychen','NumComponents',p);
[~,PCsown] = pca(yown','NumComponents',p);
l = 1; % l = 1, 2, 3
plot([PCchen(:,l) PCsown(:,l)])

plot([ychen(l,:),yown(l,:)])
corrcoef(ychen(l,:),yown(l,:))
scatter(ychen(l,:),yown(l,:))


%% Compare SPXEM vs Chen

% Run script_demo.m
ySpxem = params.A + params.B*params.X;

% Change to Chen's directory and run lines below
model.A = params0.F;
model.G = params0.Q;
model.C = params0.B;
model.S = params0.R;
k = size(model.G,1);
n = size(Y,2);
mu0 = zeros(k,1);
P0 = eye(k);
model.mu0 = mu0;
model.P0 = P0;
[mu, V, llh] = kalmanFilter(model,Y);
[nu, U, llh] = kalmanSmoother(model,Y);
[tmodel, llh] = ldsEm(Y,k);
nu = kalmanSmoother(tmodel,Y);
yChen = tmodel.C*nu;

[~,PCchen] = pca(ySpxem','NumComponents',k);
[~,PCspxem] = pca(yChen','NumComponents',k);
l = 1; % l = 1, 2, 3
plot([PCspxem(:,l) PCchen(:,l)])

plot([ySpxem(l,:),yChen(l,:)])
corrcoef(ySpxem(l,:),yChen(l,:))
scatter(ySpxem(l,:),yChen(l,:))

%% Compare SPXEM against S&S
ySS = csvread('/Users/Pavel/Documents/GitHub/Book/Codes_External/astsa/ySS.csv',1,1);
[~,PCss] = pca(ySS','NumComponents',k);
l = 1; % l = 1, 2, 3
plot([PCspxem(:,l) PCss(:,l)])

plot([ySpxem(l,:),ySS(l,:)])
corrcoef(ySpxem(l,:),ySS(l,:))
scatter(ySpxem(l,:),ySS(l,:))

%% S&S code in Matlab: Examples 6.5 and 6.8

y = [-1.05483688	-0.937319408	-0.812521393	2.079373177	1.806280989	-0.053911333...
    0.007500222	2.197135828	1.186973209	5.235426742	3.184412215	3.292151	0.415713909...
    0.769369459	1.656501359	-0.353439833	3.860909868	3.36982954	5.983089193	5.204964424...
    4.801644765	6.196882532	2.662706851	2.962996831	4.451947727	3.561414111	2.535058952...
    2.13014487	1.88422416	3.263755925	3.594458315	5.295395538	2.539936701	3.280390132...
    2.604399752	2.940259264	1.513662107	3.287890212	3.948145942	2.974003524	4.47102968...
    5.120527866	5.217002098	5.414866209	3.679024023	2.208527351	3.680387069	2.916693657...
    4.549013362	4.800153201]';
% [xp,Pp,xf,Pf,like,innov,sig,Kn] = Kfilter0(num,y,A,mu0,Sigma0,Phi,cQ,cR);
[xpSS,PpSS,xfSS,PfSS,likeSS,innov,sig,Kn] = Kfilter0(50,y,1,0,1,1,1,1);
[xsSS,PsSS,x0n,P0n,J0,J,xpSS,PpSS,xfSS,PfSS,like,Kn] = Ksmooth0(50,y,1,0,1,1,1,1);
[logllk,xp,Pp,xf,Pf,xs,Ps] = kfs(y',0,1,1,0,1,1);


% Get data (same as Example 6.6)
x = csvread('/Users/Pavel/Documents/GitHub/Book/Codes_External/astsa/Ex6_8_x.csv',1,1);
y = csvread('/Users/Pavel/Documents/GitHub/Book/Codes_External/astsa/Ex6_8_y.csv',1,1);
% Initial Estimates (same as Example 6.6)
u = [y(3:end) y(2:end-1) y(1:end-2)];
varu = cov(u); coru = corr(u);
phi = coru(1,3)/coru(1,2);
q = (1-phi^2)*varu(1,2)/phi;
r = varu(1,1) - q/(1-phi^2);
% EM procedure - output not shown
% [Phi,Q,R,mu0,Sigma0,llk,iter,cvg] = EM0(num,y,A,mu0,Sigma0,Phi,cQ,cR,max_iter,tol);
[phi,Q,R,mu0,Sigma0,llk,iter,cvg] = EM0(100,y,1,0,2.8,phi,sqrt(q),sqrt(r),75,1e-5);
% to evaluate likelihood at estimates
para = [phi sqrt(Q) sqrt(R)];
output = [para'; mu0; Sigma0]
% hessian(Linn,para)
% function like = Linn(para)
%     y = csvread('/Users/Pavel/Documents/GitHub/Book/Codes_External/astsa/Ex6_8_y.csv',1,1);
%     [~,~,~,~,like,~,~,~] = Kfilter0(100, y, 1, -1.964872, 0.02227538, para(1), para(2), para(3));
% end

%% Compare Chen vs S&S (without estimating A)

% Run Chen's code with d = 2
yChen = tmodel.C*nu;
k = 3;
n = 20;
% Use same initial values from function model = init(X, k) in ldsEm.m
[A,C,Z] = ldsPca(x,k,3*k);
model.mu0 = Z(:,1);
E = Z(:,1:end-1)-Z(:,2:end);
model.P0 = (dot(E(:),E(:))/(k*size(E,2)))*eye(k);
model.A = A;
E = A*Z(:,1:end-1)-Z(:,2:end);
model.G = E*E'/size(E,2);
model.C = C;
E = C*Z-x(:,1:size(Z,2));
model.S = E*E'/size(E,2);

Phi = model.A;
Q = model.G;
A = tmodel.C;   % Note that it uses the optimal C (not its initial value)
R = model.S;
mu0 = model.mu0;
Sigma0 = model.P0;

y = x';
[Phi,Q,R,mu0,Sigma0,llk,iter,cvg] = EM0(n,y,A,mu0,Sigma0,Phi,chol(Q),chol(R),2000,1e-4);
[xsSS,PsSS] = Ksmooth0(n,y,A,mu0,Sigma0,Phi,chol(Q),chol(R));
ySS = A*squeeze(xsSS);

k = 2;
[~,PCchen] = pca(yChen','NumComponents',k);
[~,PCss] = pca(ySS','NumComponents',k);
l = 2; % l = 1, 2, 3
figure
plot([PCss(:,l) PCchen(:,l)])

% plot([ySS(l,:),yChen(l,:)])
corrcoef(ySS(l,:),yChen(l,:))
% scatter(ySS(l,:),yChen(l,:))

figure
hold on
plot(x(1,:), x(2,:), 'ro');
plot(ySS(1,:), ySS(2,:), 'b*-');
legend('observed', 'learned')
title('LDS EM learning')
axis equal
hold off

figure
hold on
plot(x(1,:), x(2,:), 'ro');
plot(yChen(1,:), yChen(2,:), 'b*-');
legend('observed', 'learned')
title('LDS EM learning')
axis equal
hold off

%% Compare Chen vs S&S (WITH estimating A)

% In che_code directory: Run Chen's code with d = 2
yChen = tmodel.C*nu;
k = 3;
n = 20;
% Use same initial values from function model = init(X, k) in ldsEm.m
[A,C,Z] = ldsPca(x,k,3*k);
model.mu0 = Z(:,1);
E = Z(:,1:end-1)-Z(:,2:end);
model.P0 = (dot(E(:),E(:))/(k*size(E,2)))*eye(k);
model.A = A;
E = A*Z(:,1:end-1)-Z(:,2:end);
model.G = E*E'/size(E,2);
model.C = C;
E = C*Z-x(:,1:size(Z,2));
model.S = E*E'/size(E,2);

% In astsa directory
Phi = model.A;
Q = model.G;
A = model.C;
R = model.S;
mu0 = model.mu0;
Sigma0 = model.P0;

y = x';
[Phi,Q,A,R,mu0,Sigma0,llk,iter,cvg] = EM0wA(n,y,A,mu0,Sigma0,Phi,chol(Q),chol(R),2000,1e-4);
[xsSS,PsSS] = Ksmooth0(n,y,A,mu0,Sigma0,Phi,chol(Q),chol(R));
ySS = A*squeeze(xsSS);

k = 2;
[~,PCchen] = pca(yChen','NumComponents',k);
[~,PCss] = pca(ySS','NumComponents',k);
l = 2;
plot([PCss(:,l) PCchen(:,l)])

% plot([ySS(l,:),yChen(l,:)])
corrcoef(ySS(l,:),yChen(l,:))
% scatter(ySS(l,:),yChen(l,:))

%% Compare SPXEM vs S&S (WITH estimating A) -- Works

% In spxem directory: Run script_demo.m
k = K;
n = T;
y = Y';
ySPXEM = params.A + params.B*params.X;
[x0,Sx0]=stationaryEV(params0.E,params0.F,params0.Q);

% In astsa directory
Phi = params0.F;
Q   = params0.Q;
A   = params0.B;
R   = params0.R;
mu0 = x0;
Sigma0 = Sx0;

[Phi,Q,A,R,mu0,Sigma0,llk,iter,cvg] = EM0wA(n,y,A,mu0,Sigma0,Phi,chol(Q),chol(R),2000,1e-4);
[xsSS,PsSS] = Ksmooth0(n,y,A,mu0,Sigma0,Phi,chol(Q),chol(R));
ySS = A*squeeze(xsSS);

[~,PCspxem] = pca(ySPXEM','NumComponents',k);
[~,PCss] = pca(ySS','NumComponents',k);
for l = 1:k
    figure
    plot([PCss(:,l) PCspxem(:,l)])
end
for l = 1:size(y,2)
    corrcoef(ySS(l,:),ySPXEM(l,:))
end

%% Testing EM0wAnC against SPXEM - It works!

num = T;
p = K;
q = N;
y = Y';
Phi = params0.F;
Q   = params0.Q;
A   = params0.B;
R   = params0.R;
mu0 = x0;
Sigma0 = Sx0;
cQ  = chol(Q);
cR  = chol(R);
mu_y = zeros(q,1);
mu_x = zeros(p,1);
max_iter = 1;
tol = 1e-4;

% Run EM0wAnC with Run Section or run
[Phi,Q,A,R,EF,QEF,AB,RAB,mu0,Sigma0,llk,iter,cvg] = EM0wAnC(num,y,A,mu0,Sigma0,Phi,cQ,cR,mu_y,mu_x,max_iter,tol);
% Phi = EF, A = AB, Q = QEF and R~=RAB


%% Estimating DLM Using fminunc and JSZ Data - Doesn't work

% In JSZ directory
% clear
% load('sample_RY_model_jsz.mat')
% load('sample_zeros.mat')
% [BcP, AcP, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, K0Q_X, K1Q_X, AX, BX, Sigma_X] = ...
%     jszLoadings(W, K1Q_X, kinfQ, Sigma_cP, mats, dt);
% zyields_m = ones(length(dates),1)*AcP + (yields*W.')*BcP;

% In SPXEM directory
% Y = yields';
% K = 3;
% [~,params00]  = LSSMinit(Y,K);
% [mu0,Sigma0] = stationaryEV(params00.E,params00.F,params00.Q);

% In ASTSA directory
[N,T] = size(Y);
num = T;
p = K;
q = N;
y = Y';
dt = 1/12;

r = max(p,q);
params0 = nan(8,r*r);
params0(1,1:q)   = reshape(zeros(q,1),[1,q]); % mu_Q
params0(2,1:q*p) = params00.B(:)'; % PhiQ
params0(3,1:p)   = reshape(zeros(p,1),[1,p]); % mu_P
params0(4,1:p*p) = params00.F(:)'; % PhiP
params0(5,1)     = 0; % rho0
params0(6,1:p)   = [mean(y(:,1)); 0; 0]'; % rho1
params0(7,1:p*p) = reshape(chol(params00.Q),[1,p*p]); % cQ
params0(8,1:q*q) = reshape(chol(params00.R),[1,q*q]); % cR

% params0(2) = params00.B; % PhiQ
% params0(3) = zeros(p,1); % mu_P
% params0(4) = params00.F; % PhiP
% params0(5) = 0; % rho0
% params0(6) = [mean(y(:,1)) 0 0]; % rho1
% params0(7) = chol(params00.Q); % cQ
% params0(8) = chol(params00.R); % cR

% [Phi,Q,A,R,EF,QEF,AB,RAB,mu0,Sigma0,llk,iter,cvg] = EM0wAnC(num,y,A,mu0,Sigma0,Phi,cQ,cR,mu_y,mu_x,max_iter,tol);
% [xsSS,PsSS] = Ksmooth0wC(num,y,A,mu0,Sigma0,Phi,chol(Q),chol(R),AB(:,1),EF(:,1));


objfun = @(params) logllkKF(params,num,y,mu0,Sigma0,dt,q,p);
params = fminunc(objfun,params0);

mu_Q = reshape(params(1,1:q),[q,1]);
PhiQ = reshape(params(2,1:q*p),[q,p]);
mu_P = resahpe(params(3,1:p),[p,1]);
PhiP = reshape(params(4,1:p*p),[p,p]);
rho0 = params(5,1);
rho1 = reshape(params(6,1:p),[p,1]);
cQ   = reshape(params(7,1:p*p),[p,p]);
cR   = reshape(params(8,1:q*q),[q,q]);

% mu_Q = params{1};
% PhiQ = params{2};
% mu_P = params{3};
% PhiP = params{4};
% rho0 = params{5};
% rho1 = params{6};
% cQ   = params{7};
% cR   = params{8};

SigmaX  = cQ'*cQ;
rho0dt  = rho0*dt;
rho1dt  = rho1*dt;
[Ay,By] = Yloadings(maturities,mu_Q,PhiQ,SigmaX,rho0dt,rho1dt,dt);
[xs,Ps] = Ksmooth0wC(num,y,By,mu0,Sigma0,PhiP,cQ,cR,Ay,mu_P);
ySS = Ay*ones(1,T) + By*squeeze(xsSS);
ySS = ySS';

k = K;
[~,PCjsz] = pca(yields,'NumComponents',k);
[~,PCss] = pca(ySS,'NumComponents',k);
l = 1;
plot([PCss(:,l) PCjsz(:,l)])
corrcoef(ySS(l,:),yields(l,:))


function like = logllkKF(params,num,y,mu0,Sigma0,dt,q,p)
mu_Q = reshape(params(1,1:q),[q,1]);
PhiQ = reshape(params(2,1:q*p),[q,p]);
mu_P = resahpe(params(3,1:p),[p,1]);
PhiP = reshape(params(4,1:p*p),[p,p]);
rho0 = params(5,1);
rho1 = reshape(params(6,1:p),[p,1]);
cQ   = reshape(params(7,1:p*p),[p,p]);
cR   = reshape(params(8,1:q*q),[q,q]);

% mu_Q = params{1}; % muQ  = mu_x - cQ*lambda0;
% PhiQ = params{2}; % PhiQ = Phi - cQ*lambda1;
% mu_P = params{3};
% PhiP = params{4};
% rho0 = params{5};
% rho1 = params{6};
% cQ   = params{7};
% cR   = params{8};

SigmaX = cQ'*cQ;
rho0dt = rho0*dt;
rho1dt = rho1*dt;

[Ay,By] = Yloadings(maturities,mu_Q,PhiQ,SigmaX,rho0dt,rho1dt,dt);
[~,~,~,~,~,~,~,~,~,~,like,~] = Kfilter0wC(num,y,By,mu0,Sigma0,PhiP,cQ,cR,Ay,mu_P);
end

%% Modification of before loadings4ylds.m
% % M  = length(mats);
% F  = length(mu);
% % Ay = nan(1,M);      An = 0;
% % By = nan(F,M);      Bn = zeros(F,1);
% % curr_mat = 1;
% 
% Mmat = max(mats);
% Ay = nan(1,Mmat);      An = 0;
% By = nan(F,Mmat);      Bn = zeros(F,1);
% % An = nan(1,Mmat);
% % Bn = nan(F,Mmat);
% 
% for k  = 1:Mmat%mats(M)
%     % Loadings for prices for every period
%     An = -rho0dt + An + mu'*Bn + 0.5*Bn'*Hcov*Bn;
%     Bn = -rho1dt + Phi'*Bn;
%     
%     yrs = k*dt;
%     Ay (1,k) = -An/yrs; By(:,k) = -Bn/yrs;
%     % Loadings for yields at specified maturities
% %     if k == mats(curr_mat)
% %         [An mats(curr_mat)]
% %         [Bn' mats(curr_mat)]
% %         Ay(1,curr_mat) = -An/-1;%mats(curr_mat);
% %         By(:,curr_mat) = -Bn/-1;%mats(curr_mat);
% %         curr_mat = curr_mat + 1;
% %     end
% end
% 
% % % Annualized loadings for yields
% % Ay = Ay/dt;
% % By = By/dt;
% Ay = Ay(1,mats);
% By = By(:,mats);

%% From daily2monthly.m

% aux1 = struct2cell(S)';
% aux2 = fieldnames(S);
% curncs = aux1(:,strcmp(aux2,'iso'));              % Extract iso currency codes

% fltrMTY = ~ismember(header_daily(:,2),'OIS') & ~ismember(header_daily(:,2),'FFF') & ...
%     ~isnan(tnrs_all) & tnrs_all > 0;
% mtrts   = unique(tnrs_all(fltrMTY));
% times   = linspace(0,max(tnrs_all));                      % Used for plots

        % date    = data_lc(l,1);
%         ydataLC = data_lc(l,2:end)';                        % Column vector
%         idxY    = ~isnan(ydataLC);                          % sum(idxY) >= 5, see above
        % ydataLC = ydataLC(idxY);
%         tnrs1   = tnrs(idxY);  
% sum(idxObs);%numel(tnrs1);

% Header
% hdr_lc    = construct_monthly_hdr(mtrts,YCtype,1);

%     yieldsINT = yieldsNOK;
    % yieldsINT(74,colsMSS) = yieldsNOK(73,colsMSS);
%     yieldsINT(74:81,colsMSS) = repmat(yieldsNOK(82,colsMSS),8,1);
% S(23).blncd(2:end,2:end) = yieldsINT;


% S(23).(fnameb)(74:81,colsMSS) = repmat(yldsNOK(82,colsMSS),8,1);

%% From tp_estimation.m
%     W  = pcacov(cov(yields));
%     W  = W(:,1:N)';
%     cP = yields*W';
%     yields_Q = ones(length(dates),1)*AcP + (yields*W.')*BcP;
%     yields_Q = ones(nobs,1)*AcP + cP_filtered*BcP;

    %     plot(dates,[PCs(:,1) PCs_kf(:,1)])                    % Compare with yields_filtered and cP_filtered

    % Term premium
%     [mu, Phi, Hcov] = VAR1(cP_filtered); % cP, PCs, cP_filtered
%     mu = K0P_cP; Phi = K1P_cP + eye(N); Hcov = Sigma_cP;
%     Hcov(:,:) = 0;
    maturities      = round(mats/dt);
%     [Ay,By]         = yld_loadings(maturities,mu,Phi,Hcov,delta0*100,delta1*100,dt);
%     [Ay,By]         = yld_loadings(maturities,mu,Phi,Hcov,rho0_cP*dt,rho1_cP*dt,dt);
%     [Ay,By]         = loadings4ylds(maturities,mu,Phi,Hcov,delta0,delta1,dt);
    [Ay,By]         = loadings4ylds(maturities,mu,Phi,Hcov,rho0_cP*dt,rho1_cP*dt,dt);
    yields_P      = ones(nobs,1)*Ay + cP_filtered*By; % cP, PCs, cP_filtered
    
    tp_synt     = (yields_Q - yields_P)*100;            % TP in percentage points
    S(k).tpsynt = [nan mats; nan mean(tp_synt); dates tp_synt];

    
    % tpavg = 0;
% for k = 1:15
%     if k == [1 4 9 10]
%         continue
%     end
%     tpavg = tpavg + S(k).tpsynt(2, S(k).tpsynt(1,:) == 10);
% end
% tpavg = tpavg/11;
    

%% Compare IP vs GDP data per country

for k = 1:15
    figure
    plot(S(k).ip(:,1),S(k).ip(:,2))
    if size(S(k).gdp,2) > 1
        hold on
        plot(S(k).gdp(:,1),S(k).gdp(:,2))
    end
    title(S(k).iso)
    legend('IP','GDP')
    datetick('x','YYQQ')
end

%% From estimate_TR.m

for k = 2 % Colombia, it adds 10 data points to GDP but makes little difference in outcome of regression
    temp = [2.7000    3.9000    4.2000    4.1000    3.9000    4.0000    3.5000    4.8000    5.2000    5.2000];
    TblQtr.GDP(15:24) = temp;
    
    idxIP  = ismember(TblQtr.Properties.VariableNames,{'INF','IP','CBP'});
    TblIP  = [TblQtr(2:end,idxIP) TblCBP];
    TblIP  = movevars(TblIP,'CBPlag','Before',1);
    tIP    = sum(~any(ismissing(TblIP),2));
    MdlIP  = fitlm(TblIP)
end

%% From compare_atsm_surveys.m

% z1 = S(1).nomdata;
% z2 = S(1).srvyldsE;
% z1 = [z1(:,1) z1(:,z1(1,:) == 10)];
% z1 = z1(2:end,:);
% z3 = ismember(z1(:,1),z2(:,1));
% sum(z3)
% z4 = ismembertol(z1(:,1),z2(:,1),4,'DataScale', 1);
% sum(z4) % 22
% z5 = datestr(z1(z4,1)); % Dates of z1 in terms of z2
% 
% z6 = ismembertol(z2(:,1),z1(:,1),4,'DataScale', 1);
% sum(z6) %% 22
% z7 = datestr(z2(z6,1));
% 
% periodicity = unique(month(ylds_svy6m(:,1)))'; % Months in which CE publishes LT forecasts
% ylds_nom6m = end_of_period(ylds_nom,periodicity); % Nominal yields with same frequency as surveys
% 
% dates_nom = ylds_nom6m(:,1);
% dates_svy = ylds_svy6m(:,1);
% 
% min_nom = min(dates_nom);   max_nom = max(dates_nom); 
% min_svy = min(dates_svy);   max_svy = max(dates_svy);
% 
% ylds_nom6m = dataset_in_range(ylds_nom6m,min_svy,max_svy);
% ylds_svy6m = dataset_in_range(ylds_svy6m,min_nom,max_nom);
% 
% function dataset_period = end_of_period(dataset_monthly,periodicity)
% % This function returns end-of-period observations from a dataset containing
% % monthly observations (e.g. every six months). All columns are preserved.
% %
% %     INPUT
% % double: dataset_monthly - monthly observations as rows (top-down is first-last obs), col1 has dates
% % double: periodicity - months for which observations will be extracted (e.g. [4 10])
% %
% %     OUTPUT
% % dataset_period - end-of-period observations as rows, same columns as input
% %
% % Pavel Solís (pavel.solis@gmail.com), May 2019
% %%
% dates          = dataset_monthly(:,1);
% mnths          = month(dates);
% idxPeriod      = any(mnths == periodicity,2);
% dataset_period = dataset_monthly(idxPeriod,:);



