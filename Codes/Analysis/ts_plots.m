
ncntrs  = length(S);
nEMs    = length(currEM);
nAEs    = length(currAE);

[data_macro,hdr_macro]  = read_macrovars(S);          % macro and policy rates
[data_svys,hdr_svys]    = read_surveys();             % CPI and GDP forecasts

%% Store macro data in structure
vars = {'INF','UNE','IP','GDP','CBP'};
fnames = lower(vars);
for l = 1:length(vars)
    fltrMAC = ismember(hdr_macro(:,2),vars{l});
    for k = 1:nEMs
        fltrCTY    = ismember(hdr_macro(:,1),S(k).iso) & fltrMAC;
        fltrCTY(1) = true;
        data_mvar  = data_macro(:,fltrCTY);
        if size(data_mvar,2) > 1
            idxNaN     = isnan(data_mvar(:,2));	% Assumes once publication starts, it continues
            S(k).(fnames{l}) = data_mvar(~idxNaN,:);
        end
    end
end

%% Plot macro data
figdir = 'Data'; formats = {'eps'}; figsave = true;
% whole period
for l = 1:length(vars)
    figure
    for k0 = 1:nEMs
        if size(S(k0).(fnames{l}),2) > 1
            date1 = datenum(S(k0).n_dateb,'mmm-yyyy'); 
            date2 = datenum(S(k0).s_dateb,'mmm-yyyy');
            subplot(3,5,k0)
            plot(S(k0).(fnames{l})(:,1),S(k0).(fnames{l})(:,2))
            title([S(k0).cty ' ' vars{l}]); datetick('x','yy'); yline(0);
            if l ~= 6; ylabel('%'); end
            xline(date1); xline(date2);
        end
    end
    figname = ['wh' vars{l}]; save_figure(figdir,figname,formats,figsave)
end

% within period
for l = 1:length(vars)
    figure
    for k0 = 1:nEMs
        if size(S(k0).(fnames{l}),2) > 1
            [dtmn,dtmx] = datesmnmx(S,k0);
            fltrd = S(k0).(fnames{l})(:,1) >= dtmn;
            subplot(3,5,k0)
            plot(S(k0).(fnames{l})(fltrd,1),S(k0).(fnames{l})(fltrd,2))
            title([S(k0).cty ' ' vars{l}]); datetick('x','yy'); yline(0);
            if l ~= 6; ylabel('%'); end
            xline(dtmx);
        end
    end
    figname = ['wn' vars{l}]; save_figure(figdir,figname,formats,figsave)
end

%% Plot 10Y yields
figdir  = 'Data'; formats = {'eps'}; figsave = true;
fldname = {'n_data','inf','svycbp'};

% Yield only
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end)*100)
    title([S(k0).iso ' ' num2str(S(k0).(fldname{1})(1,end)) 'Y YLD']); 
    datetick('x','yy'); yline(0);
end
figname = 'YLD10Y'; save_figure(figdir,figname,formats,figsave)

% Yield and inflation
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
%     dtmn = datesmnmx(S,k0);
%     fltrd = S(k0).(fnames{2})(:,1) >= dtmn;
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end)*100,...
         S(k0).(fldname{2})(fltrd,1),S(k0).(fldname{2})(fltrd,end))
    title([S(k0).iso]); 
    if k0 ==11; legend('10Y YLD','INF','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
end

% Yield and survey interest rate forecast
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname{3}))
        subplot(3,5,k0)
        plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end)*100,...
             S(k0).(fldname{3})(2:end,1),S(k0).(fldname{3})(2:end,end))
        title([S(k0).iso]); 
        if k0 ==11; legend('10Y YLD','CBP','AutoUpdate','off'); end
        datetick('x','yy'); yline(0);
    end
end
figname = 'YLD10Y_CBP'; save_figure(figdir,figname,formats,figsave)

%% Plot CBP from surveys
figdir = 'Surveys'; formats = {'eps'}; figsave = true;
% whole period
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).svys)
        subplot(3,5,k0)
        plot(S(k0).svys(2:end,1),S(k0).svys(2:end,end))
        title(S(k0).cty); datetick('x','yy'); yline(0);
    end
end
figname = 'whCBP'; save_figure(figdir,figname,formats,figsave)

% within sample period
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).svys)
        dtmn  = datesmnmx(S,k0);
        fltrd = S(k0).svys(:,1) >= dtmn;
        subplot(3,5,k0)
        plot(S(k0).svys(fltrd,1),S(k0).svys(fltrd,end))
        title(S(k0).cty); datetick('x','yy'); yline(0);
    end
end
figname = 'wnCBP'; save_figure(figdir,figname,formats,figsave)

%% Plot INF GDP from surveys
figdir  = 'Surveys'; formats = {'eps'}; figsave = true;
tenors  = cellfun(@str2double,regexp(hdr_svys,'\d*','Match'),'UniformOutput',false);%tnrs in hdr_svys
fltrSVY = ~contains(hdr_svys,'00Y');                                	% exclude current year
macrovr = {'CPI','GDP'};
for k1 = 1:2
    figure
    for k0 = 1:nEMs
        fltrCTY   = contains(hdr_svys,{S(k0).iso,'DATE'}) & fltrSVY; 	% include dates                                          
        macrodata = data_svys(:,fltrCTY);                               % extract variables
        macroname = hdr_svys(fltrCTY);                               	% extract headers
        macrotnr  = unique(cell2mat(tenors(fltrCTY)));            	% extract unique tnrs as doubles
        macroVAR  = macrodata(:,contains(macroname,macrovr{k1}));
        
        dtmn  = datesmnmx(S,k0);
        fltrd = S(k0).svys(:,1) >= dtmn;
        subplot(3,5,k0)
        if sum(fltrCTY) > 1
            fltrDT = any(~isnan(macroVAR),2) & macrodata(:,1) >= dtmn;
            plot(macrodata(fltrDT,1),macroVAR(fltrDT,end))                	% long-term forecast
            title([S(k0).cty ' ' macrovr{k1}]); datetick('x','yy'); yline(0);
            S(k0).(['svy' lower(macrovr{k1})]) = [nan macrotnr;
                                           macrodata(fltrDT,1) macroVAR(fltrDT,:)];
        end
    end
    figname = ['wn' macrovr{k1}]; save_figure(figdir,figname,formats,figsave)
end

%% Plot TP: ny, ns, sy, ss
figdir  = 'Estimation'; formats = {'eps'}; figsave = true;
% fldname = strcat({'ny','sy','nsf','nsb','ssf','ssb'},'_tp');
fldname = [strcat({'ny','sy','nsf','nsb','ssf','ssb'},'_tp') 'ssb_yP'];
fldnmAE = [strcat({'ny','sy'},'_tp') 'ny_yP'];
% Simple
    % EM
for k1 = 1:length(fldname)
    figure
    for k0 = 1:nEMs
        if ~isempty(S(k0).(fldname{k1}))
            subplot(3,5,k0)
            plot(S(k0).(fldname{k1})(2:end,1),S(k0).(fldname{k1})(2:end,end))
    title([S(k0).iso ' ' num2str(S(k0).(fldname{k1})(1,end)) 'Y ' fldname{k1}(end-1:end)]); 
            datetick('x','yy'); yline(0);
        end
    end
    figname = fldname{k1}; save_figure(figdir,figname,formats,figsave)
