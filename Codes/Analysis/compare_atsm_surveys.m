%% Compare Results from ATSM vs Surveys
% This code compares the paths of the long-term expected policy rate and the
% term premium obtained with an affine term structure model with those
% obtained from surveys.

tnr    = 10;
nEMs   = length(currEM);
% corrTP = cell(N,3);

for k = 1:nEMs
    if ismember(S(k).iso,{'ILS','ZAR'})                                         % No survey data
        continue
    else
        ylds_svy = S(k).srvyldsE;                                               % Extract survey expectations
        ylds_nom = S(k).nomdata;                                                % Extract nominal yields
        ylds_syn = S(k).syndata;                                                % Extract synthetic yields
        tp_nom   = S(k).nomtp;                                                  % Extract nominal term premium
        tp_syn   = S(k).syntp;                                                  % Extract synthetic term premium
        
        ylds_nom = [ylds_nom(2:end,1) ylds_nom(2:end,ylds_nom(1,:) == tnr)*100];% Specified tenor, no header
        ylds_syn = [ylds_syn(2:end,1) ylds_syn(2:end,ylds_syn(1,:) == tnr)*100];
        tp_nom   = [tp_nom(3:end,1) tp_nom(3:end,tp_nom(1,:) == tnr)];
        tp_syn   = [tp_syn(3:end,1) tp_syn(3:end,tp_syn(1,:) == tnr)];
        
        fltrSVYnom = ismembertol(ylds_svy(:,1),ylds_nom(:,1),4,'DataScale',1);  % Compare dates
        fltrSVYsyn = ismembertol(ylds_svy(:,1),ylds_syn(:,1),4,'DataScale',1);  % Allow for long weekends
        fltrNOMyld = ismembertol(ylds_nom(:,1),ylds_svy(:,1),4,'DataScale',1);  % (i.e. up to 4 days around date)
        fltrSYNyld = ismembertol(ylds_syn(:,1),ylds_svy(:,1),4,'DataScale',1);
        
        ylds_nom   = ylds_nom(fltrNOMyld,:);                                    % Same periodicity
        ylds_syn   = ylds_syn(fltrSYNyld,:);                                    % Same range of dates
        tpnomsvy   = ylds_nom(:,2) - ylds_svy(fltrSVYnom,2);
        tpsynsvy   = ylds_syn(:,2) - ylds_svy(fltrSVYsyn,2);
        tp_nom_svy = [ylds_nom(:,1) tpnomsvy];
        tp_syn_svy = [ylds_syn(:,1) tpsynsvy];
        
        fltrNOMtp  = ismembertol(tp_nom(:,1),ylds_svy(:,1),4,'DataScale',1);
        fltrSYNtp  = ismembertol(tp_syn(:,1),ylds_svy(:,1),4,'DataScale',1);
        tp_nom     = tp_nom(fltrNOMtp,:);
        tp_syn     = tp_syn(fltrSYNtp,:);
        
        figure
        plot(tp_nom(:,1),tp_nom(:,2),tp_nom_svy(:,1),tp_nom_svy(:,2))
        title([S(k).iso ' Nominal Term Premium'])
        legend('ATSM','Surveys'), ylabel('%'), datetick('x','YY')
        
        figure
        plot(tp_syn(:,1),tp_syn(:,2),tp_syn_svy(:,1),tp_syn_svy(:,2))
        title([S(k).iso ' Synthetic Term Premium'])
        legend('ATSM','Surveys'), ylabel('%'), datetick('x','YY')
    end
end



% corrTP{k,1} = S(k).iso;
% corrTP{k,2} = corr(tp_nom(:,2),tp_nom_svy(:,2),'Rows','complete');
% corrTP{k,3} = corr(tp_syn(:,2),tp_syn_svy(:,2),'Rows','complete');
% 
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