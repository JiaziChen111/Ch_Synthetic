function [data_zc,hdr_zc] = zc_yields(header,dataset,curncs)
% ZC_YIELDS Zero-coupon continuosly compounded local currency (LC) yield curves
%   data_zc: stores historical data
%   hdr_zc: stores headers (note: no title row, i.e. ready to be appended)
%   BFV and IYC curves report coupon-equivalent (CE) par and zero-coupon yields,
%   they need to be converted to zero-coupon continuosly compounding (CC) yields;
%   the code assumes the compounding frequency of CE yields is semiannual
%   COP, HUF, IDR, KRW, MXN, MYR, PEN, PHP, PLN, ZAR have BFV and IYC LC curves
%   RUB, THB, TRY, AEs only have BFV curves, whereas BRL and ILS only have IYC LC curvesa

% m-files called: fltr4tickers, construct_hdr
% Pavel Solís (pavel.solis@gmail.com), April 2020

%% Zero coupon yield curves for advanced and emerging economies
hdr_zc  = {};                                                   % no title row (ie. ready to be appended)
data_zc = dataset(:,1);
settle  = dataset(:,1);
tmax    = 10;
for k0  = 1:numel(curncs)
tic
    LC  = curncs{k0};	tfbfv = true;
    [fltr,tnrscll] = fltr4tickers(LC,'LC','',header);
    
    % Determine whether BFV or IYC curve
    if ~isequal(length(unique(tnrscll)),length(tnrscll))     	% case of two curves, chose BFV
        fltr    = fltr & startsWith(header(:,3),{'C','P'});   	% BFV curves start w/ C or P
        tnrscll = header(fltr,5);                           	% update tenors (col 5 in header)
    end
    if any(~startsWith(header(fltr,3),{'C','P'}))            	% case of only IYC curve (BRL, ILS)
        tfbfv = false;
    end
    tnrsnum = cellfun(@str2num,tnrscll);
    
    % Exclude tenors beyond tmax
    ftrue = find(fltr);                                         % ftrue, ttrue, tnrs* have same dimensions
    ttrue = tnrsnum <= tmax;                                   	% maximum tenor to include
    tnrsnum(~ttrue) = [];   tnrscll(~ttrue) = [];   ftrue(~ttrue) = [];
    fltr(:) = false;        fltr(ftrue)     = true;
    if (strcmp(LC,'HUF') && strcmp(tnrscll{end},'20'))          % in case tmax >= 20
        fltr(find(fltr,1,'last')) = false; tnrscll(end) = [];
    end
    
    % Extract information and preallocate variables
    yldsCE = dataset(:,fltr)/100;                              % in decimals
    [ndates,ntnrs] = size(yldsCE);
    yldszc = nan(ndates,ntnrs);    ydates  = nan(ndates,ntnrs);    rmse = nan(ndates,1);   params = [];
    
    % Fit NS/NSS models daily
    for k1 = 1:ndates
        fltry = ~isnan(yldsCE(k1,:));                           % tenors with observations
        if sum(fltry) > 0                                       % at least one observation
            % Tenors and maturities (based on settlement day)
            tnrs = tnrsnum(fltry);                              % define the tenors
            ydates(k1,fltry) = datemnth(settle(k1),12*tnrs);    % define maturity dates
            
            % Yields treatment depending on whether BFV or IYC curve  (column vectors)
            if tfbfv == true                                  	% BFV par yields CE to zc yields CC
                try                                             % if error, use values from previous days
                    yzc2fit = pyld2zero(yldsCE(k1,fltry)',ydates(k1,fltry)',settle(k1),...
                        'InputCompounding',2,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
                catch
                    try                                         % eg. curncs{4} = 'IDR', k1 = 2292
                        yzc2fit = pyld2zero(yldsCE(k1-1,fltry)',ydates(k1,fltry)',settle(k1),...
                            'InputCompounding',2,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
                    catch                                       % eg. curncs{4} = 'IDR', k1 = 2305
                        yzc2fit = pyld2zero(yldsCE(k1-2,fltry)',ydates(k1,fltry)',settle(k1),...
                            'InputCompounding',2,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
                    end
                end
            else                                            	% IYC zc yields CE to zc yields CC
                yzc2fit = 2*log(1 + yldsCE(k1,fltry)'./2);
            end
            
            % Initial values from the data
            fmin  = find(fltry,1,'first');	fmax  = find(fltry,1,'last' );
            beta0 = yzc2fit(fmax);          beta1 = yzc2fit(fmin) - beta0;  beta2 = -beta1;
            %beta0 = yldsCE(k1,fmax);        beta1 = yldsCE(k1,fmin) - beta0; beta2 = -beta1;
            beta3 = beta2;                  tau1  = 1;                      tau2  = tau1;
            
            % Fit NS/NSS models
            [yzcfitted,params,error] = fit_NS_S(yzc2fit,tnrs,params,[beta0 beta1 beta2 beta3 tau1 tau2]);
            yldszc(k1,fltry) = yzcfitted*100;                   % in percentages
            rmse(k1) = error*100;
            
            % Plot and compare
            plot(tnrs,yzc2fit*100,'b',tnrs,yldszc(k1,fltry),'r',tnrs,yldsCE(k1,fltry)*100,'mo')
            title([LC '  ' datestr(settle(k1))])
            H(k1) = getframe(gcf);                              % imshow(H(2).cdata) for a frame
        end
    end
    
    % Save and append data
    % ['RMSE for ' LC ': ' num2str(mean(rmse,'omitnan'))]         % report fit
    name_ZC = strcat(LC,' NOMINAL LC YIELD CURVE',{' '},tnrscll,' YR');
    hdr_ZC  = construct_hdr(LC,'LCNOM','N/A',name_ZC,tnrscll,' ',' ');
    hdr_zc  = [hdr_zc; hdr_ZC];
    data_zc = [data_zc, yldszc];
toc
end

%% Comparison of US yield curves
hdr_zcus  = {};                                                 % no title row (ie. ready to be appended)
data_zcus = dataset(:,1);
settle    = dataset(:,1);
LC        = 'USD';
for k0  = 1:3                                                   % 1 - GSW, 2 - BFV, 3 - IYC
tic
    % Determine yield curve
    [fltr,~] = fltr4tickers(LC,'LC','',header);
    if     k0 == 1
        [fltr,tnrscll] = fltr4tickers(LC,'HC','',header);       % GSW curve
    elseif k0 == 2
        fltr    = fltr & startsWith(header(:,3),{'C','P'});   	% BFV curve starts w/ C or P
        tnrscll = header(fltr,5);                           	% update tenors (col 5 in header)
    elseif k0 == 3
        fltr    = fltr & ~startsWith(header(:,3),{'C','P'});   	% IYC curve
        tnrscll = header(fltr,5);                           	% update tenors (col 5 in header)
    end
    tnrsnum = cellfun(@str2num,tnrscll);
    
    % Exclude tenors not in BFV or IYC
    ftrue = find(fltr);                                         % ftrue, ttrue, tnrs* have same dimensions
    ttrue = ~ismember(tnrsnum,[0.75 6 11:30]);                	% tenors not in BFV nor IYC and others
    tnrsnum(~ttrue) = [];   tnrscll(~ttrue) = [];   ftrue(~ttrue) = [];
    fltr(:) = false;        fltr(ftrue)     = true;
    
    % Extract information and preallocate variables
    yldsCE = dataset(:,fltr)/100;                               % in decimals
    [ndates,ntnrs] = size(yldsCE);
    yldszc  = nan(ndates,ntnrs);    ydates  = nan(ndates,ntnrs);    rmse = nan(ndates,3);   params = [];
    
    % Type of yield curve
    if k0 == 1; yldszc = yldsCE*100; else                   	% GSW curve
    for k1 = 1:ndates                                           % fit NS/NSS models daily
        fltry = ~isnan(yldsCE(k1,:));                           % tenors with observations
        if sum(fltry) > 0                                       % at least one observation
            % Tenors and maturities (based on settlement day)
            tnrs = tnrsnum(fltry);                              % define the tenors
            ydates(k1,fltry) = datemnth(settle(k1),12*tnrs);    % define maturity dates
            
            % Yields treatment depending on whether BFV or IYC curve (column vectors)
            if     k0 == 2                                      % BFV par yields CE to zc yields CC
                yzc2fit = pyld2zero(yldsCE(k1,fltry)',ydates(k1,fltry)',settle(k1),...
                        'InputCompounding',2,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
            elseif k0 == 3                                      % IYC zc yields CE to zc yields CC
                yzc2fit = 2*log(1 + yldsCE(k1,fltry)'./2);
            end
            
            % Initial values from the data
            fmin  = find(fltry,1,'first');   fmax = find(fltry,1,'last' );
            beta0 = yzc2fit(fmax);           beta1 = yzc2fit(fmin) - beta0;   beta2 = -beta1;
            % beta0 = yldsCE(k1,fmax);         beta1 = yldsCE(k1,fmin) - beta0;   beta2 = -beta1;
            beta3 = beta2;                   tau1  = 1;                         tau2  = tau1;
            
            % Fit NS/NSS models
            [yzcfitted,params,error] = fit_NS_S(yzc2fit,tnrs,params,[beta0 beta1 beta2 beta3 tau1 tau2]);
            yldszc(k1,fltry) = yzcfitted*100;                   % in percentages
            rmse(k1,1) = error*100;
            rmse(k1,2) = sqrt(mean((data_zcus(k1,[false fltry])-yzc2fit'*100).^2));     % zc2fit vs GSW
            rmse(k1,3) = sqrt(mean((data_zcus(k1,[false fltry])-yldszc(k1,fltry)).^2)); % zcfitted vs GSW
            
            % Plot and compare
            plot(tnrs,yzc2fit*100,'b',tnrs,yldszc(k1,fltry),'r',tnrs,data_zcus(k1,[false fltry]),'m')
            title([LC '  ' datestr(settle(k1))])
            H(k1) = getframe(gcf);                              % imshow(H(2).cdata) for a frame
        end
    end
    ['RMSE for ' LC ': ' num2str(mean(rmse(:,1),'omitnan')) ', ' num2str(mean(rmse(:,2),'omitnan'))...
        ', ' num2str(mean(rmse(:,3),'omitnan'))]
    end
    
    % Save and append data
    name_ZC = strcat(LC,' NOMINAL LC YIELD CURVE',{' '},tnrscll,' YR');
    if     k0 == 1; hdr_ZC  = construct_hdr(LC,'LCNOMGSW','N/A',name_ZC,tnrscll,' ',' ');
    elseif k0 == 2; hdr_ZC  = construct_hdr(LC,'LCNOMBFV','N/A',name_ZC,tnrscll,' ',' ');
    elseif k0 == 3; hdr_ZC  = construct_hdr(LC,'LCNOMIYC','N/A',name_ZC,tnrscll,' ',' ');
    end
    hdr_zcus  = [hdr_zcus; hdr_ZC];
    data_zcus = [data_zcus, yldszc];
toc
end

end

function [yldszc,params1model,rmse] = fit_NS_S(yzc2fit,tnrs,params0model,params1data)
% FIT_NS_S Return zero-coupon yields yldszc after fitting NS (if max(tnrs) <= 10Y)
% or NSS (if max(tnrs) > 10Y) model to yzc2fit taking params1data (of length 6) and,
% if available, params0model (of length 4 or 6) as initial values

options = optimoptions('lsqcurvefit','Display','off'); lb = []; ub = [];
if size(yzc2fit,1) ~= 1; yzc2fit = yzc2fit'; end            % ensure yzc2fit is a row vector
if isempty(params0model) || (length(params0model) == 4 && max(tnrs) > 10)
    init_vals = [];                                         % first iteration or change from NS to NSS
else                                                        % previous iteration was either NS or NSS
    init_vals = params0model;                               % use parameters from previous iteration
end                                                         % note: size(init_vals,2) = 4 or 6
vrmse = nan(size(init_vals,1)+1,1);                         % size(rmse,1) = number of initial values

% Fit NS or NSS model
if max(tnrs) <= 10                                          % fit NS model
    init_vals = [init_vals; params1data(1) params1data(2) params1data(3) params1data(5)];
    vparams   = nan(size(init_vals));                       % size(init_vals,2) = 4
    for j0 = 1:size(init_vals,1)                            % at least one, at most two times
        try                                                 % exagerate rmse if init_vals yield error
            [prms,~,res]  = lsqcurvefit(@y_NS,init_vals(j0,:),tnrs,yzc2fit,lb,ub,options);
            vparams(j0,:) = prms;
            vrmse(j0)     = sqrt(mean(res.^2));
        catch
            vparams(j0,:) = init_vals(j0,:);
            vrmse(j0)     = 1e9;
        end
    end
    [rmse,idx]   = min(vrmse);                              % identify best fit
    params1model = vparams(idx,:);                          % choose best fit
    yldszc       = y_NS(params1model,tnrs);                 % extract yields
else                                                        % fit NSS model
    init_vals = [init_vals; params1data];                   % size(init_vals,2) = 6
    vparams   = nan(size(init_vals));
    for j0 = 1:size(init_vals,1)
        try
            [prms,~,res]  = lsqcurvefit(@y_NSS,init_vals(j0,:),tnrs,yzc2fit,lb,ub,options);
            vparams(j0,:) = prms;
            vrmse(j0)     = sqrt(mean(res.^2));
        catch
            vparams(j0,:) = init_vals(j0,:);
            vrmse(j0)     = 1e9;
        end
    end
    [rmse,idx]   = min(vrmse);
    params1model = vparams(idx,:);
    yldszc       = y_NSS(params1model,tnrs);
end
end