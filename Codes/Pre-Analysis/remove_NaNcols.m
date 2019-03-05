function [data,hdr] = remove_NaNcols(header,dataset)
% This function removes columns with no data from a dataset, if any.
% Calls to m-files: findNaN.m
% 
%     INPUTS
% cell: header    - headers of dataset (may or may not have row 1 with titles)
% double: dataset - matrix with historic values (time in rows, vars in cols)
% 
%     OUTPUT
% double: data - matrix with historic values (with no all NaN columns) 
% cell: hdr    - updated header (if no row 1 with titles in header, neither do hdr)
%
% Pavel Solís (pavel.solis@gmail.com), March 2018
%%
data     = dataset;
colsdata = size(data,2);
[rowshdr,colshdr] = size(header);

% Add extra row if needed
if rowshdr == colsdata                  % If header has row 1 with titles, use it
    hdr = header;
else                                    % Otherwise, temporarily add row 1 with titles
    [hdr_aux{1:colshdr}] = deal('hdr'); 
    hdr = [hdr_aux; header];            % Needed for fltrNaN
end

% If there are cols with NaN, remove them
fltrNaN = findNaN(hdr, data);           % Find cols with all NaN
if sum(fltrNaN) > 0                     % If at least one col with all NaN
    data(:,fltrNaN) = [];               % Delete cols with no data
    hdr(fltrNaN,:)  = [];               % Delete corresponding rows in header
end

% Remove extra row if added
if rowshdr ~= colsdata                  % If row 1 was temporarily added
    hdr = hdr(2:end,:);                 % Remove extra row 1
end
