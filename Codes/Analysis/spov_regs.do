* ==============================================================================
* Local projections
* ==============================================================================

local j = 0
foreach shock in mp1 { // path lsap {
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
	
	foreach group in 0 { // 1 {
		if `group' == 0 {
			local grp "AE"
			local vars sftnom sftsyn sftrho sftphi // nom syn dyp dtp sftdyp sftdtp
			local region regionae
		}
		else {
			local grp "EM"
			local vars sftnom sftsyn sftrho sftphi // nom dyp dtp usyc syn rho phi
			local region regionem
		}
		
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
				local ctrl`v'`t'm l(2).`v'`t'm l(1).fx 	// l(1/`maxlag').d`v'`t'm l(1/`maxlag').fx
				
				forvalues i = 0/$horizon {
					// response variables
					capture gen `v'`t'm`i' = (f`i'.`v'`t'm - l.`v'`t'm)
					
					// conditions
					local condition em == `group' & `datecond' // & `region' == 4
					
// 					// test for cross-sectional independence
// 					if inlist(`i',0) { 
// 						quiet xtreg `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition' & fomc, fe
// 						xtcsd, pesaran abs
// 					}
					
					// one regression for each horizon
					if `i' == 0 xtreg `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', fe level(95) cluster($id) 			// report on-impact effect
// 					if `i' == 0 xtscc `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', fe level(95) lag(4)
					quiet xtreg `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', fe level(95) cluster($id)
// 					quiet xtscc `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', fe level(95) lag(4)
					capture {
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
					
					drop `v'`t'm`i'
					}
				}			// horizon
				
				// graph
				twoway 	(rarea ll1_`v'`t'm ul1_`v'`t'm days, fcolor(gs12) lcolor(white) lpattern(solid)) ///
						(rarea ll2_`v'`t'm ul2_`v'`t'm days, fcolor(gs10) lcolor(white) lpattern(solid)) ///
						(line b_`v'`t'm days, lcolor(black) lpattern(solid) lwidth(thick)) /// 
						(line zero days, lcolor(black)), ///
				title(`: variable label `v'`t'm', color(black) size(medium)) ///
				ytitle("Basis Points", size(medsmall)) xtitle("Days", size(medsmall)) xlabel(0 15 30 45 60 75 90) ///
				graphregion(color(white)) plotregion(color(white)) ///
				legend(off) name(`v'`t'm, replace)
// 				graph export $pathfigs/LPs/`shk'/`grp'/`v'`t'm.eps, replace
				
				local graphs`shock'`grp'`t' `graphs`shock'`grp'`t'' `v'`t'm
				drop *_`v'`t'm				// b_, se_ and confidence intervals
			}			// yield component
		
		graph combine `graphs`shock'`grp'`t'', rows(1) ycommon ///
		title("`shock' `grp' `t'm")
		graph export $pathfigs/LPs/`shk'/`grp'/`shk'`grp'`v'`t'm.eps, replace
		
		graph drop _all
		}				// tenor
	}					// AE or EM
}						// shock