end

    % AEs
for k1 = 1:length(fldnmAE)
    figure; k2 = 0;
    for k0 = nEMs+1:nEMs+nAEs
        if ~isempty(S(k0).(fldnmAE{k1}))
            k2 = k2 + 1;
            subplot(2,5,k2)
            plot(S(k0).(fldnmAE{k1})(2:end,1),S(k0).(fldnmAE{k1})(2:end,end))
   title([S(k0).iso ' ' num2str(S(k0).(fldnmAE{k1})(1,end)) 'Y ' fldnmAE{k1}(end-1:end)]); 
            datetick('x','yy'); yline(0);
        end
    end
    figname = [fldnmAE{k1} '_AE']; save_figure(figdir,figname,formats,figsave)
end

% QE, TT events: QE1, QE2, MEP, QE3, TT
    % EMs
for k1 = 1:length(fldname)
    figure
    for k0 = 1:nEMs
        if ~isempty(S(k0).(fldname{k1}))
            subplot(3,5,k0)
            plot(S(k0).(fldname{k1})(2:end,1),S(k0).(fldname{k1})(2:end,end))
  title([S(k0).iso ' ' num2str(S(k0).(fldname{k1})(1,end)) 'Y ' fldname{k1}(end-1:end)]); 
            datetick('x','yy'); yline(0);
            xline(datenum('25-Nov-2008')); xline(datenum('3-Nov-2010')); 
            xline(datenum('21-Sep-2011')); xline(datenum('13-Sep-2012')); 
            xline(datenum('19-Jun-2013'));
        end
    end
    figname = [fldname{k1} '_QE']; save_figure(figdir,figname,formats,figsave)
end

    % AEs
for k1 = 1:length(fldnmAE)
    figure; k2 = 0;
    for k0 = nEMs+1:nEMs+nAEs
        if ~isempty(S(k0).(fldnmAE{k1}))
            k2 = k2 + 1;
            subplot(2,5,k2)
            plot(S(k0).(fldnmAE{k1})(2:end,1),S(k0).(fldnmAE{k1})(2:end,end))
       title([S(k0).iso ' ' num2str(S(k0).(fldnmAE{k1})(1,end)) 'Y ' fldnmAE{k1}(end-1:end)]); 
            datetick('x','yy'); yline(0);
            xline(datenum('25-Nov-2008')); xline(datenum('3-Nov-2010')); 
            xline(datenum('21-Sep-2011')); xline(datenum('13-Sep-2012')); 
            xline(datenum('19-Jun-2013'));
        end
    end
    figname = [fldnmAE{k1} '_QE_AE']; save_figure(figdir,figname,formats,figsave)
end

% Local events
for k1 = 1:length(fldname)
    figure; k2 = 0;
    for k0 = 1:nEMs
        if ~isempty(S(k0).(fldname{k1}))
            if ismember(S(k0).iso,{'BRL','COP','HUF','IDR','KRW','PHP','PLN','TRY'})
            k2 = k2 + 1;
            subplot(2,4,k2)
            plot(S(k0).(fldname{k1})(2:end,1),S(k0).(fldname{k1})(2:end,end))
      title([S(k0).iso ' ' num2str(S(k0).(fldname{k1})(1,end)) 'Y ' fldname{k1}(end-1:end)]); 
            datetick('x','yy'); yline(0);
            switch S(k0).iso
                case 'BRL'
                    xline(datenum('19-Oct-2009')); xline(datenum('4-Oct-2010'));
                    xline(datenum('4-Jun-2013')); 
                    %xline(datenum('6-Jan-2011'));xline(datenum('8-Jul-2011'));
                case 'COP'
                    xline(datenum('1-Jun-2006')); xline(datenum('1-May-2007'));
                    %xline(datenum('1-Dec-2004')); 
                    xline(datenum('4-Oct-2008')); % xline(datenum('1-Jul-20007'));
                case 'HUF';xline(datenum('16-Apr-2003'));
                    xline(datenum('1-Aug-2005'));xline(datenum('1-Sep-2018'));
                case 'IDR'; xline(datenum('1-Jul-2005'));
                case 'KRW'; xline(datenum('13-Jun-2010'));
                case 'PHP'; xline(datenum('1-Jan-2002'));
                case 'PLN'; xline(datenum('16-Apr-2003')); xline(datenum('28-Jul-2017'));
%                 case 'RUB'; xline(datenum('27-Sep-2013'));
%                 case 'THB'; xline(datenum('1-Dec-2006'));
                case 'TRY'; xline(datenum('1-Jan-2006')); %xline(datenum('24-Jun-2018'));
                    xline(datenum('2-Oct-2018')); %xline(datenum('27-Jan-2017'));
            end
            end
        end
    end
    figname = [fldname{k1} '_local']; save_figure(figdir,figname,formats,figsave)
end

