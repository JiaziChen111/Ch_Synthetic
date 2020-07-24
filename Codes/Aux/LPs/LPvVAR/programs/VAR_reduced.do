********************************************************************************
*** VAR
********************************************************************************

var y p pcom ff nbr tr m1 if d>yq(1959,4) & d<yq(1995,4), lags(1/4)

irf create ffvar, set(irf) step(15) replace

local rvar y p pcom ff nbr tr m1

foreach y of local rvar {
	irf graph oirf,  impulse(ff) response(`y') individual ///
		iname(`y'ff, replace) legend(off)
	local list `list' `y'ff1

}
graph combine `list'
graph export ../output/VAR_reduced.pdf, replace
graph drop _all
