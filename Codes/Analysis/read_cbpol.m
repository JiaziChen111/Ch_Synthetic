%% Read Central Bank Policy Rates of Emerging Markets
% This code reads the policy rates for emerging markets from the BIS policy
% rate database.
%
% Assumes structure S and currEM are in the workspace.
% 
% Pavel Solís (pavel.solis@gmail.com), May 2019
% 
%% Read the data
path = pwd;
cd(fullfile(path,'..','..','Data','Raw'))               % Use platform-specific file separators
filename   = 'original_BIS_CB_Policy_Rates.xlsx';
[data_pol,txt_pol] = xlsread(filename,3);               % Read data without headers but with dates
dates_pol = x2mdate(data_pol(:,1),0);                   % Convert dates from Excel to Matlab format
data_pol(:,1) = dates_pol;                              % Use dates in Matlab format
hdr_pol = txt_pol(3,:);                                 % Keep country names
cd(path)
clear filename path txt_pol dates_pol

% Extract the policy rates of emerging markets
EMnames = cell(size(currEM));
nEMs = nan(size(currEM));
countEM = 1;
for k = 1:ncntrs                                        % Use currency codes to find country names
    if ismember(S(k).iso,currEM)
        nEMs(countEM)    = k;
        EMnames{countEM} = S(k).cty;
        countEM = countEM + 1;
    end
end
EMcbpol    = ismember(hdr_pol,EMnames);
EMcbpol(1) = true;                                      % Include dates
data_pol   = data_pol(:,EMcbpol);                       % Extract EM policy rates
hdr_pol    = hdr_pol(EMcbpol);
idx2000    = data_pol(:,1) >= datenum('1-Jan-2000');
data_pol   = data_pol(idx2000,:);
clear EMcbpol idx2000 countEM
