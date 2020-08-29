* ==============================================================================
* Local projections: AE and EM
* ==============================================================================
use $file_dta2, clear


* Define local variables
local horizon = 90	// in days
local maxlag  = 1

foreach group in 0 1 {
	if `group' == 0 {
		local grp "AE"
		local vars nom dyp dtp phi // nom usyc rho phi	//  nom syn rho phi
		local region regionae
	}
	else {
		local grp "EM"
		local vars nom dyp dtp phi // nom usyc rho phi	//	nom syn rho phi
		local region regionem
	}
	
	foreach t in 24 120 { // 3 6 12 24 60 120  {
		// regressions
		foreach v in `vars' {
			
			// controls
			local ctrl`v'`t'm l(1/`maxlag').d`v'`t'm l(1/`maxlag').fx
			
			foreach i in 0 30 60 `horizon' {
				// response variables
				capture gen `v'`t'm`i' = (f`i'.`v'`t'm - l.`v'`t'm)
				
				// conditions
				local condition em == `group' & fomc	// & `region' == 4
				
				// test for cross-sectional independence
				quiet xtreg `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', fe
				xtcsd, pesaran abs
				
				capture drop `v'`t'm`i'
			}			// `i' horizon
		}			// `v' yield component
		
	}			// `t' tenor
}				// `group' AE or EM
