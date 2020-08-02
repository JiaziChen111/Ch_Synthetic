% fldsall = fieldnames(S);

%fldsall{ismember(fldsall,flds{k1})};

%     % Domestic financial variables
%     fltrCTY = ismember(hdr_finan(:,1),S(k0).iso) & fltrLC;
%     findata = data_finan(:,fltrCTY);
%     finnms  = lower(hdr_finan(fltrCTY,2)');
%     TTstx   = array2timetable(findata,'RowTimes',datetime(findts,'ConvertFrom','datenum'),...
%                 'VariableNames',finnms);
%     TT3     = synchronize(TT3,TTstx,'intersection');