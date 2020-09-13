function ts_plots(S,currEM,currAE,kwtp,vix)
% TS_PLOTS Plot different series after estimation of affine model

% m-files called: datesminmax, syncdatasets, inflation_target, save_figure,
% ts_dyindex
% Pavel Solís (pavel.solis@gmail.com), August 2020
%%
nEMs = length(currEM);
nAEs = length(currAE);

%% Plot macro data
figdir = 'Data'; formats = {'eps'}; figsave = false;
vars   = {'INF','UNE','IP','GDP','CBP'};
fnames = lower(vars);
% whole period
for l = 1:length(vars)
    figure
    for k0 = 1:nEMs
        if size(S(k0).(fnames{l}),2) > 1
            date1 = datenum(S(k0).mn_dateb,'mmm-yyyy'); 
            date2 = datenum(S(k0).ms_dateb,'mmm-yyyy');
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
            [dtmn,dtmx] = datesminmax(S,k0);
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

% Inflation volatility: permanent vs cyclical
figure
for k0 = 1:nEMs
    fldname = {'sdprm','sdcyc'};                                            % std of permanent and cyclical
    subplot(3,5,k0)
    yyaxis left
    plot(S(k0).(fldname{1})(:,1),S(k0).(fldname{1})(:,2))
    set(gca,'ytick',[])
    yyaxis right
    plot(S(k0).(fldname{2})(:,1),S(k0).(fldname{2})(:,2))
    set(gca,'ytick',[])
    title(S(k0).cty)
    if k0 == 2; legend('SDPRM','SDCYC','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); %yline(0);
end
figname = 'INF_vol'; save_figure(figdir,figname,formats,figsave)

close all

%% Plot 10Y yields
figdir  = 'Data'; formats = {'eps'}; figsave = false;
fldname = {'ms_data','inf','scbp'};

% Yield only
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end)*100)
    title(S(k0).iso); 
    datetick('x','yy'); yline(0);
end
figname = 'YLD10Y'; save_figure(figdir,figname,formats,figsave)

% All yields (term structure)
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    fltrYLD = ismember(S(k0).(fldname{1})(1,:),[0.25 1 5 10]);
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,fltrYLD)*100)
    title(S(k0).iso);
    datetick('x','yy'); yline(0);
end
lgd = legend({'3 Months','1 Year','5 Years','10 Years'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'syntTSIR'; save_figure(figdir,figname,formats,figsave)

% Yield and inflation
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    dtmn  = datesminmax(S,k0);
    fltrd = S(k0).(fldname{2})(:,1) >= dtmn;
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end)*100,...
         S(k0).(fldname{2})(fltrd,1),S(k0).(fldname{2})(fltrd,end))
    title(S(k0).iso); 
    datetick('x','yy'); yline(0);
end
lgd = legend({'10-Year Synthetic Yield','Inflation'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'YLD10Y_INF'; save_figure(figdir,figname,formats,figsave)

% Yield and survey interest rate forecast
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname{3}))
        subplot(3,5,k0)
        plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end)*100,...
             S(k0).(fldname{3})(2:end,1),S(k0).(fldname{3})(2:end,end),'-.')
        title(S(k0).cty); 
        datetick('x','yy'); yline(0);
        L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
lbl = {'10-Year Synthetic Yield','Implied Long-Term Forecast of Short Rate'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'YLD10Y_CBP'; save_figure(figdir,figname,formats,figsave)
close all

%% Plot survey data
figdir  = 'Surveys'; formats = {'eps'}; figsave = false;
macrovr = {'CPI','GDP','CBP'};
for k0 = 1:length(macrovr)
    fldname = ['s' lower(macrovr{k0})];
    figure
    for k1 = 1:nEMs
        if ~isempty(S(k1).(fldname))
            dtmn  = datesminmax(S,k1);
            fltrd = S(k1).(fldname)(:,1) >= dtmn;
            subplot(3,5,k1)
            plot(S(k1).(fldname)(fltrd,1),S(k1).(fldname)(fltrd,end),...
                S(k1).(fldname)(fltrd,1),S(k1).(fldname)(fltrd,end-1),'-.');
            title(S(k1).cty);
            datetick('x','yy'); ylim([0 8]);
            L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))     % sets #ticks to 4
            if strcmp(macrovr{k0},'CPI')
                [ld,lu] = inflation_target(S(k1).iso);
                if ~isempty(ld); yline(ld,'--'); yline(lu,'--'); end
            end
        end
    end
    lgd = legend({'Long Term','5 Years Ahead'},'Orientation','horizontal','AutoUpdate','off');
    set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
    figname = ['wn' macrovr{k0}]; save_figure(figdir,figname,formats,figsave)
