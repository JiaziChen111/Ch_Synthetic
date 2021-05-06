

replace b${t2}ffff = 1 if _n==1

gen Quarters = _n-1 if _n<17
gen zero = 0

local rvar y p pcom ff nbr tr m1

foreach y of local rvar {

	gen u${t2}`y'ff = b${t2}`y'ff + 1.96*se${t2}`y'ff
	gen l${t2}`y'ff = b${t2}`y'ff - 1.96*se${t2}`y'ff
		
}

foreach y of local rvar {
		
	twoway (rarea u${t2}`y'ff l${t2}`y'ff Quarters, ///
		fcolor(gs12) lcolor(white) lpattern(solid)) ///
	(line b${t2}`y'ff Quarters, lcolor(blue) lpattern(solid) lwidth(thick)) ///
	(line zero Quarters, lcolor(black)), ///
		ylabel(, labsize(vsmall)) xlabel(, labsize(vsmall)) xtitle() ///
		graphregion(color(white)) plotregion(color(white)) ///
		legend(off) title(ff->`y') name(`y'ff, replace)
	
		local list `list' `y'ff
}

graph combine `list', ///
	title("$t1 LP: ff shock", size(small))
graph export ../output/LP_$t1.pdf, replace
		
graph drop _all
drop Quarters zero
