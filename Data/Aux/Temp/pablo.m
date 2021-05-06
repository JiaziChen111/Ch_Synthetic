k1 = 1;

% LC nominal curves from Bloomberg
[TTpltf,THpltf] = read_platforms();
TTdy = TTpltf;
THdy = THpltf;
header_daily  = [THdy.Properties.VariableNames;table2cell(THdy)];                       % header to cell
header_daily(2:end,5) = cellfun(@num2str,header_daily(2:end,5),'UniformOutput',false);  % tnrs to string
dataset_daily = [datenum(TTdy.Date) TTdy{:,:}];

ccy  = {'BRL','MXN','THB','CAD','JPY'};
type = {'LC'};
for k0 = 1:length(ccy)
    if strcmp(ccy{k0},'MXN')
        fltr = startsWith(header_daily(:,3),'C') & ismember(header_daily(:,1),ccy{k0}) & ismember(header_daily(:,2),type{k1}) & ~ismember(header_daily(:,5),{'15','20','25','30'});
    else
        fltr = ismember(header_daily(:,1),ccy{k0}) & ismember(header_daily(:,2),type{k1}) & ~ismember(header_daily(:,5),{'15','20','25','30'});
    end
    varnm = strcat(header_daily(fltr,5),'Y');
    dtmtx = dataset_daily(:,fltr);
    dates = datetime(dataset_daily(:,1),'ConvertFrom','datenum');
    TT  = array2timetable(dtmtx,'RowTimes',dates,'VariableNames',varnm);
    TT1 = rmmissing(TT);
    filename = fullfile(pwd,'..','..','Data','Aux','Temp',[ccy{k0} type{k1} '.xlsx']);
    writetimetable(TT1,filename,'Sheet',1,'Range','A1')
end

% LC synthetic (after read_data is run)
ccy  = {'BRL','MXN','THB','CAD','JPY'};
type = {'LCSYNT'};
for k0 = 1:length(ccy)
    fltr = ismember(header_daily(:,1),ccy{k0}) & ismember(header_daily(:,2),type{k1}) & ~ismember(header_daily(:,5),{'15','20','25','30'});
    varnm = strcat(header_daily(fltr,5),'Y');
    dtmtx = dataset_daily(:,fltr);
    dates = datetime(dataset_daily(:,1),'ConvertFrom','datenum');
    TT  = array2timetable(dtmtx,'RowTimes',dates,'VariableNames',varnm);
    TT1 = rmmissing(TT);
    filename = fullfile(pwd,'..','..','Data','Aux','Temp',[ccy{k0} type{k1} '.xlsx']);
    writetimetable(TT1,filename,'Sheet',1,'Range','A1')
end
