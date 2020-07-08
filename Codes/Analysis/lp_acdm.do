
/* This code uses local projections to estimate the impulse reponse of the bond yields
of emerging markets to a 1 basis point change in the the target, path and lsap shocks */

* ==============================================================================
* Preamble
* ==============================================================================
* Define working directories and filenames
cd "/Users/Pavel/Documents/GitHub/Book/Ch_Synthetic"	// Update as necessary
local pathmain `c(pwd)'
/* Mac OS */
global pathdata "`pathmain'/Data/Analytic"
global pathcode "`pathmain'/Codes/Analysis"
global pathtbls "`pathmain'/Docs/Tables"
global pathfigs "`pathmain'/Docs/Figures/LPs"
global pathfltx "`pathmain'/Docs/Figures/Latex"
cd $pathdata

use dataspillovers.dta, clear

// Create a business calendar from the current dataset
// bcal create spillovers, from(date) generate(bizdate) purpose(Convert daily data into business calendar dates) replace
bcal load spillovers
gen bizdate = bofd("spillovers",date)
format %tbspillovers bizdate


// Declare panel dataset using business dates
global id imf
global t bizdate
sort $id $t
xtset $id $t

* Express variables and shocks in basis points
foreach v in rho phi nom syn dyq dyp dtp myq myp mtp {
    foreach t in 3 6 12 24 60 120  {
		capture {				// in case not all variables have same tenors
		replace `v'`t'm = 10000*`v'`t'm
		gen d`v'`t'm  = d.`v'`t'm
		}
	}
}

foreach v of varlist mp1 ed4 ed8 onrun10 path lsap {
    cap replace `v' = 100*`v'
}

* horizon in days, number of lags and forward
local horizon = 90
local maxlag  = 1
local maxfwd  = 4


// generate lags for fx: l(0/`maxlag').fx
// generate lags for d.`v'`t'm: l(1/`maxlag').d`v'`t'm  for all v and all t
// generate response variables `v'`t'm`i' for all v and all t
// linear time trend: egen, group($id)
// drop if mp1 == .
// bcal create fmoccal, from(date) generate(fmocdate) purpose(Convert business calendar dates into FMOC dates) replace
// use as controls f(1/`maxfwd').`shock' l(1/`maxlag').`shock'
// don't drop generated variables

foreach k of varlist fx {
	forvalues j = 0/1 {
		cap gen lag`j'_`k' = l`j'.`k'
	}
}

foreach t in 12 120 { // 3 6 12 24 60 120  {
	foreach v in nom syn rho dyp dtp phi {
	
	forvalues j = 1/5 {
		cap gen lag`j'_d`v'`t'm = l`j'.d`v'`t'm
		}
	
	forvalues i = 0/`horizon' {
		// response variables
		cap gen `v'`t'm`i' = (f`i'.`v'`t'm - l.`v'`t'm)
		}
	}
}

drop if mp1 == .
xtset, clear
bcal create fmoccal, from(date) maxgap(60) purpose(Convert business calendar dates into FMOC dates) replace
bcal load fmoccal
gen fmocdate = bofd("fmoccal",date)
format %tbfmoccal fmocdate
sort $id fmocdate
xtset $id fmocdate

pac mp1 if cty == "GBP"
pac path if cty == "GBP"
pac lsap if cty == "GBP"


* x-axis and zero line
cap gen days = _n-1 if _n <= `horizon' +1
cap gen zero = 0 	if _n <= `horizon' +1


* LPs
local j = 0
foreach shock in mp1 path lsap {
	local ++j
	if `j' == 1 local shk "Target"
	if `j' == 2 local shk "Path"
	if `j' == 3 local shk "LSAP"
	
	forvalues group = 0/1 {
		if `group' == 0 {
			local grp "AE"
			local vars nom dyp dtp
		}
		else {
			local grp "EM"
			local vars nom syn rho dyp dtp phi
		}
		
		foreach t in 12 120 { // 3 6 12 24 60 120  {
			foreach v in `vars' {
			
				// variables to store the betas, standard errors and confidence intervals
				capture {
				gen b_`v'`t'm   = .
				gen se_`v'`t'm  = .
				gen ll1_`v'`t'm = .
				gen ul1_`v'`t'm = .
				gen ll2_`v'`t'm = .
				gen ul2_`v'`t'm = .
				}
				
				// controls
				local ctrl`v'`t'm lag1_d`v'`t'm lag2_d`v'`t'm lag3_d`v'`t'm lag4_d`v'`t'm lag5_d`v'`t'm lag0_fx lag1_fx f(1/4).`shock' l(1/4).`shock'
				
				forvalues i = 0/`horizon' {
					// response variables
					capture gen `v'`t'm`i' = (f`i'.`v'`t'm - l.`v'`t'm)
					
					// one regression for each horizon
					if `i' == 0 xtreg `v'`t'm`i' `shock' `ctrl`v'`t'm' if em == `group' & date != td(17sep2001), fe level(95) cluster($id) 			// report on-impact effect
					quiet xtreg `v'`t'm`i' `shock' `ctrl`v'`t'm' if em == `group' & date != td(17sep2001), fe level(95) cluster($id)
					capture{
					replace b_`v'`t'm  = _b[`shock'] if _n == `i'+1
					replace se_`v'`t'm = _se[`shock'] if _n == `i'+1
					
					// confidence intervals
					matrix R = r(table)
					replace ll1_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ll"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					replace ul1_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ul"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					quiet xtreg, level(90)	// to get 90% CI
					matrix R = r(table)
					replace ll2_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ll"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					replace ul2_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ul"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					
					}
				}			// horizon
				
				// graph
				twoway 	(rarea ll1_`v'`t'm ul1_`v'`t'm days, fcolor(gs12) lcolor(white) lpattern(solid)) ///
						(rarea ll2_`v'`t'm ul2_`v'`t'm days, fcolor(gs10) lcolor(white) lpattern(solid)) ///
						(line b_`v'`t'm days, lcolor(black) lpattern(solid) lwidth(thick)) /// 
						(line zero days, lcolor(black)), ///
				title(`: variable label `v'`t'm', color(black) size(medium)) ///
				ytitle("Basis Points", size(medsmall)) xtitle("Days", size(medsmall)) ///
				graphregion(color(white)) plotregion(color(white)) ///
				legend(off) name(`v'`t'm, replace)
				graph export $pathfigs/`shk'/`grp'/`v'`t'm.eps, replace
				
			}			// yield component
		graph drop _all
		}				// tenor
	}					// AE or EM
}						// shock
