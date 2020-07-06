
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

global id imf
global t date
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
    replace `v' = 100*`v'
}

* horizon in days, number of lags and forward
local horizon = 90
local maxlag  = 1
local maxfwd  = 4

* specify significance levels
scalar sig1 = 0.05	 // 95% confidence interval
scalar sig2 = 0.1	 // 90% confidence interval

* x-axis and zero line
gen days = _n-1 if _n <= `horizon' +1
gen zero = 0 	if _n <= `horizon' +1

* LPs
local j = 0
foreach shock in mp1 { //path lsap {
	local ++j
	if `j' == 1 local shk "Target"
	if `j' == 2 local shk "Path"
	if `j' == 3 local shk "LSAP"
	
	forvalues group = 0/1 {
		if `group' == 0 local grp "AE"
		else local grp "EM"
		
		foreach t in 120 { // 3 6 12 24 60 120  {
			foreach v in nom { //syn dyp dtp phi {

				// variables to store the betas, standard errors and confidence intervals
				capture gen b_`v'`t'm  = .
				capture gen se_`v'`t'm = .
				
				capture gen ll1_`v'`t'm = .
				capture gen ul1_`v'`t'm = .
				capture gen ll2_`v'`t'm = .
				capture gen ul2_`v'`t'm = .
				
				// controls
				local ctrl`v'`t'm l(1/`maxlag').d`v'`t'm l(0/`maxlag').fx 	// f(1/`maxfwd').`shock' l(1/`maxlag').`shock'
				
				forvalues i = 0/`horizon' {
					// response variables
					capture gen `v'`t'm`i' = (f`i'.`v'`t'm - l.`v'`t'm)
					
// 					// test for cross-sectional independence
// 					if inlist(`i',0,30,60,90) { 
// 						quiet xtreg `v'`t'm`i' `shock' `ctrl`v'`t'm' if em == `group' & date != td(17sep2001), fe	// exclude meeting after 9/11	// regress, level(90)
// 						xtcsd, pesaran abs
// 					}
					
					// one regression for each horizon
					quiet xtreg `v'`t'm`i' `shock' `ctrl`v'`t'm' if em == `group' & date != td(17sep2001), fe cluster($id) level(95)
// 					quiet xtscc `v'`t'm`i' `shock' `ctrl`v'`t'm' if em == `group' & date != td(17sep2001), fe level(95)
					capture{
					replace b_`v'`t'm  = _b[`shock'] if _n == `i'+1
					replace se_`v'`t'm = _se[`shock'] if _n == `i'+1
					
					// confidence intervals
					matrix R = r(table)
					replace ll1_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ll"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					replace ul1_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ul"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					quiet xtreg, level(90)	// to get 90% CI
// 					quiet xtscc, level(90)	// to get 90% CI
					matrix R = r(table)
					replace ll2_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ll"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					replace ul2_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ul"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					
					*drop `v'`t'm`i'
					}
				}			// horizon
				
// 				// confidence intervals
// 				capture {
// 				gen cih1_`v'`t'm = b_`v'`t'm + invnormal(1-sig1/2)*se_`v'`t'm if _n <= (`horizon' + 1)
// 				gen cil1_`v'`t'm = b_`v'`t'm - invnormal(1-sig1/2)*se_`v'`t'm if _n <= (`horizon' + 1)

// 				gen cih2_`v'`t'm = b_`v'`t'm + invnormal(1-sig2/2)*se_`v'`t'm if _n <= (`horizon' + 1)
// 				gen cil2_`v'`t'm = b_`v'`t'm - invnormal(1-sig2/2)*se_`v'`t'm if _n <= (`horizon' + 1)
// 				}
				
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
				
				*drop *_`v'`t'm				// b_, se_ and confidence intervals
			}			// yield component
		graph drop _all
		}				// tenor
	}					// AE or EM
}						// shock



/*	
graph combine mortgdp_LP.gph gdp_LP.gph, col(2) iscale(1) ycommon ///
title("Local Projection Responses Using OLS")
graph save OLS_LP.gph, replace

graph combine OLS_LP.gph IV_LP.gph, col(1) row(2) iscale(0.5) ysize(6) ///
title("Local Projection Example: OLS v IV")
graph save LP.gph, replace

graph export LP.pdf, replace
*/

* Sources
// https://www.statalist.org/forums/forum/general-stata-discussion/general/
// 1475615-newey-regression-for-panel-data

* Packages
// ssc install xtcsd, replace	// to perform the Pesaran’s CD test of cross-sectional independence in FE panel models
// ssc install xtscc, replace	// to get DK standard errors for FE panel models
