% Longest history (works)
b =0;
for i = 1:numel(tickers)
    if ~isempty(data{i,1})
    a = numel(data{i,1}(:,1));
    if b < a; b = a; end
    end
end
% in one line
max(sum(~isnan(data)))

% Write all the dates in an Excel file (does not work as expected)
tickersT = tickers';
tickersT = [1, tickersT];
dates = datestr(data{2,1}(:,1),'mm/dd/yyyy'); % ticker with longest history
nd = size(dates,1);
nt = numel(tickersT);
A{nd,nt}={};
% A(1,:)=tickersT; % headers
% for i = 1:size(dates,1)
%     A{i+1,1} = dates(i,:);
% end
% 
% fst = 1;
% for i = 1:11
%     lst = 256*i;
%     xlRng = ['A' num2str(fst)];
%     if lst > (nd + 1); lst = nd + 1; end
%     xlswrite('test.xlsx',A(fst:lst,:),1,xlRng)
%     fst = lst + 1;
% end

xlswrite('test.xlsx',A(1,:),1,'A1')
fst = 2;
for i = 1:11        % Excel does not allow to write more than 256 rows
    lst = 256*i + 1;
    xlRng = ['A' num2str(fst)];
    if lst > (nd + 1); lst = nd + 1; end
    xlswrite('test.xlsx',A(fst:lst,:),1,xlRng)
    fst = lst + 1;
end


% What dates are not in one of the sets
a = datenum('07/16/2008');
b = dateXl(dateXl >= a);
c = data{16,1}(:,1);
d = setdiff(b,c);
datestr(d)

% Used in extractvars
a = [7, 1, 3, 9, 8]
[b,c] = min(a)
d = ~ismember(a,b)

for i = a(d)
    i
end

% Used in first two lines of matchtnr.m
% tnr1 = cellfun(@num2str,tnr1,'UniformOutput',false); % ismember requires strings
% tnr2 = cellfun(@num2str,tnr2,'UniformOutput',false);

% Used in ccs.m at the end of constructing the database
%tnr_hdr = ccs_hdr(2:end,2);
%tmp_hdr = cellfun(@num2str,ccs_hdr(2:end,2),'UniformOutput',false);
%ccs_hdr(:,2) = [ccs_hdr(1,2); tmp_hdr];

% Dates used when extracting US yield curve
%datenum('2005-01-01','yyyy-mm-dd'); % Define relative to min/max in dateXl
%datenum('2014-12-31','yyyy-mm-dd');


% Convert tenors from char to double and take the max
c = cellfun(@str2num,ccs_hdr(2:end,2),'UniformOutput',false);
max(cell2mat(c));

% Repeat content in a cell array
B = cell(3,2);
[B{:,1}] = deal('hi');