end
close all

%% Compare results (different versions, different variables): ny, ns, sy, ss
figdir  = 'Estimation'; formats = {'eps'}; figsave = false;
fldname = [strcat({'mny','msy','mnsf','mnsb','mssf','mssb'},'_tp') 'mssb_yP'];
fldnmAE = [strcat({'mny','msy'},'_tp') 'mny_yP'];
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
            if ismember(S(k0).iso,{'BRL','COP','HUF','IDR','KRW','PHP','PLN','RUB','THB','TRY'})
            k2 = k2 + 1;
            subplot(2,5,k2)
            plot(S(k0).(fldname{k1})(2:end,1),S(k0).(fldname{k1})(2:end,end))
            title([S(k0).iso ' ' num2str(S(k0).(fldname{k1})(1,end)) 'Y ' fldname{k1}(end-1:end)]); 
            datetick('x','yy'); yline(0);
            switch S(k0).iso
                case 'BRL'
                    xline(datenum('19-Oct-2009')); xline(datenum('4-Oct-2010'));
                    xline(datenum('6-Jan-2011')); xline(datenum('8-Jul-2011'));
                    xline(datenum('4-Jun-2013'));
                case 'COP'
                    xline(datenum('1-Dec-2004'));
                    xline(datenum('1-Jun-2006'));  xline(datenum('1-May-2007')); 
                    xline(datenum('1-Jul-2007')); xline(datenum('4-Oct-2008'));
                case 'HUF'
                    xline(datenum('16-Apr-2003'));
                    xline(datenum('1-Aug-2005'));xline(datenum('1-Sep-2018'));
                case 'IDR'; xline(datenum('1-Jul-2005'));
                case 'KRW'; xline(datenum('13-Jun-2010'));
                case 'PHP'; xline(datenum('1-Jan-2002'));
                case 'PLN'; xline(datenum('16-Apr-2003')); xline(datenum('28-Jul-2017'));
                case 'RUB'; xline(datenum('27-Sep-2013'));
                case 'THB'; xline(datenum('1-Dec-2006'));
                case 'TRY'
                    xline(datenum('1-Jan-2006'));  xline(datenum('27-Jan-2017'));
                    xline(datenum('24-Jun-2018')); xline(datenum('2-Oct-2018')); 
            end
            end
        end
    end
    figname = [fldname{k1} '_local']; save_figure(figdir,figname,formats,figsave)
end
close all

