function [yields_expected,explained] = expected_yields(ydata)

%% Delete
%% Already included within atsm.m

nobs    = size(ydata,1);
npc     = 3;                                 % Number of principal components

% Obtain the state variables as factors of the yields
[~,factors,~,~,explained] = pca(ydata,'NumComponents',npc);

% Dynamics of the state variables
y = factors(2:end,:);
T = size(y,1);
x = [ones(T,1) factors(1:end-1,:)];
b = (x'*x)\x'*y;
u = y - (x*b);
C = (u'*u)/T;
mu    = b(1,:)';
phi   = b(2:end,:)';
sigma = chol(C)';

% Dynamics of the short-term interest rate
r = ydata(:,1);
X = [ones(numel(r),1) factors];
delta  = (X'*X)\X'*r;
delta0   = delta(1);
delta1   = delta(2:end);

I = eye(size(phi));
Ey = r;
aux = r;
for h = 1:10
    phi_h = phi^h;
    EX = repmat(mu',nobs,1)*((I - phi)\(I - phi_h))' + factors*phi_h';
    Er = repmat(delta0,nobs,1) + EX*delta1;
    Ey = Ey + Er;
    aux = [aux Ey];
end

nrates = 1:size(aux,2);
yields_expected = aux./nrates;

%Eyields = Eyields(:,2:end);
