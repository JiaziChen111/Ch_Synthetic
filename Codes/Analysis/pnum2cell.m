function numcells = pnum2cell(numdoubles)
% This function converts a vector of numbers as doubles into a cell of numbers as strings.
%
%     INPUT
% vector: numdoubles - Vector of numbers as doubles
%
%     OUTPUT
% cell: numcells - Cell of numbers as strings
%
% Pavel Solís (pavel.solis@gmail.com), September 2018
%%
% Need numdoubles to be a column vector
% aux below is a cell with all the numbers as strings
if     isrow(numdoubles)    == 1
    aux = cellstr(num2str(numdoubles'));
elseif iscolumn(numdoubles) == 1
    aux = cellstr(num2str(numdoubles));
end
numcells = strrep(aux(:),' ','');                % Remove spaces
