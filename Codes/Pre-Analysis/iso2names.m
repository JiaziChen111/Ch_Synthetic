function ccy_names = iso2names(iso)
% This function reads three-letter codes of currencies and returns currency
% names, country names and three-digit IMF codes.
%
%     INPUTS
% cell: curncs  - three letters indicating the currency (ISO 4217)
% 
%     OUTPUT
% cell: ccy_names - three-letter and -digit codes, currency names, country names
%
% Pavel Solís (pavel.solis@gmail.com), April 2019
%%
% Retrieve codes from sources
path = pwd;
cd(fullfile(path,'..','..','Data','Raw'))                   % Use platform-specific file separators
filenameIMF      = 'original_IMF_Country_Codes.xlsx';
filenameISO      = 'original_ISO_Currency_Codes.xlsx';
[~,codes_imf]    = xlsread(filenameIMF);
[~,codes_iso]    = xlsread(filenameISO);
codes_imf(1,:)   = [];    codes_imf(:,5:end) = [];          % Delete unnecessary rows and columns
codes_iso(1:3,:) = [];    codes_iso(:,4:end) = [];
cd(path)
%%
% For country names from ISO
[~,id] = unique(codes_iso(:,1),'stable');
codes_iso = codes_iso(id,:);                                % Delete duplicate country names

aux1 = regexprep(codes_iso(:,1),' \([^\(\)]*\)','');        % Delete (what's inside) parentheses
aux1 = replace(aux1,',','');                                % Remove commas
aux1 = string(regexp(aux1,'^\w*(\s\w*)?','match'));         % Only names with at most two words
aux1 = cellstr(regexp(aux1,'^\w*(\s\w*)?','match'));
codes_iso(:,1) = aux1;

% Exclude countries that complicate the match
xclude_name = {'Australia';'Germany'};
idx       = ismember(lower(codes_iso(:,1)),lower(xclude_name));
xclude_ccy  = codes_iso(idx,2);
xclude_code = codes_iso(idx,3);
ccy_codes   = iso(~ismember(iso,xclude_code));

% From ISO codes to IMF codes
idx0     = ismember(codes_iso(:,3),ccy_codes);              % Match currency codes
iso_ccy  = unique(codes_iso(idx0,2));                       % Use currency name
iso_name = unique(codes_iso(idx0,1));                       % Use country name

idx1    = ismember(lower(codes_imf(:,3)),lower(iso_name));  % Match country name
z1_name = codes_imf(idx1,3);
z1_ccy  = codes_imf(idx1,4);                                % Implied currencies

idx2    = ismember(lower(codes_imf(:,4)),lower(iso_ccy));   % Match currency name
z2_ccy  = codes_imf(idx2,4);
z2_name = codes_imf(idx2,3);                                % Implied countries

miss_name = setdiff(z2_name,z1_name);
idx3      = ismember(lower(codes_imf(:,3)),lower([miss_name;xclude_name])); % Match country name

miss_ccy = setdiff(z2_ccy,z1_ccy);
% idx4     = ismember(lower(codes_imf(:,4)),lower([miss_ccy;xclude_ccy])); % Match currency name

fltr_imf = idx1 | idx2 | idx3;
codesNUM = codes_imf(fltr_imf,[1 3 4]);

% From IMF codes to ISO codes
idx5 = ismember(lower(codes_iso(:,1)),lower([z1_name;xclude_name]));
idx6 = ismember(lower(codes_iso(:,2)),lower(miss_ccy));
fltr_iso = idx5 | idx6;
codesWRD = codes_iso(fltr_iso,[1 2 3]);

idx7 = ismember(codesWRD(:,3),[ccy_codes;xclude_code]);     % Delete extra countries
codesWRD = codesWRD(idx7,:);

ccy_names = [codesNUM codesWRD(:,end)];

aux2 = cellfun(@str2num,ccy_names(:,1));
aux2 = num2cell(aux2);
ccy_names(:,1) = aux2;

%% Sources
% 
% Delete all text within parenthesis
% https://stackoverflow.com/questions/38839529/...
% use-of-regexprep-in-matlab-to-remove-characters-within-parentheses-in-matlab