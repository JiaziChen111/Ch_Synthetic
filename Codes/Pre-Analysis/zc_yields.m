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
options = optimoptions('lsqcurvefit','Display','off'); lb = []; ub = [];
tic
for k0  = 3%1:numel(curncs)
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
    
    % Exclusions
    if strcmp(LC,'HUF') && strcmp(tnrscll{end},'20')            % HUF 20Y yield behaves oddly
        fltr(find(fltr,1,'last')) = false; tnrscll(end) = [];
    end
    
    % Extract information (in decimals) and preallocate variables
    yldspar = dataset(:,fltr)/100;
    [ndates,ntnrs] = size(yldspar);
    yldszc  = nan(ndates,ntnrs);    ydates  = nan(ndates,ntnrs);    rmse = nan(ndates,1);
    
    for k1 = 1:ndates                                           % daily 
        fltry = ~isnan(yldspar(k1,:));                          % tenors with observations
        if sum(fltry) > 0                                       % at least one observation
            % Tenors and maturities based on settlement day
            tnrs = tnrsnum(fltry);                              % define the tenors
            ydates(k1,fltry) = datemnth(settle(k1),12*tnrs);    % define maturity dates
            
            % Yields treatment depending on whether BFV or IYC curve
            if tfbfv == true                                  	% BFV par yields SAC to zc yields CC
                yzc2fit = pyld2zero(yldspar(k1,fltry)',ydates(k1,fltry)',settle(k1),...
                    'InputCompounding',1,'InputBasis',0,'OutputCompounding',-1,'OutputBasis',0);
            else                                            	% use IYC zero-coupon yields
                yzc2fit = yldspar(k1,fltry)';
            end
            
            % Initial values (use values from previous iteration)
            if k1 == 1
                fmin = find(fltry,1,'first');   fmax = find(fltry,1,'last' );
                beta0 = yldspar(k1,fmax); beta1 = yldspar(k1,fmin) - beta0; beta2 = -beta1; 
                beta3 = beta2;            tau1  = 1;                        tau2  = tau1;
            elseif length(params) == 4                          % previous iteration was NS
                beta0 = params(1); beta1 = params(2); beta2 = params(3); tau1 = params(4);
            else                                                % previous iteration was NSS
                beta0 = params(1); beta1 = params(2); beta2 = params(3); 
                beta3 = params(4); tau1  = params(5); tau2  = params(6);
            end
            
            % Fit NS or NSS model 
            if max(tnrs) <= 10
                init_vals = [beta0 beta1 beta2 tau1];
                [params,~,res] = lsqcurvefit(@y_NS,init_vals,tnrs,yzc2fit',lb,ub,options);	% fit NS model
                yldszc(k1,fltry) = y_NS(params,tnrs)*100;                           % NS yields in percent
            else
                init_vals = [beta0 beta1 beta2 beta3 tau1 tau2];
                [params,~,res] = lsqcurvefit(@y_NSS,init_vals,tnrs,yzc2fit',lb,ub,options);	% fit NSS model
                yldszc(k1,fltry) = y_NSS(params,tnrs)*100;                          % NSS yields in percent
            end
            rmse(k1) = sqrt(mean(res.^2));
            
            plot(tnrs,yzc2fit*100,'b',tnrs,yldszc(k1,fltry),'r',tnrs,yldspar(k1,fltry)*100,'mo')
            title([LC '  ' datestr(settle(k1))])
            H(k1) = getframe(gcf);                              % imshow(H(2).cdata) for individual frames
        end
    end
    ['RMSE for ' LC ': ' num2str(mean(rmse,'omitnan')*100)]
    
    name_ZC = strcat(LC,' NOMINAL LC YIELD CURVE',{' '},tnrscll,' YR');
    hdr_ZC  = construct_hdr(LC,'LCNOM','N/A',name_ZC,tnrscll,' ',' ');
    hdr_zc  = [hdr_zc; hdr_ZC];
    data_zc = [data_zc, yldszc];
end
toc