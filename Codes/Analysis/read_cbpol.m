%% Read Central Bank Policy Rates of Emerging Markets
% This code reads the policy rates for emerging markets (EMs) from the BIS
% policy rate database.
%
% Assumes structure S and currEM are in the workspace.
% 
% Pavel Solís (pavel.solis@gmail.com), May 2019
% 
%% Read the data
path = pwd;
cd(fullfile(path,'..','..','Data','Raw'))               % Use platform-specific file separators
filename   = 'BIS_CB_Policy_Rates.xlsx';
[data_cbpol,txt_pol] = xlsread(filename,3);             % Read data without headers but with dates
dates_pol  = x2mdate(data_cbpol(:,1),0);                % Convert dates from Excel to Matlab format
data_cbpol(:,1) = dates_pol;                            % Use dates in Matlab format
hdr_cbpol  = txt_pol(3,:);                              % Keep country names
tckr_cbpol = txt_pol(4,:);                              % Save tickers
cd(path)
clear filename path *_pol

% Extract only the policy rates of EMs
ncntrs  = length(S);
EMnames = cell(size(currEM));
nEMs    = nan(size(currEM));
countEM = 1;
for k = 1:ncntrs                                        % Use currency codes to find country names
    if ismember(S(k).iso,currEM)
        nEMs(countEM)    = k;
        EMnames{countEM} = S(k).cty;
        countEM = countEM + 1;
    end
end

EMcbpol    = ismember(hdr_cbpol,EMnames);
tckr_cbpol = tckr_cbpol(EMcbpol)';                      % EM tickers
EMcbpol(1) = true;                                      % Include dates
data_cbpol = data_cbpol(:,EMcbpol);                     % Extract EM policy rates
idx2000    = data_cbpol(:,1) >= datenum('1-Jan-2000');
data_cbpol = data_cbpol(idx2000,:);
clear EMcbpol idx2000 countEM
