function [data_lc,dropped] = special_cases_rf(fltrYLD,data_lc,tnrs,k)
% This function helps to improve the fit of the Nelson-Siegel model by 
% removing outliers and points causing negative short-term implied yields.
% However, in many cases the improvement is as if the point had not been dropped.
% Row numbers below may change if the dataset changes, in which case they would
% need to be updated. 
% This function is called by fit_NS.m; flag_ssr and flag_3mo are useful in
% suggesting potential points to be dropped.
% Calls to m-files: yrs2tnrs.m
% 
%     INPUTS
% logical: fltrYLD - filter indicating where (cols) the yields are within the dataset
% double: data_lc  - dataset containing historic (end-of-month) yields for different maturities
% double: tnrs     - used to match the position of the yields in fltrYD
% char: k          - three letters indicating the country
% 
%     OUTPUT
% double: data_lc  - dataset with the outliers removed
% double: dropped  - contains the year-yield pairs of the points dropped
%
% Pavel Solís (pavel.solis@gmail.com), April/September 2018
%%
nobs = size(data_lc,1);

% Convention: 1st entry indicates the row in data_lc, 2nd entry indicates the year [row year]
% drop_ssr is for outliers, drop_3mo is for explosive (-/+) 3-month implied yields
if     k == 'BRL'           % Since May 2014, 7 yrs are very close to zero which affects the fit
    drop_ssr = [25 2; 28 7; 30 4; 32 4; 62 7; 64 7; 71 3; 72 1; 75 1; 76 7; 79 1; 82 1; 91 1; 92 10; 
        93 1; 94 3; 95 1; 97 1; 98 1; 103 1; 111 2; 133 7; 135 7; 136 7; 137 7; 138 7; 140 7; 141 7];
    drop_3mo = [5 2; 7 7; 108 1; 113 3; 115 5; 118 2; 119 2; 120 7; 122 3; 126 5; 127 5; 130 7; 134 7];
elseif k == 'COP'
    drop_ssr = [14 7; 38 2; 53 7; 145 2];
    drop_3mo = [23 10; 25 1; 54 9; 56 9; 57 9; 67 1; 69 1; 70 1; 101 9];
elseif k == 'HUF'
    drop_ssr = [25 5; 26 7; 27 4; 29 3; 32 1; 34 9; 47 7; 56 8; 62 10; 66 8; 68 2]; 
    drop_3mo = [28 8];
elseif k == 'IDR'
    drop_ssr = [3 3; 11 4; 15 3; 85 1; 95 1; 98 2; 103 5; 127 5; 142 4; 153 7];
    drop_3mo = [1 1; 2 2; 5 2; 18 10; 20 3; 57 10; 59 1; 61 10; 68 10;
        70 2; 166 4; 174 2; 176 2; 179 1; 180 3; 192 3; 201 3];
elseif k == 'ILS'
    drop_ssr = [6 4; 10 10; 14 4; 15 6; 24 10; 41 10; 52 10; 53 10; 84 4];
    drop_3mo = [2 3; 3 10; 43 7; 46 9; 48 7; 49 8; 54 7; 55 8; 62 3;
        63 3; 64 9; 76 10; 94 10];
elseif k == 'MXN'
    drop_ssr = [62 5];
    drop_3mo = [28 3; 40 2; 41 10; 42 10; 43 2];
elseif k == 'PEN'
    drop_ssr = [9 5; 21 5; 24 5; 32 5; 42 7; 105 10; 111 2; 121 5];
    drop_3mo = [11 10; 17 2; 18 1; 106 8; 107 8; 113 9];
elseif k == 'PHP'
    drop_ssr = [24 3; 70 2; 99 7; 100 1; 101 7; 103 3; 107 1; 110 5;
        112 4; 114 2; 118 3; 141 5; 174 5];
    drop_3mo = [27 3; 157 5; 165 7];
elseif k == 'PLN'
    drop_ssr = [21 5; 24 3; 45 7; 46 7; 87 2; 94 2];
    drop_3mo = [2 7; 25 3; 26 7; 27 10];
elseif k == 'TRY'
    drop_ssr = [1 3; 6 8; 7 2; 44 8; 130 5; 132 7; 133 7; 141 10; 143 10; 144 7];
    drop_3mo = [55 9; 57 9; 102 9; 103 9; 145 7; 146 2; 148 1];
elseif k == 'KRW'
    drop_ssr = [15 5; 18 10; 30 1; 31 7; 52 7; 54 5; 58 3; 69 7; 70 5; 73 7; 74 3; 79 2; 88 2; 
        99 3; 102 2; 112 7; 115 2; 117 2; 119 9; 121 9; 122 9; 137 7; 141 1; 143 8; 195 3; 197 7];
    drop_3mo = [2 1; 5 7; 9 7; 10 3; 23 1; 24 7; 28 4; 29 3; 56 4; 78 3; 109 9];
elseif k == 'MYR'
    drop_ssr = [(1:nobs)' repmat(2,nobs,1)]; % 2-year rate is an outlier
    drop_ssr([18 31 78],2) = 3; drop_ssr(73,2) = 5; drop_ssr([17 37],2) = 7; % Instead of 2yr
    drop_3mo = [24 7; 27 7];
elseif k == 'RUB'
    drop_ssr = [7 7; 38 2; 46 9; 95 10; 99 2; 120 2; 131 9; 133 3; 142 4];
    drop_3mo = [1 1; 2 7; 3 7; 101 5; 103 1; 132 8; 140 1];
elseif k == 'THB'
    drop_ssr = [2 7; 5 2; 6 5; [66,101,103:108,110,118:120]' repmat(4,12,1)];
    drop_3mo = [];
elseif k == 'ZAR'
    drop_ssr = [23 5; 29 5; 75 10; 92 2; 103 10; 106 4; 108 2; 114 4; 152 7; 158 3; 166 9];
    drop_3mo = [49 9; 68 3; 69 1; 70 1];
end
    
% Find the data points to be dropped, save them, drop them and report them
dropped       = nan(nobs,2);                         % For non-dropped points, use NaN
if ~isempty(drop_ssr) || ~isempty(drop_3mo)          % Proceed if at least one has info
    posY      = find(fltrYLD);                       % Columns' numbers in dataset
    drop_mtrx = [drop_ssr; drop_3mo];                % Rows and years to be dropped
    idxPos    = yrs2tnrs(tnrs,drop_mtrx);            % Location of the years within tnrs
    retrv     = [drop_mtrx(:,1) posY(idxPos)];       % Rows and cols to be dropped
    idxDrops  = retrv(:,1) + (retrv(:,2)-1)*nobs;    % Linear indexing of points to be dropped
    values    = data_lc(idxDrops);                   % Save before dropping them
    data_lc(idxDrops) = NaN;                         % Drop the data points
    dropped(retrv(:,1),:) = [drop_mtrx(:,2) values]; % Years and values dropped
end
%% Sources
%
% Linear indexing formula in second answer of the following link
% https://stackoverflow.com/questions/36710491/accessing-multiple-elements-in-a-matrix-matlab