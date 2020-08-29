* ==============================================================================
* Local projections: Forward premium
* ==============================================================================
use $file_dta2, clear


* Define local variables
local xtcmd xtscc				// xtreg
local xtopt fe level(90) lag(4)	// fe level(90) cluster($id)
local horizon = 90	// in days
local maxlag  = 1
local vars rho

foreach group in 0 1 {
	if `group' == 0 {
		local grp "AE"
		local region regionae
	}
	else {
		local grp "EM"
		local region regionem
	}
	
	// regressions
	foreach t in 24 120 { // 3 6 12 24 60 120  {
		foreach v in `vars' {
		
			// variables to store the betas and confidence intervals
			capture {
			foreach shock in mp1 path lsap {
				gen b_`shock'_`v'`t'm   = .
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
				
				// one regression for each horizon
				if `i' == 0 `xtcmd' `v'`t'm`i' mp1 path lsap `ctrl`v'`t'm' if `condition', `xtopt'	// on-impact effect
				quiet `xtcmd' `v'`t'm`i' mp1 path lsap `ctrl`v'`t'm' if `condition', `xtopt'

				capture {				
				foreach shock in mp1 path lsap {
					replace b_`shock'_`v'`t'm  = _b[`shock'] if _n == `i'+1
					
					// confidence intervals
					matrix R = r(table)
					replace ll1_`shock'_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ll"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					replace ul1_`shock'_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ul"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
				}	// `shock'
				drop `v'`t'm`i'
				}
			}			// `i' horizon
		}			// `v' yield component
	}			// `t' tenor
	
	// graphs
	local j = 0
	foreach shock in mp1 path lsap {
		local ++j
		if `j' == 1 local shk "Target"
		if `j' == 2 local shk "Path"
		if `j' == 3 local shk "LSAP"
		
		foreach t in 24 120 { // 3 6 12 24 60 120  {
			local ty = `t'/12
			foreach v in `vars' {
			twoway 	(line ll1_`shock'_`v'`t'm days, lcolor(gs6) lpattern(dash)) ///
					(line ul1_`shock'_`v'`t'm days, lcolor(gs6) lpattern(dash)) ///
					(line b_`shock'_`v'`t'm days, lcolor(blue*1.25) lpattern(solid) lwidth(thick)) /// 
					(line zero days, lcolor(black)), ///
			ytitle("Basis Points", size(medsmall)) xtitle("Days", size(medsmall)) xlabel(0 15 30 45 60 75 90, nogrid) ylabel(, nogrid) ///
			graphregion(color(white)) plotregion(color(white)) legend(off) name(`v'`t'm, replace) ///
			title(`ty' Years, color(black) size(medium))				// for rho version

// 				graph export $pathfigs/LPs/`shk'/`grp'/`v'`t'm.eps, replace
			local graphs`shock'`grp' `graphs`shock'`grp'' `v'`t'm		// for rho version
			
			drop *_`shock'_`v'`t'm				// b_ and confidence intervals
			}	// `v' yield component
		}	// `t' tenor

		graph combine `graphs`shock'`grp'', rows(1) ycommon				// for rho version
		graph export $pathfigs/LPs/`shk'/`grp'/`shk'`grp'rho.eps, replace
		graph drop _all
	}		// `shock'
	
}				// `group' AE or EM
