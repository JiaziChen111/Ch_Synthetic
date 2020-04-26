function [data_zc,hdr_zc] = zc_yields(header,dataset,curncs)
% ZC_YIELDS Return zero-coupon local currency (LC) yield curves
%   data_zc: stores historical data
%   hdr_zc: stores headers (note: row 1 has no titles, i.e. ready to be appended)
%   In dataset BFV curves report par yields and IYC curves report zero-coupon yields
%   COP, HUF, IDR, KRW, MXN, MYR, PEN, PHP, PLN, ZAR have BFV and IYC LC curves
%   RUB, THB, TRY, AEs only have BFV curves, whereas BRL and ILS only have IYC LC curves

% m-files called: fltr4tickers, construct_hdr
% Pavel Solís (pavel.solis@gmail.com), April 2020
%%
hdr_zc  = {};                                  % no row 1 with titles (i.e. ready to be appended)
data_zc = dataset(:,1);
settle  = dataset(:,1);
for k0  = 25%1:numel(curncs)
tic
    LC  = curncs{k0};	tfbfv = true;
    [fltr,tnrscll] = fltr4tickers(LC,'LC','',header);
    tnrsnum = cellfun(@str2num,tnrscll);
    
    % Determine whether BFV or IYC curve
    if ~isequal(length(unique(tnrscll)),length(tnrscll))     	% case of two curves, chose BFV
        fltr    = fltr & startsWith(header(:,3),{'C','P'});   	% BFV curves start w/ C or P
        tnrscll = header(fltr,5);                           	% update tenors (col 5 in header)
    end
    if any(~startsWith(header(fltr,3),{'C','P'}))            	% case of only IYC curve (BRL, ILS)
        tfbfv = false;
    end
    
    % Exclusions (yields that behave oddly)
    if (strcmp(LC,'HUF') && strcmp(tnrscll{end},'20')) || ...   % PLN since 2012, THB since 2016
       (ismember(LC,{'PLN','RUB','THB','CAD','CHF','DKK','EUR','GBP','SEK'}) && strcmp(tnrscll{end},'30'))
%        (strcmp(LC,'PLN') && strcmp(tnrscll{end},'30')) 
        fltr(find(fltr,1,'last')) = false; tnrscll(end) = [];
    end
    
    % Extract information and preallocate variables
    yldspar = dataset(:,fltr)/100;                              % in decimals
    [ndates,ntnrs] = size(yldspar);
    yldszc  = nan(ndates,ntnrs);    ydates  = nan(ndates,ntnrs);    rmse = nan(ndates,1);   params = [];
    
    % Fit NS/NSS models daily
    for k1 = 1:ndates
        fltry = ~isnan(yldspar(k1,:));                          % tenors with observations
        if sum(fltry) > 0                                       % at least one observation
            % Tenors and maturities based on settlement day
            tnrs = tnrsnum(fltry);                              % define the tenors
            ydates(k1,fltry) = datemnth(settle(k1),12*tnrs);    % define maturity dates
            
            % Yields treatment depending on whether BFV or IYC curve
            if tfbfv == true                                  	% BFV par yields SAC to zc yields CC
                try                                             % if error, use values from previous days
                    yzc2fit = pyld2zero(yldspar(k1,fltry)',ydates(k1,fltry)',settle(k1),...
                        'InputCompounding',1,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
                catch
                    try                                         % eg. curncs{4} = 'IDR', k1 = 2292
                        yzc2fit = pyld2zero(yldspar(k1-1,fltry)',ydates(k1,fltry)',settle(k1),...
                            'InputCompounding',1,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
                    catch                                       % eg. curncs{4} = 'IDR', k1 = 2305
                        yzc2fit = pyld2zero(yldspar(k1-2,fltry)',ydates(k1,fltry)',settle(k1),...
                            'InputCompounding',1,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
                    end
                end
            else                                            	% use IYC zero-coupon yields
                yzc2fit = yldspar(k1,fltry)';
            end
            
            % Initial values from the data
            fmin  = find(fltry,1,'first');   fmax = find(fltry,1,'last' );
            beta0 = yldspar(k1,fmax); beta1 = yldspar(k1,fmin) - beta0; beta2 = -beta1; 
            beta3 = beta2;            tau1  = 1;                        tau2  = tau1;
            
            % Fit NS/NSS models
            [yzcfitted,params,error] = fit_NS_S(yzc2fit,tnrs,params,[beta0 beta1 beta2 beta3 tau1 tau2]);
            yldszc(k1,fltry) = yzcfitted*100;                   % in percentages
            rmse(k1) = error*100;
            
%             % Plot and compare
%             plot(tnrs,yzc2fit*100,'b',tnrs,yldszc(k1,fltry),'r',tnrs,yldspar(k1,fltry)*100,'mo')
%             title([LC '  ' datestr(settle(k1))])
%             H(k1) = getframe(gcf);                              % imshow(H(2).cdata) for individual frames
        end
    end
    
    % Save and append data
    ['RMSE for ' LC ': ' num2str(mean(rmse,'omitnan'))]
    name_ZC = strcat(LC,' NOMINAL LC YIELD CURVE',{' '},tnrscll,' YR');
    hdr_ZC  = construct_hdr(LC,'LCNOM','N/A',name_ZC,tnrscll,' ',' ');
    hdr_zc  = [hdr_zc; hdr_ZC];
    data_zc = [data_zc, yldszc];
toc
end
%%
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