local horizon = 90
local maxlag  = 1

* LPs
local j = 0
foreach shock in mp1 { // path lsap {
	local ++j
	if `j' == 1 local shk "Target"
	if `j' == 2 local shk "Path"
	if `j' == 3 local shk "LSAP"

levelsof cty, local(levels)
foreach grp of local levels { // 	foreach group in "AUD" {
// 		local grp "CHF" // `group'
// 		local vars usyc
		local vars sftnom // sftsyn 
		
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
				local ctrl`v'`t'm l(1/`maxlag').d`v'`t'm // l(1/`maxlag').fx
				
				forvalues i = 0/`horizon' {
					// response variables
					capture gen `v'`t'm`i' = (f`i'.`v'`t'm - l.`v'`t'm)
					
					// conditions
					local condition cty == "`grp'" & date > td(1jan2004) & date < td(1jan2016)
					
					// one regression for each horizon
					if `i' == 0 reg `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', level(95) robust 			// report on-impact effect
					quiet reg `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', level(95) robust
					capture {
					replace b_`v'`t'm  = _b[`shock'] if _n == `i'+1
					replace se_`v'`t'm = _se[`shock'] if _n == `i'+1
					
					// confidence intervals
					matrix R = r(table)
					replace ll1_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ll"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					replace ul1_`v'`t'm = el(matrix(R),rownumb(matrix(R),"ul"),colnumb(matrix(R),"`shock'")) if _n == `i'+1
					quiet reg, level(90)	// to get 90% CI
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
				ytitle("Basis Points", size(medsmall)) xtitle("Days", size(medsmall)) ylabel(-1(1)5) xlabel(10(20)90) ///
				graphregion(color(white)) plotregion(color(white)) ///
				legend(off) name(`v'`t'm, replace)
				graph export $pathfigs/`shk'/CTY/`grp'`v'`t'm.eps, replace
				
				local graphs`shock'`grp'`t' `graphs`shock'`grp'`t'' `v'`t'm
				drop *_`v'`t'm				// b_, se_ and confidence intervals
			}			// yield component
		
		graph drop _all
		}				// tenor
	}					// grp (AE, EM, CTY)
}						// shock

