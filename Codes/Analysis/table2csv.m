% % matlab to stata
% 
% in matlab:
% 
% cell2csv(cellarrayname, 'dataname')
% 
% then in stata:
% 
% insheet using dataname.csv
% 
% 
% % stata to matlab
% 
% in stata:
% 
% outsheet varlist using dataname, comma
% 
% then in matlab:
% 
% data = csv2mat_numeric('dataname.out')


paneldata = [paneltp.Properties.VariableNames; table2cell(paneltp)];
filename = fullfile('..','..','Data','importable_paneltp.csv');
cell2csv(filename,paneldata)
clear filename


%% Sources

% http://www.fight-entropy.com/2010/05/data-transfer-from-matlab-to-stata-and.html