%% Compare TP (different versions, same variable): ny, ns, sy, ss
figdir  = 'Estimation'; formats = {'eps'}; figsave = false;
% sgmS baseline vs free: differences due to convergence, check fit for BRL-COP-MYR
fldtype1 = 'mssb_';   fldvar  = 'tp';
fldtype2 = 'mssf_';   fldname = [fldtype2 fldvar];
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == 2
            legend([fldtype1 fldvar],[fldtype2 fldvar],'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

% Synthetic vs nominal: yields only (gains from synthetic)
fldtype1 = 'sy_';   fldvar  = 'tp';
fldtype2 = 'ny_';   fldname = [fldtype2 fldvar];
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == 2
            legend([fldtype1 fldvar],[fldtype2 fldvar],'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

% Synthetic vs nominal: surveys (gains from synthetic)
fldtype1 = 'mssb_';   fldvar  = 'tp';
fldtype2 = 'mnsb_';   fldname = [fldtype2 fldvar];
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == 2
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
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == 2
            legend([fldtype1 fldvar],[fldtype2 fldvar],'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

% Synthetic: surveys vs yields (gains from surveys)
fldtype1 = 'mssb_';	fldvar  = 'tp';
fldtype2 = 'msy_';   fldname = [fldtype1 fldvar];
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == 2
            legend([fldtype1 fldvar],[fldtype2 fldvar],'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

% Synthetic surveys vs nominal yields (gains from both)
fldtype1 = 'mssb_';	fldvar  = 'tp';
fldtype2 = 'mny_';   fldname = [fldtype1 fldvar];
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == 2
            legend([fldtype1 fldvar],[fldtype2 fldvar],...
                'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

    % AEs
% Synthetic vs nominal: yields only (gains from synthetic)
fldtype1 = 'ny_';   fldvar  = 'tp';
fldtype2 = 'sy_';   fldname = [fldtype2 fldvar];
figure; k2 = 0;
for k0 = nEMs+1:nEMs+nAEs
    if ~isempty(S(k0).(fldname))
        k2 = k2 + 1;
        subplot(2,5,k2)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y TP'])
        if k0 == nEMs+2
            legend([fldtype1 fldvar],[fldtype2 fldvar],'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar '_AE']; save_figure(figdir,figname,formats,figsave)
close all

%% Model fit to synthetic
figdir  = 'Estimation'; formats = {'eps'}; figsave = false;

    % Monthly data
fldname = {'ms_blncd','bsl_yQ'};
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end)*100,...
         S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,end)*100,'-.');    % 10Y
    title(S(k0).cty)
    datetick('x','yy'); yline(0);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
lgd = legend({'Observed','Fitted'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 's_ylds_bsl_yQ'; save_figure(figdir,figname,formats,figsave)

    % Daily data
fldname = {'ds_blncd','d_yQ'};
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end)*100,...
         S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,end)*100,'--');    % 10Y
    title(S(k0).cty)
    datetick('x','yy'); yline(0);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
lgd = legend({'Observed','Fitted'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 's_ylds_d_yQ'; save_figure(figdir,figname,formats,figsave)

close all

%% Comparing yP vs surveys_CBP (assess fit + benefits of surveys)
figdir  = 'Estimation'; formats = {'eps'}; figsave = false;
% mssb_yP (surveys) vs surveys_CBP 
fldname = {'bsl_yP','scbp'};
figure
for k0 = 1:nEMs
    dtmn  = datesminmax(S,k0);
    subplot(3,5,k0)
    fltrt = S(k0).(fldname{1})(1,:) == 10;
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,fltrt)*100);
    if ~isempty(S(k0).(fldname{2}))
        fltrd = S(k0).(fldname{2})(:,1) >= dtmn;
        hold on; plot(S(k0).(fldname{2})(fltrd,1),S(k0).(fldname{2})(fltrd,end),'*');  % 10Y
    end
    title(S(k0).cty)
    datetick('x','yy'); yline(0);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
lgd = legend('Model','Forecast','Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldname{1} '_' fldname{2}]; save_figure(figdir,figname,formats,figsave)

% msy_yP (yields only) vs surveys_CBP
fldname = {'msy_yP','scbp'};
figure
for k0 = 1:nEMs
    dtmn  = datesminmax(S,k0);
    subplot(3,5,k0)
    fltrt = S(k0).(fldname{1})(1,:) == 10;
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,fltrt)*100);
    if ~isempty(S(k0).(fldname{2}))
        fltrd = S(k0).(fldname{2})(:,1) >= dtmn;
        hold on; plot(S(k0).(fldname{2})(fltrd,1),S(k0).(fldname{2})(fltrd,end),'*');  % 10Y
    end
    title(S(k0).cty)
    if k0 == 12
        legend('Model w/o S','Surveys','Orientation','horizontal','location','best','AutoUpdate','off')
    end
    datetick('x','yy');yline(0);
end
figname = [fldname{1} '_' fldname{2}]; save_figure(figdir,figname,formats,figsave)
close all

%% Real rate = yP - svyINF
figdir  = 'Estimation'; formats = {'eps'}; figsave = false;

    % Long-term
fldname = 'rrt';
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,end)*100)       % 10Y
        title(S(k0).cty);
        datetick('x','yy'); yline(0); ylim([-2 5]);
        L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
figname = [fldname '_LT']; save_figure(figdir,figname,formats,figsave)

    % Long-term EMRR vs USRR
fldname = 'rrt';
% TT_rr   = read_spf();
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,end)*100); hold on       % 10Y
        fltrUS = datenum(TT_rr.Time) >= S(k0).(fldname)(2,1) & datenum(TT_rr.Time) <= S(k0).(fldname)(end,1);
        plot(datenum(TT_rr.Time(fltrUS)),TT_rr.USRR10Y(fltrUS),'-.')
        hold off
        title(S(k0).cty);
        datetick('x','yy'); yline(0); ylim([-2 5]);
        L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
