function [data_lc,dropped] = special_cases_rk(fltrYLD,data_lc,tnrs,ctry)
% This function helps to improve the fit of the Nelson-Siegel model by 
% removing outliers and points causing negative short-term implied yields.
% However, in many cases the improvement is as if the point had not been dropped.
% Row numbers below may change if the dataset changes, in which case they would
% need to be updated. 
% This function is called by fit_NS.m; flag_ssr and flag_3mo are useful in
% suggesting potential points to be dropped.
% Note: Special cases needed to address may depend a lot on the initial values.
% Calls to m-files: yrs2tnrs.m
% 
%     INPUTS
% logical: fltrYLD - filter indicating where (cols) the yields are within the dataset
% double: data_lc  - dataset containing historic (end-of-month) yields for different maturities
% double: tnrs     - used to match the position of the yields in fltrYD
% char: ctry       - three letters indicating the country
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

% if strcmp(YCtype,'LCRF')
%     Update inserting code of special_cases_rf in here
% elseif strcmp(YCtype,'LC')

switch ctry
    case 'BRL'           % Since May 2014, 7 yrs are very close to zero which affects the fit
    drop_ssr = [];
    drop_3mo = [];
    case 'COP'
    drop_ssr = [];
    drop_3mo = [2 2; 3 5; 4 2; 5 2; 6 2; 35 2; 42 2; 42 9; 63 1];
    %[2 2; 3 5; 4 2; 5 2; 6 2; 10 9; 42 2; 42 9; 63 1; 90 2]; init_vals = params2
    case 'HUF'
    drop_ssr = []; 
    drop_3mo = [124 1];
    case 'IDR'
    drop_ssr = [];
    drop_3mo = [2 2; 5 2; 6 5; 31 8; 34 2; 34 10; 58 1; 98 2; 114 2; 114 3; 114 4;134 1; 134 9];%Check 114
    case 'ILS'
    drop_ssr = [];
    drop_3mo = [2 5; 3 8; 4 8; 5 6; 22 4; 23 2; 64 3; 72 3; 110 10; 111 10; ...
        112 10; 121 10; 122 10; 123 10; 124 10; 131 10];
    case 'MXN'
    drop_ssr = [];
    drop_3mo = [55 2; 55 10; 56 2; 56 10; 87 2]; % Check 55 and 56
    case 'PEN'
    drop_ssr = [];
    drop_3mo = [];
    case 'PHP'
    drop_ssr = [];
    drop_3mo = [19 10; 90 7; 125 1; 144 2; 169 2; 188 2; 190 2; 208 10];
    case 'PLN'
    drop_ssr = [];
    drop_3mo = [51 5; 64 1; 70 2; 70 3; 80 2; 149 2];
    case 'TRY'
    drop_ssr = [];
    drop_3mo = [1 3; 24 5; 25 5; 116 2; 117 2; 118 2];
    case 'KRW'
    drop_ssr = [];
    drop_3mo = [120 1];
    case 'MYR'
    drop_ssr = [];
    drop_3mo = [];
    case 'RUB'
    drop_ssr = [];
    drop_3mo = [100 1; 109 2; 110 2];
    case 'THB'
    drop_ssr = [5 2];
    drop_3mo = [24 2; 28 5; 66 1; 74 7];
    case 'ZAR'
    drop_ssr = [];
    drop_3mo = [25 2; 30 3; 31 3; 50 2; 52 3; 71 3; 85 1; 87 1; 88 1; 107 2; 111 5];
end

% end % End of if statement

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