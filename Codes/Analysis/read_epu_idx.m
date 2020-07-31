function S = read_epu_idx(S)
% READ_EPU_IDX Read Economic Policy Uncertainty indexes from SBD (2016)
% Files are not standardized, need to deal with filenames and dates
%
% Pavel Solís (pavel.solis@gmail.com), June 2020
%%
% epuidx  = struct('cty',{},'data',{});
ctrsEPU = {'BRL','COP','MXN','KRW','RUB'};
ctrsBMR = {'BRL','MXN','RUB'};
nctrs   = length(S);

path = pwd;
cd(fullfile(path,'..','..','Data','Raw','EPU'))         % use platform-specific file separators
for k = 1:length(ctrsEPU)
    switch ctrsEPU{k}                                   % use appropriate filename
        case ctrsBMR
            filename = ['import_EPU_Index_' ctrsEPU{k} '.xlsx'];
        otherwise
            filename = ['EPU_Index_' ctrsEPU{k} 'o.xlsx']; 
    end 
    [data,txt] = xlsread(filename,1);                   % read data
    epu_data   = data(:,end);                           % for all countries, EPU index is in last column
    
    % Identify year and month
    if any(strcmp(ctrsBMR,ctrsEPU{k}))                  % ctrsEPU{k} is 'BRL', 'MXN' or'RUB'
        epu_yrs  = data(:,1);
        epu_mths = data(:,2);
    else                                                % 'COP' or'KRW'
        epu_aux1 = txt(2:end-8,1);                      % coincidence that last obs is end-8 for both
        if strcmp(ctrsEPU{k},'COP')                     % 'COP'
            epu_aux2 = datenum(epu_aux1,'yyyy-mm');
        else                                            % 'KRW'
            epu_aux2 = datenum(epu_aux1,'m/yyyy');
        end
        epu_yrs  = year(epu_aux2);
        epu_mths = month(epu_aux2);
    end
    epu_dates = unique(lbusdate(epu_yrs,epu_mths));     % last U.S. business day per month
    for k0 = 1:nctrs
        if strcmp(S(k0).iso,ctrsEPU{k})
            S(k0).epu = [epu_dates epu_data];
        end
    end
end
cd(path)