%% Compare TP (different types, same variable): ny, ns, sy, ss
figdir  = 'Estimation'; formats = {'eps'}; figsave = true;
% sgmS baseline vs free -  explanation for differences: convergence, fit not good for BRL-COP-MYR
fldtype1 = 'ssb_';   fldvar = 'tp';
fldtype2 = 'ssf_';   fldname = [fldtype2 fldvar];
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        h = plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
                 S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == 2
            lh = legend(h,'location','best');
            legend([fldtype1 fldvar],[fldtype2 fldvar],...
                'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

% Synthetic vs nominal: yields only (gains from synthetic)
fldtype1 = 'sy_';   fldvar = 'tp';
fldtype2 = 'ny_';   fldname = [fldtype2 fldvar];
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        h = plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
                 S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == 2
            lh = legend(h,'location','best');
            legend([fldtype1 fldvar],[fldtype2 fldvar],...
                'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

% Synthetic vs nominal: surveys (gains from synthetic)
fldtype1 = 'ssb_';   fldvar = 'tp';
fldtype2 = 'nsb_';   fldname = [fldtype2 fldvar];
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        h = plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
                 S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == 2
            lh = legend(h,'location','best');
            legend([fldtype1 fldvar],[fldtype2 fldvar],...
                'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

% Nominal: surveys vs yields (gains from surveys)
fldtype1 = 'nsb_';   fldvar = 'tp';
fldtype2 = 'ny_';   fldname = [fldtype1 fldvar];
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        h = plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
                 S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == 2
            lh = legend(h,'location','best');
            legend([fldtype1 fldvar],[fldtype2 fldvar],...
                'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

% Synthetic: surveys vs yields (gains from surveys)
fldtype1 = 'ssb_';   fldvar = 'tp';
fldtype2 = 'sy_';   fldname = [fldtype1 fldvar];
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        h = plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
                 S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == 2
            lh = legend(h,'location','best');
            legend([fldtype1 fldvar],[fldtype2 fldvar],...
                'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

% Synthetic surveys vs nominal yields (gains from both)
fldtype1 = 'ssb_';   fldvar = 'tp';
fldtype2 = 'ny_';   fldname = [fldtype1 fldvar];
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        h = plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
                 S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == 2
            lh = legend(h,'location','best');
            legend([fldtype1 fldvar],[fldtype2 fldvar],...
                'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

    % AEs
% Synthetic vs nominal: yields only (gains from synthetic)
fldtype1 = 'ny_';   fldvar = 'tp';
fldtype2 = 'sy_';   fldname = [fldtype2 fldvar]; k2 = 0;
for k0 = nEMs+1:nEMs+nAEs
    if ~isempty(S(k0).(fldname))
        k2 = k2 + 1;
        subplot(2,5,k2)
        h = plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
                 S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == nEMs+2
            lh = legend(h,'location','best');
            legend([fldtype1 fldvar],[fldtype2 fldvar],...
                'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar '_AE']; save_figure(figdir,figname,formats,figsave)

%% Compare TP (different types, different variables): ny, ns, sy, ss
figdir  = 'Estimation'; formats = {'eps','pdf'}; figsave = true;
% Model fit to synthetic
fldname = {'s_blncd','ssb_yQ'};
for k0 = 1:nEMs
    if isempty(S(k0).(fldname{2}))
        fldname = {'s_blncd','sy_yQ'};
    end
    subplot(3,5,k0)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end),...
         S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,end));
    title([S(k0).cty ' ' num2str(S(k0).(fldname{1})(1,end)) 'Y'])
    if k0 == 8
        legend('Observed','Fitted','location','best','AutoUpdate','off')
    end
    datetick('x','yy');yline(0);
end
figname = [fldname1 '_' fldname2]; save_figure(figdir,figname,formats,figsave)

%% Comparing yP vs surveys_CBP (assess fit + benefits of surveys)
figdir  = 'Estimation'; formats = {'eps'}; figsave = true;
% surveys_CBP vs ssb_yP (surveys)
fldname = {'svycbp','ssb_yP'};
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname{2}))
        dtmn  = datesmnmx(S,k0);
        subplot(3,5,k0)
        fltrd = S(k0).(fldname{1})(:,1) >= dtmn;
        fltrt = find(S(k0).(fldname{2})(1,:) == 10);
        plot(S(k0).(fldname{1})(fltrd,1),S(k0).(fldname{1})(fltrd,end),'*',...
             S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,fltrt)*100)
        title([S(k0).iso ' ' num2str(S(k0).(fldname{1})(1,end)) 'Y'])
        if k0 == 14
            legend('Surveys','Model','Orientation','horizontal','location','southoutside','AutoUpdate','off')
        end
        datetick('x','yy');yline(0);
    end
end
figname = [fldname{1} '_' fldname{2}]; save_figure(figdir,figname,formats,figsave)

% surveys_CBP vs sy_yP (yields only)
fldtype1 = 'svycbp';   fldvar1 = '';    fldname1 = [fldtype1 fldvar1];
fldtype2 = 'sy_';   fldvar2 = 'yP';     fldname2 = [fldtype2 fldvar2];
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname1)) && ~isempty(S(k0).(fldname2))
        dtmn  = datesmnmx(S,k0);
        subplot(3,5,k0)
        fltrd = S(k0).(fldname1)(:,1) >= dtmn;
        fltrt = find(S(k0).(fldname2)(1,:) == 10,1,'first');
        h = plot(S(k0).(fldname1)(fltrd,1),S(k0).(fldname1)(fltrd,end)/100,'*',...
                 S(k0).(fldname2)(2:end,1),S(k0).(fldname2)(2:end,fltrt));
        title([S(k0).iso ' ' num2str(S(k0).(fldname1)(1,end)) 'Y'])
        if k0 == 12
            lh = legend(h,'location','best');
            legend(fldname1,fldname2,'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy');yline(0);
    end
end
figname = [fldname1 '_' fldname2]; save_figure(figdir,figname,formats,figsave)

%% Real rate = yP - svyINF
figdir  = 'Estimation'; formats = {'eps'}; figsave = true;
fldname = {'ssb_yP','svycpi'};
% Calculate the real rate for EMs
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname{1}))
        dtst1 = S(k0).(fldname{1}); dtst2 = S(k0).(fldname{2});         % extract data
        hdr1 = dtst1(1,:);  hdr2 = dtst2(1,:);                          % record headers
        tnrcmn = intersect(hdr1,hdr2,'stable');                         % identify common tenors
        fltr1 = ismember(hdr1,tnrcmn);  fltr2 = ismember(hdr2,tnrcmn);  % find common tenors
        fltr1(1) = true;    fltr2(1) = true;                            % include dates
        [~,yP,inf] = syncdtst(dtst1(:,fltr1),dtst2(:,fltr2));           % synchronize arrays
        realr = yP;                                                     % copy dates and headers
        realr(2:end,2:end) = yP(2:end,2:end) - inf(2:end,2:end)/100;    % real rate in decimals
        S(k0).realrt = realr;
    end
end

    % All tenors
fldname = 'realrt';
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,2:end))
        title([S(k0).iso ' ' fldname(1:4)]); 
        if k0 == 1
            legend(cellfun(@num2str,num2cell(S(k0).(fldname)(1,2:end)),...
                'UniformOutput',false),'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldname '_all']; save_figure(figdir,figname,formats,figsave)

    % Long-term
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,end))
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y ' fldname(1:4)]); 
        datetick('x','yy'); yline(0); ylim([-0.02 0.08]);
    end
end
figname = [fldname '_LT']; save_figure(figdir,figname,formats,figsave)

%% TP survey = sy - svyCBP
figdir  = 'Estimation'; formats = {'eps'}; figsave = true;
fldname = {'s_blncd','svycbp'};
% Calculate TP survey
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname{2}))
        dtst1 = S(k0).(fldname{1}); dtst2 = S(k0).(fldname{2});         % extract data
        hdr1 = dtst1(1,:);  hdr2 = dtst2(1,:);                          % record headers
        tnrcmn = intersect(hdr1,hdr2,'stable');                         % identify common tenors
        fltr1 = ismember(hdr1,tnrcmn);  fltr2 = ismember(hdr2,tnrcmn);  % find common tenors
        fltr1(1) = true;    fltr2(1) = true;                            % include dates
        [~,sylds,svycb] = syncdtst(dtst1(:,fltr1),dtst2(:,fltr2));           % synchronize arrays
        svytp = sylds;                                                     % copy dates and headers
        svytp(2:end,2:end) = sylds(2:end,2:end) - svycb(2:end,2:end)/100;    % real rate in decimals
        S(k0).svytp = svytp;
    end
end

    % Long-term
fldname = 'svytp';
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,end))
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TPsvy']); 
        datetick('x','yy'); yline(0);
    end
end
figname = fldname; save_figure(figdir,figname,formats,figsave)

    % Compare TPsvy vs TPsynt
fldname = {'svytp','ssb_tp'};
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname{2}))
        subplot(3,5,k0)
        plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end),...
             S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,end))
        title([S(k0).iso ' ' num2str(S(k0).(fldname{1})(1,end)) 'Y']);
        if k0 == 14; legend('TPsvy','TPsynt','Orientation','horizontal','AutoUpdate','off'); end
        datetick('x','yy'); yline(0);
    end
end
figname = ['svy_' fldname{2}]; save_figure(figdir,figname,formats,figsave)

