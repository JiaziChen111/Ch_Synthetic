%% Compare CIP Calculations
% This code compares my CIP variables with those of Du, Im & Schreger (2018).
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
if ~exist('T_cip','var')                            % Run code if T_cip is not in the workspace
    run read_cip.m
end

curncs = read_currencies(T_cip);
S      = cell2struct(curncs','ccy');                % Assign a currency to a structure with field ccy

[~,tnrscell] = findgroups(T_cip.tenor);             % Find the tenors as categorical variable
tnrscell = cellstr(tnrscell);                       % Convert to cell array
tnrsnum  = tnrscell;
tnrsnum{contains(tnrsnum,'3m')} = '0.25y';          % Express all tenors in years
tnrsnum  = strrep(tnrsnum,'y','');                  % Remove 'y' from all tenors
tnrsnum  = cellfun(@str2num,tnrsnum);               % Convert cell array to numbers
[tnrsnum,idx] = sort(tnrsnum);                      % Sort all tenors in ascending order
tnrscell = tnrscell(idx);                           % Reorder cell array of tenors in ascending order

%% Compare Forward Premium for All Maturities
for k = 1:length(curncs)
    corrs = [];
    for l = 1:length(tnrscell)
        LC = curncs{k}; tnr = tnrscell{l};

        rows  = T_cip.currency==LC & T_cip.tenor==tnr;
        aux   = table(T_cip.date(rows),T_cip{rows,'rho'},'VariableNames',{'date',['dis' tnr]});
        TTdis = table2timetable(aux);               % Create timetable for DIS rho
        
        hdr  = header_daily;
        fltr = ismember(hdr(:,1),LC) & ismember(hdr(:,2),'RHO') & ismember(hdr(:,5),num2str(tnrsnum(l)));
        if sum(fltr) > 0                            % Proceed if tenor was calculated (i.e. data was available)
            t     = datetime(dataset_daily(:,1),'ConvertFrom','datenum');
            aux   = table(t,dataset_daily(:,fltr),'VariableNames',{'date',['own' tnr]});
            TTown = table2timetable(aux);           % Create timetable for own rho
            
            TT    = synchronize(TTdis,TTown,'intersection');   % Match values of rho in time
            corrs = [corrs; tnrsnum(l), corr(TT.(['dis' tnr]),TT.(['own' tnr]),'Rows','complete')];
        end

        figure;
        plot(T_cip.date(rows),T_cip{rows,'rho'})
        if sum(fltr) > 0                            % Proceed if tenor was calculated (i.e. data was available)
            hold on
            plot(t,dataset_daily(:,fltr))
            legend('DIS','Own')
        else
            legend('DIS')
        end
        title([LC ': Forward Premium ' tnr])
        datetick('x','yy','keeplimits')
    end
    input([LC ' is displayed. Press Enter key to continue.'])
    S(k).rhocorr = corrs;
end

clear k l t idx aux hdr tnr* LC fltr TTdis TTown TT corrs