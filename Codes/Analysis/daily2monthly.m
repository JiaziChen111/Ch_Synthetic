function [S,dataset_monthly,header_monthly] = daily2monthly(S,dataset_daily,header_daily)
% DAILY2MONTHLY Monthly datasets for CIPDEV, LCNOM, LCSYNT for countries in S
% 
%     INPUT
% struct: S - country and currency names, letter and digit codes
% double: dataset_daily - obs as rows (top-down old-new obs), col1 has dates
% cell:   header_daily  - names for the columns of dataset_daily
% 
%     OUTPUT
% struct: S - (un)balanced panels for each variable type, date of first obs
% double: dataset_monthly - obs as rows (top-down old-new obs), col1 has dates
% cell:   header_monthly  - names for the columns of dataset_monthly

% Pavel Sol�s (pavel.solis@gmail.com), June 2020
%%
VarType = {'CIPDEV','LCNOM','LCSYNT'};
fields  = {'dated','data','dateb','blncd'};
ncntrs  = length(S);    ntypes = length(VarType);                           % #countries and #variables
tnrmin  = 5;            tnrmax = 10;                                        % minimum and maximum tenors
datesdy = dataset_daily(:,1);
datesmt = unique(lbusdate(year(datesdy),month(datesdy)));                   % last U.S. business day per month
tnrsall = [0; cellfun(@str2num,header_daily(2:end,5))];                     % tenors as doubles
fltrTNR = tnrsall <= tnrmax;                                                % identify tenors <= maximum tenor
tnrsall = tnrsall(fltrTNR);
dataset_monthly = dataset_daily(ismember(datesdy,datesmt),fltrTNR);         % extract monthly dataset
header_monthly  = header_daily(fltrTNR,:);                                  % monthly header
nmonths = size(dataset_monthly,1);

for j0 = 1:ntypes
    switch VarType{j0}                                                      % prefix for field names
        case 'CIPDEV';  prefix = 'c_';
        case 'LCNOM';   prefix = 'n_';
        case 'LCSYNT';  prefix = 's_';
    end
    
    % Construct datasets for each type of variable per country
    fnames  = strcat(prefix,fields);                                        % field names for variable type
    fltrTYP = ismember(header_monthly(:,2),{VarType{j0},'Type'});           % include column name
    for k0  = 1:ncntrs
        % Unbalanced panels
        fltrVAR  = ismember(header_monthly(:,1),{S(k0).iso,'Currency'}) & fltrTYP; % country + variable type
        tnrs     = tnrsall(fltrVAR);                                     	% available tenors
        data_var = dataset_monthly(:,fltrVAR);                              % extract data (include dates)
        istnrmin = repmat(tnrs' >= tnrmin,nmonths,1);                     	% cols w/ tenors >= minimum tenor
        isrowobs = ~isnan(data_var);                                      	% rows w/ actual observations
        idxRows  = any(isrowobs & istnrmin,2);                           	% rows w/ tenors above min
        data_var = data_var(idxRows,:);                                     % keep rows w/ tenors above min
        S(k0).(fnames{1}) = datestr(data_var(1,1),'mmm-yyyy');              % first monthly observation
        S(k0).(fnames{2}) = [tnrs'; data_var(:,1) data_var(:,2:end)/100];	% data in decimals
        
        % Balanced panels
        udataset = S(k0).(fnames{2});
        tnrsrmv  = [];                                                      % remove tenors in limited cases
        if any(strcmp(VarType{j0},{'CIPDEV','LCSYNT'}))
            switch S(k0).iso
                case {'COP','AUD'}
                    tnrsrmv = [8 9];
                case {'HUF','DKK','EUR','GBP','NOK','SEK'}
                    tnrsrmv = 9;
                case {'KRW','CAD','CHF','NZD'}
                    tnrsrmv = [6 8 9];
            end
        end
        udataset = udataset(:,~ismember(udataset(1,:),tnrsrmv));          	% keep tenors not in tnrsrmv
        idxRmv   = any(isnan(udataset),2);                                  % rows w/ NaNs
        udataset = udataset(~idxRmv,:);                                     % remove rows w/ NaNs
        S(k0).(fnames{3}) = datestr(udataset(2,1),'mmm-yyyy');
        S(k0).(fnames{4}) = udataset;
    end
end