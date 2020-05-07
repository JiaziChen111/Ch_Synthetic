function [fltrNaN,NaNwho] = findNaN(header,dataset,cols)
% This function finds which columns in a dataset have all NaN.
% 
%     INPUTS
% cell: header    - headers of dataset from which NaN columns will be identified
% double: dataset - matrix with historic values (time in rows, vars in cols)
% double: cols    - [optional] vector of header columns to be reported
% 
%     OUTPUT
% logical: fltrNaN - true for variables with no observations (only NaN)
% cell: NaNwho     - identifiers of variables with all NaN
%
%     EXAMPLES
% [fltrNaNdata,NaNdata] = findNaN(hdr_blp, data_blp, [1 3]);
% [fltrNaNccs,NaNccs]   = findNaN(hdr_ccs, data_ccs);

% Pavel Solís (pavel.solis@gmail.com), March 2018
%%
NaNdata = isnan(dataset);           % Matrix of logicals for NaN
NaNmax  = max(sum(NaNdata));        % Maximum number of NaN in the dataset
fltrNaN = (sum(NaNdata) == NaNmax); % Logical row vector for cols with only NaN
nobs    = size(dataset,1);          % Number of observations in the dataset
if NaNmax == nobs                   % If at least one variable has all NaN
    if exist('cols','var')          % If cols defined, report those cols
        NaNwho = header(fltrNaN,cols);
    else                            % If cols not defined, report all cols
        NaNwho = header(fltrNaN,:);
    end
else
    fltrNaN(:) = 0; NaNwho = {};    % If NaNmax ~= nobs, there is no all NaN cols
end
