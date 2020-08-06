% Compare datasets w/ Stata, use categorical variables
TTfp = array2timetable(data_fp(:,2:end),'RowTimes',datetime(data_fp(:,1),'ConvertFrom','datenum'));
TTzc = array2timetable(data_zc(:,2:end),'RowTimes',datetime(data_zc(:,1),'ConvertFrom','datenum'));

TTfp(:,69:75);
TTzc(:,1:12);


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