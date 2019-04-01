function save_figure(subfolder,figname,saveit)
% This function saves the current figure in subfolder under the Figures folder.
%
%   INPUTS
% char: subfolder - name of subfolder under the Figures folder 
% char: figname   - name with which the figure will be saved
% logical: saveit - 1 for actually saving it (avoids commenting the line calling the function)
%
% Pavel Solís (pavel.solis@gmail.com), April 2019
%%
if saveit == 1
    figname = fullfile('..','..','Docs','Figures',subfolder,figname);
    saveas(gcf,figname,'epsc')
    saveas(gcf,figname,'fig')
    close
end
 