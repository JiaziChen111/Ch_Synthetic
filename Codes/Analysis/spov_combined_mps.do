* ==============================================================================
* Local projections
* ==============================================================================

use $file_dta2, clear

* Adjust target and LSAP shocks
replace mp1  = 0 if date >= td(1jan2009)
replace lsap = 0 if date <  td(1jan2009)


local horizon = 90	// in days
local maxlag  = 1

foreach group in 0 1 {
	if `group' == 0 {
		local grp "AE"
		local vars nom dyp dtp phi // nom usyc rho phi	//  nom syn rho phi	// rho
		local region regionae
	}
	else {
		local grp "EM"
		local vars nom dyp dtp phi // nom usyc rho phi	//	nom syn rho phi	// rho
		local region regionem
	}
	
	foreach t in 24 120 { // 3 6 12 24 60 120  {
		local ty = `t'/12
		foreach v in `vars' {
		
			// variables to store the betas, standard errors and confidence intervals
			capture {
			
			foreach shock in mp1 path lsap {
				gen b_`shock'_`v'`t'm   = .
				gen se_`shock'_`v'`t'm  = .
				gen ll1_`shock'_`v'`t'm = .
				gen ul1_`shock'_`v'`t'm = .
			}	// `shock'
			
			}
			
			// controls
			local ctrl`v'`t'm l(1/`maxlag').d`v'`t'm l(1/`maxlag').fx	// l(2).`v'`t'm l(1).fx
			
			forvalues i = 0/`horizon' {
				// response variables
				capture gen `v'`t'm`i' = (f`i'.`v'`t'm - l.`v'`t'm)
				
				// conditions
				local condition em == `group' //	& `datecond' & `region' == 4
				
// 					// test for cross-sectional independence
// 					if inlist(`i',0) { 
// 						quiet xtreg `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition' & fomc, fe
// 						xtcsd, pesaran abs
// 					}
				
				// one regression for each horizon
				if `i' == 0 xtreg `v'`t'm`i' mp1 path lsap `ctrl`v'`t'm' if `condition', fe level(90) cluster($id) 			// report on-impact effect
// 					if `i' == 0 xtscc `v'`t'm`i' mp1 path lsap `ctrl`v'`t'm' if `condition', fe level(95) lag(4)
				quiet xtreg `v'`t'm`i' mp1 path lsap `ctrl`v'`t'm' if `condition', fe level(90) cluster($id)
// 					quiet xtscc `v'`t'm`i' mp1 path lsap `ctrl`v'`t'm' if `condition', fe level(95) lag(4)
				capture {
				
				foreach shock in mp1 path lsap {
					replace b_`shock'_`v'`t'm  = _b[`shock'] if _n == `i'+1
					replace se_`shock'_`v'`t'm = _se[`shock'] if _n == `i'+1
					
					// confidence intervals
					matrix R = r(table)
					replace ll1_`shock'_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ll"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					replace ul1_`shock'_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ul"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
				}	// `shock'
				
				drop `v'`t'm`i'
				}
			}			// `i' horizon

			
			foreach shock in mp1 path lsap {
				// graph
				twoway 	(line ll1_`shock'_`v'`t'm days, lcolor(gs6) lpattern(dash)) ///
						(line ul1_`shock'_`v'`t'm days, lcolor(gs6) lpattern(dash)) ///
						(line b_`shock'_`v'`t'm days, lcolor(blue*1.25) lpattern(solid) lwidth(thick)) /// 
						(line zero days, lcolor(black)), ///
				ytitle("Basis Points", size(medsmall)) xtitle("Days", size(medsmall)) xlabel(0 15 30 45 60 75 90, nogrid) ylabel(, nogrid) ///
				graphregion(color(white)) plotregion(color(white)) legend(off) name(`v'`t'm, replace) ///
				title(`: variable label `v'`t'm', color(black) size(medium))
// 				title(`ty'Y, color(black) size(medium))						// for rho version

// 				graph export $pathfigs/LPs/`shk'/`grp'/`v'`t'm.eps, replace

				local graphs`shock'`grp'`t' `graphs`shock'`grp'`t'' `v'`t'm
// 				local graphs`shock'`grp' `graphs`shock'`grp'' `v'`t'm		// for rho version
			}	// `shock'

			drop *_`v'`t'm				// b_, se_ and confidence intervals
		}			// `v' yield component
	
	local j = 0
	foreach shock in mp1 path lsap {
		local ++j
		if `j' == 1 local shk "Target"
		if `j' == 2 local shk "Path"
		if `j' == 3 local shk "LSAP"
		graph combine `graphs`shock'`grp'`t'', rows(1) ycommon
		graph export $pathfigs/LPs/`shk'/`grp'/`shk'`grp'`t'm.eps, replace
	}	// `shock'
	graph drop _all
	}				// `t' tenor

// 		local j = 0															// for rho version
// 		foreach shock in mp1 path lsap {
// 			local ++j
// 			if `j' == 1 local shk "Target"
// 			if `j' == 2 local shk "Path"
// 			if `j' == 3 local shk "LSAP"
// 			graph combine `graphs`shock'`grp'', rows(1) ycommon
// 			graph export $pathfigs/LPs/`shk'/`grp'/`shk'`grp'rho.eps, replace
// 		}	// `shock'
// 		graph drop _all
}					// `group' AE or EM
