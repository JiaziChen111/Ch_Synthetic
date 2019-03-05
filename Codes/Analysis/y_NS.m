function yields = y_NS(param, maturities)
% This function contains the equation for the zero curve implied by the
% Nelson-Siegel model for the instantaneous forward rate.
%
%     INPUTS
% double: param - vector containing parameters beta0, beta1, beta2, tau
% double: maturities - vector of maturities
%
%     OUTPUT
% double: yields - vector of yields at the specified maturities
%
% Pavel Solís (pavel.solis@gmail.com), April 2018
%%
aux1   = maturities/param(4);
aux2   = exp(-aux1);
yields = param(1) + (param(2) + param(3))*((1-aux2)./aux1) - param(3)*aux2;
 