lgd = legend({'Domestic Real Rate','U.S. Real Rate'},'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldname '_LTvsUSrrt']; save_figure(figdir,figname,formats,figsave)

    % All tenors
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,2:end)*100)
        title(S(k0).cty);
        if k0 == 1
            legend(cellfun(@num2str,num2cell(S(k0).(fldname)(1,2:end)),...
                'UniformOutput',false),'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
        L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
figname = [fldname '_all']; save_figure(figdir,figname,formats,figsave)

close all

%% TP survey = sy - sCBP
figdir  = 'Estimation'; formats = {'eps'}; figsave = false;

    % Long-term TPsvy
fldname = 'stp';
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,end)*100)
        title(S(k0).cty); 
        datetick('x','yy'); yline(0); ylim([-3 11.5]);
        L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
figname = fldname; save_figure(figdir,figname,formats,figsave)

    % Compare TPsynt vs TPsvy: robustness check of TP estimates
fldname = {'bsl_tp','stp'};
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,end)*100);    % 10Y
    if ~isempty(S(k0).(fldname{2}))
        hold on; plot(S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,end)*100);
    end
    title(S(k0).cty);
    if k0 == 6; legend('Model','Surveys','Location','northeast','AutoUpdate','off'); end
    datetick('x','yy'); yline(0); % ylim([-2 10]);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = [fldname{1} '_svy']; save_figure(figdir,figname,formats,figsave)
close all

%% Synthetic vs nominal yP: if yP similar, supports BRP  = TP + CR
figdir  = 'Estimation'; formats = {'eps'}; figsave = false;
    % Surveys
fldtype1 = 'mssb_';   fldvar = 'yP';
fldtype2 = 'mnsb_';   fldname = [fldtype2 fldvar];
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));  % 10Y
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y yP'])
        if k0 == 13
            legend([fldtype1 fldvar],[fldtype2 fldvar],'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)

    % Yields only: if differ wrt surveys, supports using surveys
fldtype1 = 'sy_';   fldvar  = 'yP';
fldtype2 = 'ny_';   fldname = [fldtype2 fldvar];
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        plot(S(k0).([fldtype1 fldvar])(2:end,1),S(k0).([fldtype1 fldvar])(2:end,end),...
             S(k0).([fldtype2 fldvar])(2:end,1),S(k0).([fldtype2 fldvar])(2:end,end));  % 10Y
        title([S(k0).iso ' ' num2str(S(k0).(fldname)(1,end)) 'Y yP'])
        if k0 == 13
            legend([fldtype1 fldvar],[fldtype2 fldvar],'Orientation','horizontal','AutoUpdate','off')
        end
        datetick('x','yy'); yline(0);
    end
end
figname = [fldtype1 fldtype2 fldvar]; save_figure(figdir,figname,formats,figsave)
close all

%% Term structure
% Term premia
figdir  = 'Estimation'; formats = {'eps'}; figsave = false;
fldname = 'bsl_tp';
figure
lstyle  = {'-','-.','--'};
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        fltrTNR = ismember(S(k0).(fldname)(1,:),[1 5 10]);
        posTNR  = find(fltrTNR);
        hold on
        for k1 = 1:length(posTNR)
            plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,posTNR(k1))*100,lstyle{k1})
        end
        hold off
        title(S(k0).cty); 
        datetick('x','yy'); yline(0);
        L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
lbl = cellfun(@num2str,num2cell(S(k0).(fldname)(1,fltrTNR)),'UniformOutput',false);
lbl = {[lbl{1} ' Year'],[lbl{2} ' Years'],[lbl{3} ' Years']};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldname '_ts']; save_figure(figdir,figname,formats,figsave)

% Credit risk  premia
fldname = 'mc_blncd';
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).(fldname))
        subplot(3,5,k0)
        fltrTNR = ismember(S(k0).(fldname)(1,:),[1 5 10]);
        posTNR  = find(fltrTNR);
        hold on
        for k1 = 1:length(posTNR)
            plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,posTNR(k1))*100,lstyle{k1})
        end
        hold off
        title(S(k0).cty); 
        datetick('x','yy'); yline(0);
        L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
lbl = cellfun(@num2str,num2cell(S(k0).(fldname)(1,fltrTNR)),'UniformOutput',false);
lbl = {[lbl{1} ' Year'],[lbl{2} ' Years'],[lbl{3} ' Years']};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = [fldname '_ts']; save_figure(figdir,figname,formats,figsave)

close all

