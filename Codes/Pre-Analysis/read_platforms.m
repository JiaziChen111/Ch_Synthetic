function [TTpltf,THpltf] = read_platforms()
% READ_PLATFORMS Read data retrieved from Bloomberg and Datastream
%   TTpltf: stores historical data in a timetable
%   THpltf: stores headers in a table

% Pavel Solís (pavel.solis@gmail.com), April 2020
%%
pathc   = pwd;
pathd   = fullfile(pathc,'..','..','Data','Raw');       % platform-specific file separators
namefls = {'EM_Currencies_Data.xlsx'};
% namefls = {'AE_EM_Curves_Data.xlsx','EM_Currencies_Data.xlsx'};
nfls    = length(namefls);

cd(pathd)
for k0 = 1:nfls
    opts  = detectImportOptions(namefls{k0},'Sheet','Data');
    opts  = setvartype(opts,opts.VariableNames(2:end),'double');
    ttaux = readtimetable(namefls{k0},opts);
    opts  = detectImportOptions(namefls{k0},'Sheet','Identifiers');
    opts  = setvartype(opts,opts.VariableNames([1:4 6:7]),'categorical');   % tenor remains as double
    thaux = readtable(namefls{k0},opts,'ReadVariableNames',true);
    %thaux = readtable(namefls{k0},'Sheet','Identifiers','ReadVariableNames',true);
    if k0 == 1
        TTpltf = ttaux;
        THpltf = thaux;
    else
        TTpltf = synchronize(TTpltf,ttaux);
        THpltf = [THpltf; thaux];
    end
end
cd(pathc)

if size(THpltf,1) ~= size(TTpltf,2)
    error('The number of tickers in the ''Data'' and ''Identifiers'' sheets must be the same.')
end

% Clean dataset
TTpltf.Properties.VariableNames = erase(TTpltf.Properties.VariableNames,{'Curncy','Index','Comdty'});
% THpltf.Ticker = TTpltf.Properties.VariableNames';               % variable names in TTdt as tickers in THdt

% Formatting
TTpltf.Date.Format = 'dd-MMM-yyyy';
% varaux = THpltf.Properties.VariableNames;
% exctnr = ~contains(varaux,'Tenor');                             % tenor remains as double
% THpltf = [varfun(@categorical,THpltf,'inputvariables',varaux(exctnr)) THpltf(:,~exctnr)];   % categorical 
% THpltf = movevars(THpltf,7,'After',4);                          % relocate tenor to original position
% THpltf.Properties.VariableNames = varaux;                       % conversion to categorical changes names