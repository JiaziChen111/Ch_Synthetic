function [Spc,corrPC,pctmiss] = compare_pcs(S,nPCs,figsave)
% COMPARE_PCS Compare principal components obtained for a dataset with missing
% observations vs the dataset with less observations but no missing data
%   Spc     - structure with eigenvector matrices
%   corrPC  - correlation of principal components
%   pctmiss - percentage of missing data
% 
% Pavel Solís (pavel.solis@gmail.com), June 2019
%%
nctrs  = length(S);
fnames = fieldnames(S);
prefix = {'n_','s_'};
figdir  = 'PCcomparison'; formats = {'eps'};
corrPC = nan(nctrs,nPCs,2);   pctmiss = nan(nctrs,2);   Spc = struct([]);

for k0 = 1:2
    fnamed = fnames{contains(fnames,[prefix{k0} 'data'])};
    fnameb = fnames{contains(fnames,[prefix{k0} 'blncd'])};
    for k1 = 1:nctrs
        datem = S(k1).(fnamed)(2:end,1);
        datef = S(k1).(fnameb)(2:end,1);
        ymiss = S(k1).(fnamed)(2:end,2:end);
        yfull = S(k1).(fnameb)(2:end,2:end);
        nmiss = sum(sum(isnan(ymiss)));
        pctmiss(k1,k0) = nmiss*100/numel(ymiss);                        % percentage of missing data
        if nmiss > 0
            [Wm,PCm] = pca(ymiss,'NumComponents',nPCs,'Algorithm','als');
        else
            [Wm,PCm] = pca(ymiss,'NumComponents',nPCs);
        end
        [Wf,PCf] = pca(yfull,'NumComponents',nPCs);
        Spc(k1).([prefix{k0} 'Wd']) = Wm;
        Spc(k1).([prefix{k0} 'Wb']) = Wf;
        
        for k2 = 1:nPCs
            subplot(nPCs,1,k2)
            plot(datem,PCm(:,k2),datef,PCf(:,k2))
            title([S(k1).cty ' PC' num2str(k2)]); legend('Miss','Full'); datetick('x','yy')
        end
        figname = [prefix{k0} '_' S(k1).iso];
        save_figure(figdir,figname,formats,figsave)
        
        TTm = array2timetable(PCm,'RowTimes',datetime(datem,'ConvertFrom','datenum'));
        TTf = array2timetable(PCf,'RowTimes',datetime(datef,'ConvertFrom','datenum'));
        TT  = synchronize(TTm,TTf);
        corrPC(k1,:,k0) = diag(corrcoef(TT{:,:},'Rows','complete'),nPCs)'; % diagonal nPCs gives correlations
    end
end