%% Plot bond risk premia
figdir  = 'Estimation'; formats = {'eps'}; figsave = false;
% BRP: compensation for risk in EMs
fldname = 'brp';
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(S(k0).(fldname)(2:end,1),S(k0).(fldname)(2:end,end)*100)           % 10Y
    title(S(k0).cty); 
    datetick('x','yy'); yline(0); ylim([-2 10]);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = fldname; save_figure(figdir,figname,formats,figsave)

% BRP components: relative importance
figure
for k0 = 1:nEMs
    fldname = {'brp','bsl_tp','mc_blncd'};
    subplot(3,5,k0)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100,...
         S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,S(k0).(fldname{2})(1,:) == 10)*100,...
         S(k0).(fldname{3})(2:end,1),S(k0).(fldname{3})(2:end,S(k0).(fldname{3})(1,:) == 10)*100)   % 10Y
    title(S(k0).cty)
    if k0 == 13
        legend('BRP','TP','LCCS','Orientation','horizontal','Location','south','AutoUpdate','off'); 
    end
    datetick('x','yy'); yline(0);% ylim([-2 10]);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = 'brp_dcmp'; save_figure(figdir,figname,formats,figsave)

% Compare BRP vs TPnom: if similar, supports LCNOM gives biased estimates of TP
figure
for k0 = 1:nEMs
    if ~isempty(S(k0).mssb_tp)
        fldname = {'brp','nsb_tp'};
    else
        fldname = {'brp','ny_tp'};
    end
    subplot(3,5,k0)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100,...
         S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,S(k0).(fldname{2})(1,:) == 10)*100)   % 10Y
    title(S(k0).cty)
    if k0 == 14; legend('BRP','TPnom','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = 'brp_ntp'; save_figure(figdir,figname,formats,figsave)
close all

%% Nominal YC decomposition: drivers of yields
figdir  = 'Estimation'; formats = {'eps'}; figsave = false;
    % EM: monthly
fldname = {'bsl_yP','bsl_tp','bsl_cr'};       % daily data: {'d_yP','d_tp','dc_blncd'};
figure
for k0 = 1:nEMs
    subplot(3,5,k0)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100,'-',...
         S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,S(k0).(fldname{2})(1,:) == 10)*100,'-.',...
         S(k0).(fldname{3})(2:end,1),S(k0).(fldname{3})(2:end,S(k0).(fldname{3})(1,:) == 10)*100,'--')% 10Y
    title(S(k0).cty)
    datetick('x','yy'); yline(0);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
lbl = {'Expected Short Rate','Term Premium','Credit Risk Premium'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'ny_dcmp'; save_figure(figdir,figname,formats,figsave)

    % AE
fldname = {'bsl_yP','bsl_tp'};  k1 = 0;
figure
for k0 = nEMs+1:nEMs+nAEs
    k1 = k1 + 1;
    subplot(2,5,k1)
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100,'-',...
         S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,S(k0).(fldname{2})(1,:) == 10)*100,'-.')% 10Y
    title(S(k0).cty)
    datetick('x','yy'); yline(0);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
