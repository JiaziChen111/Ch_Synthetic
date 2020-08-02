usycnms = TTusyc.Properties.VariableNames;
fltrMTH = contains(usycnms,'M');
tenors  = cell2mat(cellfun(@str2double,regexp(usycnms,'\d*','Match'),'UniformOutput',false));
tenors  = [tenors(fltrMTH),tenors(~fltrMTH)*12];
fltrGSW = ismember(tenors,matsout*12);
TTgsw   = TTusyc(:,fltrGSW);
TTgsw.Properties.VariableNames = strcat('usyc',tenors(fltrGSW),'m');

TT_kw = array2timetable(TT_kw{:,:}/100,'RowTimes',TT_kw.Time,'VariableNames',TT_kw.Properties.VariableNames);
