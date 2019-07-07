%% Panel for Term Premia and their Drivers
% This function creates a panel of term premia and macro-financial variables.
% 
% Pavel Solís (pavel.solis@gmail.com), October 2018
%%
% Filters for global and domestic variables
LCnames = {'TP','CCY','STX','INF','UNE','IP'};
USDnames = {'VIX','FFR','OIL','TPUS','STX'};
fltrLC   = ismember(hdr_macro(:,2),LCnames);
fltrUSD  = ismember(hdr_macro(:,2),USDnames) & ismember(hdr_macro(:,1),'USD');
dates_macro = data_macro(:,1);

% Construct the panel
ncntrs  = length(S);
data_panel = []; hdr_cty = [];
for k = 1:15
    fltrCTY  = ismember(hdr_macro(:,1),S(k).iso) & fltrLC;
    ID = repmat(S(k).imf,length(dates_macro),1);
    varsLC = data_macro(:,fltrCTY);
    hdr_LC = hdr_macro(fltrCTY,2)';
    
    % If multiple matches, choose first appearance
    [~,idxUnq] = unique(hdr_macro(fltrCTY,2),'stable');
    varsLC  = varsLC(:,idxUnq);
    hdr_LC  = hdr_LC(idxUnq);
    
    varsUSD = data_macro(:,fltrUSD);
    hdr_USD = hdr_macro(fltrUSD,2)';
    
    hdr_cty{k,1} = [hdr_LC hdr_USD];
    data_panel   = [data_panel; dates_macro ID varsLC varsUSD];
end

% Save information in a table
idxSTX = find(strcmp(hdr_cty{1,1},'STX'));
hdr_cty{1,1}(max(idxSTX)) = {'SPX'};
names = [{'DATE','CODE'} hdr_cty{1,1}];
paneltp = array2table(data_panel,'VariableNames',names');
paneltp.DATE = cellfun(@datestr,num2cell(paneltp.DATE),'UniformOutput',false); % from datenum to datestr

% Export the table to Excel
path = pwd;
filename = fullfile(path,'..','..','Data','Raw','importable_paneltp.xlsx');
writetable(paneltp,filename,'Sheet',1,'Range','A1')
clear path filename