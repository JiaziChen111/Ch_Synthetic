function idxPos = yrs2tnrs(tnrs,drop_mtrx)
% This function converts years into the position of those years within tnrs.
% This allows to use years directly when defining drop_matrix.
% 
%     INPUTS
% double: tnrs      - used to find the position of the years
% double: drop_mtrx - col 1 contains rows, col 2 contains years; they don't need to be ordered
% 
%     OUTPUT
% double: idxPos    - indicates the position of the years within tnrs
%
% Pavel Solís (pavel.solis@gmail.com), April 2018
%%
n_changes  = 1:size(drop_mtrx,1);
n_per_col  = (n_changes'-1)*size(tnrs,1);   % Count previous elements at beginning of cols
idx        = (tnrs == drop_mtrx(:,2)');     % Logical matrix size(tnrs,1) x size(drop_mtrx,1)
global_pos = find(idx);                     % Position of tenors based on linear indexing
idxPos     = global_pos - n_per_col;        % Index with position of years within tnrs

%% Sources
%
% The computation above reverts back the linear indexing computation in the 
% second answer of the link below to recover the rows
% https://stackoverflow.com/questions/36710491/accessing-multiple-elements-in-a-matrix-matlab
%