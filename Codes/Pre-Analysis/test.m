% Compare datasets w/ Stata, use categorical variables
TTfp = array2timetable(data_fp(:,2:end),'RowTimes',datetime(data_fp(:,1),'ConvertFrom','datenum'));
TTzc = array2timetable(data_zc(:,2:end),'RowTimes',datetime(data_zc(:,1),'ConvertFrom','datenum'));

TTfp(:,69:75);
TTzc(:,1:12);

%  append_dataset
dataset1 = z1; %dataset_daily;
dataset2 = data_zc; %data_fp;
TT1 = array2timetable(dataset1(:,2:end),'RowTimes',datetime(dataset1(:,1),'ConvertFrom','datenum'));
TT2 = array2timetable(dataset2(:,2:end),'RowTimes',datetime(dataset2(:,1),'ConvertFrom','datenum'));
TT3 = synchronize(TT1,TT2,'union');
z1 = [datenum(TT3.Time) TT3{:,:}];
