
% Each section requires structure S in the workspace after fitting the ATSM

%% Compare YCs and ATSM fit
figstop = true;
flds{1} = {'n_blncd','s_blncd'};                                        	% compare YCs: LCNOM vs LCSYNT
flds{2} = {'n_blncd','n_yQ'};                                               % compare LCNOM vs ATSM
flds{3} = {'s_blncd','s_yQ'};                                               % compare LCSYNT vs ATSM
flds    = flds{1};                                                          % choose option to plot
nfld    = length(flds); tnrs = cell(nfld,1); dts = cell(nfld,1); srs = cell(nfld,1);
ncts    = length(S);
for k0 = 1:ncts
    k1 = 1;
    tnrs{k1} = S(k0).(flds{k1})(1,2:end);
    dts{k1}  = S(k0).(flds{k1})(2:end,1);
    srs{k1}  = S(k0).(flds{k1})(2:end,2:end);
    nobs     = size(srs{k1},1);
    for j0 = 1:nobs
        k1 = 2;
        tnrs{k1} = S(k0).(flds{k1})(1,2:end);
        dts{k1}  = S(k0).(flds{k1})(2:end,1);
        srs{k1}  = S(k0).(flds{k1})(2:end,2:end);
        fltrDT   = ismember(dts{2},dts{1}(j0));
        if sum(fltrDT) == 0
            plot(tnrs{1},srs{1}(j0,:)*100,'b')
        else
            plot(tnrs{1},srs{1}(j0,:)*100,'b',tnrs{2},srs{2}(fltrDT,:)*100,'r')
        end
        title([S(k0).cty ': ' datestr(dts{1}(j0))])
        H = getframe(gcf);
    end
    close
    if figstop == true; input([S(k0).iso ' displayed. Press Enter key to continue.']); end
end

%% Compare CIP deviations with TP estimates from LCNOM and LCSYNT
tnr  = 10;
flds = {'n_tp','s_tp','c_data'};
nfld = length(flds); tnrs = cell(nfld,1); dts = cell(nfld,1); srs = cell(nfld,1);
ncts = length(S);
for k0 = 1:ncts
    for k1 = 1:length(flds)
        tnrs{k1} = S(k0).(flds{k1})(1,2:end);
        dts{k1}  = S(k0).(flds{k1})(2:end,1);
        srs{k1}  = S(k0).(flds{k1})(2:end,2:end);
    end
    figure
    plot(dts{1},srs{1}(:,tnrs{1} == tnr),'b',...
         dts{2},srs{2}(:,tnrs{2} == tnr),'r',...
         dts{3},srs{3}(:,tnrs{3} == tnr)*100,'g')
    legend('TP Nominal','TP Synthetic','CIP Deviation','AutoUpdate','off')
    title([S(k0).cty ': ' num2str(tnr) 'Y'])
    datetick('x','yy'); ylabel('%'); yline(0);
end