%% Synthetic vs nominal yP (to define BRP = TP + CR)
figdir  = 'Estimation'; formats = {'eps'}; figsave = true;
    % Surveys
fldtype1 = 'ssb_';   fldvar = 'yP';
fldtype2 = 'nsb_';   fldname = [fldtype2 fldvar];
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        h = plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
                 S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y yP'])
        if k0 == 13
            lh = legend(h,'location','best');
            legend([fldtype1 fldvar],[fldtype2 fldvar],...
                'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

    % Yields only
fldtype1 = 'sy_';   fldvar = 'yP';
fldtype2 = 'ny_';   fldname = [fldtype2 fldvar];
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        h = plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
                 S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y yP'])
        if k0 == 13
            lh = legend(h,'location','best');
            legend([fldtype1 fldvar],[fldtype2 fldvar],...
                'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

%% Term structure of term premia
figdir  = 'Estimation'; formats = {'eps'}; figsave = true;
fldname = 'ssb_tp';
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,2:end))
        title([S(k0).iso ' ' fldname(end-1:end)]); 
        if k0 == 10
            legend(cellfun(@num2str,num2cell(S(k0).(fldname)(1,2:end)),...
                'UniformOutput',false),'AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldname '_ts']; save_figure(figdir,figname,formats,figsave)

% QE events
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,2:end))
        title([S(k0).iso ' ' fldname(end-1:end)]); 
        if k0 == 10
          legend(cellfun(@num2str,num2cell(S(k0).(fldname)(1,2:end)),...
              'UniformOutput',false),'AutoUpdate','off')
        end
        xline(datenum('25-Nov-2008')); xline(datenum('19-Jun-2013'));
        datetick('x','yy'); yline(0);
    end
end
figname = [fldname '_ts_QE']; save_figure(figdir,figname,formats,figsave)

%% Construct bond risk premia

for k0 = 1:nEMs
    if ~isempty(S(k0).ssb_tp)
        fldname = {'ssb_tp','c_data'};
    else
        fldname = {'sy_tp','c_data'};
    end
    dtst1 = S(k0).(fldname{1}); dtst2 = S(k0).(fldname{2});         % extract data
    hdr1 = dtst1(1,:);  hdr2 = dtst2(1,:);                          % record headers
    tnrcmn = intersect(hdr1,hdr2,'stable');                         % identify common tenors
    fltr1 = ismember(hdr1,tnrcmn);  fltr2 = ismember(hdr2,tnrcmn);  % find common tenors
    fltr1(1) = true;    fltr2(1) = true;                            % include dates
    [~,tpsynt,lccs] = syncdtst(dtst1(:,fltr1),dtst2(:,fltr2));    	% synchronize arrays
    brp = tpsynt;                                                  	% copy dates and headers
    brp(2:end,2:end) = tpsynt(2:end,2:end) + lccs(2:end,2:end);     % brp rate in decimals
    S(k0).brp = brp;
end

%% Plot bond risk premia
figdir  = 'Estimation'; formats = {'eps'}; figsave = true;
% BRP
fldname = 'brp';
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,end))
    title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y ' fldname]); 
    datetick('x','yy'); yline(0);
end
figname = fldname; save_figure(figdir,figname,formats,figsave)

% BRP components
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).ssb_tp)
        fldname = {'brp','ssb_tp'};
    else
        fldname = {'brp','sy_tp'};
    end
    fldname = [fldname 'c_blncd'];
    
    subplot(3,5,k0)
    fltr1 = find(S(k0).(fldname{1})(1,:) == 10);
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,fltr1))
    hold on
    fltr2 = find(S(k0).(fldname{2})(1,:) == 10);
    plot(S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,fltr2))
    fltr3 = find(S(k0).(fldname{3})(1,:) == 10);
    plot(S(k0).(fldname{3})(2:end,1),S(k0).(fldname{3})(2:end,fltr3))
    hold off
    title([S(k0).iso '10Y'])
    if k0 == 13; legend('BRP','TP','LCCS','Orientation','horizontal',...
            'Location','south','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
end
figname = 'brp_dcmp'; save_figure(figdir,figname,formats,figsave)

% Compare BRP vs TPnom
figure
for k0 = 1:nEMs
    fldname = 'brp';
    if ~isempty(S(k0).ssb_tp)
        fldname = [fldname {'nsb_tp'}];
    else
        fldname = [fldname {'ny_tp'}];
    end
    
    subplot(3,5,k0)
    fltr1 = find(S(k0).(fldname{1})(1,:) == 10);
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,fltr1))
    hold on
    fltr2 = find(S(k0).(fldname{2})(1,:) == 10);
    plot(S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,fltr2))
    hold off
    title([S(k0).iso '10Y'])
    if k0 == 14; legend('BRP','TPnom','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
end
figname = 'brp_ntp'; save_figure(figdir,figname,formats,figsave)

%% Nominal YC decomposition: Drivers of yields
figdir  = 'Estimation'; formats = {'eps','pdf'}; figsave = true;
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).ssb_tp)
        fldaux = {'ssb_yP','ssb_tp'};
    else
        fldaux = {'sy_yP','sy_tp'};
    end
    fldname = [fldaux 'c_blncd'];
    han1 = subplot(3,5,k0);
    fltr1 = find(S(k0).(fldname{1})(1,:) == 10);
    fltr2 = find(S(k0).(fldname{2})(1,:) == 10);
    fltr3 = find(S(k0).(fldname{3})(1,:) == 10);
    h1 = plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,fltr1)*100,...
    	 S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,fltr2)*100,...
    	 S(k0).(fldname{3})(2:end,1),S(k0).(fldname{3})(2:end,fltr3)*100);
    title([S(k0).iso '10Y'])
    if k0 == 13; legend(h1,{'Exp','TP','LCCS'},'Orientation','horizontal',...
            'Location','southoutside','AutoUpdate','off');
    end
    datetick('x','yy'); yline(0);
end
figname = 'ny_dcmp'; save_figure(figdir,figname,formats,figsave)

%% Load US TP: Guimaraes, KW
figdir  = 'Estimation'; formats = {'eps'}; figsave = true;
% load('svyyldnewp0.mat','smplstpsvy'); load('svyyldnewp0.mat','smplsdate')
% load('svyyld.mat','smplsdate'); load('svyyld.mat', 'smplstpsvy')
% ustpguim = [nan [0.25 1:5 7 10]; smplsdate{1,4} smplstpsvy{1,4}];

KW10   = getFredData('THREEFYTP10',datestr(min(ustpguim(:,1)),29),...
    datestr(datenum('1-Feb-2019'),29)); 
KWtp10 = [nan 10; KW10.Data];                              	% 29: date format ID
KWtp10(isnan(KWtp10(:,2)),:) = [];                        	% remove NaNs

KW01   = getFredData('THREEFYTP1',datestr(min(ustpguim(:,1)),29),...
    datestr(datenum('1-Feb-2019'),29)); 
KWtp01 = [nan 1; KW01.Data];
KWtp01(isnan(KWtp01(:,2)),:) = [];                        	% remove NaNs

