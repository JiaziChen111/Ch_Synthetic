%% Read Bloomberg Tickers
% This code reads Bloomberg tickers (swap curves and yield curves) from the
% online spreadsheet of Du & Schreger (2016).
%
% Pavel Solís (pavel.solis@gmail.com), March 2018
%% Stack All Tickers
path = pwd;
cd(fullfile(path,'..','..','Data'))% Use platform-dependent file separators
filename = 'original_LC_Sovereign_Risk_Bloomberg_Tickers.xlsx';
[~,sheets] = xlsfinfo(filename);
nsheets = numel(sheets);
lbounds = zeros(nsheets,1);        % Record the number of entries in each sheet

[~,summary] = xlsread(filename,1);
lbounds(1)  = size(summary,1);

for k = 2:nsheets
    [~,~,raw] = xlsread(filename,k);
    if k == 2; hdr_blp = raw(1,1:5); end   % Row 1 will have the titles
    raw  = raw(2:end,:);      % Remove header from raw
    rows = size(raw,1);
    lb = 0;
    for l = 2:rows            % Identify if there are NaN rows at the bottom
        if all(isnan(raw{l,1})) && all(~isnan(raw{l-1,1}))
            lb = l-1;         % Last line with relevant content
        end
    end
    if lb > 0; lbounds(k) = lb; else; lbounds(k) = rows; end
    hdr_blp = [hdr_blp; raw(1:lbounds(k),1:5)];
end
cd(path)

%% Fill In Missing Tenors
tnr_blp = hdr_blp(2:end,5);            % Exclude header
tnrmiss = cell2mat(cellfun(@isnan,tnr_blp,'UniformOutput',false)); % Logical
tnridx  = find(tnrmiss) + 1;           % Rows with missing tenors (+ header)
nmiss   = numel(tnridx);               % Number of missing tenors
nameblp = hdr_blp(tnridx,4);           % Names of tickers with missing tenors

for k = 1:nmiss
    aux = sscanf(nameblp{k},'%*[^0123456789]%d'); % Find numbers in a string
    hdr_blp{tnridx(k),5} = aux(end);  % If more than 1 number, use last one (the year)
end

tnr_blp = cellfun(@num2str,hdr_blp(2:end,5),'UniformOutput',false);
hdr_blp(:,5) = [hdr_blp(1,5); tnr_blp]; % Convert tenors from numbers to strings

%% Minor Corrections
old = 'THB '; new = 'THB';             % There is an extra space
hdr_blp(:,1) = strrep(hdr_blp(:,1),old,new);

clear k l lb rows raw filename lbounds tnr_blp tnrmiss tnridx path
clear old new aux nmiss nsheets nameblp summary

%% Sources
% Find NaN values in a cell array
% https://www.mathworks.com/matlabcentral/answers/318627-how-to-find-nan-values-in-a-cell-array
% Find numbers in a string
% https://www.mathworks.com/matlabcentral/answers/...
% 108285-problem-using-sscanf-in-picking-out-numbers-from-string
% Find positions of strings in cell array satisfying a condition 
% https://www.mathworks.com/matlabcentral/answers/84242-find-in-a-cell-array