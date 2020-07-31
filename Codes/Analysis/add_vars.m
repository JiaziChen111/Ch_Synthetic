function [S,uskwfy,uskwyp,uskwtp,ustp10,ustpguim,vix] = add_vars(S,currEM)
% ADD_VARS Add variables to structure S (estimated real rates, 
% survey-based term premia, EPU indexes)

% m-files called: read_macrovars, datesminmax, syncdatasets, getFredData, read_epu_idx
% Pavel Sol�s (pavel.solis@gmail.com), June 2020
%%
[data_macro,hdr_macro] = read_macrovars(S);                 % macro and policy rates
nEMs = length(currEM);

%% Calculate and store the real rate for EMs
fldname = {'ssb_yP','scpi'};
for k0  = 1:nEMs
    if ~isempty(S(k0).(fldname{1}))
        dtst1  = S(k0).(fldname{1}); dtst2 = S(k0).(fldname{2});        % extract data
        hdr1   = dtst1(1,:);  hdr2 = dtst2(1,:);                        % record headers
        tnrcmn = intersect(hdr1,hdr2,'stable');                         % identify common tenors
        fltr1  = ismember(hdr1,tnrcmn);  fltr2 = ismember(hdr2,tnrcmn); % find common tenors
        fltr1(1) = true;    fltr2(1) = true;                            % include dates
        [~,yP,inf] = syncdatasets(dtst1(:,fltr1),dtst2(:,fltr2));      	% synchronize arrays
        realr = yP;                                                     % copy dates and headers
        realr(2:end,2:end) = yP(2:end,2:end) - inf(2:end,2:end)/100;    % real rate in decimals, use scpi
        S(k0).rrt = realr;
    end
end

%% Calculate and store TP from surveys
fldname = {'s_blncd','scbp'};
for k0  = 1:nEMs
    if ~isempty(S(k0).(fldname{2}))
        dtst1  = S(k0).(fldname{1}); dtst2 = S(k0).(fldname{2});        % extract data
        hdr1   = dtst1(1,:);  hdr2 = dtst2(1,:);                        % record headers
        tnrcmn = intersect(hdr1,hdr2,'stable');                         % identify common tenors
        fltr1  = ismember(hdr1,tnrcmn);  fltr2 = ismember(hdr2,tnrcmn); % find common tenors
        fltr1(1) = true;    fltr2(1) = true;                            % include dates
        [~,sylds,svycb] = syncdatasets(dtst1(:,fltr1),dtst2(:,fltr2));	% synchronize arrays
        svytp = sylds;                                                  % copy dates and headers
        svytp(2:end,2:end) = sylds(2:end,2:end) - svycb(2:end,2:end)/100;% tp in decimals
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

%% Load US YC components: Guimaraes, KW
pathc = pwd;
pathd = '/Users/Pavel/Documents/GitHub/Book/Ch_Synthetic/Data/Aux/USYCSVY';
cd(pathd)
load('svyyld.mat','smplstpsvy'); load('svyyld.mat','smplsdate');
cd(pathc)
ustpguim = [nan [0.25 1:5 7 10]; smplsdate{1,4} smplstpsvy{1,4}];

datemn = datestr(min(ustpguim(:,1)),29);    datemx = datestr(datenum('1-Feb-2019'),29) ;% 29: date format ID
KW10   = getFredData('THREEFYTP10',datemn,datemx); 
KWtp10 = [nan 10; KW10.Data];
KWtp10(isnan(KWtp10(:,2)),:) = [];                                      % remove NaNs

KW01   = getFredData('THREEFYTP1',datemn,datemx); 
KWtp01 = [nan 1; KW01.Data];
KWtp01(isnan(KWtp01(:,2)),:) = [];

KWtp   = syncdatasets(KWtp01,KWtp10);
[~,~,uskwtp] = syncdatasets(S(k0).ms_ylds,KWtp);
ustp10 = uskwtp(:,[1 end]);

KW10   = getFredData('THREEFY10',datemn,datemx); 
KWfy10 = [nan 10; KW10.Data];
KWfy10(isnan(KWfy10(:,2)),:) = [];

KW01   = getFredData('THREEFY1',datemn,datemx); 
KWfy01 = [nan 1; KW01.Data];
KWfy01(isnan(KWfy01(:,2)),:) = [];

KWfy = syncdatasets(KWfy01,KWfy10);
[~,~,uskwfy] = syncdatasets(uskwtp,KWfy);

uskwyp = uskwfy;                                                        % copy dates and tenors
uskwyp(2:end,2:end) = uskwfy(2:end,2:end) - uskwtp(2:end,2:end);

% plot(uskwfy(2:end,1),[uskwfy(2:end,end) uskwyp(2:end,end) uskwtp(2:end,end)])

%% Load data for EPU and VIX
S   = read_epu_idx(S);
vix = data_macro(:,ismember(hdr_macro(:,2),{'type','VIX'}));
