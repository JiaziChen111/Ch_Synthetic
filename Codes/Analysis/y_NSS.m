function yields = y_NSS(param, maturities)
% This function contains the equation for the zero curve implied by the
% Nelson-Siegel-Svensson model for the instantaneous forward rate.
%
%     INPUTS
% double: param - vector containing parameters beta0 to beta3, tau1, tau2
% double: maturities - vector of maturities
%
%     OUTPUT
% double: yields - vector of yields at the specified maturities
%
% Pavel Solís (pavel.solis@gmail.com), April 2018
%%
aux1   = maturities/param(5);
aux2   = exp(-aux1);
yields_NS = param(1) + (param(2) + param(3))*((1-aux2)./aux1) - param(3)*aux2;

aux3   = maturities/param(6);
aux4   = exp(-aux3);
yields = yields_NS + param(4)*((1-aux4)./aux3 - aux4);