function [TTm,TTd] = compare_tbills()
% COMPARE_TBILLS Read U.S. Treasury bill yields from CRSP and those implied
% by Gürkaynak, Sack & Wright (2007)
%   TTm: stores historical monthly data in a timetable
%   TTd: stores historical daily data in a timetable

% Once yields are annualized, they are very closely aligned
% Pavel Solís (pavel.solis@gmail.com), April 2020
%%
pathc   = pwd;
pathd   = fullfile(pathc,'..','..','Data','Raw');                     	% platform-specific file separators
namefl  = {'TFZ_MTH_RF','TFZ_DLY_RF2','TFZ_MTH_TS','TRZ_DLY_TS2'};
namefl  = strcat('CRSP_',namefl,'.xlsx');
varname = {'TYLDA'};

cd(pathd)
for k0 = 1:length(namefl)
    opts  = detectImportOptions(namefl{k0});
    opts  = setvartype(opts,opts.VariableNames(contains(opts.VariableNames,'CALDT')),'datetime');
    ttaux = readtimetable(namefl{k0},opts);
    ttaux.Properties.DimensionNames{1} = 'Date';
    ttaux(isnat(ttaux.Date),:) = [];                                    % delete extra rows
    
    if     k0 == 1                                                      % risk-free monthly
        ttaux.TYLDA = ttaux.TMYTM;                                      % already annualized
        TTrfm = synchronize(ttaux(ttaux.KYTREASNOX == 2000001,varname),...
                            ttaux(ttaux.KYTREASNOX == 2000002,varname));
        TTrfm.Properties.VariableNames = {'RF1M','RF3M'};
    elseif k0 == 2                                                      % risk-free daily
        ttaux.TYLDA = ttaux.TDYLD*365*100;                              % annualized percent
        TTrfd = synchronize(ttaux(ttaux.KYTREASNOX == 2000061,varname),...
                            ttaux(ttaux.KYTREASNOX == 2000062,varname));
        TTrfd = synchronize(TTrfd,ttaux(ttaux.KYTREASNOX == 2000063,varname));
        TTrfd.Properties.VariableNames = {'RF4W','RF13W','RF26W'};
    elseif k0 == 3                                                      % term structure monthly
        ttaux.TYLDA = ttaux.TMAVEYLD*12*100;                            % annualized percent
        TTtsm = synchronize(ttaux(ttaux.KYTREASNOX == 2000010,varname),...
                            ttaux(ttaux.KYTREASNOX == 2000012,varname));
        TTtsm = synchronize(TTtsm,ttaux(ttaux.KYTREASNOX == 2000015,varname));
        TTtsm = synchronize(TTtsm,ttaux(ttaux.KYTREASNOX == 2000018,varname));
        TTtsm.Properties.VariableNames = {'TS1M','TS3M','TS6M','TS9M'};
    elseif k0 == 4                                                      % term structure daily
        ttaux.TYLDA = ttaux.TDYLD*365*100;                              % annualized percent
        TTtsd = synchronize(ttaux(ttaux.KYTREASNOX == 2000067,varname),...
                            ttaux(ttaux.KYTREASNOX == 2000076,varname));
        TTtsd = synchronize(TTtsd,ttaux(ttaux.KYTREASNOX == 2000089,varname));
        TTtsd.Properties.VariableNames = {'TS4W','TS13W','TS26W'};
    end
end
cd(pathc)

TTrf = synchronize(TTrfm,TTrfd,'Intersection');
TTts = synchronize(TTtsm,TTtsd,'Intersection');
TTm  = synchronize(TTrf,TTts);
TTd  = synchronize(TTrfd,TTtsd);


% Risk-free monthly vs daily
plot(TTrf.Date,TTrf.RF1M,TTrf.Date,TTrf.RF4W,'--')                  % some large differences before 2000
max(abs(TTrf.RF1M - TTrf.RF4W))                                     % differences up to 2%
mean(abs(TTrf.RF1M - TTrf.RF4W))                                    % 0.1394
corr(TTrf.RF1M,TTrf.RF4W)                                           % 0.9949
plot(TTrf.Date,TTrf.RF3M,TTrf.Date,TTrf.RF13W,'--')                 % closely aligned
corr(TTrf.RF3M,TTrf.RF13W)                                          % 1
plot(TTrf.Date,TTrf.RF4W,TTrf.Date,TTrf.RF13W,TTrf.Date,TTrf.RF26W)
plot(TTrf.Date,TTrf.RF1M,TTrf.Date,TTrf.RF13W,TTrf.Date,TTrf.RF26W)


% Term structure monthly vs daily (monthly data has missing values b/w 2000/06 and 2009/03)
plot(TTts.Date,TTts.TS1M,TTts.Date,TTts.TS4W,'--')                  % some large differences before 2000
max(abs(TTts.TS1M - TTts.TS4W))                                     % differences up to 2.5%
mean(abs(TTts.TS1M - TTts.TS4W),'omitnan')                       	% 0.1522
corr(TTts.TS1M,TTts.TS4W,'Rows','complete')                      	% 0.9942
plot(TTts.Date,TTts.TS3M,TTts.Date,TTts.TS13W,'--')
corr(TTts.TS3M,TTts.TS13W,'Rows','complete')                     	% 0.9999
plot(TTts.Date,TTts.TS6M,TTts.Date,TTts.TS26W,'--')
corr(TTts.TS6M,TTts.TS26W,'Rows','complete')                      	% 0.9999
plot(TTts.Date,TTts.TS4W,TTts.Date,TTts.TS13W,TTts.Date,TTts.TS26W)
plot(TTts.Date,TTts.TS1M,TTts.Date,TTts.TS13W,TTts.Date,TTts.TS26W)


% Monthly risk-free vs term structure
plot(TTm.Date,TTm.RF1M,TTm.Date,TTm.TS1M,'--')
corr(TTm.RF1M,TTm.TS1M,'Rows','complete')                       	% 0.9981
plot(TTm.Date,TTm.RF3M,TTm.Date,TTm.TS3M,'--')
corr(TTm.RF3M,TTm.TS3M,'Rows','complete')                         	% 0.9999


% Daily risk-free vs term structure
plot(TTd.Date,TTd.RF4W,TTd.Date,TTd.TS4W,'--')
corr(TTd.RF4W,TTd.TS4W)                                           	% 1
max(abs(TTd.RF4W-TTd.TS4W))
plot(TTd.Date,TTd.RF13W,TTd.Date,TTd.TS13W,'--')
corr(TTd.RF13W,TTd.TS13W)                                         	% 1
max(abs(TTd.RF13W-TTd.TS13W))
plot(TTd.Date,TTd.RF26W,TTd.Date,TTd.TS26W,'--')
corr(TTd.RF26W,TTd.TS26W,'Rows','complete')                       	% 1, missing TS values b/w 1987-09-25&30
max(abs(TTd.RF26W-TTd.TS26W))
