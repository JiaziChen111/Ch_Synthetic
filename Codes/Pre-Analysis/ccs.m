%% Cross-Currency Swaps
% This code uses swap curves to construct a CCS database. 
% Assumes that read_tickers_v4.m and read_bloomberg.m have already been run.
% Calls to m-files: compute_ccs.m, remove_NaNcols.m
%
% Pavel Sol�s (pavel.solis@gmail.com), March 2018
%% Construct the CCS Database
LCs  = sheets(3:end);       % Local currencies ('sheets' generated by read_tickers_v4.m)
LCs  = ['BRL', LCs]';       % Two formulas for Brazil
frml = [1,6,1,2,1,3,4,1,1,2,7,1,3,8,5,3]'; % See compute_ccs.m
hdr_ccs  = {};              % No row 1 with titles (ie ready to be appended)
data_ccs = dates;           % 'dates' generated by read_bloomberg.m

for k = 1:numel(LCs) % hdr_blp & data_blp generated by read_tickers_v4.m & read_bloomberg.m
    [CCS,hdr] = compute_ccs(LCs{k},frml(k),hdr_blp,data_blp);
    hdr_ccs   = [hdr_ccs; hdr];
    data_ccs  = [data_ccs, CCS];
end

[data_ccs,hdr_ccs] = remove_NaNcols(hdr_ccs,data_ccs);

%% Report CCS Tenors per Currency
tnrperLCccs = {};              % Count only after remove_NaNcols.m is called
LC_once = unique(hdr_ccs(:,1));
for k = LC_once'
    ntnrperLC = sum(strcmp(hdr_ccs(:,1),k));
    tnrperLCccs  = [tnrperLCccs; k, 'CCS', ntnrperLC];
end

clear k filename fltrNaN LCs LC_once nLC CCS hdr hdr_tmp ntnrperLC frml