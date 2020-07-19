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

// Time shift
cap gen byte sftcty = !inlist(cty,"CAD","BRL","COP","MXN","PEN")
foreach v of varlist nom* dyp* dtp* {
	cap clonevar sft`v' = `v'
	cap replace sft`v' = f.`v' //if sftcty
}

foreach t in 3 6 12 24 60 120  {
	capture {
	clonevar sftrho`t'm = rho`t'm
	clonevar sftsyn`t'm = syn`t'm
	clonevar sftphi`t'm = phi`t'm
	replace sftrho`t'm = f.rho`t'm
	replace sftsyn`t'm = usyc`t'm + sftrho`t'm
	replace sftphi`t'm = sftnom`t'm - sftsyn`t'm
	}
}

* Express variables and shocks in basis points
foreach v of varlist mp1 ed4 ed8 onrun10 path lsap {
    cap replace `v' = 100*`v'
}

foreach v in usyc rho phi nom syn dyq dyp dtp myq myp mtp sftnom sftsyn {
    foreach t in 3 6 12 24 60 120  {
		capture {				// in case not all variables have same tenors
		replace `v'`t'm = 10000*`v'`t'm
		gen d`v'`t'm  = d.`v'`t'm
		}
	}
}

* horizon in days, number of lags and forward
local horizon = 90
local maxlag  = 1
local maxfwd  = 4


foreach t in 24 120 { // 3 6 12 24 60 120  {
	foreach v in usyc nom sftnom syn sftsyn { // nom syn rho dyp dtp phi
	
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
bcal create fmoccalcty, from(date) maxgap(60) purpose(Convert business calendar dates into FMOC dates) replace
bcal load fmoccalcty
gen fmocdate = bofd("fmoccalcty",date)
format %tbfmoccalcty fmocdate
sort $id fmocdate
xtset $id fmocdate

* x-axis and zero line
cap gen days = _n-1 if _n <= `horizon' +1
cap gen zero = 0 	if _n <= `horizon' +1

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
		local vars nom sftnom syn sftsyn
		
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
				local ctrl`v'`t'm lag1_d`v'`t'm lag2_d`v'`t'm lag3_d`v'`t'm lag4_d`v'`t'm lag5_d`v'`t'm f(1/4).`shock' l(1/4).`shock'
				
				forvalues i = 0/`horizon' {
					
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
				
				drop *_`v'`t'm				// b_, se_ and confidence intervals
			}			// yield component
		
		graph drop _all
		}				// tenor
	}					// grp (AE, EM, CTY)
}						// shock