KWtp = syncdtst(KWtp01,KWtp10);
[~,~,uskwtp] = syncdtst(S(k0).s_ylds,KWtp);
ustp10 = uskwtp(:,[1 end]);

KW10   = getFredData('THREEFY10',datestr(min(ustpguim(:,1)),29),...
    datestr(datenum('1-Feb-2019'),29)); 
KWfy10 = [nan 10; KW10.Data];
KWfy10(isnan(KWfy10(:,2)),:) = [];                        	% remove NaNs

KW01   = getFredData('THREEFY1',datestr(min(ustpguim(:,1)),29),...
    datestr(datenum('1-Feb-2019'),29)); 
KWfy01 = [nan 1; KW01.Data];
KWfy01(isnan(KWfy01(:,2)),:) = [];                        	% remove NaNs

KWfy = syncdtst(KWfy01,KWfy10);
[~,~,uskwfy] = syncdtst(uskwtp,KWfy);

uskwyp = uskwfy;                                            % copy dates and tenors
uskwyp(2:end,2:end) = uskwfy(2:end,2:end) - uskwtp(2:end,2:end);

% plot(uskwfy(2:end,1),[uskwfy(2:end,end) uskwyp(2:end,end) uskwtp(2:end,end)])

%% Plot US TP: Guimaraes, KW
plot(ustpguim(2:end,1),ustpguim(2:end,end),ustp10(2:end,1),ustp10(2:end,2))
datetick('x','yy'); legend('Guimaraes','KW')
figname = 'ustp'; save_figure(figdir,figname,formats,figsave)

plot(ustp10(2:end,1),ustp10(2:end,2))
xline(datenum('25-Nov-2008')); xline(datenum('3-Nov-2010')); xline(datenum('21-Sep-2011')); 
xline(datenum('13-Sep-2012')); xline(datenum('19-Jun-2013')); yline(0); datetick('x','yy')
figname = 'ustp_QE'; save_figure(figdir,figname,formats,figsave)

%% Load data for TP correlations
% LCCS, USTP, EPU, VIX
S   = read_epu_idx(S);
vix = data_macro(:,ismember(hdr_macro(:,2),{'type','VIX'}));

%% Plot TP against LCCS, USTP, VIX, EPU, INF
figdir  = 'Estimation'; formats = {'eps'}; figsave = true;
% TP vs LCCS
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).ssb_tp)
        fldname = {'ssb_tp'};
    else
        fldname = {'sy_tp'};
    end
    fldname = [fldname 'c_blncd'];
    
    subplot(3,5,k0)
    fltr1 = find(S(k0).(fldname{1})(1,:) == 10);
    fltr2 = find(S(k0).(fldname{2})(1,:) == 10);
    yyaxis left
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,fltr1))
    set(gca,'ytick',[])
    yyaxis right
    plot(S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,fltr2))
    set(gca,'ytick',[])
    title([S(k0).iso '10Y'])
    if k0 == 2; legend('TP','LCCS','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
end
figname = 'stp_lccs'; save_figure(figdir,figname,formats,figsave)

% TP vs USTP
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).ssb_tp)
        fldname = {'ssb_tp'};
    else
        fldname = {'sy_tp'};
    end
    subplot(3,5,k0)
    fltr1 = find(S(k0).(fldname{1})(1,:) == 10);
    yyaxis left
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,fltr1))
    set(gca,'ytick',[])
    yyaxis right
    plot(ustp10(2:end,1),ustp10(2:end,2))
    set(gca,'ytick',[])
    title([S(k0).iso '10Y'])
    if k0 == 13; legend('TP','USTP','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
end
figname = 'stp_ustp'; save_figure(figdir,figname,formats,figsave)

% TP vs VIX
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).ssb_tp)
        fldname = {'ssb_tp'};
    else
        fldname = {'sy_tp'};
    end
    subplot(3,5,k0)
    fltr1 = find(S(k0).(fldname{1})(1,:) == 10);
    yyaxis left
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,fltr1))
    set(gca,'ytick',[])
    yyaxis right
    plot(vix(:,1),vix(:,2))
    set(gca,'ytick',[])
    title([S(k0).iso '10Y'])
    if k0 == 6; legend('TP','VIX','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
end
figname = 'stp_vix'; save_figure(figdir,figname,formats,figsave)

% TP vs EPU
figure; k2 = 0;
for k0 = 1:nEMs
    if ~isempty(S(k0).epu)
        k2 = k2 + 1;
        fldname = {'ssb_tp','epu'};
        subplot(3,2,k2)
        fltr1 = find(S(k0).(fldname{1})(1,:) == 10);
        fltrd = S(k0).(fldname{2})(:,1) > datenum('1-Jan-2000');
        yyaxis left
        plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,fltr1))
        set(gca,'ytick',[])
        yyaxis right
        plot(S(k0).(fldname{2})(fltrd,1),S(k0).(fldname{2})(fltrd,2))
        set(gca,'ytick',[])
        title([S(k0).iso '10Y'])
        if k2 == 5; legend('TP','EPU','Orientation','horizontal','AutoUpdate','off'); end
        datetick('x','yy'); yline(0);
    end
end
figname = 'stp_epu'; save_figure(figdir,figname,formats,figsave)

