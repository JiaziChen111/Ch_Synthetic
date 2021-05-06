function imf_code = curr2imf(curr_code)
% This function reads currency codes and return IMF codes.
% 
%     INPUTS
% char: curr_code  - three letters indicating the currency (ISO 4217)
% 
%     OUTPUT
% double: imf_code - three digits indicating the IMF code.
%
% Pavel Solís (pavel.solis@gmail.com), April 2018
%%
% Retrieve codes from sources
path             = pwd;
cd(fullfile(path,'..','..','Data'))% Use platform-dependent file separators
filename1        = 'original_ISO_Currency_Codes.xlsx';
filename2        = 'original_IMF_Country_Codes.xlsx';
[~,codes_iso]    = xlsread(filename1);
[~,codes_imf]    = xlsread(filename2);
codes_imf(1,:)   = [];    codes_imf(:,5:end) = [];
codes_iso(1:3,:) = [];    codes_iso(:,4:end) = [];
cd(path)

% For country names from ISO, delete parentheses and what's inside them
codes_iso(:,1) = regexprep(codes_iso(:,1),' \([^\(\)]*\)','');

% Use country names as a bridge to do the conversion between codes
idx1     = ismember(codes_iso(:,3),curr_code);              % Match currency code
name_iso = codes_iso(idx1,1);                               % Use country name
idx2     = ismember(lower(codes_imf(:,3)),lower(name_iso)); % Match country name

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

imf_code = str2double(codes_imf{idx2,1});

%% Sources

% Delete all text within parenthesis
% https://stackoverflow.com/questions/38839529/...
% use-of-regexprep-in-matlab-to-remove-characters-within-parentheses-in-matlab
