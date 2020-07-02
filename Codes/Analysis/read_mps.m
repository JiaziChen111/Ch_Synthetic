function TT_mps = read_mps()
% READ_MPS Read U.S. monetary policy shocks

% Pavel Solís (pavel.solis@gmail.com), June 2020
%%
pathc  = pwd;
pathd  = fullfile(pathc,'..','..','Data','Raw','MPS');                      % platform-specific file separators
namefl = 'wide_mar2019.xls';

cd(pathd)
opts  = detectImportOptions(namefl);
opts  = setvartype(opts,opts.VariableNames(1),'datetime');
opts  = setvartype(opts,opts.VariableNames(2:end),'double');
opts.VariableNames{1} = 'Time';
TT_mps = readtimetable(namefl,opts);
cd(pathc)



% path and TP shocks