lbl = {'Expected Short Rate','Term Premium'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
figname = 'ny_dcmp_AE'; save_figure(figdir,figname,formats,figsave)

close all

%% Compare estimated CRC versus DS LCCS
    % Monthly frequency
fldname = {'bsl_cr','mc_blncd'};
tnr = 10;
figure
for k1 = 1:nEMs
    subplot(3,5,k1)
    var1 = S(k1).(fldname{1})(2:end,S(k1).(fldname{1})(1,:) == tnr)*100;
    var2 = S(k1).(fldname{2})(2:end,S(k1).(fldname{2})(1,:) == tnr)*100;
    plot(S(k1).(fldname{1})(2:end,1),var1,S(k1).(fldname{2})(2:end,1),var2);
    title(S(k1).cty)
    datetick('x','yy'); yline(0);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
lbl = {'Own','DS'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')

    % Daily frequency
fldname = {'d_cr','dc_blncd'};
tnr = 10;
figure
for k1 = 1:nEMs
    subplot(3,5,k1)
    var1 = S(k1).(fldname{1})(2:end,S(k1).(fldname{1})(1,:) == tnr)*100;
    var2 = S(k1).(fldname{2})(2:end,S(k1).(fldname{2})(1,:) == tnr)*100;
    plot(S(k1).(fldname{1})(2:end,1),var1,S(k1).(fldname{2})(2:end,1),var2);
    title(S(k1).cty)
    datetick('x','yy'); yline(0);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
lbl = {'Own','DS'};
lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')

%% Components with confidence bands
    % EM
figdir = 'Estimation'; formats = {'eps'}; figsave = false;
vars   = {'yQ','yP','tp','cr'};
names  = {'Fitted Yields','Expected Short Rate','Term Premium','Credit Risk Compensation'};
tnr    = 10;
for k0 = 1:length(vars)
    fldname = {['bsl_' vars{k0}],['bsl_' vars{k0} '_se']};
    figure
    for k1 = 1:nEMs
        subplot(3,5,k1)
        var   = S(k1).(fldname{1})(2:end,S(k1).(fldname{1})(1,:) == tnr)*100;
        varse = S(k1).(fldname{2})(2:end,S(k1).(fldname{2})(1,:) == tnr)*100;
        plot(S(k1).(fldname{1})(2:end,1),var,'-'); hold on
        plot(S(k1).(fldname{2})(2:end,1),var - 2*varse,'--','Color', [0.6 0.6 0.6])
        plot(S(k1).(fldname{2})(2:end,1),var + 2*varse,'--','Color', [0.6 0.6 0.6]); hold off
        title(S(k1).cty)
        datetick('x','yy'); yline(0);
        L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
    end
    lbl = {names{k0},'Confidence Bands'};
    lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
    set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
    figname = [fldname{1} '_CI_' num2str(tnr) 'y_V1']; save_figure(figdir,figname,formats,figsave)
end

    % AE
vars   = {'yQ','yP','tp'};
names  = {'Fitted Yields','Expected Short Rate','Term Premium'};
tnr    = 10;
for k0 = 1:length(vars)
    fldname = {['bsl_' vars{k0}],['bsl_' vars{k0} '_se']};
    figure
    k2 = 0;
    for k1 = nEMs+1:length(S)
        k2 = k2 + 1;
        subplot(2,5,k2)
        var   = S(k1).(fldname{1})(2:end,S(k1).(fldname{1})(1,:) == tnr)*100;
        varse = S(k1).(fldname{2})(2:end,S(k1).(fldname{2})(1,:) == tnr)*100;
        plot(S(k1).(fldname{1})(2:end,1),var,'-'); hold on
        plot(S(k1).(fldname{2})(2:end,1),var - 2*varse,'--','Color', [0.6 0.6 0.6])
        plot(S(k1).(fldname{2})(2:end,1),var + 2*varse,'--','Color', [0.6 0.6 0.6]); hold off
        title(S(k1).cty)
        datetick('x','yy'); yline(0);
        L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
    end
    lbl = {names{k0},'Confidence Bands'};
    lgd = legend(lbl,'Orientation','horizontal','AutoUpdate','off');
    set(lgd,'Position',[0.3730 0.0210 0.2554 0.0357],'Units','normalized')
    figname = [fldname{1} '_CI_' num2str(tnr) 'y_V1_AE']; save_figure(figdir,figname,formats,figsave)
end

%% Plot TP against LCCS, USTP, VIX, EPU, INF
figdir  = 'Estimation'; formats = {'eps'}; figsave = false;
% TP vs LCCS: negative relationship
figure
for k0 = 1:nEMs
    fldname = {'bsl_tp','mc_blncd'};
    subplot(3,5,k0)
    yyaxis left
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100)
    set(gca,'ytick',[])
    yyaxis right
    plot(S(k0).(fldname{2})(2:end,1),S(k0).(fldname{2})(2:end,S(k0).(fldname{2})(1,:) == 10)*100) % 10Y
    set(gca,'ytick',[])
    title(S(k0).cty)
    if k0 == 2; legend('TP','LCCS','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = 'tp_lccs'; save_figure(figdir,figname,formats,figsave)            % update reference to figure

% TP vs USTP: US TP as potential driver of EM TP
figure
for k0 = 1:nEMs
    fldname = {'bsl_tp'};
    subplot(3,5,k0)
    yyaxis left
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100)   % 10Y
    set(gca,'ytick',[])
    yyaxis right
    plot(kwtp(2:end,1),kwtp(2:end,end))
    set(gca,'ytick',[])
    title(S(k0).cty)
    if k0 == 13; legend('TP','USTP','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = 'tp_ustp'; save_figure(figdir,figname,formats,figsave)            % update reference to figure

% TP vs VIX: relationship w/ measures of risk and uncertainty
figure
for k0 = 1:nEMs
    fldname = {'bsl_tp'};
    subplot(3,5,k0)
    yyaxis left
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100) % 10Y
    set(gca,'ytick',[])
    yyaxis right
    plot(vix(:,1),vix(:,2))
    set(gca,'ytick',[])
    title(S(k0).cty)
    if k0 == 6; legend('TP','VIX','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = 'tp_vix'; save_figure(figdir,figname,formats,figsave)             % update reference to figure

% TP vs EPU: relationship w/ measures of uncertainty
figure; k2 = 0;
for k0 = 1:nEMs
    if ~isempty(S(k0).epu)
        k2 = k2 + 1;
        fldname = {'bsl_tp','epu'};
        [~,dtmx] = datesminmax(S,k0);
        fltrd = S(k0).(fldname{2})(:,1) > dtmx;
        subplot(3,2,k2)
        yyaxis left
        plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100) % 10Y
        set(gca,'ytick',[])
        yyaxis right
        plot(S(k0).(fldname{2})(fltrd,1),S(k0).(fldname{2})(fltrd,2))
        set(gca,'ytick',[])
        title(S(k0).cty)
        if k2 == 5; legend('TP','EPU','Orientation','horizontal','AutoUpdate','off'); end
        datetick('x','yy'); yline(0);
        L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))         % sets #ticks to 4
    end
