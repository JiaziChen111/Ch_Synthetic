function [S,vix] = add_vars(S,currEM)
% ADD_VARS Add variables to structure S (estimated real rates, 
% survey-based term premia, EPU indexes)

% m-files called: read_macrovars, datesminmax, syncdatasets, read_epu_idx
% Pavel Solís (pavel.solis@gmail.com), July 2020
%%
[data_macro,hdr_macro] = read_macrovars(S);                 % macro and policy rates
nEMs = length(currEM);

%% Calculate and store the ex-ante real rate for EMs
fldname = {'ssb_yP','scpi'};
for k0  = 1:nEMs
    if ~isempty(S(k0).(fldname{1}))
        dtst1  = S(k0).(fldname{1}); dtst2 = S(k0).(fldname{2});        % extract data
        hdr1   = dtst1(1,:);  hdr2 = dtst2(1,:);                        % record headers
        tnrcmn = intersect(hdr1,hdr2,'stable');                         % identify common tenors
        fltr1  = ismember(hdr1,tnrcmn);  fltr2 = ismember(hdr2,tnrcmn); % find common tenors
        fltr1(1) = true;    fltr2(1) = true;                            % include dates
        [~,yP,sinf] = syncdatasets(dtst1(:,fltr1),dtst2(:,fltr2));      % synchronize arrays
        realr = yP;                                                     % copy dates and headers
        realr(2:end,2:end) = yP(2:end,2:end) - sinf(2:end,2:end)/100;   % real rate in decimals
        S(k0).rrt = realr;
    end
end

%% Calculate and store the survey-based TP
fldname = {'s_blncd','scbp'};
for k0  = 1:nEMs
    if ~isempty(S(k0).(fldname{2}))
        dtst1  = S(k0).(fldname{1}); dtst2 = S(k0).(fldname{2});        % extract data
        hdr1   = dtst1(1,:);  hdr2 = dtst2(1,:);                        % record headers
        tnrcmn = intersect(hdr1,hdr2,'stable');                         % identify common tenors
        fltr1  = ismember(hdr1,tnrcmn);  fltr2 = ismember(hdr2,tnrcmn); % find common tenors
        fltr1(1) = true;    fltr2(1) = true;                            % include dates
        [~,sylds,spol] = syncdatasets(dtst1(:,fltr1),dtst2(:,fltr2));	% synchronize arrays
        svytp = sylds;                                                  % copy dates and headers
        svytp(2:end,2:end) = sylds(2:end,2:end) - spol(2:end,2:end)/100;% tp in decimals
        S(k0).stp = svytp;
    end
end

%% Calculate and store bond risk premia
for k0 = 1:nEMs
    if ~isempty(S(k0).ssb_tp)
        fldname = {'ssb_tp','c_data'};
    else
        fldname = {'sy_tp','c_data'};
    end
    dtst1  = S(k0).(fldname{1}); dtst2 = S(k0).(fldname{2});            % extract data
    hdr1   = dtst1(1,:);  hdr2 = dtst2(1,:);                            % record headers
    tnrcmn = intersect(hdr1,hdr2,'stable');                             % identify common tenors
    fltr1  = ismember(hdr1,tnrcmn);  fltr2 = ismember(hdr2,tnrcmn);     % find common tenors
    fltr1(1) = true;    fltr2(1) = true;                                % include dates
    [~,tpsynt,lccs] = syncdatasets(dtst1(:,fltr1),dtst2(:,fltr2));      % synchronize arrays
    brp = tpsynt;                                                       % copy dates and headers
    brp(2:end,2:end) = tpsynt(2:end,2:end) + lccs(2:end,2:end);         % brp rate in decimals
    S(k0).brp = brp;
end

%% Load data for EPU and VIX
S   = read_epu_idx(S);
vix = data_macro(:,ismember(hdr_macro(:,2),{'type','VIX'}));