% Before construct_hdr
% A = cell(tnrmax,5);
% [A{:,1}] = deal(currency);
% [A{:,2}] = deal(type);
% [A{:,3}] = deal(ticker{:});
% [A{:,4}] = deal(name);
% 
% aux1  = 1:tnrmax;
% aux2  = cellstr(num2str(aux1'));
% old = ' '; new = '';
% tenor = strrep(aux2(:),old,new);
% [A{:,5}] = deal(tenor{:});

% To construct headers
% C = strcat('CROSS-CURRENCY SWAP',{' '},hdr_ccs(2:end,2),' YR');
% B = construct_hdr(hdr_ccs(2:end,1), 'CCS', 'N/A', C, hdr_ccs(2:end,2));

% D = strcat('ZERO-COUPON YIELD',{' '},tenor,' YR');
% A = construct_hdr('USD', 'LC', ticker, D, tenor);

% From read_tickers_v4.m
%save ccs_info.mat lbounds sheets stacked summary

% Used in ccs.m
%ccs_type = [LCs, num2cell(ccs_frml)];          % LCs & fomulas in one cell
%nccs     = numel(ccs_type)/2;
%hdr_tmp  = {'h1','h2','h3','h4','h5'}; 
%[hdr_tmp{1:5}] = deal('hdr'); % Row 1 to match col 1 (dates), needed for fltrNaN
%[CCS,hdr] = compute_ccs(ccs_type{k,1},ccs_type{k,2},hdr_blp,data_blp);
%fltrNaN = findNaN(hdr_tmp, data_ccs, [1 2]);
% Clean the Database
% fltrNaN = findNaN(hdr_tmp, data_ccs);   % Find cols with all NaN
% data_ccs(:,fltrNaN) = [];               % Delete cols with no data
% hdr_tmp(fltrNaN,:)  = [];
% hdr_ccs = hdr_tmp(2:end,:);             % Remove extra row 1
%
%LC_once = LC_once(~strcmp(LC_once,'h1')); % Exclude header
%name_ccs = strcat('CROSS-CURRENCY SWAP',{' '},hdr_tmp(2:end,2),' YR');
%hdr_ccs = construct_hdr(hdr_tmp(2:end,1),'CCS','N/A',name_ccs,hdr_tmp(2:end,2)); No extra row 1
%save ccs_data.mat data_ccs hdr_ccs dates dataB tnrspercurr

% didn't work within the loop for compute_ccs because remove_NaNcols no yet run
%     ntnrperLC = sum(strcmp(hdr(:,1),LCs{k}));
%     tnrperLC  = [tnrperLC; LCs{k}, {ntnrperLC}];

% didn't use in read_data.m since hdr_blp has the row 1 with titles not hdr_usyc
%[dataset,header] = append_dataset(data_usyc, data_blp, hdr_usyc, hdr_blp);

% used in plots
%[hdr_tmp{1:5}] = deal('hdr');
%hdr_tmp   = [hdr_tmp; hdr_ccs];
hdr_LC   = hdr_tmp(fltr5yr,1);          % For title of figures
ccs5yr   = data_ccs(:,fltr5yr);         % 5 year CCS
ccs5yrMA = movmean(ccs5yr,10);          % To report results as in Du & Schreger (2016)
nLC      = size(ccs5yrMA,2);

% Subplot for all currencies
for k = 1:nLC
    subplot(4,4,k)
    plot(dates,ccs5yrMA(:,k))
    title(hdr_LC{k})
    datetick('x','yyyy')
end

% Plot for each currency
for k = 1:nLC
    figure
    plot(dates,ccs5yrMA(:,k))
    title(hdr_LC{k})
    datetick('x','yyyy')
end

%% Paper 'Components of Yield Curve Movements. Illustrative Worked Examples'
path = pwd;
cd(fullfile(path,'..','..','Data'))% Use platform-dependent file separators
filename = 'delete.xlsx';
[var_match] = xlsread(filename,2);
cd(pwd)

%% Data from GSW
path = pwd;
cd(fullfile(path,'..','..','Data'))% Use platform-dependent file separators
filename = 'original_US_Yield_Curve_Data.xlsx';
[dataGSW,txt] = xlsread(filename); % dataGSW only has values, txt includes headers and dates
cd(path)

times = linspace(1,10);
maturities = 1:10;
ydata = dataGSW(1,1:10);
x0 = dataGSW(1,[94:96 98]); % beta0, beta1, beta2, tau1
                            % good initial values for N-S model although from NSS model

% NS formulation for yields after integrating the instantaneous forward rate
% y_NS = @(b,xdata)b(1) + b(2)*((1-exp(-xdata/b(4)))./(xdata/b(4))) + ...
%     b(3)*((1-exp(-xdata/b(4)))./(xdata/b(4))-exp(-xdata/b(4)));
y_NS(params0,maturities)
plot(maturities,ydata,'ko',times,y_NS(params0,times),'b-')

options = optimoptions('lsqcurvefit','Display','off');
lb = []; ub = [];
x = lsqcurvefit(@y_NS,x0,maturities,ydata,lb,ub,options);  % NLS estimation of N-S model
y_NS(x,maturities)
plot(maturities,ydata,'ko',times,y_NS(x,times),'b-')

plot(times,y_NS(params0,times),'r-',times,y_NS(x,times),'b-.'); %compare

%% Previous version of read_usyc.m (did not read the N-S parameters)

path = pwd;
cd(fullfile(path,'..','..','Data'))% Use platform-dependent file separators
filename = 'original_US_Yield_Curve_Data.xlsx';
[dataGSW,txt] = xlsread(filename); % dataGSW only has values, txt includes headers and dates
cd(path)

% Headers
tnrmax = 10;                                % Maximum tenor needed is 10yrs
tckrUS = txt(10,2:(tnrmax+1))';             % Line 10 in GSW has the 'tickers'
%tckrUS = txt(10,[2:(tnrmax+1) 95:97 99])';
aux1   = 1:tnrmax;
aux2   = cellstr(num2str(aux1'));           % Cell with all the tenors as strings
old    = ' '; new = '';
tnr_usyc  = strrep(aux2(:),old,new);        % Remove spaces
name_usyc = strcat('USD ZERO-COUPON YIELD',{' '},tnr_usyc,' YR');
hdr_usyc  = construct_hdr('USD','HC',tckrUS,name_usyc,tnr_usyc); % HC - hard currency

% Dates
txt(1:10,:) = []; txt(:,2:end) = [];        % Only keep the dates from txt
dates_usyc   = datenum(txt);                % Convert dates from char to datenum

% Data
dataGSW  = dataGSW(:,1:tnrmax);             % Only keep yield curve data up to tnrmax
dataGSW  = [dates_usyc, dataGSW];           % Append the variables to the dates
%dataGSW  = [dates_usyc, dataGSW];
%dataGSW  = dataGSW(:,[1:(tnrmax+1) 95:97 99]);
[~,idx1] = sort(dates_usyc);                % Sort dates in ascending order
dataGSW  = dataGSW(idx1,:);                 % Reorder dataset from earliest to latest 

% Sample
date1st = min(dates);                       % 'dates' generated by read_bloomberg.m
dateEnd = max(dates);                       % Start and end dates relative to 'dates'
idx2    = (dataGSW(:,1) >= date1st) & (dataGSW(:,1) <= dateEnd); % Logical
dataGSW = dataGSW(idx2,:);                  % Limit the dataset to the sample dates
dates_usyc = dataGSW(:,1);

% Fill in missing dates (EMs have different holidays than the US)
nT = numel(dates);
[datesmiss,idx_miss] = setdiff(dates,dates_usyc); % Dates in 'dates' not in 'datesUSyc'
samedates = ~ismember(1:nT,idx_miss);       % Logical for same dates
data_usyc = zeros(nT,tnrmax + 1);           % Pre-allocate output
data_usyc(samedates,:) = dataGSW(:,:);      % Populate same dates with GSW data
data_usyc(idx_miss,1)  = datesmiss;
data_usyc(idx_miss,2:end) = data_usyc(idx_miss - 1,2:end); % Use previous values

clear aux1 aux2 idx1 idx2 old new datesmiss samedates idx_miss name_usyc 
clear date1st dateEnd filename txt dataGSW tnrmax tckrUS nT tnr_usyc dates_usyc

%% When using fit_nss (mixing N-S and Svensson)

options    = optimoptions('lsqcurvefit','Display','off'); lb = []; ub = [];
fltrLCRF   = ismember(header(:,2),'LCRF');      % 1 for countries with LC data
fltrPRM    = ismember(header(:,2),'PARAMETER'); % 1 for US NSS model parameters
times      = linspace(1,10);
maturities = 1:10;                              % Maturities wanted

k = ctrsLC{1};
fltrCTRY = ismember(header(:,1),k);
tnrs     = header(fltrCTRY & fltrLCRF,5);
tnrs     = cellfun(@str2num,tnrs,'UniformOutput',false);
tnrs     = cell2mat(tnrs);                      % Tenors available

lastobs = size(dataset,1);
datasetLCRF = [];
for l = 923:lastobs
    date    = dataset(l,1);
    ydataLC = dataset(l,fltrCTRY & fltrLCRF)';
    params0 = dataset(l,fltrPRM);                   % Good initial values for LC NSS model
    [params,ssr] = lsqcurvefit(@y_NSS,params0,tnrs,ydataLC,lb,ub,options); % NLS estimation
    yields  = y_NSS(params,maturities);             % Yields based on NSS
    plot(tnrs,ydataLC,'ko',times,y_NSS(params0,times),'b-',times,y_NSS(params,times),'r-')
    if ssr > 2                                      % Above mean when running only NSS
        params0 = params0([1:3 5]);                 % beta0 to beta2 and tau1
        [params1,ssr] = lsqcurvefit(@y_NS,params0,tnrs,ydataLC,lb,ub,options); % NLS estimation
        yields  = y_NS(params,maturities);          % Yields based on NS
        plot(tnrs,ydataLC,'ko',times,y_NS(params0,times),'b-',times,y_NS(params1,times),'r-')
        params = [params1(1:3) 0 params1(4) 0];     % Only to match dimensions
    end
    datasetLCRF = [datasetLCRF; date, yields, params, ssr];
    F(l) = getframe(gcf);
end

fig = figure;
movie(fig,F(923:end),1)

% ydataLC'
% y_NSS(params,tnrs)'
% plot(tnrs,ydataLC,'ko',times,y_NSS(params0,times),'b-')
% plot(tnrs,ydataLC,'ko',times,y_NSS(params,times),'b-')
%plot(times,y_NSS(params0,times),'r-',times,y_NSS(params,times),'b-.'); %compare

%clear k j fltrLCRF fltrPRM times maturities tnrs params0 ydataLC ydataUS options

% To see end of month computation
A = [dataset(:,1) dataset(:,fltrCTRY & fltrLCRF)];
t = datestr(dates);
idxT = ismember(dates,datasetLCRF);
t(idxT)


%% Previous version of fit_NS (use NSS when threshold in comments)

% Filters 
options    = optimoptions('lsqcurvefit','Display','off'); lb = []; ub = [];
fltrLCRF   = ismember(header(:,2),'LCRF');      % 1 for countries with LC data
fltrPRM    = ismember(header(:,2),'PARAMETER'); % 1 for US NSS model parameters
times      = linspace(0,10);
maturities = [0.25 1:10];                       % Maturities wanted

k = ctrsLC{1};

% Available tenors per country
fltrCTRY = ismember(header(:,1),k);
tnrs     = header(fltrCTRY & fltrLCRF,5);
tnrs     = cellfun(@str2num,tnrs,'UniformOutput',false);
tnrs     = cell2mat(tnrs);                      % Tenors available

% End of month data
idxDates = sum(~isnan(dataset(:,fltrCTRY & fltrLCRF)),2) > 4; 
data_lc  = dataset(idxDates,:);                 % Rows with at least 5 data points for NS
%idxEndMo = [diff(day(data_lc(:,1))); 0] < 0;    % 1 for last day of month; keep same dimension
idxEndMo = diff([day(data_lc(:,1)); 1]) < 0;    % 1 for last day of month; keep last observation
data_lc  = data_lc(idxEndMo,:);                 % Last available trading day per month

lastobs = size(data_lc,1);
dataset_lcrf = [];
for l = 1:lastobs
    date    = data_lc(l,1);
    params0 = data_lc(l,fltrPRM);               % Good initial values for LC NS model
    params1 = params0([1:3 5]);                 % Only need beta0 to beta2 and tau1
    
    params2 = lsqcurvefit(@y_NSS,params0,tnrs1,ydataLC,lb,ub,options);
    params2 = params2([1:3 5]); 
    
    % Available data may fluctuate between 5 and numel(tnrs)
    ydataLC = data_lc(l,fltrCTRY & fltrLCRF)';  % Column vector
    idxY    = ~isnan(ydataLC);                  % sum(idxY) >= 5, see above
    ydataLC = ydataLC(idxY);
    tnrs1    = tnrs(idxY);                       % Tenors with data
    
    % Non-linear least squares estimation of Nelson-Siegel
    [params1,ssr1] = lsqcurvefit(@y_NS,params1,tnrs1,ydataLC,lb,ub,options); % NLS estimation
    
    [params2,ssr2] = lsqcurvefit(@y_NS,params2,tnrs1,ydataLC,lb,ub,options); % NLS estimation

    if ssr1 < ssr2
        params = params1;
    else
        params = params2;
    end
    
%     if ssr > 3                                  % Alternative initial values
%         params2 = lsqcurvefit(@y_NSS,params0,tnrs1,ydataLC,lb,ub,options);
%         params1 = params2([1:3 5]);  
%         [params,ssr] = lsqcurvefit(@y_NS,params1,tnrs1,ydataLC,lb,ub,options);
%     end
    
% Original thresholds for ssr and yields(1)
        % Flag special cases and suggest potential solutions
        if ssr > 1                                  % Potential outliers
            yrs2drop  = suggest_yrs2drop(init_vals,tnrs1,ydataLC,lb,ub,options);
            flag_ssr = [flag_ssr; l yrs2drop]; end  
        if (yields(1) < 0) || (yields(1) > 20)    % Abnormal 3m implied yield
            yrs2drop  = suggest_yrs2drop(init_vals,tnrs1,ydataLC,lb,ub,options);
            flag_3mo = [flag_3mo; l yrs2drop]; end


    yields  = y_NS(params,maturities);          % Yields based on NS
    dataset_lcrf = [dataset_lcrf; date, yields, params, ssr];
    
    % Plot: actual, LC NS, US NSS
    %if key_ssr > 3
    plot(tnrs1,ydataLC,'ko',times,y_NSS(params0,times),'b-',times,y_NS(params,times),'r-')
    title(datestr(date))
    H(l) = getframe(gcf);
    %end
end

% idx_ssr = false(numel(H),1);    idx_ssr(flag_ssr) = true;
% idx_3mo = false(numel(H),1);    idx_3mo(flag_3mo) = true;
% idx_H   = idx_ssr | idx_3mo;

% idx_H = ~isnan(dropped(:,1));
% idx_H = [100:120];
% fig   = figure;
% movie(fig,H(idx_H),1,0.5)                            % Play once, 1 frame lasts 2 seconds

fig = figure;
% imshow(H(25).cdata)
movie(fig,H,1,1)                              % Play once, 1 frame lasts 2 seconds

%movie(fig,F([1 14 15 34:38 43 45 48 53 57 64 72 76]),1,0.5)

%clear k l lb ub fltrLCRF fltrPRM fltrCTRY tnrs tnrs1 params0 params1 params ssr
%clear idxDates idxEndMo idxY fig date options times maturities ydataLC yields


% Special cases

%     % Cases with outliers
%     data_lc([34 35],posY(1)) = NaN;             % 1 year
%     data_lc(112,posY(2)) = NaN;                 % Not flagged; correct hump shaped
%     data_lc(38,posY(3)) = NaN;                  % 3 years 
%     data_lc(14,posY(6)) = NaN;                  % 7 years
%     data_lc(53,posY(8)) = NaN;                  % 9 years
% 
%     % Correct negative 3 month implied yields
%     data_lc([25 67 69 70],posY(1)) = NaN;       % 1 year
%     data_lc(101,posY(2)) = NaN;                 % 2 years
%     data_lc([54 56 57],posY(8)) = NaN;          % 9 years

% n_changes  = 1:size(drop_ssr,1);
% n_per_col  = (n_changes'-1)*size(tnrs,1);   % Count previous elements at beginning of cols
% idx        = (tnrs == drop_ssr(:,2)');      % Logical matrix size(tnrs,1) x size(drop_ssr,1)
% global_pos = find(idx);                     % Position of tenors using linear indexing
% idxPos     = global_pos - n_per_col;        % Index with position of tenors for posY

%% Previous version of curr2imf.m (using sheets & defining EMEs)

%EMEs       = sheets(3:end);
%EMEs(2,:)  = {'BRA','COL','HUN','IDN','ISR','MEX','PER','PHL','POL','TUR',...
%    'KOR','MYS','RUS','THA','ZAF'};
%regexp(codes_iso(:,1),'\S*\s','match');    % Delete parenthesis
%regexprep(codes_iso(:,1),' \(\w*\)','')
%idx1     = ismember(EMEs(1,:),curr_code);
%iso_code = EMEs(2,idx1);
%idx2     = ismember(codes_imf(:,2),iso_code);

%% Previous version of final block in special_cases.m

% Find the data points to be dropped, save them, drop them and report them
    idxPos1  = yrs2tnrs(tnrs,drop_ssr);             % Location of the years within tnrs
    idxPos2  = yrs2tnrs(tnrs,drop_3mo);
    retrv    = [drop_ssr(:,1) posY(idxPos1); drop_3mo(:,1) posY(idxPos2)]; % Tenors and yields
    idxDrops = retrv(:,1) + (retrv(:,2)-1)*nobs;    % Linear indexing of dropped points
    values   = data_lc(idxDrops);                   % Save before dropping them
    data_lc(idxDrops) = NaN;                        % Drop the data points
    aux      = [[drop_ssr; drop_3mo] values];
    dropped  = nan(nobs,2);                         % For non-dropped points, use NaN
    dropped(aux(:,1),:) = aux(:,2:3);               % Years and values dropped

%% Previous NLS estimation of NS

% NLS estimation of NS model with 2 initial values, choose the best fit
    [params1,ssr1] = lsqcurvefit(@y_NS,params1,tnrs1,ydataLC,lb,ub,options);    
    [params2,ssr2] = lsqcurvefit(@y_NS,params2,tnrs1,ydataLC,lb,ub,options);
    if ssr1 < ssr2; params = params1; ssr = ssr1;
    else;           params = params2; ssr = ssr2;   end

%% From special_cases.m
    
% 'COP'
%     drop_ssr = [];%[14 7; 34 1; 35 1; 38 3; 53 9; 112 2];             % Cases with outliers
%     drop_ssr = [14 7; 38 2; 53 9; 145 5]; 
%     drop_3mo = [23 1; 25 1; 54 9; 56 9; 57 9; 67 1; 69 1; 70 1; 101 2];
%
% 'HUF'
%drop_ssr = [21 5; 26 7; 29 5; 31 1; 32 1; 34 9; 47 7;56 1; 62 5; 66 7;...
        %68 7; 73 1]; % The fit in many cases improved as if the point had not been dropped

% drop_ssr = [25 5; 26 7; 29 5; 32 1; 34 9; 47 7; 56 1; 62 10; 66 7; 68 7]; 
% % In many cases, the improvement is as if the point had not been dropped
% drop_3mo = [28 1];
%
% 'THB'
%drop_ssr = [2 7; 5 2; 6 5; 66 4; 103 4; 101 4; 104 4; 105 4; 106 4; 107 4; 108 4; 110 4; 118 4; 119 4; 120 4];
%% Formula used in local indexing
%sub2ind is almost definitely the way to go, but if you really need it to 
% be fast, you might find it faster to just calculate the linear indices yourself:

A = [1 2 5 4
     4 6 2 5
     3 6 8 9
     2 4 5 7
     2 9 4 2];

ret = [1 1;
       2 2;
       3 1;
       4 4;
       5 3];

n = size(A,1);
A(ret(:,1) + (ret(:,2)-1)*n);

%% VAR estimation

Mdl    = varm(3,1);
EstMdl = estimate(Mdl,factors);
summarize(EstMdl)

%% Previous version of atsm.m

options    = optimoptions('lsqcurvefit','Display','off'); lb = []; ub = [];
maturities = [0.25 1:10];                       % Maturities used
times      = linspace(0,10);
npc        = 3;
lambda0    = nan(npc,npc+1);

for k = 186 %IDs
    fltrCTY = dataset_lcrf(:,2) == k;
    ydata   = dataset_lcrf(fltrCTY,3:13);
    params  = dataset_lcrf(fltrCTY,14:17);
    nobs    = size(ydata);
    
    % Obtain the factors
    [~,factors,~,~,explained] = pca(ydata,'NumComponents',npc);
    
    % Dynamics of the vector of state variables
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
    
    % Price of risk
    lambda0(:,1)     = zeros(npc,1);
    lambda0(:,2:end) = -ones(npc,npc);
    lambda = lsqcurvefit(@y_ATSM,lambda0,maturities,ydata,lb,ub,options);
    
    % Modeled yields
    yields = y_ATSM(lambda,maturities);         % Same dimensions as ydata
    
    % Plot yields: NS v. ATSM
    for l = 1:nobs
        prmtrs = params(l,:);
        plot(times,y_NS(prmtrs,times),'r-',maturities,yields(l,:),'c*')
        title([k '  ' datestr(date)])
        H(l) = getframe(gcf);
    end
end

% yields = y_ATSM(lambda,maturities)

% function yields = y_ATSM(lambda,maturities)
% %[A,B] = pricing_params(delta,maturities);
% delta0 = delta(1);
% delta1 = delta(2:end);
% nmats  = numel(maturities);
% A      = zeros(nmats,1);
% B      = zeros(npc,nmats);
% A(1)   = -delta0;
% B(1)   = -delta1;
% for k  = 2:nmats
%     mu_star  = mu - sigma*lambda(:,1);
%     A(k)     = -delta0 + A(k-1) + B(k-1)'*mu_star + 0.5*B(k-1)'*sigma*sigma'*B(k-1);
%     phi_star = phi - sigma*lambda(:,2:end);
%     B(:,k)   = phi_star'*B(k-1) - delta1;
% end
% 
% yields = (-repmat(A',nobs,1) - factors*B)./maturities;
% 
% end
 
% Plot yields: NS v. ATSM
    for l = 1:size(ydata,1)
        plot(times,y_NS(params(l,:),times),'r-',...
            maturities1,yieldsP(l,:),'c*',maturities1,yieldsQ(l,:),'b--o') % [!]
            %maturities(2:end),yieldsP(l,:),'c*',maturities(2:end),yieldsQ(l,:),'b--o') % [!]
        title([num2str(id) '  ' datestr(date(l))])
        H(l) = getframe(gcf);
    end
    
    
% Modeled yields
% yieldsP = y_ATSM(lambda,maturities(2:end));            % Estimated yields    [!]
% yieldsQ = y_ATSM(lambda0,maturities(2:end));           % Risk-neutral yields [!]
yieldsP = y_ATSM(lambda,maturities1);            % Estimated yields    [!]
yieldsQ = y_ATSM(lambda0,maturities1);           % Risk-neutral yields [!]


%% Verion of atsm.m on April 24, 2018 at the meeting with Wright

maturities = [0.25 1:10];                       % Maturities used
maturities1= 1:10;                              % Number of yields to be estimated
times      = linspace(0,10);
rp5yr      = [];
pc3exp     = [];

for k = 3%1:numel(IDs)
    id      = IDs(k);
    fltrCTY = dataset_lcrf(:,2) == id;
    ydata   = dataset_lcrf(fltrCTY,3:13);
    params  = dataset_lcrf(fltrCTY,14:17);
    date    = dataset_lcrf(fltrCTY,1);
    
    % Modeled yields
    [yieldsP,yieldsQ,rmse,explained] = affine_pricing(maturities1,ydata);
    risk_premia = yieldsP - yieldsQ;
    rp5yr = [rp5yr; id mean(ydata(:,end-5)) mean(risk_premia(:,end-5)) rmse];
    pc3exp = [pc3exp [id; explained(1:3)]];
    
    % Plot yields: N-S v. ATSM
    for l = 1:size(ydata,1)
        plot(times,y_NS(params(l,:),times),'r-',...
            maturities1,yieldsP(l,:),'c*',maturities1,yieldsQ(l,:),'b--o') % [!]
        title([num2str(id) '  ' datestr(date(l))])
        H(l) = getframe(gcf);
    end
    clear H
    close
end


% function [yieldsP,yieldsQ,rmse,explained] = affine_pricing(maturities1,ydata)
% options = optimoptions('lsqcurvefit','Display','off'); lb = []; ub = [];
% nobs    = size(ydata,1);
% npc     = 3;                                 % Number of principal components
% lambda0 = zeros(npc,npc+1);
% 
% % Obtain the state variables as factors of the yields
% [~,factors,~,~,explained] = pca(ydata,'NumComponents',npc);
% 
% % Dynamics of the state variables
% y = factors(2:end,:);
% T = size(y,1);
% x = [ones(T,1) factors(1:end-1,:)];
% b = (x'*x)\x'*y;
% u = y - (x*b);
% C = (u'*u)/T;
% mu    = b(1,:)';
% phi   = b(2:end,:)';
% sigma = chol(C)';
% 
% % Dynamics of the short-term interest rate
% r = ydata(:,1);
% X = [ones(numel(r),1) factors];
% delta  = (X'*X)\X'*r;
% 
% % Price of risk
% if numel(maturities1) == size(ydata,2)
%     [lambda,~,res] = lsqcurvefit(@y_ATSM,lambda0,maturities1,ydata,lb,ub,options);
% else
%     [lambda,~,res] = lsqcurvefit(@y_ATSM,lambda0,maturities1,ydata(:,2:end),lb,ub,options);
% end
% rmse = sqrt(mean(mean(res.^2))); % For a panel
% 
% % Modeled yields
% yieldsP = y_ATSM(lambda,maturities1);            % Estimated yields    [!]
% yieldsQ = y_ATSM(lambda0,maturities1);           % Risk-neutral yields [!]
% 
%     function yields = y_ATSM(lambda,maturities1)
%         [A,B]  = pricing_params(lambda,maturities1);
%         yields = (-repmat(A',nobs,1) - factors*B)./maturities1;
%     end
% 
%     function [A,B] = pricing_params(lambda,maturities1)
%     delta0   = delta(1);
%     delta1   = delta(2:end);
%     nmats    = numel(maturities1);
%     A        = zeros(nmats,1);
%     B        = zeros(npc,nmats);
%     A(1)     = -delta0;
%     B(:,1)   = -delta1;
%     mu_star  = mu - sigma*lambda(:,1);
%     phi_star = phi - sigma*lambda(:,2:end);
%     for k    = 2:nmats
%         A(k)   = -delta0 + A(k-1) + B(:,k-1)'*mu_star + 0.5*B(:,k-1)'*(sigma*sigma')*B(:,k-1);
%         B(:,k) = phi_star'*B(:,k-1) - delta1;
%     end
%     end
% end
 
%% Tables

filename = fullfile('..','..','Docs','Tables','StartingDates1.tex');
%rowLabels = {'row 1', 'row 2'};
columnLabels = {'Country', 'Starting Date'};
matrix2latex(first_mo,filename,'columnLabels',columnLabels,'alignment','c','format','%-6.2f','size','tiny');

%%
% Table of N-S RMSE

tableRMSE = [];
for k = 1:numel(IDs)
    id      = IDs(k);
    cty     = ctrsLC{k};
    fltrCTY = dataset_lcrf(:,2) == id;
    rmse   = dataset_lcrf(fltrCTY,end);
    average_rmse = mean(rmse);
    x = round(average_rmse*1000)/1000; % Remove extra zeros on the right
    tableRMSE = [tableRMSE; cty {num2str(x)}];
end

filename = fullfile('..','..','Docs','Tables','RMSE_NelsonSiegel1.tex');
columnLabels = {'Country', 'RMSE'};
matrix2latex(tableRMSE',filename,'columnLabels',columnLabels,'alignment','c','format','%-6.2f','size','tiny');


% PCE table

filename = fullfile('..','..','Docs','Tables','PC_explained1.tex');
columnLabels = {'Country','PC1','PC2','PC3','Sum'};
matrix2latex(pc3exp',filename,'columnLabels',columnLabels,'alignment','c','format','%6.2f');


% RP table

filename = fullfile('..','..','Docs','Tables','risk_premia_5yr1.tex');
columnLabels = {'Country','5yr Yield','5yr Risk Premium'};
matrix2latex(rp5yr,filename,'columnLabels',columnLabels,'alignment','c','format','%2.2f');

% RP summary statistics table 
filename = fullfile('..','..','Docs','Tables','rp_5yr_stats.tex');
columnLabels = {'Obs','Yield','Mean','Std','Min','Max'};
rowLabels = ctrsLC;
matrix2latex(rp5yr_stats,filename,'rowLabels',rowLabels,'columnLabels',columnLabels,'alignment','c','format','%4.2f');


% PC table for common factors
filename = fullfile('..','..','Docs','Tables','PC_common_factors1.tex');
rowLabels = {'Since Nov 2016 - All Countries','Since Jun 2005 - 8 countries'};
columnLabels = {'PC1','PC2','PC3','Sum'};
matrix2latex(pc3exp_common,filename,'rowLabels',rowLabels,'columnLabels',columnLabels,'alignment','c','format','%6.2f');



%% Plots

s = struct('cty',{},'dates',{},'rp',{});

for k = 1:numel(IDs)
    id      = IDs(k);
    fltrCTY = dataset_lcrf(:,2) == id;
    s(k).cty   = ctrsLC{k};
    s(k).dates = dataset_rp(fltrCTY,1);
    s(k).rp    = dataset_rp(fltrCTY,end-5);
    %mean(s(k).rp)
    
%     % Plot yields: N-S v. Expected v. ATSM
%     for l = 1:size(ydata,1)
%         plot(times,y_NS(params(l,:),times),'r-',...
%             maturities1,yieldsQ(l,:),'c*',maturities1,yieldsP(l,:),'b--o',...
%             maturities,yieldsE(l,:),'mx') % [!]
%         title([num2str(id) '  ' datestr(date(l))])
%         H(l) = getframe(gcf);
%     end
%     clear H
%     close
end

% s(15).cty   = [];
% s(15).dates = NaN;
% s(15).rp    = NaN;

% g = reshape(1:15,3,5)';
% plot(s(g(1,1)).dates,s(g(1,1)).rp,s(g(1,2)).dates,s(g(1,2)).rp,s(g(1,3)).dates,s(g(1,3)).rp)
% labels = {s(g(1,1)).cty, s(g(1,2)).cty, s(g(1,3)).cty};
% legend(labels)

g = [2 13 11; 1 4 6; 8 9 10; 7 12 15; 3 5 14];
%g = [7 12 15; 2 13 11; 1 4 6; 8 9 10; 3 5 14];
%sp = [];
%sp = zeros(ceil(5),1);

for k = 1:4
    
    if k < 4
        subplot(2,2,k)
    plot(s(g(k,1)).dates,s(g(k,1)).rp,s(g(k,2)).dates,s(g(k,2)).rp,'-.',s(g(k,3)).dates,s(g(k,3)).rp,'--');
        labels = {s(g(k,1)).cty, s(g(k,2)).cty, s(g(k,3)).cty};
        legend(labels,'Location','best','Orientation','horizontal')
        datetick('x','yy')
        %sp = [sp; aux];
    else
        subplot(2,2,k)
    plot(s(g(k,1)).dates,s(g(k,1)).rp,s(g(k,2)).dates,s(g(k,2)).rp,'-.');
        labels = {s(g(k,1)).cty, s(g(k,2)).cty};
        legend(labels,'Location','best','Orientation','horizontal')
        datetick('x','yy')
        %sp = [sp; aux];
    end
end

figname = fullfile('..','..','Docs','Figures','risk_premia_5yr_1');
saveas(gcf,figname,'epsc')
saveas(gcf,figname,'fig')
close

figure
k = 5;
plot(s(g(k,1)).dates,s(g(k,1)).rp,s(g(k,2)).dates,s(g(k,2)).rp,'-.',s(g(k,3)).dates,s(g(k,3)).rp,'--');
labels = {s(g(k,1)).cty, s(g(k,2)).cty, s(g(k,3)).cty};
legend(labels,'Location','best','Orientation','horizontal')
datetick('x','yy')
figname = fullfile('..','..','Docs','Figures','risk_premia_5yr_2');
saveas(gcf,figname,'epsc')
saveas(gcf,figname,'fig')


%% Previous version of read_macro_vars.m

path = pwd;
cd(fullfile(path,'..','..','Data'))% Use platform-dependent file separators
filename1   = 'original_Macro_Finance_Vars_Bloomberg.xlsx';
data_macro  = xlsread(filename1);      % Read data without headers but with dates
dates_macro = x2mdate(data_macro(:,1),0);  % Convert dates from Excel to Matlab format
data_macro(:,1) = dates_macro;             % Use dates in Matlab format

filename2 = 'original_Macro_Finance_Vars_Bloomberg_Tickers.xlsx';
[~,txt]   = xlsread(filename2,2);
hdr_macro = txt(:,1:6);
cd(path)

%%
fltrVIX = ismember(hdr_macro(:,2),'VIX');
fltrFFR = ismember(hdr_macro(:,2),'FFR');
fltrSPX = ismember(hdr_macro(:,2),'STX') & ismember(hdr_macro(:,1),'USD');
fltrOIL = ismember(hdr_macro(:,2),'OIL');

for k = 1:numel(IDs)
    id       = IDs(k);
    cty      = ctrsLC{k};
    fltrCTY1 = dataset_rp(:,2) == id;
    rp5yr    = dataset_rp(fltrCTY1,end-5);
    dates_rp = dataset_rp(fltrCTY1,1);
    fltrDTS  = ismember(dates_macro,dates_rp);
    vars     = data_macro(fltrDTS,:);
    
    lvix = log(vars(:,fltrVIX));
    ffr  = vars(:,fltrFFR);
    spx  = vars(:,fltrSPX);
    oil  = vars(:,fltrOIL);
    
    fltrCTY2 = ismember(hdr_macro(:,1),cty);
    fltrCCY  = ismember(hdr_macro(:,2),'CCY') & fltrCTY2;
    fltrSTX  = ismember(hdr_macro(:,2),'STX') & fltrCTY2;
    fltrINF  = ismember(hdr_macro(:,2),'INF') & fltrCTY2;
    fltrUNE  = ismember(hdr_macro(:,2),'UNE') & fltrCTY2;
    fltrIP   = ismember(hdr_macro(:,2),'IP')  & fltrCTY2;
    
    ccy = vars(:,fltrCCY);
    stx = vars(:,fltrSTX);
    inf = vars(:,fltrINF);
    une = vars(:,fltrUNE);
    ip  = vars(:,fltrIP);
    
    const = ones(size(rp5yr));
    [~,~,~,~,stats1] = regress(rp5yr,[const lvix]);
    [~,~,~,~,stats2] = regress(rp5yr,[const ffr]);
    [~,~,~,~,stats3] = regress(rp5yr,[const spx]);
    [~,~,~,~,stats4] = regress(rp5yr,[const oil]);
    [~,~,~,~,stats5] = regress(rp5yr,[const ccy]);
    [~,~,~,~,stats6] = regress(rp5yr,[const stx]);
    [~,~,~,~,stats7] = regress(rp5yr,[const inf une ip]);
    disp(cty)
    [stats1;stats2;stats3;stats4;stats5;stats6;stats7]
end


%clear filename* fltr* txt


%% 

    beta = mdl_macro.Coefficients.Estimate;
    stdb = mdl_macro.Coefficients.SE;
    pval = mdl_macro.Coefficients.pValue;
    nobs = mdl_macro.NumObservations;
    r2   = mdl_macro.Rsquared.Ordinary;
    aux  = [beta(2:end); stdb(2:end); pval(2:end); nobs; r2];
    matrix_3reg(:,k) = aux;

 %%   
    
for k = 1:numel(IDs)
%     id       = IDs(k);
%     cty      = ctrsLC{k};
%     fltrCTY1 = dataset_rp(:,2) == id;
%     rp5yr    = dataset_rp(fltrCTY1,end-5);
%     dates_rp = dataset_rp(fltrCTY1,1);

%     fltrDTS  = ismember(dates_macro,rp5(k).dates);
%     vars     = data_macro(fltrDTS,:);
    
%     lvix = log(vars(:,fltrVIX));    ffr  = vars(:,fltrFFR);
%     spx  = vars(:,fltrSPX);         oil  = vars(:,fltrOIL);
    
    fltrCTY = ismember(hdr_macro(:,1),cty);
    fltrCCY  = ismember(hdr_macro(:,2),'CCY') & fltrCTY;
    fltrSTX  = ismember(hdr_macro(:,2),'STX') & fltrCTY;
    fltrINF  = ismember(hdr_macro(:,2),'INF') & fltrCTY;
    fltrUNE  = ismember(hdr_macro(:,2),'UNE') & fltrCTY;
    fltrIP   = ismember(hdr_macro(:,2),'IP')  & fltrCTY;    

%     fltrCCY  = ismember(hdr_macro(:,2),'CCY') & fltrCTY;
%     fltrSTX  = ismember(hdr_macro(:,2),'STX') & fltrCTY;
%     fltrINF  = ismember(hdr_macro(:,2),'INF') & fltrCTY;
%     fltrUNE  = ismember(hdr_macro(:,2),'UNE') & fltrCTY;
%     fltrIP   = ismember(hdr_macro(:,2),'IP')  & fltrCTY;
%    
%     ccy = vars(:,fltrCCY);  
%     stx = vars(:,fltrSTX);
%     inf = vars(:,fltrINF);  
%     une = vars(:,fltrUNE);  
%     ip  = vars(:,fltrIP);
end
    
% From compare_datasets
% This code compares dataset_lcrf at the time of the proposal with it today
% in order to find out what is causing the difference in results (risk premia)

maturities = [0.25 1:10];
times      = linspace(0,10);

for k = 2%1:numel(IDs)
    id           = IDs(k);
    fltrCTY      = dataset_lcrf(:,2) == id;         % specific rows
    fltrCTYtdy   = dataset_lcrf_tdy(:,2) == id;     % specific rows, differ
    panel_lcrf   = dataset_lcrf(fltrCTY,1:13);      % it has dates, id, 3mo-10yr yields
    panel_lcrf_tdy = dataset_lcrf_tdy(fltrCTYtdy,1:13);
    params      = dataset_lcrf(fltrCTY,14:17);
    params_tdy  = dataset_lcrf_tdy(fltrCTYtdy,14:17);
    mean(panel_lcrf_tdy - panel_lcrf);
    nobs = size(panel_lcrf,1);
    
    for l = 27%1:nobs
        date        = panel_lcrf(l,1);
        date_tdy    = panel_lcrf_tdy(l,1);
        if date ~= date_tdy; warning('dates are different'); end
        NSblue = y_NS(params(l,:),times);
        NSred  = y_NS(params_tdy(l,:),times);
        plot(times,NSblue,'b-',times,NSred,'r-')
        title([ctrsLC{k} '  ' datestr(date)])
        H(l) = getframe(gcf);
        if sum(abs(NSred - NSblue) > 0.5) > 0; disp('Press a key'); pause; end
    end
end
    
%% From read_acm_tp.m
% filename1 = 'importable_ACM_Term_Premium.csv';
% data_acm1  = csvread(filename1,1,1);

%% From rp_us.m
% For dataset_usyc
% idxEndMo = [diff(day(data_hc(:,1))); -1] < 0;   % 1 if last day of month; keep last obs
% data_hc  = data_hc(idxEndMo,:);                 % Last available trading day per month
% For data_acm
% dateIdx  = (data_acm(:,1) >= date1) & (data_acm(:,1) <= date2); % Logical
% data_acm = data_acm(dateIdx,:);               % Limit the dataset to the sample dates

% risk_premia = yieldsQ - yieldsP;

%% Include in rp_common factors

% vars = end_of_month(data_macro);
% plot(vars(:,2)) % col2 is VIX
% 
% vix1 = vars(vars(:,1) >= date_min,2);
% vix2 = vars(vars(:,1) >= date_200X,2);
% corr(vix1,factors1)
% corr(vix2,factors2)
% 
% ffr1 = vars(vars(:,1) >= date_min,3);
% ffr2 = vars(vars(:,1) >= date_200X,3);
% corr(ffr1,factors1)
% corr(ffr2,factors2)
% 
% stx1 = vars(vars(:,1) >= date_min,4);
% stx2 = vars(vars(:,1) >= date_200X,4);
% corr(stx1,factors1)
% corr(stx2,factors2)
% 
% % Behavior of common factors around GFC and taper tantrum?
% plot(date_aux,factors2)
% datetick('x','yy')
% legend({'PC1','PC2','PC3'})


%%
% % Headers
% ctrsNcods = [ctrsLC cellstr(num2str(IDs))];       % Countries and their codes
% aux       = cellstr(num2str(maturities(2:end)')); % Cell with all the tenors (starting 1yr) as strings
% tnrs      = strrep(aux(:),' ','');                % Remove spaces
% tnrs3mo   = [{'0.25'}; tnrs];
% 
% name_ycrf = strcat('DEFAULT-FREE LC YIELD CURVE',{' '},tnrs3mo,' YR');
% hdr_ycrf  = construct_hdr('LCRFYC',name_ycrf,tnrs3mo);
% hdr_param = construct_hdr('PARAMLCRF','N-S LCRF YIELD CURVE',paramsNS);
% hdr_rmse  = construct_hdr('RMSELCRF','LCRF N-S FIT RMSE','X');
% 
% hdr_lcrf  = {'type','description','tenor';
%     'IMFC','IMF CODE','X'};
% hdr_lcrf  = [hdr_lcrf; hdr_ycrf; hdr_param; hdr_rmse];

% name_yE   = strcat('DEFAULT-FREE EXPECTED SHORT RATE IN',{' '},tnrs3mo,' YR');
% name_yQ   = strcat('DEFAULT-FREE RISK NEUTRAL YIELD',{' '},tnrs,' YR');
% name_yP   = strcat('DEFAULT-FREE PHYSICAL YIELD',{' '},tnrs,' YR');
% name_rp   = strcat('DEFAULT-FREE RISK PREMIUM',{' '},tnrs,' YR');
% name_rp1  = strcat('DEFAULT-FREE RISK PREMIUM',{' '},tnrs3mo,' YR');
% paramsNS  = {'BETA0';'BETA1';'BETA2';'TAU'};
% 
% hdr_yE   = construct_hdr('LCRFYE',name_yE,tnrs3mo);
% hdr_yQ   = construct_hdr('LCRFYQ',name_yQ,tnrs);
% hdr_yP   = construct_hdr('LCRFYP',name_yP,tnrs);
% hdr_rprf = construct_hdr('LCRFRP',name_rp,tnrs);
% hdr_rprf1= construct_hdr('LCRFRP',name_rp1,tnrs3mo);
% 
% hdr_rp   = [hdr_yE; hdr_yQ; hdr_yP; hdr_rprf];          % Ready to appended (ie no title rows)
% hdr_rp1  = [{'type','description','tenor'; 'IMFC','IMF CODE','X'};hdr_rprf1];
% clear name_yE name_yQ name_yP name_rp hdr_yE hdr_yQ hdr_yP hdr_rprf

% name_yclc = strcat('NON-DEFAULT-FREE LC N-S YIELD CURVE',{' '},tnrs3mo,' YR');
% name_yE   = strcat('NON-DEFAULT-FREE EXPECTED SHORT RATE IN',{' '},tnrs,' YR');
% name_yQ   = strcat('NON-DEFAULT-FREE RISK NEUTRAL YIELD',{' '},tnrs,' YR');
% name_yP   = strcat('NON-DEFAULT-FREE PHYSICAL YIELD',{' '},tnrs,' YR');
% name_rp   = strcat('NON-DEFAULT-FREE RISK PREMIUM',{' '},tnrs,' YR');
% paramsNS  = {'BETA0';'BETA1';'BETA2';'TAU'};

% hdr_yclc  = construct_hdr('LCRKNS',name_yclc,tnrs3mo);
% hdr_param = construct_hdr('PARAMLCRK','NON-DEFAULT-FREE LC N-S YIELD CURVE',paramsNS);
% hdr_rmse1 = construct_hdr('RMSELCRK','NON-DEFAULT-FREE LC N-S FIT RMSE','X');
% hdr_yE    = construct_hdr('LCRKYE',name_yE,tnrs);
% hdr_yQ    = construct_hdr('LCRKYQ',name_yQ,tnrs);
% hdr_yP    = construct_hdr('LCRKYP',name_yP,tnrs);
% hdr_rp    = construct_hdr('LCRKRP',name_rp,tnrs);
% hdr_rmse2 = construct_hdr('RMSEATSMLCRK','NON-DEFAULT-FREE LC ATSM FIT RMSE','X');
% 
% hdr_lc  = [hdr_yclc; hdr_param; hdr_rmse1; hdr_yE; hdr_yQ; hdr_yP; hdr_rp; hdr_rmse2];
% clear name_yclc hdr_yclc hdr_param hdr_rmse1 hdr_rmse2 paramsNS
% clear name_yE name_yQ name_yP name_rp hdr_yE hdr_yQ hdr_yP hdr_rp paramsNS


name_lccs1 = strcat('IMPLIED LC CREDIT SPREAD',{' '},tnrs,' YR');
name_lccs2 = strcat('OBSERVED LC CREDIT SPREAD',{' '},tnr2,' YR');   % tnr2 from header_daily
hdr_lccs1  = construct_hdr('LCCSI',name_lccs1,tnrs);
hdr_lccs2  = construct_hdr('LCCSO',name_lccs2,tnr2);
hdr_lccs  = [hdr_lccs1; hdr_lccs2];
clear name_lccs1 name_lccs2 hdr_lccs1 hdr_lccs2

% name_us   = strcat('USD ZERO-COUPON YIELD',{' '},tnrs3mo,' YR');
% name_rp   = strcat('USD RISK PREMIUM',{' '},tnrs,' YR');
% paramsNSS = {'BETA0';'BETA1';'BETA2';'BETA3';'TAU1';'TAU2'};
% 
% hdr_ycus  = construct_hdr('USYC',name_us,tnrs3mo);
% hdr_param = construct_hdr('PARAMETER','N-S-S USD YIELD CURVE',paramsNSS);
% hdr_rpus  = construct_hdr('USRP',name_rp,tnrs);
% 
% hdr_usrp  = [{'type','description','tenor'; 'IMFC','IMF CODE','X'};
%     hdr_ycus; hdr_param; hdr_rpus];
% clear name_* hdr_ycus hdr_param hdr_rpus paramsNSS

% header_monthly = [hdr_lcrf; hdr_rp; hdr_lc; hdr_lccs; hdr_us];
% header_monthly = [hdr_lcrf; hdr_lc; hdr_lccs; hdr_us]; % When hdr_rp no longer needed
% clear hdr_lcrf hdr_lc hdr_lccs hdr_usrp

% To remove extra zeros on the right for printing purposes (eg saving doubles as cell)
% x = round(explained(1:3)*1000)/1000;            % Three decimals
% y = round(sum(explained(1:3))*100)/100;         % Two decimals

%% From rp_adjusted (can be deleted after it runs smoothly)
% dataset_monthly = [];
% for k = 1:numel(IDs)
%     id      = IDs(k);
%     cty     = ctrsLC{k};
%     fltrCTY = dataset_lcrf(:,2) == id;
%     fltrYLD = ismember(hdr_lcrf(:,1),'LCRFYC');
%     fltrPRM = ismember(hdr_lcrf(:,1),'PARAMLCRF');
%     ydata   = dataset_lcrf(fltrCTY,fltrYLD);
%     params  = dataset_lcrf(fltrCTY,fltrPRM);      % Used for plots
%     date    = dataset_lcrf(fltrCTY,1);
%     
%     % ATSM fitted yields
%     [yieldsQ,yieldsP,yieldsE,rmse,explained] = fit_ATSM(maturities1,ydata);
%     %risk_premia = yieldsQ - yieldsP;   % obs x maturities1!
%     risk_premia = ydata - yieldsE;      % obs x maturities
%     % risk_premia = ydata(:,2:end) - yieldsE; % obs x maturities1!
%     dataset_rp = [dataset_rp; date, repmat(id,size(ydata,1),1), risk_premia];
%     dataset_monthly = [dataset_monthly; dataset_lcrf(fltrCTY,:),...
%                       yieldsE(:,2:end),yieldsQ,yieldsP,risk_premia(:,2:end),rmse];
% 
% % dataset_rp = [dataset_rp; date,repmat(id,size(ydata,1),1),yieldsE,yieldsQ,yieldsP,risk_premia(:,2:end)];
% % dataset_rp = [dataset_rp; date,repmat(id,size(ydata,1),1),yieldsE,yieldsQ,yieldsP,risk_premia,rmse];
% % change for new one; immediately after that, need to update references
% % to it in plot_risk_premia.m
%     
%     x = round(mean(ydata(:,end-5))*1000)/1000;
%     y = round(mean(risk_premia(:,end-5))*1000)/1000;
%     z = risk_premia(:,end-5);
%     %rp5yr_means = [rp5yr_means; id mean(ydata(:,end-5)) mean(risk_premia(:,end-5)) rmse];
%     %rp5yr_means = [rp5yr_means; cty cellstr(num2str(x)) cellstr(num2str(y))];
%     rp5yr_stats = [rp5yr_stats; numel(z) mean(ydata(:,end-5)) mean(z) std(z) min(z) max(z)];
%     
%     x = round(explained(1:3)*1000)/1000; % Remove extra zeros on the right
%     y = round(sum(explained(1:3))*100)/100;
%     pc3exp = [pc3exp [cty; cellstr(num2str(x)); cellstr(num2str(y))]];
%     
% %     % Plot yields: N-S v. Expected v. ATSM
% %     for l = 1:size(ydata,1)
% %         plot(times,y_NS(params(l,:),times),'r-',...
% %             maturities1,yieldsQ(l,:),'c*',maturities1,yieldsP(l,:),'b--o',...
% %             maturities,yieldsE(l,:),'mx') % [!]
% %         title([num2str(id) '  ' datestr(date(l))])
% %         H(l) = getframe(gcf);
% %     end
% %     clear H
% %     close
% end
%% From rp_correlations.m (this version applies only to one maturity)
% yr_dbl  = 5;
% yr_str  = num2str(yr_dbl);
% fltrEM  = ismember(header_monthly(:,1),'LCRFRP') & ismember(header_monthly(:,3),yr_str);
% fltrUS  = ismember(hdr_usrp(:,1),'USRP') & ismember(hdr_usrp(:,3),yr_str);
% tp_corr = [];
% resid   = [];
% lm      = struct('mdl',{});
% 
% for k = 1:numel(IDs)
%     id      = IDs(k);
%     cty     = ctrsLC{k};
%     fltrCTY = dataset_monthly(:,2) == id;
%     tp_EM   = dataset_monthly(fltrCTY,fltrEM);
%     date1   = min(dataset_monthly(fltrCTY,1));  % First date for US relative to EM
%     date2   = max(dataset_monthly(fltrCTY,1));  % Last date for US relative to EM
%     tp_aux  = dataset_in_range(data_usrp,date1,date2);
%     
%     % Next lines can be done for all maturities with a loop
%     tp_US     = tp_aux(:,fltrUS); 
%     tp_corr   = [tp_corr; [cty cellstr(num2str(corr(tp_EM,tp_US)))]];
%     lm(k).mdl = fitlm(tp_US,tp_EM);
%     resid     = [resid; lm(k).mdl.Residuals.Raw];
% end
% 
% %dataset_monthly = [dataset_monthly resid];  % Would like to add a resid per each maturity
% 
% % Statistics
% correls = cellfun(@str2num,tp_corr(:,2));
% sprintf('Mean %0.4f, Max %0.4f, Min %0.f',mean(correls),max(correls),min(correls))
% disp(tp_corr(correls > 0.5,1));               % Countries with correlation > 0.5
% 
% clear id k cty fltr* date1 date2 yr_* tp_aux tp_EM tp_US
%% From rp_common_factors.m (can be deleted when it runs smoothly)
% % Commented lines apply for rp directly, current version applies to
% % residuals of regressing EM TPs on US TP
% 
% % idx1stMo  = [1; diff(dataset_lcrf(:,2))] ~= 0;   % Find first month per country
% % init_mo   = dataset_lcrf(idx1stMo,1);
% 
% idx1stMo  = [1; diff(dataset_monthly(:,2))] ~= 0; % Find first month per country, col2 finds change in ID
% init_mo   = dataset_monthly(idx1stMo,1);
% 
% % Identify countries and minimum dates
% fltr2005  = init_mo < datenum('1-Jul-2005');
% init_2005 = init_mo(fltr2005);
% ctrsLC05  = ctrsLC(fltr2005);
% IDs2005   = IDs(fltr2005);
% 
% date_max   = max(init_mo);
% date_2005  = max(init_2005);
% 
% % Construct a balanced panel for all countries starting in same date
% % aux = dataset_rp(dataset_rp(:,1) >= date_max,:);
% aux = dataset_monthly(dataset_monthly(:,1) >= date_max,:);
% 
% panel_all = [];
% for k = 1:numel(IDs)    
%     id        = IDs(k);
%     cty       = ctrsLC{k};                      % May not be needed
%     fltrCTY   = aux(:,2) == id;
%     % rpdata    = aux(fltrCTY,end-5);
%     resids    = aux(fltrCTY,end);               % as long as end is resid
%                                                 % Will need a filter for col of resids
%     %panel_all = [panel_all rpdata];
%     panel_all = [panel_all resids];
% end
% 
% npc = 3;
% [~,factors1,~,~,explained_all] = pca(panel_all,'NumComponents',npc);
% 
% 
% % Construct a balanced panel for countries with data going back to 2005
% % fltr2005 = ismember(dataset_rp(:,2),IDs2005);
% fltr2005 = ismember(dataset_monthly(:,2),IDs2005);
% aux = dataset_monthly(fltr2005,:);
% aux = aux(aux(:,1) >= date_2005,:);
% panel_05 = [];
% for k = 1:numel(IDs2005)    
%     id        = IDs2005(k);
%     cty       = ctrsLC05{k};                    % May not be needed
%     fltrCTY   = aux(:,2) == id;
%     % rpdata    = aux(fltrCTY,end-5);
%     resids    = aux(fltrCTY,end);               % as long as end is resid
%                                                 % Will need a filter for col of resids
%     % panel_05 = [panel_05 rpdata];
%     panel_05 = [panel_05 resids];
% end
% 
% [~,factors2,~,~,explained_05] = pca(panel_05,'NumComponents',npc);
% 
% pc3exp_common = [explained_all(1:3)' sum(explained_all(1:3));
%     explained_05(1:3)' sum(explained_05(1:3))]; % First 3 PCs var in cols1-3, total in col4 
% 
% plot(factors1)
% plot(factors2)
% 
% 
% % Not tested but should work (from rp_common_factors.m)
% fltrRP  = ismember(header_monthly(:,1),'LCRFRP');
% 
% fltrPNL = dataset_monthly(:,1) >= date_min;
% aux_tp  = dataset_monthly(fltrPNL,fltrRP);      % For TP
% aux_og  = data_resd(fltrPNL,:);                 % For residuals
% npc     = 3;
% ntnrs   = sum(fltrRP);
% nallobs = sum(fltrPNL);
% nids    = numel(IDs);
% npercty = nallobs/nids;                         % Since balanced panel
% pnlAtp  = reshape(aux_tp,npercty,nids,[]);        % A panel per maturity (3rd dimension)
% pnlAog  = reshape(aux_og,npercty,nids,[]);
% 
% %     fltrCOD  = ismember(ctrsNcods(:,1),region{k});
% %     ctyIDs   = cell2mat(ctrsNcods(fltrCOD,2));       % IDs of countries in region
% 
%% Working new version of rp_common_factors.m
% date_cf   = '1-Jul-2005';                           % Date can be changed
% 
% % Find initial month per country (by change in ID) and identify minimum common dates
% % idx1stMo  = [1; diff(dataset_monthly(:,2))] ~= 0;
% % init_mo   = dataset_monthly(idx1stMo,1);
% init_mo   = date_first_obs(dataset_monthly);
% date_min  = max(init_mo);                           % Minimum common date for all countries
% init_200X = init_mo(init_mo < datenum(date_cf));
% date_200X = max(init_200X);
% 
% % Construct balanced panels (ie same start date for countries included)
% l      = 1;
% npc    = 3;
% fltrRP = ismember(header_monthly(:,1),'LCRFRP');
% ntnrs  = sum(fltrRP);
% pc_explnd = [];
% for comn_date = [date_min, date_200X]               % Find factors for different common dates
%     ctyIDs  = IDs(init_mo <= comn_date);
%     fltrCTY = ismember(dataset_monthly(:,2),ctyIDs);
%     fltrDTE = dataset_monthly(:,1) >= comn_date;
%     fltrPNL = fltrCTY & fltrDTE;                    % Countries with common dates
%     [pc_explnd, pcpc_explnd] = common_factors(dataset_monthly,data_resd,fltrPNL,ctyIDs);
%     
%     aux_tp  = dataset_monthly(fltrPNL,fltrRP);      % For TP
%     aux_og  = data_resd(fltrPNL,:);                 % For residuals
%     nallobs = sum(fltrPNL);
%     nids    = numel(ctyIDs);                        
%     pnl_tp  = reshape(aux_tp,[],nids,ntnrs);        % A panel per maturity (3rd dimension)
%     pnl_og  = reshape(aux_og,[],nids,ntnrs);        % Since balanced panel: [npercty] = nallobs/nids; 
%     factors_tp = []; factors_og = []; explnd_tp = []; explnd_og = [];
%     for k = 1:ntnrs                                 % Find factors per maturity
%         [~,factors_tp(:,:,k),~,~,explnd_tp(:,k)] = pca(pnl_tp(:,:,k),'NumComponents',npc);
%         [~,factors_og(:,:,k),~,~,explnd_og(:,k)] = pca(pnl_og(:,:,k),'NumComponents',npc);
%     end
%     pc_explnd(:,:,l) = [sum(explnd_tp(1:npc,:)); sum(explnd_og(1:npc,:))]; % 3D for different comn_date
%     if l == 1
%         pc1_tp = squeeze(factors_tp(:,1,:));        % PC1 for all maturities (obs x mty)
%         pc1_og = squeeze(factors_og(:,1,:));
%     end
%     l = l + 1;
% end
% 
% % Common factors in PC1's across maturities for first comn_date
% [~,factors_tp,~,~,explnd_tp] = pca(pc1_tp,'NumComponents',npc);
% [~,factors_og,~,~,explnd_og] = pca(pc1_og,'NumComponents',npc);
% pcpc_explnd = [sum(explnd_tp(1:npc,:)); sum(explnd_og(1:npc,:))];
%% Working function inside rp_common_factors.m
% function [pc_explnd, pcpc_explnd] = common_factors(dataset_monthly,data_resd,fltrPNL,fltrRP,ctyIDs)
%     npc    = 3;
%     ntnrs  = sum(fltrRP);
%     aux_tp = dataset_monthly(fltrPNL,fltrRP);      % For TP
%     aux_og = data_resd(fltrPNL,:);                 % For residuals
%     nids   = numel(ctyIDs);                        
%     pnl_tp = reshape(aux_tp,[],nids,ntnrs);        % A panel per maturity (3rd dimension)
%     pnl_og = reshape(aux_og,[],nids,ntnrs);        % Since balanced panel: [npercty]=sum(fltrPNL)/nids; 
%     factors_tp = []; factors_og = []; explnd_tp = []; explnd_og = [];
%     for k = 1:ntnrs                                 % Find factors per maturity
%         [~,factors_tp(:,:,k),~,~,explnd_tp(:,k)] = pca(pnl_tp(:,:,k),'NumComponents',npc);
%         [~,factors_og(:,:,k),~,~,explnd_og(:,k)] = pca(pnl_og(:,:,k),'NumComponents',npc);
%     end
%     pc_explnd = [sum(explnd_tp(1:npc,:)); sum(explnd_og(1:npc,:))]; % 2 x ntnrs
%     
%     % Common factors in PC1's across maturities
%     pc1_tp = squeeze(factors_tp(:,1,:));            % PC1 for all maturities (obs x ntnrs)
%     pc1_og = squeeze(factors_og(:,1,:));    
%     [~,~,~,~,xplnd_tp] = pca(pc1_tp,'NumComponents',npc);
%     [~,~,~,~,xplnd_og] = pca(pc1_og,'NumComponents',npc);
%     pcpc_explnd = [sum(xplnd_tp(1:npc)); sum(xplnd_og(1:npc))];     % 2 x 1
%     
%     % Correlation between PCs from tp and og
%     % Correlation between PCs and macro financial variables
% end

%% From read_epu_idx.m (can be deleted)
% filename  = 'importable_EPU_Index_BRL.xlsx';
% filename  = 'importable_EPU_Index_MXN.xlsx';
% filename  = 'importable_EPU_Index_RUB.xlsx';
% filename  = 'original_EPU_Index_COP.xlsx';
% filename  = 'original_EPU_Index_KRW.xlsx'; 
%datenum([ '31-12-1990'],'dd-m-yyyy'); % Date and input format
% vec = datestr(busdays('1/8/16','3/1/16','monthly')); % Determines the business days for a monthly period
% data_epu  = [epu_dates data_epu];           % Append data to dates
% data_epu = [epu_dates data(:,end)];

%% To include in rp_correlations.m (already incorporated)
% fltrRP1   = ismember(header_monthly(:,1),'LCRFRP');
% fltrRP2   = ismember(hdr_usrp(:,1),'USRP');
% 
% corr_tpepu = [];
% corr_ogepu = [];
% 
% for k = 1:ntnrs
% %     k
%     fltrEM  = fltrRP1 & ismember(header_monthly(:,3),num2str(k));
%     fltrUS  = fltrRP2 & ismember(hdr_usrp(:,3),num2str(k));
%     tp_aux2 = [];
%     
%     tp_aux3 = []; tp_aux4 = [];
%     
%     res_aux = [];
%     for  l  = 1:numel(IDs)
% %         l
%         id      = IDs(l);
%         cty     = ctrsLC{l};
%         fltrCTY = dataset_monthly(:,2) == id;
%         
%         % Extract EM TP
%         tp_EM   = dataset_monthly(fltrCTY,fltrEM);
%         date1   = min(dataset_monthly(fltrCTY,1));  % First date for US relative to EM
%         date2   = max(dataset_monthly(fltrCTY,1));  % Last date for US relative to EM
%         
% %         % Extract US TP for specified range
%         tp_aux1 = dataset_in_range(data_usrp,date1,date2);
%         tp_US   = tp_aux1(:,fltrUS); 
%         tp_aux2 = [tp_aux2; corr(tp_EM,tp_US)];
%         
%         % Regress EM TP on US TP and save residual
%         mdl     = fitlm(tp_US,tp_EM);
%         res_aux = [res_aux; mdl.Residuals.Raw];
%         
%         % Correlation of EM TP with EPU index
%         if any(strcmp(ctrsEPU,ctrsLC{l}))               % ctrsEPU{k} is any country with EPU index
%             idx = find(ismember(ctrsEPU,ctrsLC{l}));
%             epu = dataset_in_range(epuidx(idx).info,date1,date2); % Trim to tp_EM range
%             
%             % Need to create tp_EM2 because sometimes EPU has fewer obs (epu_max_date < tp_max_date)
%             tp_EM2   = dataset_monthly(fltrCTY,:);      % All obs of EM (need dates)
%             res_aux2 = [tp_EM2(:,1) mdl.Residuals.Raw]; % col1: dates, col2: EPU index
%             res_aux2 = dataset_in_range(res_aux2,min(epu(:,1)),max(epu(:,1))); % Trim to EPU range
%             tp_EM2   = dataset_in_range(tp_EM2,min(epu(:,1)),max(epu(:,1))); 
%             tp_EM2   = tp_EM2(:,[1 find(fltrEM)]);      % col1: dates, col2: trimmed tp_EM
%             tp_aux3  = [tp_aux3; corr(tp_EM2(:,2),epu(:,2))]; 
%             tp_aux4  = [tp_aux4; corr(res_aux2(:,2),epu(:,2))];
%             
%             if k == 10
%                 subplot(2,3,idx)
%                 yyaxis left;  plot(tp_EM2(:,1),tp_EM2(:,2)); ylabel('Term Premium')
%               % yyaxis left; plot(res_aux2(:,1),res_aux2(:,2)); ylabel('Orthogonal TP')
%                 yyaxis right; plot(epu(:,1),epu(:,2));       ylabel('EPU Index')
%                 title([ctrsLC{l} ' TP and EPU'])
%                 datetick('x','yy')
%             end
%         end
%     end
% %     disp([[num2str(k) ' Year:'] ctrsLC(tp_aux2 > 0.5)']); % Countries with correlation > 0.5
%     corr_tpepu   = [corr_tpepu tp_aux3];          % EPU countries x maturities
%     corr_ogepu   = [corr_ogepu tp_aux4];
% %     data_resd = [data_resd res_aux];            % all_obs x maturities
% end
%% From rp_us.m
% corr([data_usrp(:,fltrRPYR),acm_parts(:,2),KWtp(:,2)]) % 0.8812    0.4659    0.7656 for 10 yr
% mean([data_usrp(:,fltrRPYR),acm_parts(:,2),KWtp(:,2)]) % 1.9863    1.0243    0.3458 for 10 yr

%% Early version of read_macro_vars.m

% fltrVIX = ismember(hdr_macro(:,2),'VIX');
% fltrFFR = ismember(hdr_macro(:,2),'FFR');
% fltrSPX = ismember(hdr_macro(:,2),'STX') & ismember(hdr_macro(:,1),'USD');
% fltrOIL = ismember(hdr_macro(:,2),'OIL');
% 
% for k = 1:numel(IDs)
%     id       = IDs(k);
%     cty      = ctrsLC{k};
%     fltrCTY1 = dataset_rp(:,2) == id;
%     rp5yr    = dataset_rp(fltrCTY1,end-5);
%     dates_rp = dataset_rp(fltrCTY1,1);
%     fltrDTS  = ismember(dates_macro,dates_rp);
%     vars     = data_macro(fltrDTS,:);
%     
%     lvix = log(vars(:,fltrVIX));
%     ffr  = vars(:,fltrFFR);
%     spx  = vars(:,fltrSPX);
%     oil  = vars(:,fltrOIL);
%     
%     fltrCTY2 = ismember(hdr_macro(:,1),cty);
%     fltrCCY  = ismember(hdr_macro(:,2),'CCY') & fltrCTY2;
%     fltrSTX  = ismember(hdr_macro(:,2),'STX') & fltrCTY2;
%     fltrINF  = ismember(hdr_macro(:,2),'INF') & fltrCTY2;
%     fltrUNE  = ismember(hdr_macro(:,2),'UNE') & fltrCTY2;
%     fltrIP   = ismember(hdr_macro(:,2),'IP')  & fltrCTY2;
%     
%     ccy = vars(:,fltrCCY);
%     stx = vars(:,fltrSTX);
%     inf = vars(:,fltrINF);
%     une = vars(:,fltrUNE);
%     ip  = vars(:,fltrIP);
%     
%     const = ones(size(rp5yr));
%     [~,~,~,~,stats1] = regress(rp5yr,[const lvix]);
%     [~,~,~,~,stats2] = regress(rp5yr,[const ffr]);
%     [~,~,~,~,stats3] = regress(rp5yr,[const spx]);
%     [~,~,~,~,stats4] = regress(rp5yr,[const oil]);
%     [~,~,~,~,stats5] = regress(rp5yr,[const ccy]);
%     [~,~,~,~,stats6] = regress(rp5yr,[const stx]);
%     [~,~,~,~,stats7] = regress(rp5yr,[const inf une ip]);
%     disp(cty)
%     [stats1;stats2;stats3;stats4;stats5;stats6;stats7]
% end
% 
%% Earlier version of rp_adjusted.m
% Can be deleted once dataset_rp is deleted
% name_rp1 = strcat('DEFAULT-FREE RISK PREMIUM',{' '},tnrs3mo,' YR');          % May go
% hdr_rprf1= construct_hdr('LCRFRP',name_rp1,tnrs3mo);                         % May go
% hdr_rp1  = [{'type','description','tenor'; 'IMFC','IMF CODE','X'};hdr_rprf1];% May go

% Can be deleted
% dataset_rp =[dataset_rp; date,repmat(id,size(ydata,1),1),yieldsE,yieldsQ,yieldsP,risk_premia(:,2:end)];
% dataset_rp = [dataset_rp; date,repmat(id,size(ydata,1),1),yieldsE,yieldsQ,yieldsP,risk_premia,rmse];
% change for new one; immediately after that, need to update references
% to it in plot_risk_premia.m
%rp5yr_means = [rp5yr_means; id mean(ydata(:,end-5)) mean(risk_premia(:,end-5)) rmse];
%rp5yr_means = [rp5yr_means; cty cellstr(num2str(x)) cellstr(num2str(y))];
%     z = risk_premia(:,end-5);
%     rp5yr_stats = [rp5yr_stats; numel(z) mean(ydata(:,end-5)) mean(z) std(z) min(z) max(z)];
%     pc_exp_aux = [pc_exp_aux [cty; cellstr(num2str(x)); cellstr(num2str(y))]];
% x = round(mean(ydata(:,end-5))*1000)/1000;
% y = round(mean(risk_premia(:,end-5))*1000)/1000;
% x = round(explained(1:3)*1000)/1000; % Remove extra zeros on the right
% y = round(sum(explained(1:3))*100)/100;

%hdr_rp   = [hdr_yE; hdr_yQ; hdr_yP; hdr_rprf; hdr_rmse2];        % Ready to appended (ie no title rows)
% if sum(sum(dataset_rp(:,[1 2]) - dataset_lcrf(:,[1 2]))) == 0   % Safetynet before appending
%     dataset_monthly = [dataset_lcrf dataset_rp(:,4:end)];     % col4 is 1yr_rp. Update with size(rp,2)!
%     header_monthly  = [hdr_lcrf; hdr_rp1(4:end,:)];             % Update when using hdr_rp!
%     % header_monthly  = [hdr_lcrf; hdr_rp];
% end
%% From fit_NS.m after converting it to a function (can be deleted)
% ctrsNcods = [ctrsLC cellstr(num2str(IDs))];   % Countries and their codes
% tnrs      = pnum2cell(maturities(2:end));       % Cell with all the tenors (starting 1yr) as strings

% tnrs3mo   = pnum2cell(maturities);
% adj1      = 'RF';   adj2 = '';                  % Values when YCtype = 'LCRF'
% if strcmp(YCtype,'LC')
%     adj1  = 'RK';   adj2 = 'NON-';
% end
% name_yc   = strcat([adj2 'DEFAULT-FREE LC N-S YIELD CURVE'],{' '},tnrs3mo,' YR');
% paramsNS  = {'BETA0';'BETA1';'BETA2';'TAU'};
% hdr_yc    = construct_hdr(['LCNS' adj1],name_yc,tnrs3mo);
% hdr_param = construct_hdr(['PARAMLC' adj1],[adj2 'DEFAULT-FREE LCRF N-S YIELD CURVE'],paramsNS);
% hdr_rmse1 = construct_hdr(['RMSELC' adj1],[adj2 'DEFAULT-FREE LCRF N-S FIT RMSE'],'X');
% hdr_lc    = [{'type','description','tenor'; 'IMFC','IMF CODE','X'};
%             hdr_yc; hdr_param; hdr_rmse1];

% clear k l lb ub id fltr* tnrs1 params* idx* fig date options* times maturities y* crncy
% clear dataset_aux dropped init_* ncountries nobs name_* hdr_y* hdr_p* hdr_rm* paramsNS
% clear flag_* rmse tnrmax adj*                      % Uncomment only after done addressing special cases

%% From rp_estimation.m after converting it to a function (can be deleted)
% clear k l cty date explained fltr* id maturities* params rmse times x y* z
% clear name_* hdr_yE hdr_yQ hdr_yP hdr_rprf hdr_rmse2 tnrs_rp risk_* pc_exp_*
% name_yE   = strcat('DEFAULT-FREE EXPECTED SHORT RATE IN',{' '},tnrs,' YR');
% name_yQ   = strcat('DEFAULT-FREE RISK NEUTRAL YIELD',{' '},tnrs,' YR');
% name_yP   = strcat('DEFAULT-FREE PHYSICAL YIELD',{' '},tnrs,' YR');
% name_rp   = strcat('DEFAULT-FREE RISK PREMIUM',{' '},tnrs,' YR');             
% hdr_yE    = construct_hdr('LCRFYE',name_yE,tnrs);
% hdr_yQ    = construct_hdr('LCRFYQ',name_yQ,tnrs);
% hdr_yP    = construct_hdr('LCRFYP',name_yP,tnrs);
% hdr_rprf  = construct_hdr('LCRFRP',name_rp,tnrs);
% hdr_rmse2 = construct_hdr('RMSEATSMLCRF','DEFAULT-FREE LCRF ATSM FIT RMSE','X');
% header_monthly  = [hdr_lcrf; hdr_yE; hdr_yQ; hdr_yP; hdr_rprf; hdr_rmse2];

% fltrYC  = ismember(header_monthly(:,1),[YCtype 'NS']) & ~ismember(header_monthly(:,3),'0.25');
% fltrRP  = ismember(header_monthly(:,1),[YCtype 'RP']);
% tnrs_rp = cellfun(@str2num,header_monthly(fltrRP,3)); % Convert str into double

% for k = 1:numel(IDs)                            % To report all maturities per country
%     id      = IDs(k);
%     fltrCTY = data_month(:,2) == id;
%     y       = dataset_monthly(fltrCTY,fltrYC);
%     z       = dataset_monthly(fltrCTY,fltrRP);
%     stats_rp_cty(:,:,k) = [tnrs_rp'; mean(y); std(y); mean(z); std(z); max(z); min(z); 
%                repmat(size(z,1),1,size(z,2))];
% end
%% From rp_plot.m after converting it into a function (can be deleted)
% clear k g id p1 fltr* saveit keydates labels tsmats years ax yr_*

%% From rp_us.m after converting it to a function (can be deleted)
% tnrs3mo   = pnum2cell(maturities);
% tnrs      = pnum2cell(maturities(2:end));       % Cell with all the tenors (starting 1yr) as strings
% name_us   = strcat('USD ZERO-COUPON YIELD',{' '},tnrs3mo,' YR');
% paramsNSS = {'BETA0';'BETA1';'BETA2';'BETA3';'TAU1';'TAU2'};
% name_yE   = strcat('USD EXPECTED SHORT RATE IN',{' '},tnrs,' YR');
% name_yQ   = strcat('USD RISK NEUTRAL YIELD',{' '},tnrs,' YR');
% name_yP   = strcat('USD PHYSICAL YIELD',{' '},tnrs,' YR');
% name_rp   = strcat('USD RISK PREMIUM',{' '},tnrs,' YR');
% hdr_ycus  = construct_hdr('USZC',name_us,tnrs3mo);
% hdr_param = construct_hdr('PARAMETER','USD N-S-S YIELD CURVE',paramsNSS);
% hdr_yE    = construct_hdr('USYE',name_yE,tnrs);
% hdr_yQ    = construct_hdr('USYQ',name_yQ,tnrs);
% hdr_yP    = construct_hdr('USYP',name_yP,tnrs);
% hdr_rpus  = construct_hdr('USRP',name_rp,tnrs);
% hdr_rmseu = construct_hdr('USRMSEATSM','USD ATSM FIT RMSE','X');
% hdr_usrp  = [{'type','description','tenor'; 'IMFC','IMF CODE','X'};
%             hdr_ycus; hdr_param; hdr_yE; hdr_yQ; hdr_yP; hdr_rpus; hdr_rmseu];

% fltrZC  = ismember(hdr_usrp(:,1),'USZC') & ~ismember(hdr_usrp(:,3),'0.25');
% tnrs_rp = cellfun(@str2num,hdr_usrp(fltrRP,3)); % Convert str into double
% y       = data_usrp(:,fltrZC);
% z       = data_usrp(:,fltrRP);

% clear date explained fltr* id l maturities* params0 times date1 date2 dateIdx
% clear acm_parts acm_labels yr_* row KWtp yields* x y z nobs idxDates tnrs_*
% clear name_* hdr_y* hdr_param hdr_r* paramsNSS rmse data_aux risk_* ydata

%% From rp_correlations.m after converting it to a function (can be deleted)
% name_resd = strcat('RESIDUAL REGRESSION EM TP ON US TP',{' '},tnrs,' YR');
% hdr_resd  = construct_hdr([YCtype 'RSDRP'],name_resd,tnrs);
% clear k l fltr* date1 date2 yr_* tp_aux* res_aux* tp_EM* tp_US idx epu name_* 
% clear mdl cty ntnrs lccs tnrsCS nobsCS
%% From rp_common_factors.m after converting it to a function (can be deleted)
% clear k reg* fltr* comn_date ctyIDs data_aux date_* init_*
%% End of rp_panel_reg.m
tblnms = [tblnms; names];
        tblmtx = [tblmtx; outmtrx(:)];
        tblbtm = [tblbtm cellstr(num2str([nobs; nctrs; r2]))];
%     end
% end
 
spcs    = cell(size(tblnms));
spcs(:) = {' '};
nmsaux  = [tblnms'; spcs'];
tblnms  = nmsaux(:);
tbl = [tblnms tblmtx];

%% From rp_panel_reg (can be deleted)
% tbl(1:nrgrss,1) = tblnms;                     % Substitute first column
% tbl(:,3:2:end) = [];                          % Delete extra cols (useful for verification)
% tbl(sum(cellfun(@isempty,tbl),2) == size(tbl,2),:) = [];    % Delete blank spaces

%% From rp_plot.m (October 17,2018)
% function rp_plot(dataset_monthly,header_monthly,YCtype,ctrsNcods,yr_subplot,saveit)
%
% %% Risk premia per maturity across countries
% yr_str = num2str(yr_subplot);
% fltrRP = ismember(header_monthly(:,1),[YCtype 'RP']) & ismember(header_monthly(:,3),yr_str);
% rp     = struct('cty',{},'dates',{},'data',{});
% IDs    = cell2mat(ctrsNcods(:,2));
% ctrsLC = ctrsNcods(:,1);
% 
% % Save the country, dates and data for all countries in a structure
% for k = 1:numel(IDs)
%     id          = IDs(k);
%     fltrCTY     = dataset_monthly(:,2) == id;
%     rp(k).cty   = ctrsLC{k};
%     rp(k).dates = dataset_monthly(fltrCTY,1);
%     rp(k).data  = dataset_monthly(fltrCTY,fltrRP);
% end
% 
% % Order in which countries will appear in subplots
% % g = [1 5 6; 2 8 9; 3 11 13; 7 10 15; 4 12 14];      % By region
% g = [7 2 6; 3 8 9; 3 11 13; 7 10 15; 4 12 14];      % By region
% 8 +24
% for k = 1:4
%     if k < 4
%         subplot(2,2,k)
%         plot(rp(g(k,1)).dates,rp(g(k,1)).data,rp(g(k,2)).dates,rp(g(k,2)).data,'-.',...
%             rp(g(k,3)).dates,rp(g(k,3)).data,'--');
%         labels = {rp(g(k,1)).cty, rp(g(k,2)).cty, rp(g(k,3)).cty};
% %         legend(labels,'Location','best','Orientation','horizontal')
% %         datetick('x','yy')
%     else
%         subplot(2,2,k)
%         plot(rp(g(k,1)).dates,rp(g(k,1)).data,rp(g(k,2)).dates,rp(g(k,2)).data,'-.');
%         labels = {rp(g(k,1)).cty, rp(g(k,2)).cty};
% %         legend(labels,'Location','best','Orientation','horizontal')
% %         datetick('x','yy')
%     end
%     legend(labels,'Location','best','Orientation','horizontal')
%     datetick('x','yy')
% end
% 
% % Title over a group of subplots
% ax = axes('Units','Normal','Position',[.075 .075 .85 .85],'Visible','off');
% set(get(ax,'Title'),'Visible','on')
% title([yr_str ' Yr Term Premia'])
% save_figure(['rp_' yr_str 'yr_1'],saveit)
% 
% % Countries not in subplot
% figure
% k = 5;
% plot(rp(g(k,1)).dates,rp(g(k,1)).data,rp(g(k,2)).dates,rp(g(k,2)).data,'-.',...
%     rp(g(k,3)).dates,rp(g(k,3)).data,'--');
% labels = {rp(g(k,1)).cty, rp(g(k,2)).cty, rp(g(k,3)).cty};
% legend(labels,'Location','best','Orientation','horizontal')
% datetick('x','yy')
% title([yr_str ' Yr Term Premia'])
% save_figure(['rp_' yr_str 'yr_2'],saveit)
 
%% From rp_plot before nesting 2 for loops for subplot(2,1,[1 2])
function rp_plot(dataset_monthly,header_monthly,YCtype,ctrsNcods,yr_subplot,saveit)
% This function plots the risk premia of different countries together; uses
% the dataset generated by rp_estimation.m
% Calls to m-files: save_figure.m, pnum2cell.m
%
%     INPUTS
% dataset_monthly - matrix with monthly obs of N-S curves as rows, col1 has dates
% header_monthly  - cell with names for the columns of data_monthly
% YCtype          - char with the type of risk premia to plot (from risky or risk-free LC)
% ctrsNcods       - cell with countries (and their IMF codes) to plot
% yr_plot         - double with the maturity to show in subplots
% saveit          - double: 1 to save figures, 0 otherwise
% 
% Pavel Solís (pavel.solis@gmail.com), September 2018
%
%% Risk premia per maturity across countries
yr_str   = num2str(yr_subplot);
fltrRP   = ismember(header_monthly(:,1),[YCtype 'RP']) & ismember(header_monthly(:,3),yr_str);
rp       = struct('cty',{},'dates',{},'data',{});
IDs      = cell2mat(ctrsNcods(:,2));
ctrsLC   = ctrsNcods(:,1);
keydates = [733681; 733863; 735415; 736664];        % datenum for Sept2008, March 2009, June2013, Nov2016

% Save the country, dates and data for all countries in a structure
for k = 1:numel(IDs)
    id          = IDs(k);
    fltrCTY     = dataset_monthly(:,2) == id;
    rp(k).cty   = ctrsLC{k};
    rp(k).dates = dataset_monthly(fltrCTY,1);
    rp(k).data  = dataset_monthly(fltrCTY,fltrRP);
    if id == 542                                    % Only for plotting purposes because long history
       rp(k).dates = rp(k).dates(64:end);
       rp(k).data  = rp(k).data(64:end);
    end
end

% Order in which countries will appear in subplots
% g = [1 5 6; 2 8 9; 3 11 13; 7 10 15; 4 12 14];      % By region
g = [7 2 11; 3 14 9; 3 11 13; 7 10 15; 6 12 15];      % For 5 & 10 YR TP

for k = 1:4
    if k < 3%4
        % subplot(2,2,k)
        subplot(2,1,k);
        p1 = plot(rp(g(k,1)).dates,rp(g(k,1)).data,rp(g(k,2)).dates,rp(g(k,2)).data,'-.',...
            rp(g(k,3)).dates,rp(g(k,3)).data,'--');
        labels = {rp(g(k,1)).cty, rp(g(k,2)).cty, rp(g(k,3)).cty};
%     else
%         subplot(2,2,k);
%         p1 = plot(rp(g(k,1)).dates,rp(g(k,1)).data,rp(g(k,2)).dates,rp(g(k,2)).data,'-.');
%         labels = {rp(g(k,1)).cty, rp(g(k,2)).cty};
    end
    line(repmat(keydates,1,2),get(gca,'YLim'),'Color',[0 0 0]+0.65,'LineStyle','-.'); % Vertical lines
    datetick('x','yy')
    line(xlim,[0,0],'Color',[0 0 0]+0.6);  % Horizontal line at the origin
    legend(p1,labels,'Location','best','Orientation','horizontal')
end

% Title over a group of subplots
ax = axes('Units','Normal','Position',[.075 .075 .85 .85],'Visible','off');
set(get(ax,'Title'),'Visible','on')
title([yr_str '-Year Term Premia'])
save_figure(['rp_' yr_str 'yr_1'],saveit)

% Countries not in subplot
figure
k = 5;
p1 = plot(rp(g(k,1)).dates,rp(g(k,1)).data,rp(g(k,2)).dates,rp(g(k,2)).data,'-.',...
     rp(g(k,3)).dates,rp(g(k,3)).data,'--');
labels = {rp(g(k,1)).cty, rp(g(k,2)).cty, rp(g(k,3)).cty};
line(repmat(keydates,1,2),get(gca,'YLim'),'Color',[0 0 0]+0.65,'LineStyle','-.'); % Vertical lines
datetick('x','yy')
line(xlim,[0,0],'Color',[0 0 0]+0.6);  % Horizontal line at the origin
legend(p1,labels,'Location','best','Orientation','horizontal')
title([yr_str '-Year Term Premia'])
save_figure(['rp_' yr_str 'yr_2'],saveit)

%% Risk premia per country across maturities (Term structure of risk premia)
% years    = [1; 5; 10];                      % Maturities for RP term structure
% tsmats   = pnum2cell(years);
% 
% for k = 1:numel(IDs)
%     id      = IDs(k);
%     fltrCTY = dataset_monthly(:,2) == id;
%     fltrYRS = ismember(header_monthly(:,1),[YCtype 'RP']) & ismember(header_monthly(:,3),tsmats);
%     figure
%     p1      = plot(dataset_monthly(fltrCTY,1),dataset_monthly(fltrCTY,fltrYRS));
%     labels  = strcat(tsmats,' Yr');
%     
%     line(repmat(keydates,1,2),get(gca,'YLim'),'Color',[0 0 0]+0.65,'LineStyle','-.'); % Vertical lines
%     datetick('x','yy')
%     line(xlim,[0,0],'Color',[0 0 0]+0.6);  % Horizontal line at the origin
%     legend(p1,labels,'Location','best','Orientation','horizontal')
%     title([ctrsLC{k} ' Term Structure of Term Premia'])
%     save_figure(['rp_ts_' ctrsLC{k}],saveit)
% end

%% Sources
%
% Insert a title over a group of subplots
% https://www.mathworks.com/matlabcentral/answers/100459-how-can-i-insert-a-title-over-a-group-of-subplots



%% Dates and Times
% datetime is the best data type for representing points in time
% datetime arrays support arithmetic, sorting, comparisons, plotting, and formatted display
t = datetime(2014,6,28,6:7,0,0);% datetime array that represents two dates
t.Format = 'MMM dd, yyyy';      % Change the display format of the datetime array

% results of arithmetic differences are returned in duration (length of time) arrays
d.Format = 'h';                 % Change the display format of the duration array
d = days(2);                    % duration in a single unit of fixed length
L = calmonths(2);               % duration in a single unit of variable length
t2 = t+calmonths(2)+caldays(35);% Add calendar durations to a datetime to compute a new date
t = t1:t2;                      % The default step size is one calendar day
t = t1:caldays(2):t2;           % Sequence of Datetime Values Between Endpoints with Step Size of 2 calendar days
t = t1:days(1):t2;              % sequence of datetime values spaced by one FIXED-length day
d = 0:seconds(30):minutes(3);   % sequence of duration values between 0 and 3 minutes, incremented by 30 seconds

t = datetime(2013,11,1) + calmonths(1:5);  % Each datetime in t occurs on the first day of each month
t = datetime(2014,1,31) + calmonths(0:11); % sequence of dates that fall on the last day of each month

t_years = t.Year;               % Get the year values of each datetime in the array
m = month(t);                   % Using functions is an alternate way to retrieve specific date or time
[y,m,d] = ymd(t);               % get the year, month, and day values of t as three separate numeric arrays
tf = isbetween(A,t1,t2);        % determine whether the values lie within the interval bounded by t1 and t2

xlim(datetime(2014,[7 8],[12 23])) % Change the x-axis limits
xtickformat('dd-MMM-yyyy')         % change the format for the tick labels along the x-axis

% A serial date number represents a calendar date as the number of days that has passed since a fixed base date
% datenum convert a datetime array to a serial date number
datenum('03-Oct-2010')
d = '23-Aug-2010 16:35:42';
t = datetime(d,'InputFormat','dd-MMM-yyyy HH:mm:ss');% Convert date strings to datetime array, specify input format
t = datetime(731885.75,'ConvertFrom','datenum');     % Convert serial date numbers to a datetime array
S = char(t);                    % Convert a datetime array to a character vector (e.g. to append to a file name)
str = string(t);                % Convert a datetime value to a string


%% Categorical Arrays
% A categorical array provides efficient storage and convenient manipulation of data
% Categorical arrays are often used in a table to define groups of rows

valueset = {'small','medium','large'};                   % first category specified is the smallest category
sizeOrd = categorical(AllSizes,valueset,'Ordinal',true); % ordinal categorical array
isordinal(sizeOrd)                                       % Determine if the categorical array is ordinal

T.SelfAssessedHealthStatus = categorical(T.SelfAssessedHealthStatus,...
{'Poor','Fair','Good','Excellent'},'Ordinal',true);
summary(SelfAssessedHealthStatus)
histogram(SelfAssessedHealthStatus)                      % Plot Categorical Data
histogram(Location(SelfAssessedHealthStatus<='Fair'))

vars = {'Age','Height','Weight'};
rows = T.Location=='County General Hospital' & T.Gender=='Female';
T1 = T(rows,vars);              % Select Data Based on Categories: gender is female, location is CGH

rows = T.SelfAssessedHealthStatus<='Fair';
T2 = T(rows,vars);              % all patients who assessed their health status as poor or fair

VA_CountyGenIndex = ...
ismember(Location,{'County General Hospital','VA Hospital'}); % Search for Members of a Group of Categories
LastName(VA_CountyGenIndex);

histogram(Age(Gender=='Female'))                % plot the age of only the female patients

Location = removecats(Location,'VA Hospital');  % remove VA Hospital from the categories of Location


%% Tables
% readtable reads variables with nonnumeric elements as cell array of character vectors
T = readtable('messy.csv','TreatAsEmpty',{'.','NA'});
T = readtable('testScores.csv','ReadRowNames',true);  % Use the first column as row names in the table
T.Properties.RowNames = LastName;                     % Otherwise, row names can later be assigned

% Accessing data in a table
% you can specify rows/variables as a colon, numeric indices, logical expressions, a single
% variable name, a cell array of variable names; for variables as the output of the vartype function
T(rows,vars)        % table, one or more rows, one or more variables
S = vartype(type);
T(rows,S)           % table, one or more rows, one or more variables of the specified type

T{rows,vars}        % extract data, one or more rows, one or more variables
T{rows,S}           % extract data, one or more rows, one or more variables of the specified type
T.var, T.(varindex) % extract data, ALL rows, ONE variable
T.var(rows)         % extract data, one or more rows, ONE variable
T.Variables         % extract data, ALL rows, ALL variables when they can be horizontally concatenated into array

T.Properties
T = addprop(T,{'OutputFileName','OutputFileType','ToPlot'}, ... % add custom properties
{'table','table','variable'});                       % first two are table metadata, last one is variable metadata
T.Properties.CustomProperties.OutputFileName = 'outageResults';
T.Properties.CustomProperties.OutputFileType = '.mat';
T.Properties.CustomProperties.ToPlot = [false false true true true false]; % reordered appropriately when movevars
stackedplot(T,T.Properties.CustomProperties.ToPlot); % To plot only the desired variables
T = rmprop(T,{'OutputFileName','OutputFileType'});   % Remove custom properties

T.Properties.VariableNames{'Gender'} = 'Sex';       % Change variable name
T{:,2:end} = T{:,2:end}*25/100;                     % Replace Data Values

summary(T)
size(T)
Tnew = T('Johnson',{'Height','Weight'});            % Select specific variables of the patient named 'Johnson'
T.BMI = (T.Weight*0.453592)./(T.Height*0.0254).^2;  % Calculate and Add Result as Table Variable
T.Properties.VariableUnits{'BMI'} = 'kg/m^2';
T.Properties.VariableDescriptions{'BMI'} = 'Body Mass Index';

tf = (T.Smoker == false);
h1 = histogram(T.BMI(tf));                          % whether there is a relationship between smoking and BMI

T = sortrows(T,'RowNames');
T = sortrows(T,'OutageTime');                       % Sort it using the OutageTime variable (in ascending order)
T3 = sortrows(T2,{'C','A'},{'descend','ascend'});   % Sort in descending order by C, then in ascending order by A

varnames = T.Properties.VariableNames;
others = ~strcmp('Gender',varnames);
varnames = [varnames(others) 'Gender'];             % reorder table variables by name

nonsmokers = T;                 % Create a subtable containing data only for the patients who are not smokers
toDelete = (nonsmokers.Smoker == true);
nonsmokers(toDelete,:) = [];
nonsmokers.Smoker = [];         % Delete Smoker variable from the table Using Dot Syntax

Tnew = unique(Tnew);            % deletes two duplicate rows
Tnew([18,20,21],:) = [];        % Delete rows 18, 20, and 21 from the table

rows = patients.Age<30;
vars = {'Gender','Height','Weight'};
T3 = patients(rows,vars);       % return a table containing the desired subset of the data

rows = patients.Smoker==false & patients.Age<30;
patients.Height(rows);          % extract the desired rows from a variable

toDelete = Tnew.Age < 30;
Tnew(toDelete,:) = [];          % delete rows for any patients under the age of 30
T(:,'Gender') = [];             % Remove the Gender variable from the table

T = addvars(T,LastName,'Before','Age'); % Add Variable from Workspace to Table
T = movevars(T,'BMI','After','Weight'); % Move Variable in Table
T = movevars(T,'RestorationTime','Before',1);
T = T(:,[5 1:4 6 7]);           % reorder the table variables Using Indexing
T3 = T3(:,{'A','C','B','D','E'});% Reorder the table so that A and C are next to each other
T = removevars(T,{'Systolic','Diastolic'}); % Delete Variables
T = mergevars(T,{'Systolic','Diastolic'},'NewVariableName','BP');
T = splitvars(T,'BloodPressure','NewVariableNames',{'Systolic','Diastolic'});
T3 = rows2vars(T,'VariableNamesSource','LastName'); % Reorient Rows To Become Variables

TF = ismissing(T,{'' '.' 'NA' NaN -99});    % Find Rows with Missing Values
T(any(TF,2),:)                              % Display the subset of rows with Missing Values
T = standardizeMissing(T,-99);              % replaces instances of -99 with NaN
T2 = fillmissing(T,'previous');             % replace missing values with values from previous rows
T3 = rmmissing(T);                          % contains only the rows from T without missing values

A = patients{1:5,{'Height','Weight'}};      % Extract Multiple Rows and Multiple Variables into an Array
T.TestAvg = mean(T{:,2:end},2); % Extract data from variables 2-4, find average of each row, store it in new var
varfun(@mean,T,'InputVariables','TestAvg',...
'GroupingVariables','Gender')               % Compute the mean of TestAvg by gender of the students

[G,smoker] = findgroups(Smoker);    % Split the patients into nonsmokers and smokers (Smoker is grouping variable)
                                    % G: vector of group identifiers; smoker: groups
meanWeight = splitapply(@mean,Weight,G);        % vector with the mean weight for each group

[G,gender,smoker] = findgroups(Gender,Smoker);  % unique combinations of values across grouping variables
meanWeight = splitapply(@mean,Weight,G);
T = table(gender,smoker,meanWeight);

S = SelfAssessedHealthStatus;
I = ismember(S,{'Poor','Fair'});                       % Compare the standard deviation in Diastolic readings of 
stdDiastolicPF = splitapply(@std,Diastolic(I),G(I));   % those patients who report Poor or Fair health, and 
stdDiastolicGE = splitapply(@std,Diastolic(~I),G(~I)); % those patients who report Good or Excellent health

G = findgroups(T.Region);
maxLoss = splitapply(@max,T.Loss,G);                   % Determine the greatest power loss in each region

T1 = T(:,{'Region','Cause'});
[G,powerLosses] = findgroups(T1);                      % powerLosses is a table because T1 is a table
powerLosses.maxLoss = splitapply(@max,T.Loss,G);       % Determine greatest power loss by cause in each region
osumFcn = @(x)(sum(x,'omitnan'));       
powerLosses.totalCustomers = splitapply(osumFcn,T.Customers,G); % Calculate Number of Customers Impacted


%% Timetables

indoors = readtable('indoors.csv'); % readtable function returns a table only
indoors = table2timetable(indoors); % convert table to a timetable

% newTimeBasis: Basis for computing row times of OUTPUT tt
% options: union (default), intersection, commonrange (union over the intersection of time ranges), first, last
tt = synchronize(indoors,outdoors); % Combine all the data into one timetable ('union' is default)
ttHourly = rmmissing(ttHourly);     % Remove rows with missing values
[R,TF] = rmmissing(A,dim,'MinNumMissing',n); % dimension of A to operate along, first dimension is default
                                    % n: remove rows that contain at least n missing values
                                    % TF: logical vector with the rows or columns of A that were removed
TT = synchronize(TT1,TT2,'intersection'); % 'intersection' specifies the basis for the row times of the OUTPUT tt

% newTimeStep: Time step for spacing times in the OUTPUT timetable
TT = synchronize(TT1,TT2,'daily');   % daily specifies the time step for the row times of the output TT
TT = synchronize(TT1,TT2,'monthly'); % TT has data from TT1 and TT2 where they have row times on the time step
                                     % TT has NaNs where it has a row time that TT1 and TT2 don't have

TF = issorted(TT);                   % Determine whether TT is sorted
TT = sortrows(TT);                   % Sort the timetable by row times
sortrows(TT,'Date')                  % refer to the first dimension of the timetable by name
sortrows(TT,{'X' 'Y'})               % sorts by the data variables X and Y; on X first, then on Y

TF = isregular(TT);                  % Determine whether TT has the same time interval between consecutive rows
unique(diff(TT.Time));               % Display the unique differences between row times, AND sorts them


%% Structure Arrays
combined = [struct1,struct2];        % To concatenate structures, they must have the same set of fields
combined(1).a;                       % To access contents of a field, specify index of the structure in the array
upperLeft = S.X(1:50,1:80);          % To access part of a field

numElements = arrayfun(@(x) numel(x.f), s);  % calls function numel for each element of array s e.g. numel(s(1).f)

newStruct(25,50) = struct('a',[],'b',[],'c',[]); % initialize a structure array by assigning empty arrays
                                                 % to each field of the last element in the array
                                                 % here memory is only allocated for the header, not the contents

currentDate = datestr(now,'mmmdd');
myStruct.(currentDate) = [1,2,3];               % dynamic field name
myStruct.('Feb29') %or myStruct.("Feb29")        % both are fine
                                                 
[v1, v2, v3] = s(1:3).f;% returns the field f from multiple elements in a comma-separated list
allNums = [nums.f];     % concatenate data if field f contains the same type of data and can form a hyperrectangle

% Structures can be referenced dynamically, you have to put brackets around the dynamic reference
s.a         % is the same as
s.('a');    % So then,
n = 'a';
s.(n);      % can be used instead
fNames = fieldnames(S);
S.(fNames{n});

% Remove fields (first and fourth) from structure
fields = {'first','fourth'};
S = rmfield(S,fields);

%% Cell Arrays
[r1c1, r2c1, r1c2, r2c2] = C{1:2,1:2};  % returns the contents of multiple cells as a comma-separated list
nums = [C{2,:}];                        % Concatenate the contents when each cell contains the same type of data

C = cell(25,50);    % Initialize a cell array. In this case, Matlab creates the header for a cell array
C{25,50} = [];      % However, it does not allocate any memory for the contents of each cell


%%
Bloomberg
'Sheet',2,'ReadVariableNames',true,'DatetimeType','exceldatenum','TreatAsEmpty','#N/A N/A'

Datastream
'Sheet',2,'ReadVariableNames',true,'DatetimeType','exceldatenum','TreatAsEmpty','NA'

%% From compare_cip.m
diffs = [];
TT.diff = TT.(['dis' tnr]) - TT.(['own' tnr]);  % Calculate daily difference in rhos
diffs = [diffs; tnrsnum(l), mean(TT.diff,'omitnan')];
S(k).rhodiff = diffs;

%% From compare_fx.m
% All Forwards Together
%     plot(TT_daily.Date,[fx_fwd_blpP fx_fwd_blpF fx_fwd_wmrF fx_fwd_wmrM])
%     lgnd = [cellstr(TH_daily.Ticker(fltrBLPpts)),cellstr(TH_daily.Ticker(fltrBLPout)),...
%         cellstr(TH_daily.Ticker(fltrWMRf)),cellstr(TH_daily.Ticker(fltrWMRm))];
% 
% All Forwards Together (Not Accounting for Forward Points Convention)
% 
% for k = 1:length(currEM)
%     tnr = 0.25;
%     fltrFWD = TH_daily.Currency==currEM{k} & TH_daily.Type=='FWD' & TH_daily.Tenor==tnr;
%     fwd = TT_daily{:,fltrFWD};
%     figure
%     plot(TT_daily.Date,fwd)
%     lgnd = strcat(cellstr(TH_daily.Ticker(fltrFWD)),{' '},cellstr(TH_daily.Source(fltrFWD)));
%     legend(lgnd,'Location','best')
%     title(currEM{k})
%     datetick('x','yy','keeplimits')
% end

%% From matchtnrs.m (can be deleted)
% % If necessary, adjust filters so that all tenors coincide
% [tnrmin, minpos] = min(ntnr);           % Find min and max tenors
% tnrmax = max(ntnr);
% if tnrmin ~= tnrmax                     % Stop if all have same tenors (tnrmin=tnrmax)
%     tnrshigh = ~ismember(ntnr,tnrmin);  % Logical of high tenors
%     tnrshpos = find(tnrshigh);          % Position of high tenors
%     for k = tnrshpos                    % Remove tenors that will not be used
%         [fltr{k},tnr{k},idx{k}] = adjustfltr(tnr{k},tnr{minpos},idx{k},fltr{k});
%     end
% end
% 
% % Flag cases with same tnrmin but different elements (eg [1,3,4] & [2,3,4]), if any
%  Applied to PHP, PLN, RUB when currencies = {LC,LC} and types = {'LC','LCSYNT'};
% if sum(ntnr(:) == tnrmin) > 1          % Only if at least 2 have tnrmin
%     tnrmins = find(ntnr(:) == tnrmin); % Positions of tenors with same tnrmin
%     for k = tnrmins(2:end)'            % By if condition, there are at least 2
%         coincident = adjustfltr(tnr{k},tnr{tnrmins(1)},idx{k},fltr{k});
%         if sum(coincident) < tnrmin
%             % warning('Types %s and %s have different tenors.',types{tnrmins(1)},types{k})
%             warning('Types have different tenors.')
%         end
%     end
% end 
% 
% ntnr = cellfun(@sum,fltr);

%     function [fltr1,tnr1,idx1] = adjustfltr(tnr1,tnr2,idx1,fltr1)

%%

fltrLC     = ismember(header_daily(:,2),YCtype);      % 1 if LC/LCSYNT data
ncntrs = length(S);%numel(curncs);
tnrs_all    = [0; cellfun(@str2num,header_daily(2:end,5))];

% Construct the database of LC yield curves
dataset_lc = [];
for k = 1:ncntrs                                  % Adjust here when working with one country
    crncy = S(k).iso;

    % Available tenors per country
    fltrYLD = ismember(header_daily(:,1),crncy) & fltrLC;   % Country + LC data
    tnrs    = tnrs_all(fltrYLD);                            % Tenors available

    % End-of-month data
    idxDates = sum(~isnan(dataset_daily(:,fltrYLD)),2) > 4; 
    fltrYLD(1) = true;                                      % To include dates
    data_lc  = dataset_daily(idxDates,fltrYLD);             % Keep rows with at least 5 observations
    [data_lc,first_obs] = end_of_month(data_lc);            % Keep end-of-month observations
    S(k).start = datestr(first_obs,'mmm-yyyy');             % First monthly observation
    S(k).lcsynt = [0 tnrs'; data_lc];

% dates = data_lc(:,1);
% yields = data_lc(:,2:end);
% 
% dates = dates(80:end);
% yields = yields(80:end,:);
% nobs = size(yields,1);
end
%%
[coeff1,score1,~,~,~,mu1] = pca(yields,'algorithm','als');
reconstrct = score1*coeff1' + repmat(mu1,nobs,1);
%%
    for l = 1:nobs                                  % Adjust here when working in one month
%         % Tenors available may fluctuate between 5 and numel(tnrs)
%         date    = data_lc(l,1);
%         ydataLC = data_lc(l,fltrYLD)';                      % Column vector
%         idxY    = ~isnan(ydataLC);                          % sum(idxY) >= 5, see above
%         ydataLC = ydataLC(idxY);
%         tnrs1   = tnrs(idxY);                               % Tenors with data on date l
%         ntnrs(l)= numel(tnrs1);
%         if     l == 1
%             S(k).ntnrsI = numel(tnrs1);
%         elseif l == nobs
%             S(k).ntnrsL = numel(tnrs1);
%         end

%         % Plot yields: actual, dropped, LC NS, US NSS
%         plot(tnrs1,ydataLC)
%         plot(tnrs,yields(l,:)','o',tnrs,reconstrct(l,:)','x',tnrs,yields_m(l,:)','*')
%         plot(mats,yields(l,:)','o',mats,yields_m(l,:)','x')
        plot(mats,yields(l,:)','o',mats,yields_mKF(l,:)','x')
        title([crncy '  ' datestr(dates(l))]), ylabel('%'), xlabel('Maturity')
        H(l) = getframe(gcf);                               % To see individual frames: imshow(H(2).cdata)
    end
%     dataset_lc = [dataset_lc; dataset_aux];

% end for cntrs
%% Synchronize data from JSZ and GSW
% Run read_usyc.m, use mats instead of mtrts
T_jsz = array2table(yields*100);
TT_jsz = table2timetable(T_jsz,'RowTimes',datetime(dates,'ConvertFrom','datenum'));
TT_combined = synchronize(TT_jsz,TT_usyc,'intersection');

plot(TT_combined.Time,[TT_combined{:,1} TT_combined{:,8}]);
plot(TT_combined.Time,[TT_combined{:,2} TT_combined{:,9}]);
plot(TT_combined.Time,[TT_combined{:,3} TT_combined{:,10}]);
plot(TT_combined.Time,[TT_combined{:,4} TT_combined{:,11}]);
plot(TT_combined.Time,[TT_combined{:,5} TT_combined{:,12}]);
plot(TT_combined.Time,[TT_combined{:,6} TT_combined{:,13}]);
plot(TT_combined.Time,[TT_combined{:,7} TT_combined{:,14}]);


%% Replicate RY Model in JSZ Paper

load('sample_RY_model_jsz.mat')
load('sample_zeros.mat')
[BcP, AcP, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, K0Q_X, K1Q_X, AX, BX, Sigma_X] = jszLoadings(W, K1Q_X, kinfQ, Sigma_cP, mats, dt);
zyields_m = ones(length(dates),1)*AcP + (yields*W.')*BcP;

% sample_zeros.mat
% Variables: dates mats yields

% sample_RY_model_jsz.mat
% Variables: AX	AcP	BcP	BX	dt	K0Q_cP	K0Q_X	K1Q_cP	K1Q_X	kinfQ	llks	rho0_cP	...
%     rho0_X	rho1_cP	rho1_X	rinfQ	Sigma_cP	sigma_e	Sigma_X	W

S = whos;
zAX = AX;	zAcP = AcP;	zBcP = BcP;	zBX = BX;	zdt = dt;	zK0Q_cP = K0Q_cP;...
    zK0Q_X = K0Q_X;	zK1Q_cP = K1Q_cP;	zK1Q_X = K1Q_X;	zkinfQ = kinfQ;	zllks = llks;...
    zrho0_cP = rho0_cP;	zrho0_X = rho0_X;	zrho1_cP = rho1_cP;	zrho1_X = rho1_X;...
    zrinfQ = rinfQ;	zSigma_cP = Sigma_cP;	zsigma_e = sigma_e;	zSigma_X = Sigma_X;	zW = W;

clear AX	AcP	BcP	BX	dt	K0Q_cP	K0Q_X	K1Q_cP	K1Q_X	kinfQ	llks	rho0_cP	...
    rho0_X	rho1_cP	rho1_X	rinfQ	Sigma_cP	sigma_e	Sigma_X	W

% run sample_estimation.m since line 14 and compare variables with zvariables
    % Setup format of model/data:
% W = pcacov(cov(yields));
% W = W(:,1:N)';  % N*J
N = 3;  % N = 2;
W = [1,0,0,0,0,0,0;0,0,1,0,0,0,0;0,0,0,0,0,0,1];    % With this cP is 0.5, 2, 10 yrs
cP = yields*W'; % T*N
dt = 1/12;
    % Estimate the model by ML. 
% help sample_estimation_fun
VERBOSE = true;
[llks, AcP, BcP, AX, BX, kinfQ, K0P_cP, K1P_cP, sigma_e, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, cP, llkP, llkQ,  K0Q_X, K1Q_X, rho0_X, rho1_X, Sigma_cP] = ...
        sample_estimation_fun(W, yields, mats, dt, VERBOSE);
rinfQ = -kinfQ/K1Q_X(1,1);
% kinfQ = -K1Q_X(1,1)*rinfQ;
    % Compute the loadings
[BcP, AcP, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, K0Q_X, K1Q_X, AX, BX, Sigma_X] = jszLoadings(W, K1Q_X, kinfQ, Sigma_cP, mats, dt);
yields_m = ones(length(dates),1)*AcP + (yields*W.')*BcP;
plot(dates,zyields_m(:,7),'x',dates,yields_m(:,7),'+')

% Compare actual yields vs estimated yields
    % Time series
plot(dates,yields(:,7),'x',dates,yields_m(:,7),'+')    % Slightly off in 1 and 5 years

    % Cross section
plot(mats,yields(1,:),'x',mats,yields_m(1,:),'+')      % 8.19 vs 8.25 (6 bp)
plot(mats,yields(25,:),'x',mats,yields_m(25,:),'+')
plot(mats,yields(75,:),'x',mats,yields_m(75,:),'+')    % 6.10 vs 6.03 (7 bp)
plot(mats,yields(100,:),'x',mats,yields_m(100,:),'+')  % 5.6 vs 5.68 (8 bp)
plot(mats,yields(125,:),'x',mats,yields_m(125,:),'+')  % 6.27 vs 6.45 (18 bp), 6.26 vs 6.4 (14 bp)
plot(mats,yields(200,:),'x',mats,yields_m(200,:),'+')  % 4.90 vs 4.95 (5 bp)
plot(mats,yields(216,:),'x',mats,yields_m(216,:),'+')  % 3.17 vs 3.3 (13 bp)

% PCs: actual vs model
[~,PCs] = pca(yields,'NumComponents',3);
[~,PCs_m] = pca(yields_m,'NumComponents',3);
plot(dates,[PCs(:,1) PCs_m(:,1)])    % Closely track actual PCs

N = 3;
Weights = pcacov(cov(yields));
Weights = Weights(:,1:N)';
cPCs = yields*Weights';
plot([PCs_m(:,1) cPCs(:,1)])         % Same pattern, different levels

% K1P_cP
% cP = yields*zW';              % Given by sample_estimation.m
[Gamma_hat, alpha_hat, Omega_hat] = regressVAR(cP);
% K1P_cP = Gamma_hat - eye(N);  % Given by sample_estimation.m

%% Tries to Calculate the TP from JSZ Estimation
% [A,B] = pricing_params(round(mats/dt),K0Q_cP,K1Q_cP,Sigma_cP,rho0_cP*dt,rho1_cP*dt,dt);
dt = 1/12;
mats_periods = round(mats/dt);
K0 = K0Q_cP;
K1 = K1Q_cP;
Sigma = Sigma_cP;
rho0d = rho0_cP*dt;
rho1d = rho1_cP*dt;

% function [A,B] = pricing_params(mats_periods,K0,K1,Sigma,rho0d,rho1d,dt)
        M      = length(mats_periods);
        N      = length(K0);
        A      = zeros(1,M);
        B      = zeros(N,M);
        A(1)   = -rho0d;
        B(:,1) = -rho1d;
        for k  = 2:M
            A(k)   = -rho0d + A(k-1) + K0'*B(:,k-1) + 0.5*B(:,k-1)'*(Sigma*Sigma')*B(:,k-1);
            B(:,k) = -rho1d + B(:,k-1) + K1'*B(:,k-1);
        end
        A = -A./mats_periods;   % Loadings for yields
        B = -B./mats_periods;
        A = A/dt;               % Annualized
        B = B/dt;
% end

yields_own = ones(length(dates),1)*A + (yields*W.')*B;
% yields_own = ones(length(dates),1)*A + cP*B;
% plot(dates,zyields_m(:,7),'x',dates,yields_own(:,7),'+')
yyaxis left
plot(dates,yields(:,7),'x')
yyaxis right
plot(dates,yields_own(:,7),'+')

%% Replicate RPC Model in JSZ Paper

N = 3;
W = pcacov(cov(yields));
W = W(:,1:N)';
cP = yields*W'; % T*N
dt = 1/12;
VERBOSE = true;
[llks, AcP, BcP, AX, BX, kinfQ, K0P_cP, K1P_cP, sigma_e, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, cP, llkP, llkQ,  K0Q_X, K1Q_X, rho0_X, rho1_X, Sigma_cP] = ...
        sample_estimation_fun(W, yields, mats, dt, VERBOSE);
rinfQ = -kinfQ/K1Q_X(1,1);


%% Tries to Replicate RKF Model in JSZ Paper (Close)

N = 3;
W = pcacov(cov(yields));
W = W(:,1:N)';
cP = yields*W'; % T*N
dt = 1/12;
VERBOSE = true;
[llks, AcP, BcP, AX, BX, kinfQ, K0P_cP, K1P_cP, sigma_e, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, cP, llkP, llkQ,  K0Q_X, K1Q_X, rho0_X, rho1_X, Sigma_cP] = ...
        sample_estimation_fun(W, yields, mats, dt, VERBOSE);
[llk, AcP, BcP, AX, BX, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, cP, yields_filtered, cP_filtered] = ...
    jszLLK_KF(yields, W, K1Q_X, kinfQ, Sigma_cP, mats, dt, K0P_cP, K1P_cP, sigma_e);

[BcP, AcP, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, K0Q_X, K1Q_X, AX, BX, Sigma_X] = jszLoadings(W, K1Q_X, kinfQ, Sigma_cP, mats, dt);
rinfQ = -kinfQ/K1Q_X(1,1);
yields_kf = ones(length(dates),1)*AcP + (yields*W.')*BcP;
plot(dates,zyields_m(:,7),'x',dates,yields_kf(:,7),'+')

    % Time series
plot(dates,yields(:,7),'x',dates,yields_kf(:,7),'+')    % Slightly off in 1 and 5 years

    % Cross section
plot(mats,yields(216,:),'x',mats,yields_kf(216,:),'+')

[~,PCs] = pca(yields,'NumComponents',3);
[~,PCs_kf] = pca(yields_kf,'NumComponents',3);
plot(dates,[PCs(:,1) PCs_kf(:,1)])              % Compare with yields_filtered and cP_filtered


%% 
N = 2;
% mats = tnrs';
W = pcacov(cov(yields));
% W = coeff1;
W = W(:,1:N)';  % N*J
cP = yields*W'; % T*N
dt = 1/12;

% Estimate the model by ML. 
% help sample_estimation_fun
VERBOSE = true;
[llks, AcP, BcP, AX, BX, kinfQ, K0P_cP, K1P_cP, sigma_e, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, cP, llkP, llkQ,  K0Q_X, K1Q_X, rho0_X, rho1_X, Sigma_cP] = ...
        sample_estimation_fun(W, yields, mats, dt, VERBOSE);

[BcP, AcP, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, K0Q_X, K1Q_X, AX, BX, Sigma_X] = jszLoadings(W, K1Q_X, kinfQ, Sigma_cP, mats, dt);

yields_m = ones(length(dates),1)*AcP + (yields*W.')*BcP;

figure(1)
plot(year(dates) + month(dates)/12, yields_m)
xlabel('date')
ylabel('yields')



[llk, AcP, BcP, AX, BX, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, cP, yields_filtered, cP_filtered] = ...
    jszLLK_KF(yields, W, K1Q_X, kinfQ, Sigma_cP, mats, dt, K0P_cP, K1P_cP, sigma_e);
fprintf('The average (negative) log likelihood is %6.6g when using KF instead of assuming yields without error at these estimates\n', mean(llk))

[BcP, AcP, K0Q_cP, K1Q_cP, rho0_cP, rho1_cP, K0Q_X, K1Q_X, AX, BX, Sigma_X] = jszLoadings(W, K1Q_X, kinfQ, Sigma_cP, mats, dt);

yields_mKF = ones(length(dates),1)*AcP + (yields*W.')*BcP;

figure(2)
plot(year(dates) + month(dates)/12, [yields*W', cP_filtered])
xlabel('date')
ylabel('yields')


end