end
figname = 'tp_epu'; save_figure(figdir,figname,formats,figsave)             % update reference to figure

% TP vs INF
figure
for k0 = 1:nEMs
    fldname = {'bsl_tp','inf'};
    [~,dtmx] = datesminmax(S,k0);
    fltrd = S(k0).(fldname{2})(:,1) > dtmx;
    subplot(3,5,k0)
    yyaxis left
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100) % 10Y
    set(gca,'ytick',[])
    yyaxis right
    plot(S(k0).(fldname{2})(fltrd,1),S(k0).(fldname{2})(fltrd,2))
    set(gca,'ytick',[])
    title(S(k0).cty)
    if k0 == 2; legend('TP','INF','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = 'tp_inf'; save_figure(figdir,figname,formats,figsave)             % update reference to figure

% TP vs inflation volatility
figure
for k0 = 1:nEMs
    fldname = {'bsl_tp','sdprm'};                                           % std of permanent component
    [~,dtmx] = datesminmax(S,k0);
    fltrd = S(k0).(fldname{2})(:,1) > dtmx;
    subplot(3,5,k0)
    yyaxis left
    plot(S(k0).(fldname{1})(2:end,1),S(k0).(fldname{1})(2:end,S(k0).(fldname{1})(1,:) == 10)*100) % 10Y
    set(gca,'ytick',[])
    yyaxis right
    plot(S(k0).(fldname{2})(fltrd,1),S(k0).(fldname{2})(fltrd,2))
    set(gca,'ytick',[])
    title(S(k0).cty)
    if k0 == 2; legend('TP','SDPRM','Orientation','horizontal','AutoUpdate','off'); end
    datetick('x','yy'); yline(0);
    L = get(gca,'XLim'); set(gca,'XTick',linspace(L(1),L(2),4))             % sets #ticks to 4
end
figname = 'tp_sdprm'; save_figure(figdir,figname,formats,figsave)

close all

%% DY index (daily frequency): Yield components
figdir  = 'Estimation'; formats = {'eps','fig'}; figsave = true;

    % AE + EM (nominal, synthetic)
tenor = 10;
fldname = {'dn_data','ds_data'};
lstyle  = {'-','-.','--'};
datemin = datenum('31-Jan-2019');
figure
for k0 = 1:length(fldname)
    [DYindex,DYtable] = ts_dyindex(S,currEM,fldname{k0},tenor);
    disp(DYtable)
    plot(DYindex(:,1),DYindex(:,2),lstyle{k0}); hold on
    if DYindex(1,1) < datemin
        datemin = DYindex(1,1);
    end
end
k0 = 1;
[DYindex,DYtable] = ts_dyindex(S,currAE,fldname{k0},tenor);
disp(DYtable)
fltrAE = DYindex(:,1) >= datemin;
plot(DYindex(fltrAE,1),DYindex(fltrAE,2),lstyle{end}); hold on
datetick('x','yy'); hold off
lbl = {'Emerging Markets - Nominal','Emerging Markets - Synthetic','Advanced Countries - Nominal'};
legend(lbl,'Location','best','AutoUpdate','off');
figname = ['dy_index' num2str(tenor) 'y_nomsyn']; save_figure(figdir,figname,formats,figsave)

    % EM
tenor = 10;
fldname = {'d_yP','d_tp','dc_data'};
lstyle  = {'-','-.','--'};
figure
for k0 = 1:length(fldname)
    [DYindex,DYtable] = ts_dyindex(S,currEM,fldname{k0},tenor);
    disp(DYtable)
    plot(DYindex(:,1),DYindex(:,2),lstyle{k0}); hold on
end
datetick('x','yy'); hold off
lbl = {'Exp. Short Rate','Term Premium','Credit Risk Premium'};
legend(lbl,'Location','best','AutoUpdate','off');
figname = ['dy_index' num2str(tenor) 'y_dcmp']; save_figure(figdir,figname,formats,figsave)

    % AE
fldname = {'dn_data','d_yP','d_tp'};
figure
for k0 = 1:length(fldname)
    [DYindex,DYtable] = ts_dyindex(S,currAE,fldname{k0},tenor);
    disp(DYtable)
    plot(DYindex(:,1),DYindex(:,2),lstyle{k0}); hold on
end
datetick('x','yy'); hold off
legend({'Nominal Yield','Exp. Short Rate','Term Premium'},'Location','best','AutoUpdate','off');
figname = ['dy_index' num2str(tenor) 'y_dcmp_AE']; save_figure(figdir,figname,formats,figsave)

%% DY index (daily frequency): Term structure
figdir  = 'Estimation'; formats = {'eps','fig'}; figsave = true;
fldname = {'dn_data'}; % {'dn_data','d_yP','d_tp','dc_data'};
lstyle  = {'-','-.','--',':'};
tenor   = [10 5 1 0.25];
lbl     = {'10 Years','5 Years','1 Year','3 Months'};

    % EM
for k0 = 1:length(fldname)
    figure
    for k1 = 1:length(tenor)
        [DYindex,DYtable] = ts_dyindex(S,currEM,fldname{k0},tenor(k1));
        disp([fldname{k0} ' ' num2str(tenor(k1))])
        disp(DYtable)
        plot(DYindex(:,1),DYindex(:,2),lstyle{k1}); hold on
    end
    datetick('x','yy'); hold off
    legend(lbl,'Location','best','AutoUpdate','off');
    figname = ['dy_index_' fldname{k0}]; save_figure(figdir,figname,formats,figsave)
end

    % AE
for k0 = 1:length(fldname)
    figure
    for k1 = 1:length(tenor)
        [DYindex,DYtable] = ts_dyindex(S,currAE,fldname{k0},tenor(k1));
        disp([fldname{k0} ' ' num2str(tenor(k1))])
        disp(DYtable)
        plot(DYindex(:,1),DYindex(:,2),lstyle{k1}); hold on
    end
    datetick('x','yy'); hold off
    legend(lbl,'Location','best','AutoUpdate','off');
    figname = ['dy_index_' fldname{k0} '_AE']; save_figure(figdir,figname,formats,figsave)
end

%% Plot yield curves
k0 = 1;                                                                     % country
matrix = S(k0).ms_blncd;                                                    % synthetic
dates  = matrix(2:end,1);
tenors = matrix(1,2:end);
ylds   = matrix(2:end,2:end);
for k1 = 1:length(dates)
    plot(tenors,ylds(k1,:)*100,'b')
    title(datestr(dates(k1)))
    H(k1) = getframe(gcf);                                  % play: movie(H,1,2); one frame: imshow(H(2).cdata)
end


%% Sources

% Hold on a legend in a plot
% https://www.mathworks.com/matlabcentral/answers/...
% 9434-how-can-i-hold-the-previous-legend-on-a-plot
% plot(S(k).(fnames{l})(:,1),S(k).(fnames{l})(:,2),'DisplayName',S(k).iso)
% if k == 1; legend('-DynamicLegend'); hold all; else; hold all; end

% Set the subplot position without worrying about the outside legends
% https://www.mathworks.com/matlabcentral/answers/...
% 300188-how-do-i-set-the-subplot-position-without-worrying-about-the-outside-legends

% Setting and extracting position vector of legend
% https://www.mathworks.com/matlabcentral/answers/12555-legend-position-on-a-plot

% Recession shaded areas
% https://www.mathworks.com/matlabcentral/answers/243194-shade-an-area-in-a-plot-between-two-y-values