% TP vs INF
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).ssb_tp)
        fldname = {'ssb_tp'};
    else
        fldname = {'sy_tp'};
    end
    fldname = [fldname 'inf'];
    
    subplot(3,5,k0)
    fltr1 = find(S(k0).(fldname{1})(1,:) == 10);
    yyaxis left
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,fltr1))
    set(gca,'ytick',[])
    yyaxis right
    plot(S(k0).(fldname{2})(:,1),S(k0).(fldname{2})(:,2))
    set(gca,'ytick',[])
    title([S(k0).iso '10Y'])
    if k0 == 2; legend('TP','INF','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
end
figname = 'stp_inf'; save_figure(figdir,figname,formats,figsave)

%% TP correlations: LCCS, INF, EPU, USTP, VIX
    % EMs
corrTPem = cell(nEMs+1,13); corrBRP = cell(nEMs+1,13);
corrTPem(1,:)  = {'' 'LCCS' 'pval' 'INF' 'pval' 'EPU' 'pval',...
    'EPULCCS' 'pval' 'USTP' 'pval' 'VIX' 'pval'};
corrBRP(1,:) = {'' 'LCCS' 'pval' 'INF' 'pval' 'EPU' 'pval',...
    'EPULCCS' 'pval' 'USTP' 'pval' 'VIX' 'pval'};
hdrfk = [nan 10];
for k0 = 1:nEMs
    corrTPem{k0+1,1} = S(k0).iso; corrBRP{k0+1,1} = S(k0).iso;
    if ~isempty(S(k0).ssb_tp)
        fldname = {'ssb_tp'};
    else
        fldname = {'sy_tp'};
    end
    fldname = [fldname 'c_blncd' 'inf' 'epu' 'brp'];
    fltr1 = find(S(k0).(fldname{1})(1,:) == 10);
    fltr2 = find(S(k0).(fldname{2})(1,:) == 10);
    fltr5 = find(S(k0).(fldname{5})(1,:) == 10);
    datatp  = S(k0).(fldname{1})(:,[1 fltr1]);
    databrp = S(k0).(fldname{5})(:,[1 fltr5]);
    % LCCS
    mrgd  = syncdtst(datatp,S(k0).(fldname{2})(:,[1 fltr2]));
    [correl,pval]    = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPem(k0+1,2:3) = {correl,round(pval,4)};
    
    mrgd  = syncdtst(databrp,S(k0).(fldname{2})(:,[1 fltr2]));
    [correl,pval]     = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrBRP(k0+1,2:3) = {correl,round(pval,4)};
    
    % INF
    datacr = [hdrfk; S(k0).(fldname{3})];
    mrgd   = syncdtst(datatp,datacr);
    [correl,pval]    = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPem(k0+1,4:5) = {correl,round(pval,4)};
    
    mrgd   = syncdtst(databrp,datacr);
    [correl,pval]     = corr(mrgd(2:end,2),mrgd(2:end,3),'rows','complete');
    corrBRP(k0+1,4:5) = {correl,round(pval,4)};
    
    % EPU
    if ~isempty(S(k0).epu)
        datacr = [hdrfk; S(k0).(fldname{4})];
        mrgd   = syncdtst(datatp,datacr);
        [correl,pval]    = corr(mrgd(2:end,2),mrgd(2:end,3));
        corrTPem(k0+1,6:7) = {correl,round(pval,4)};
        
        mrgd   = syncdtst(S(k0).(fldname{2})(:,[1 fltr2]),datacr);
        [correl,pval] = corr(mrgd(2:end,2),mrgd(2:end,3));
        corrTPem(k0+1,8:9) = {correl,round(pval,4)};
        
        mrgd   = syncdtst(databrp,datacr);
        [correl,pval]    = corr(mrgd(2:end,2),mrgd(2:end,3),'rows','complete');
        corrBRP(k0+1,6:7) = {correl,round(pval,4)};
    end
    % USTP
    mrgd   = syncdtst(datatp,ustp10);
    [correl,pval]      = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPem(k0+1,10:11) = {correl,round(pval,4)};
    
    mrgd   = syncdtst(databrp,ustp10);
    [correl,pval]       = corr(mrgd(2:end,2),mrgd(2:end,3),'rows','complete');
    corrBRP(k0+1,10:11) = {correl,round(pval,4)};
    
    % VIX
    datacr = [hdrfk; vix];
    mrgd   = syncdtst(datatp,datacr);
    [correl,pval]      = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPem(k0+1,12:13) = {correl,round(pval,4)};
    
    mrgd   = syncdtst(databrp,datacr);
    [correl,pval]       = corr(mrgd(2:end,2),mrgd(2:end,3),'rows','complete');
    corrBRP(k0+1,12:13) = {correl,round(pval,4)};
end

    % AEs
corrTPae = cell(nAEs+1,7);
corrTPae(1,:)  = {'' 'CIPdev' 'pval' 'USTP' 'pval' 'VIX' 'pval'};
for k0 = nEMs+1:ncntrs
    corrTPae{k0-14,1} = S(k0).iso;
    fldname = {'ny_tp','c_blncd'};
    fltr1 = find(S(k0).(fldname{1})(1,:) == 10);
    fltr2 = find(S(k0).(fldname{2})(1,:) == 10);
    datatp  = S(k0).(fldname{1})(:,[1 fltr1]);
    % CIP deviations
    mrgd  = syncdtst(datatp,S(k0).(fldname{2})(:,[1 fltr2]));
    [correl,pval]    = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPae(k0-14,2:3) = {correl,round(pval,4)};
    
    % USTP
    mrgd   = syncdtst(datatp,ustp10);
    [correl,pval]      = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPae(k0-14,4:5) = {correl,round(pval,4)};
    
    % VIX
    mrgd   = syncdtst(datatp,[nan 10; vix]);
    [correl,pval]      = corr(mrgd(2:end,2),mrgd(2:end,3));
    corrTPae(k0-14,6:7) = {correl,round(pval,4)};
end

mean(cell2mat(corrTPem(2:end,10)))
[mean(cell2mat(corrTPae(2:end,4))), mean(cell2mat(corrTPae(2:end,6)))] % USTP

%% Correlations of LCNOM components with alternative measures
corrTPyP = cell(nEMs+1,5);
corrTPyP(1,:) = {'' 'TP-Slope' 'Res-Slope' 'TP-Res' 'yP-2Y'};
for k0 = 1:nEMs
    corrTPyP{k0+1,1} = S(k0).iso;
    if ~isempty(S(k0).ssb_tp)
        fldname = {'ssb_tp','ssb_yP'};
    else
        fldname = {'sy_tp','sy_yP'};
    end
    fldname = [fldname 's_blncd'];
    [~,datatps,datayld] = syncdtst(S(k0).(fldname{1}),S(k0).(fldname{3}));
    [~,datayp] = syncdtst(S(k0).(fldname{2}),datatps);
    
    fltr11 = find(datatps(1,:) == 10);
    fltr21 = find(datayp(1,:) == 10);
    fltr31 = find(datayld(1,:) == 10);
    fltr32 = find(datayld(1,:) == 2);
    fltr33 = find(datayld(1,:) == 0.25);
    datatps = datatps(2:end,fltr11);
    datayp  = datayp(2:end,fltr21);
    datas10 = datayld(2:end,fltr31);
    datas02 = datayld(2:end,fltr32);
    datas3M = datayld(2:end,fltr33);
    slopes  = datas10 - datas3M;
    corrTPyP{k0+1,2} = corr(datatps,slopes);
    
    mdlRSs  = fitlm(datas3M,datas10);
    datarss = mdlRSs.Residuals.Raw;
    corrTPyP{k0+1,3} = corr(datarss,slopes);
    corrTPyP{k0+1,4} = corr(datarss,datatps);
    
    corrTPyP{k0+1,5} = corr(datayp,datas02);
end

%% Percent of variation in yields explained by first 3 PCs

pcexplnd = cell(ncntrs+1,5);
pcexplnd(1,:) = {'' 'PC1' 'PC2' 'PC3' 'PC1-PC3'};
for k0 = 1:ncntrs
    pcexplnd{k0+1,1} = S(k0).iso;
    if ismember(S(k0).iso,currEM)
        fnameb  = 's_blncd';
    else
        fnameb  = 'n_blncd';
    end
    yields = S(k0).(fnameb)(2:end,2:end);
    [~,~,~,~,explained] = pca(yields);
    pcexplnd{k0+1,2} = sum(explained(1));
    pcexplnd{k0+1,3} = sum(explained(2));
    pcexplnd{k0+1,4} = sum(explained(3));
    pcexplnd{k0+1,5} = sum(explained(1:3)); % percent explained by first 3 PCs using balanced panel
end

[mean(cell2mat(pcexplnd(2:16,2))), mean(cell2mat(pcexplnd(2:16,3))),...
    mean(cell2mat(pcexplnd(2:16,4))), mean(cell2mat(pcexplnd(2:16,5)));...
    mean(cell2mat(pcexplnd(17:end,2))), mean(cell2mat(pcexplnd(17:end,3))),...
    mean(cell2mat(pcexplnd(17:end,4))), mean(cell2mat(pcexplnd(17:end,5)))]

%% Common factors affecting YC components
% TPs, real rates, yP, LCCS, BRP for all, ST vs LT
k2 = 0;
pc1yc = cell(5,2);
pc1yc(2:end,1) = {'Nominal' 'Expected' 'TP' 'LCCS'};
grp = 'EM';                                         % 'EM' or 'AE'
if strcmp(grp,'EM'); n1 = 1; nN = nEMs; else; n1 = nEMs+1; nN = ncntrs; end
tnrspc = 10;                              % All: 0.25:0.25:10, ST: 1, LT: 10
dateskey = {'1-Jan-2008','1-Jan-2000'};     % {'1-Jan-2008','1-Sep-2008'} all countries after GFC
datestrt = datenum(dateskey{1});            % select countries based on date of first observation
datecmmn = datenum(dateskey{2});           % select sample period for selected countries
for k0 = n1:nN
    if strcmp(grp,'EM')                    % for EMs synthetic, distinguish those w/ surveys
        if ~isempty(S(k0).ssb_tp)
            fldname  = {'n_blncd','ssb_yP','ssb_tp','c_blncd'};
        else
            fldname  = {'n_blncd','sy_yP','sy_tp','c_blncd'};
        end
    else                                            % for AEs nominal
        fldname  = {'n_blncd','ny_yP','ny_tp','c_blncd'};
    end
    if datenum(S(k0).s_dateb,'mmm-yyyy') <= datestrt
%     if ismember(S(k0).iso,{'BRL','HUF','KRW','MXN','MYR','PHP','PLN','THB'})    % EM TP < 0
%     if ismember(S(k0).iso,currEM(~contains(currEM,{'ILS','ZAR'})))              % EM w/ surveys
        k2 = k2 + 1;
        fltrtnr1 = [true ismember(S(k0).(fldname{1})(1,2:end),tnrspc)];  % include dates
        fltrtnr2 = [true ismember(S(k0).(fldname{2})(1,2:end),tnrspc)];
        fltrtnr3 = [true ismember(S(k0).(fldname{3})(1,2:end),tnrspc)];
        fltrtnr4 = [true ismember(S(k0).(fldname{4})(1,2:end),tnrspc)];
        if k2 == 1
            ttyld = S(k0).(fldname{1})(:,fltrtnr1);
            ttyP  = S(k0).(fldname{2})(:,fltrtnr2);
            tttp  = S(k0).(fldname{3})(:,fltrtnr3);
            ttcip = S(k0).(fldname{4})(:,fltrtnr4);
        else
            ttyld = syncdtst(ttyld,S(k0).(fldname{1})(:,fltrtnr1),'union');
            ttyP  = syncdtst(ttyP, S(k0).(fldname{2})(:,fltrtnr2),'union');
            tttp  = syncdtst(tttp, S(k0).(fldname{3})(:,fltrtnr3),'union');
            ttcip = syncdtst(ttcip,S(k0).(fldname{4})(:,fltrtnr4),'union');
        end
    end
end
fltrbln = find(any(isnan(ttyld),2),1,'last') + 1;	% first date w/ balanced panel
ttyld = ttyld(fltrbln:end,:);                       % no headers, sample w/ no NaNs
[~,~,~,~,explndemyld] = pca(ttyld(ttyld(:,1) >= datecmmn,2:end));   % factors after common date

fltrbln = find(any(isnan(ttyP),2),1,'last') + 1;
ttyP = ttyP(fltrbln:end,:);
[~,~,~,~,explndemyP] = pca(ttyP(ttyP(:,1) >= datecmmn,2:end));

fltrbln = find(any(isnan(tttp),2),1,'last') + 1;
tttp = tttp(fltrbln:end,:);
[~,~,~,~,explndemtp] = pca(tttp(tttp(:,1) >= datecmmn,2:end));

fltrbln = find(any(isnan(ttcip),2),1,'last') + 1;
ttcip = ttcip(fltrbln:end,:);
[~,~,~,~,explndemlccs] = pca(ttcip(ttcip(:,1) >= datecmmn,2:end));%ttcip(fltrbln:end,2:end)

pc1yc(1,:) = {'' [num2str(k2) '-' datestr(datecmmn,'mm/yy')]};
pc1yc(2:end,2) = {explndemyld(1); explndemyP(1); explndemtp(1); explndemlccs(1)};

%% US and non-US common factors
k2 = 0;
r2TPyP = cell(ncntrs+1,6);
r2TPyP(1,:) = {'' 'yP1' 'yP10' 'TP1' 'TP10' 'yP10-USTP10'};
pc1res = cell(6,2);
pc1res(2:end,1) = {'yP1' 'yP10' 'TP1' 'TP10' 'yP10-USTP10'};
grp = 'AE';                                         % 'EM' or 'AE'
if strcmp(grp,'EM'); n1 = 1; nN = nEMs; else; n1 = nEMs+1; nN = ncntrs; end
dateskey = {'1-Jan-2008','1-Sep-2008'};      % {'1-Jan-2008','1-Sep-2008'} all countries after GFC
datestrt = datenum(dateskey{1});              % select countries based on date of first observation
datecmmn = datenum(dateskey{2});            % select sample period for selected countries
for k0 = n1:nN
    k2 = k2 + 1;
    r2TPyP{k2+1,1} = S(k0).iso;
    if strcmp(grp,'EM')                       % for EMs synthetic, distinguish those w/ surveys
        if ~isempty(S(k0).ssb_tp)
            fldname = {'ssb_yP','ssb_tp'};
        else
            fldname = {'sy_yP','sy_tp'};
        end
    else                                            % for AEs nominal
        fldname  = {'ny_yP','ny_tp'};
    end
    
    if datenum(S(k0).s_dateb,'mmm-yyyy') <= datestrt
%     if ismember(S(k0).iso,{'BRL','HUF','KRW','MXN','MYR','PHP','PLN','THB'}) % EM TP < 0
%     if ismember(S(k0).iso,currEM(~contains(currEM,{'ILS','ZAR'})))           % EM w/ surveys
    
        [~,datayp,uskwypk0] = syncdtst(S(k0).(fldname{1}),uskwyp);
        [~,datatp,uskwtpk0] = syncdtst(S(k0).(fldname{2}),uskwtp);
       
        datayp10 = datayp(datayp(:,1) >= datecmmn,datayp(1,:) == 10);
        datayp01 = datayp(datayp(:,1) >= datecmmn,datayp(1,:) == 1);
        datatp10 = datatp(datatp(:,1) >= datecmmn,datatp(1,:) == 10);
        datatp01 = datatp(datatp(:,1) >= datecmmn,datatp(1,:) == 1);
        usyp10   = uskwypk0(uskwypk0(:,1) >= datecmmn,uskwypk0(1,:) == 10);
        usyp01   = uskwypk0(uskwypk0(:,1) >= datecmmn,uskwypk0(1,:) == 1);
        ustp10   = uskwtpk0(uskwtpk0(:,1) >= datecmmn,uskwtpk0(1,:) == 10);
        ustp01   = uskwtpk0(uskwtpk0(:,1) >= datecmmn,uskwtpk0(1,:) == 1);

        mdlRSyp01 = fitlm(usyp01,datayp01);
        resyp01   = mdlRSyp01.Residuals.Raw;
        r2TPyP{k2+1,2} = mdlRSyp01.Rsquared.Ordinary;

        mdlRSyp10 = fitlm(usyp10,datayp10);
        resyp10   = mdlRSyp10.Residuals.Raw;
        r2TPyP{k2+1,3} = mdlRSyp10.Rsquared.Ordinary;

        mdlRStp01 = fitlm(ustp01,datatp01);
        restp01   = mdlRStp01.Residuals.Raw;
        r2TPyP{k2+1,4} = mdlRStp01.Rsquared.Ordinary;

        mdlRStp10 = fitlm(ustp10,datatp10);
        restp10   = mdlRStp10.Residuals.Raw;
        r2TPyP{k2+1,5} = mdlRStp10.Rsquared.Ordinary;
        
        mdlRSyptp10 = fitlm(ustp10,datayp10);
        resyptp10   = mdlRSyptp10.Residuals.Raw;
        r2TPyP{k2+1,6} = mdlRSyptp10.Rsquared.Ordinary;
        
        if k2 == 1
            ttyp01 = [nan 1; datayp(datayp(:,1) >= datecmmn,1) resyp01];
            ttyp10 = [nan 10;datayp(datayp(:,1) >= datecmmn,1) resyp10];
            tttp01 = [nan 1; datatp(datatp(:,1) >= datecmmn,1) restp01];
            tttp10 = [nan 10;datatp(datatp(:,1) >= datecmmn,1) restp10];
            ttyptp10 = [nan 10;datayp(datayp(:,1) >= datecmmn,1) resyptp10];
        else
            ttyp01 = syncdtst(ttyp01,...
                [nan 1; datayp(datayp(:,1) >= datecmmn,1) resyp01],'union');
            ttyp10 = syncdtst(ttyp10,...
                [nan 10;datayp(datayp(:,1) >= datecmmn,1) resyp10],'union');
            tttp01 = syncdtst(tttp01,...
                [nan 1; datatp(datatp(:,1) >= datecmmn,1) restp01],'union');
            tttp10 = syncdtst(tttp10,...
                [nan 10;datatp(datatp(:,1) >= datecmmn,1) restp10],'union');
            ttyptp10 = syncdtst(ttyptp10,...
                [nan 10;datayp(datayp(:,1) >= datecmmn,1) resyptp10],'union');
        end
    end
end

fltrbln = find(any(isnan(ttyp01),2),1,'last') + 1; % first date w/ balanced panel
ttyp01  = ttyp01(fltrbln:end,:);                        % no headers, sample w/ no NaNs
[~,~,~,~,explndyp01] = pca(ttyp01(ttyp01(:,1) >= datecmmn,2:end)); % factors after common date

fltrbln = find(any(isnan(ttyp10),2),1,'last') + 1;
ttyp10  = ttyp10(fltrbln:end,:);
[~,~,~,~,explndyp10] = pca(ttyp10(ttyp10(:,1) >= datecmmn,2:end));

fltrbln = find(any(isnan(tttp01),2),1,'last') + 1;
tttp01  = tttp01(fltrbln:end,:);
[~,~,~,~,explndtp01] = pca(tttp01(tttp01(:,1) >= datecmmn,2:end));

fltrbln = find(any(isnan(tttp10),2),1,'last') + 1;
tttp10  = tttp10(fltrbln:end,:);
[~,~,~,~,explndtp10] = pca(tttp10(tttp10(:,1) >= datecmmn,2:end));


fltrbln = find(any(isnan(ttyptp10),2),1,'last') + 1;
ttyptp10  = ttyptp10(fltrbln:end,:);
[~,~,~,~,explndyptp10] = pca(ttyptp10(ttyptp10(:,1) >= datecmmn,2:end));


pc1res(1,:) = {'' [num2str(k2) '-' datestr(datecmmn,'mm/yy')]};
pc1res(2:end,2) = {explndyp01(1); explndyp10(1); explndtp01(1); explndtp10(1); explndyptp10(1)};

%% Quick loop
fldname = 'svys';
% aux = [];
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        S(k0).svycbp = S(k0).(fldname);
%         aux = [aux; k0 S(k0).(fldname).sgmS];
    end
end

%% US TP
ynsvys = readmatrix(fullfile(fullfile(pwd,'..','..','Data','Aux','USYCSVY'),...
    'USYCSVYdata.xlsx'),'Sheet',1);
dates  = x2mdate(ynsvys(:,1));                                  	% dates as datenum
ynsvys = ynsvys(:,2:end)./100;                                   	% data in decimals
yonly  = ynsvys(:,1:8);                                          	% yield data
matsY  = [0.25 1:5 7 10];                                           % yield maturities in years
matsS  = [0.25:0.25:1 10];
p      = 3;                                                       	% number of state vectors
dt     = 1/12;                                                     	% monthly periods
matout = [1 5 10];

[ylds_Qjsz,ylds_Pjsz,tpjsz,params0] = estimation_jsz(yonly,matsY,matout,dt,p);
[ylds_Q,ylds_P,termprm,params] = estimation_svys(ynsvys,matsY,matsS,matout,dt,params0);

figure; plot(dates,yonly(:,end),dates,ylds_Qjsz(:,end),dates,ylds_Q(:,end))
figure; plot(dates,termprm(:,end),dates,tpjsz(:,end))
svys  = ynsvys(:,9:end);
figure; plot(dates(240:end),ylds_P(240:end,end),dates(240:end),ylds_Pjsz(240:end,end),...
             dates(240:end),svys(240:end,end),'*')


function [dtmn,dtmx] = datesmnmx(S,k0)
% Returns the minimum and maximum dates
date1 = datenum(S(k0).n_dateb,'mmm-yyyy'); date2 = datenum(S(k0).s_dateb,'mmm-yyyy');
dtmn  = min(date1,date2); dtmx  = max(date1,date2);
end

function [mrgd,dtst1,dtst2] = syncdtst(dtst1,dtst2,synctype)
% Synchronize arrays (default is intersection)
if nargin < 3; synctype = 'intersection'; end
hdr1  = dtst1(1,2:end);  hdr2 = dtst2(1,2:end);  cols1 = size(dtst1,2);
TT1   = array2timetable(dtst1(2:end,2:end),'RowTimes',...
    datetime(dtst1(2:end,1),'ConvertFrom','datenum'));
TT2   = array2timetable(dtst2(2:end,2:end),'RowTimes',...
    datetime(dtst2(2:end,1),'ConvertFrom','datenum'));
TT    = synchronize(TT1,TT2,synctype);
mrgd  = [nan hdr1 hdr2; datenum(TT.Time) TT{:,:}];
dtst1 = mrgd(:,1:cols1);
dtst2 = [mrgd(:,1) mrgd(:,cols1+1:end)];
end

%%
% plot(S(k).(fnames{l})(:,1),S(k).(fnames{l})(:,2),'DisplayName',S(k).iso)
% if k == 1; legend('-DynamicLegend'); hold all; else; hold all; end
% Source: Hold on a legend in a plot
% https://www.mathworks.com/matlabcentral/answers/...
% 9434-how-can-i-hold-the-previous-legend-on-a-plot