%% Read Economic Policy Uncertainty (EPU) Indexes
% This code reads the EPU indexes of SBD (2016). Since the files are not
% standardized, it is necessary to deal with the filenames and dates depending
% on the country.
%
% Pavel Solís (pavel.solis@gmail.com), September 2018
%%
epuidx  = struct('cty',{},'info',{});
ctrsEPU = {'BRL','COP','MXN','KRW','RUB'};
ctrsBMR = {'BRL','MXN','RUB'};

path = pwd;
cd(fullfile(path,'..','..','Data'))         % Use platform-specific file separators
for k = 1:length(ctrsEPU)
    switch ctrsEPU{k}                       % Use appropriate filename
        case ctrsBMR
            filename = ['importable_EPU_Index_' ctrsEPU{k} '.xlsx']; 
        otherwise
            filename = ['original_EPU_Index_' ctrsEPU{k} '.xlsx']; 
    end 
    [data,txt] = xlsread(filename,1);       % Read data
    epu_data   = data(:,end);               % For all countries, EPU index is in last column
    
    % Identify year and month
    if any(strcmp(ctrsBMR,ctrsEPU{k}))      % ctrsEPU{k} is 'BRL', 'MXN' or'RUB'
        epu_yrs  = data(:,1);
        epu_mths = data(:,2);
    else                                    % ctrsEPU{k} is 'COP' or'KRW'
        epu_aux1 = txt(2:end-8,1);          % Coincidence that last obs is end-8 for both
        if strcmp(ctrsEPU{k},'COP')         % ctrsEPU{k} is 'COP'
            epu_aux2 = datenum(epu_aux1,'yyyy-mm');
        else                                % ctrsEPU{k} is 'KRW'
            epu_aux2 = datenum(epu_aux1,'m/yyyy');
        end
        epu_yrs  = year(epu_aux2);
        epu_mths = month(epu_aux2);
    end
    epu_eomd  = eomday(epu_yrs,epu_mths);                   % End-of-month day
    epu_eom   = datenum(epu_yrs,epu_mths,epu_eomd);         % EPU indexes seem to be eom business days
    epu_dates = busdays(epu_eom(1),epu_eom(end),'monthly'); % Determines end-of-month business days
    epu_all   = [epu_dates epu_data];                       % Verifies both have same number of rows

    % Save country, dates and data for all countries in a structure
    epuidx(k).cty  = ctrsEPU{k};
    epuidx(k).info = epu_all;
end
cd(path)

clear k filename* path data txt epu_*

%% Source

% Check whether string is in a cell array
% https://www.mathworks.com/matlabcentral/answers/16333-checking-of-existing-an-string-in-a-cell-arrays
