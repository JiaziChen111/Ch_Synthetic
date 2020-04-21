%% Compare CIP Calculations
% This code compares my CIP variables with those of Du, Im & Schreger (2018).
% Assumes that header_daily and dataset_daily are in the workspace and
% contain the CIP variables (rho, spread, CIP deviations).
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
% 
%% Prepare Currencies and Tenors
if ~exist('T_cip','var')                            % Run code if T_cip is not in the workspace
    run read_cip.m
end

% iso   = read_currencies(T_cip);
Scorr = cell2struct(iso','iso');                % Assign a currency to a structure with field ccy

[~,tnrscell] = findgroups(T_cip.tenor);             % Find the tenors as categorical variable
tnrscell = cellstr(tnrscell);                       % Convert to cell array
tnrsnum  = tnrscell;
tnrsnum{contains(tnrsnum,'3m')} = '0.25y';          % Express all tenors in years
tnrsnum  = strrep(tnrsnum,'y','');                  % Remove 'y' from all tenors
tnrsnum  = cellfun(@str2num,tnrsnum);               % Convert cell array to numbers
[tnrsnum,idx] = sort(tnrsnum);                      % Sort all tenors in ascending order
tnrscell = tnrscell(idx);                           % Reorder cell array of tenors in ascending order
ntnrs    = length(tnrscell);

%% For Each Country Compare CIP Variables for All Maturities

varDIS  = {'rho','diff_y','cip_govt'};
varOWN  = {'RHO','LCSPRD','CIPDEV'};
pltname = {'Forward Premium','Spread','CIP Deviations'};
figdir  = 'DISvsOwn'; figsave = false; formats = {'eps'}; tf_input = true;

for j = 1:length(varDIS)
for k = 1:length(iso)
    close all
    corrs = nan(ntnrs,2);
    for l = 1:ntnrs
        LC = iso{k}; tnr = tnrscell{l}; corrs(l,1) = tnrsnum(l);

        rows  = T_cip.currency==LC & T_cip.tenor==tnr;
        aux   = table(T_cip.date(rows),T_cip{rows,varDIS{j}},'VariableNames',{'date',['dis' tnr]});
        TTdis = table2timetable(aux);               % Create timetable for DIS variable
        
        hdr  = header_daily;
        fltr = ismember(hdr(:,1),LC) & ismember(hdr(:,2),varOWN{j}) & ismember(hdr(:,5),num2str(tnrsnum(l)));
        if sum(fltr) > 0                            % Compare if tenor was calculated (i.e. data was available)
            t     = datetime(dataset_daily(:,1),'ConvertFrom','datenum');
            aux   = table(t,dataset_daily(:,fltr),'VariableNames',{'date',['own' tnr]});
            TTown = table2timetable(aux);           % Create timetable for own variable
            
            TT = synchronize(TTdis,TTown,'intersection'); % Match values of variables in time
            corrs(l,2) = corr(TT.(['dis' tnr]),TT.(['own' tnr]),'Rows','complete');
        end

        figure;
        if strcmp(varDIS{j},'cip_govt')             % Plot CIP deviations in percentage points
            plot(T_cip.date(rows),T_cip{rows,varDIS{j}}./100)
        else
            plot(T_cip.date(rows),T_cip{rows,varDIS{j}})
        end
        if sum(fltr) > 0                            % Plot own if tenor was calculated (i.e. data was available)
            hold on
            plot(t,dataset_daily(:,fltr))
            legend('DIS','Own')
        else
            legend('DIS')
        end
        title([pltname{j} ': ' LC ' ' tnr])
        ylabel('%')
        datetick('x','yy','keeplimits')
        figname = [varDIS{j} '_' LC '_' tnr];
        save_figure(figdir,figname,formats,figsave)
    end
    if tf_input; input([varDIS{j} ' ' LC ' is displayed. Press Enter key to continue.']); end
    Scorr(k).([varDIS{j} '_corr']) = corrs;
end
end

clear j k l t idx aux rows hdr tnr* LC fltr TTdis TTown TT corrs var* plt* fig*