function [names, imf_codes] = curr2name(curr_codes)
% This function reads currency codes and returns names and IMF codes.
%
%     INPUTS
% cell: curr_codes  - three letters indicating the currency (ISO 4217)
% 
%     OUTPUT
% cell: names       - names of the respective countries
% double: imf_codes - three digits indicating the respective IMF codes.
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
% Retrieve codes from sources
path             = pwd;
cd(fullfile(path,'..','..','Data','Raw'))                   % Use platform-specific file separators
filenameIMF      = 'original_IMF_Country_Codes.xlsx';
filenameISO      = 'original_ISO_Currency_Codes.xlsx';
[~,codes_imf]    = xlsread(filenameIMF);
[~,codes_iso]    = xlsread(filenameISO);
codes_imf(1,:)   = [];    codes_imf(:,5:end) = [];          % Delete unnecessary rows and columns
codes_iso(1:3,:) = [];    codes_iso(:,4:end) = [];
cd(path)
%%
% For country names from ISO, delete parentheses and what's inside them
codes_iso(:,1) = regexprep(codes_iso(:,1),' \([^\(\)]*\)','');

% Use country names as a bridge to do the conversion between codes
idx1     = ismember(codes_iso(:,3),curr_codes);             % Match currency codes
name_iso = codes_iso(idx1,1);                               % Use country name
idx2     = ismember(lower(codes_imf(:,3)),lower(name_iso)); % Match country name

ccy_iso  = codes_iso(idx1,2);

idx3 = contains(lower(codes_imf(:,3)),lower(name_iso));
%idx3 = ismember(lower(codes_imf(:,3)),lower(name_iso));

idx4 = contains(lower(codes_imf(:,4)),lower(ccy_iso));
% idx4 = ismember(lower(codes_imf(:,4)),lower(ccy_iso));

z1 = codes_imf(idx3,3);
z2 = codes_imf(idx4,3);
z3 = codes_imf(idx3 & idx4,3);
%%

% For no-match and multiple-match cases use currency names instead of country names
if sum(idx2) == 0
    name_iso = codes_iso(idx1,2);                               % Use currency name
    idx2     = ismember(lower(codes_imf(:,4)),lower(name_iso)); % Match currency name
end

if sum(idx2) > 1
    codes_imf(:,4) = regexprep(codes_imf(:,4),'\w*\s','');      % Remove country
    name_iso = codes_iso(idx1,2);                               % Use currency name
    idx2     = ismember(lower(codes_imf(:,4)),lower(name_iso));
end
% if sum(idx2) > 1  % Alternative option for multiple matches but requires user input
%     sprintf('Multiple matching entries for %s',curr_code{1})
%     celldisp(name_iso)
%     inp     = input('Choose the row of the country that you want: ');
%     aux     = find(idx2);
%     idx2(:) = false;
%     idx2(aux(inp)) = true;
% end

imf_codes = str2double(codes_imf{idx2,1});

%% Sources

% Delete all text within parenthesis
% https://stackoverflow.com/questions/38839529/...
% use-of-regexprep-in-matlab-to-remove-characters-within-parentheses-in-matlab
