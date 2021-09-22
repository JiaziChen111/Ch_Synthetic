********************************************************************************
*** Structural VAR
********************************************************************************

matrix A = (1,0,0,0,0,0,0\.,1,0,0,0,0,0\.,.,1,0,0,0,0\.,.,.,1,0,0,0\.,.,.,.,1,0,0\.,.,.,.,.,1,0\.,.,.,.,.,.,1)
matrix B =(.,0,0,0,0,0,0\0,.,0,0,0,0,0\0,0,.,0,0,0,0\0,0,0,.,0,0,0\0,0,0,0,.,0,0\0,0,0,0,0,.,0\0,0,0,0,0,0,.)

svar y p pcom ff nbr tr m1 if d>yq(1959,4) & d<yq(1995,4), lags(1/4) aeq(A) beq(B)

irf set "sirf.irf"
irf create ffsvar, step(15)

local rvar y p pcom ff nbr tr m1

foreach y of local rvar {
	irf graph oirf,  impulse(ff) response(`y') individual ///
		iname(`y'ff, replace) legend(off)
	local list `list' `y'ff1

}
graph combine `list'
graph export ../output/VAR_structural.pdf, replace
graph drop _all
