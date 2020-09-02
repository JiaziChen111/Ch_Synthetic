* ==============================================================================
* Local projections: US YC
* ==============================================================================
local horizon = 90	// in days
local maxlag  = 1
local j = 0
foreach shock in mp1 path lsap {
	local ++j
	if `j' == 1 {
		local shk "Target"
		local datecond date > td(1jan2000) & date < td(1jan2009)
	}
	if `j' == 2 {
		local shk "Path"
		local datecond date > td(1jan2000) & date < td(1jan2020)
	}
	if `j' == 3 {
		local shk "LSAP"
		local datecond date > td(1jan2009) & date < td(1jan2020)
	}

// levelsof cty, local(levels)
// foreach grp of local levels { // 	foreach group in "AUD" {
		local grp "CHF" // `group'
		local vars usyc usyp ustp
// 		local vars nom sftnom syn sftsyn
		
		foreach t in 24 120 { // 3 6 12 24 60 120  {
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
				local ctrl`v'`t'm l(1/`maxlag').d`v'`t'm	// l(2).`v'`t'm l(1/`maxlag').fx
				
				forvalues i = 0/`horizon' {
					// response variables
					capture gen `v'`t'm`i' = (f`i'.`v'`t'm - l.`v'`t'm)
					
					// conditions
					local condition cty == "`grp'" & `datecond'
					
					// one regression for each horizon
					if `i' == 0 reg `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', level(90) robust 			// report on-impact effect
					quiet reg `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', level(90) robust
					capture {
					replace b_`v'`t'm  = _b[`shock'] if _n == `i'+1
					replace se_`v'`t'm = _se[`shock'] if _n == `i'+1
					
					// confidence intervals
					matrix R = r(table)
					replace ll1_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ll"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					replace ul1_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ul"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					drop `v'`t'm`i'
					}
				}			// horizon
				
				// graph
				twoway 	(line ll1_`v'`t'm days, lcolor(gs6) lpattern(dash)) ///
						(line ul1_`v'`t'm days, lcolor(gs6) lpattern(dash)) ///
						(line b_`v'`t'm days, lcolor(blue*1.25) lpattern(solid) lwidth(thick)) /// 
						(line zero days, lcolor(black)), ///
				title(`: variable label `v'`t'm', color(black) size(medium)) ///
				ytitle("Basis Points", size(medsmall)) xtitle("Days", size(medsmall)) ylabel(-2(1)2) xlabel(0 15 30 45 60 75 90, nogrid) ylabel(, nogrid) ///
				graphregion(color(white)) plotregion(color(white)) ///
				legend(off) name(`v'`t'm, replace)
// 				graph export $pathfigs/LPs/`shk'/CTY/`shk'`grp'`v'`t'm.eps, replace
				
				local graphs`shock'`grp'`t' `graphs`shock'`grp'`t'' `v'`t'm
				drop *_`v'`t'm				// b_, se_ and confidence intervals
			}			// yield component
		
		graph combine `graphs`shock'`grp'`t'', rows(1) ycommon
		graph export $pathfigs/LPs/`shk'/CTY/`shk'USDnomyptp`t'm.eps, replace
		graph drop _all
		}				// tenor
// 	}					// grp (AE, EM, CTY)
}						// shock
