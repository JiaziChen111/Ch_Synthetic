function [S,corrExp,corrTP] = compare_atsm_surveys(S,currEM,showfigs)
% Compare the expected future policy rate and term premium obtained with an 
% affine term structure model to those from surveys
% 
%	INPUTS
% struct: S         - contains names of countries/currencies, codes and YC data
% char: currEM      - ISO currency codes of EM in the sample
% logical: showfigs - display figures of the comparison if true
% 
%	OUTPUT
% cell: corrExp - nominal and synthetic correl w/surveys of expected policy rate
% cell: corrTP  - nominal and synthetic correl w/term premium from surveys

% m-files called: none
% Pavel Solís (pavel.solis@gmail.com), May 2020

%% Display policy rate forecasts for different maturities
nEMs = length(currEM);
if showfigs
    for k = 1:nEMs
        figure
        plot(S(k).yS(2:end,1),S(k).yS(2:end,2:end))
        title(S(k).cty), ylabel('%'), datetick('x','YY')
        legend(cellfun(@num2str,num2cell(S(k).yS(1,2:end)),'UniformOutput',false))
    end
    input([S(k).iso ' displayed. Press Enter key to continue.']);
end

%% Compare ATSM and surveys
tnr     = 10;                                                                   % maturity for survey
corrExp = cell(nEMs,3); corrTP  = cell(nEMs,3);
for k = 1:nEMs
    if ismember(S(k).iso,{'ILS','ZAR'})                                         % no survey data
        continue
    else
        % Extract information
        ylds_svy = S(k).yS;                                                     % survey expectations
        ylds_nom = S(k).n_data;                                                 % nominal yields
        ylds_syn = S(k).s_data;                                                 % synthetic yields
        yldsPnom = S(k).n_yP;                                                   % nominal expected yields
        yldsPsyn = S(k).s_yP;                                                   % synthetic expected yields
        tp_nom   = S(k).n_tp;                                                   % nominal term premium
        tp_syn   = S(k).s_tp;                                                   % synthetic term premium
        
        % Use the specified tenor, remove header and transform to percentages
        ylds_nom = [ylds_nom(2:end,1) ylds_nom(2:end,ylds_nom(1,:) == tnr)*100];
        ylds_syn = [ylds_syn(2:end,1) ylds_syn(2:end,ylds_syn(1,:) == tnr)*100];
        yldsPnom = [yldsPnom(2:end,1) yldsPnom(2:end,yldsPnom(1,:) == tnr)*100];
        yldsPsyn = [yldsPsyn(2:end,1) yldsPsyn(2:end,yldsPsyn(1,:) == tnr)*100];
        tp_nom   = [tp_nom(2:end,1) tp_nom(2:end,tp_nom(1,:) == tnr)];
        tp_syn   = [tp_syn(2:end,1) tp_syn(2:end,tp_syn(1,:) == tnr)];
        
        % Calculate the semiannual term premium using surveys
        fltrSVYnom = ismember(ylds_svy(:,1),ylds_nom(:,1));                     % compare dates
        fltrSVYsyn = ismember(ylds_svy(:,1),ylds_syn(:,1));
        fltrNOMyld = ismember(ylds_nom(:,1),ylds_svy(2:end,1));
        fltrSYNyld = ismember(ylds_syn(:,1),ylds_svy(2:end,1));
        ylds_nom   = ylds_nom(fltrNOMyld,:);                                    % same periodicity
        ylds_syn   = ylds_syn(fltrSYNyld,:);                                    % same range of dates
        tpnomsvy   = ylds_nom(:,2) - ylds_svy(fltrSVYnom,ylds_svy(1,:) == tnr);
        tpsynsvy   = ylds_syn(:,2) - ylds_svy(fltrSVYsyn,ylds_svy(1,:) == tnr);
        tp_nom_svy = [ylds_nom(:,1) tpnomsvy];
        tp_syn_svy = [ylds_syn(:,1) tpsynsvy];
        S(k).sn_tp = tp_nom_svy;
        S(k).ss_tp = tp_syn_svy;
        
        % Use the semmiannual expected policy rate
        fltrSVYnmP = ismember(ylds_svy(:,1),yldsPnom(:,1));                     % same periodicity
        fltrSVYsnP = ismember(ylds_svy(:,1),yldsPsyn(:,1));                     % same range of dates
        fltrNOMyP  = ismember(yldsPnom(:,1),ylds_svy(2:end,1));
        fltrSYNyP  = ismember(yldsPsyn(:,1),ylds_svy(2:end,1));
        yldsPnom   = yldsPnom(fltrNOMyP,:);
        yldsPsyn   = yldsPsyn(fltrSYNyP,:);
        
        % Use the semmiannual ATSM term premium [Check whether ylds_svy or  tp_nom_svy/tp_syn_svy]
        fltrSVYnTP = ismember(tp_nom_svy(:,1),tp_nom(:,1));                     % same periodicity
        fltrSVYsTP = ismember(tp_syn_svy(:,1),tp_syn(:,1));                     % same range of dates
        fltrNOMtp  = ismember(tp_nom(:,1),tp_nom_svy(:,1));
        fltrSYNtp  = ismember(tp_syn(:,1),tp_syn_svy(:,1));
        tp_nom     = tp_nom(fltrNOMtp,:);
        tp_syn     = tp_syn(fltrSYNtp,:);
        
        % Compare expected policy rates
        corrExp{k,1} = S(k).iso;
        corrExp{k,2} = corr(yldsPnom(:,2),ylds_svy(fltrSVYnmP,ylds_svy(1,:) == tnr),'Rows','complete');
        corrExp{k,3} = corr(yldsPsyn(:,2),ylds_svy(fltrSVYsnP,ylds_svy(1,:) == tnr),'Rows','complete');
        
        if showfigs
            figure
            plot(yldsPnom(:,1),yldsPnom(:,2),yldsPsyn(:,1),yldsPsyn(:,2),...
                ylds_svy(2:end,1),ylds_svy(2:end,ylds_svy(1,:) == tnr))
            title([S(k).iso ' Expected Policy Rate'])
            legend('Nominal','Synthetic','Surveys'), ylabel('%'), datetick('x','YY')
        end
        
        % Compare term premia
        corrTP{k,1} = S(k).iso;
        corrTP{k,2} = corr(tp_nom(:,2),tp_nom_svy(fltrSVYnTP,2),'Rows','complete');
        corrTP{k,3} = corr(tp_syn(:,2),tp_syn_svy(fltrSVYsTP,2),'Rows','complete');
        
        if showfigs
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
end

% mean(cell2mat(corrExp([1:4 6:14],2:3)))
% mean(cell2mat(corrTP([1:4 6:14],2:3)))