% add PCs
% add it in ts_pca
fldname = {'s_blncd','n_blncd'};
for k0 = 1:length(S)
    if ismember(S(k0).cty,currEM)
        dtst = S(k0).(fldname{1});
    else
        dtst = S(k0).(fldname{2});
    end
    ylds = dtst(2:end,2:end);
end


%%

% % Replace w/ NaN when there is no survey data
% for k4 = 1:nEMs
%     if ~isempty(S(k4).scpi)
%         TT1 = TTsvy(~ismissing(TTsvy(:,k4)),k4);
%         fltrSVY = isbetween(HPyr.Time,min(TT1.Time),max(TT1.Time));
%         HPyr{~fltrSVY,k4} = nan;
%     end
% end
