z1   = [];

z2   = [];

pval = [];

z3   = ;




fltr1str = pval >= 0.05 & pval < 0.1;
fltr2str = pval >= 0.01 & pval < 0.05;
fltr3str = pval < 0.01;

beta = cellstr(num2str(z1,'%.3f'));
stdb = cellstr(strcat('(',num2str(z2,'%.2f'),')'));
r2   = cellstr(num2str(round(z3,3)));

beta(fltr1str) = strcat(beta(fltr1str),'*');
beta(fltr2str) = strcat(beta(fltr2str),'**');
beta(fltr3str) = strcat(beta(fltr3str),'***');
mtrx  = [beta'; stdb'];
z4 = [mtrx(:); r2];