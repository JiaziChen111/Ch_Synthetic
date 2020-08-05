% Compare datasets w/ Stata, use categorical variables
TTfp = array2timetable(data_fp(:,2:end),'RowTimes',datetime(data_fp(:,1),'ConvertFrom','datenum'));
TTzc = array2timetable(data_zc(:,2:end),'RowTimes',datetime(data_zc(:,1),'ConvertFrom','datenum'));

TTfp(:,69:75);
TTzc(:,1:12);

%  append_dataset
TT1 = array2timetable(dataset1(:,2:end),'RowTimes',dataset1(:,1));
TT2 = array2timetable(dataset2(:,2:end),'RowTimes',dataset2(:,1));
TT3 = synchronize(TT1,TT2,'union');
dataset = [datenum(TT3.Time) TT3{:,:}];
