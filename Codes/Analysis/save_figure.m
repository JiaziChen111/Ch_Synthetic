function save_figure(name,saveit)
% This function saves the current figure in the 'Figures' folder.
% Calls to m-files: none
%
%   INPUTS
% char: name      - name with which the figure will be saved
% logical: saveit - 1 for actually saving it (avoids commenting the line calling the function)
%
% Pavel Solís (pavel.solis@gmail.com), April 2018
%%
if saveit == 1
    figname = fullfile('..','..','Docs','Figures',name);
    saveas(gcf,figname,'epsc')
    saveas(gcf,figname,'fig')
    close
end
 