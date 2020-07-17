
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

local  file_src "$pathdata/dataspillovers"
local  file_dta "$pathdata/dataspillovers.dta"
local  file_ssn "$pathtbls/impact_regs"
global file_out "$pathtbls/impact_tbls"


use `file_dta', clear

// Create a business calendar from the current dataset
// bcal create spillovers, from(date) purpose(Convert daily data into business calendar dates) replace
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
// 	clonevar sft`v' = `v'
	cap replace `v' = f.`v' if sftcty
}

foreach t in 3 6 12 24 60 120  {
	cap gen sftrho`t'm = f.rho`t'm
	cap gen sftsyn`t'm = usyc`t'm + sftrho`t'm
	cap gen sftphi`t'm = nom`t'm - sftsyn`t'm
}

	
* Express shocks and variables in basis points
foreach v of varlist mp1 ed4 ed8 onrun10 path lsap {
    cap replace `v' = 100*`v'
}

foreach v in usyc rho phi nom syn dyq dyp dtp sftrho sftsyn sftphi { // myq myp mtp {
    foreach t in 3 6 12 24 60 120  {
		capture {				// in case not all variables have same tenors
		replace `v'`t'm = 10000*`v'`t'm
		gen d`v'`t'm  = d.`v'`t'm
		
// 		if "`v'" == "phi" {		// censor the credit risk premium at zero
// 			gen `v'cns`t'm = `v'`t'm
// 			replace `v'cns`t'm = 0 if `v'`t'm < 0 & em == 1		// only for EMs
// 			gen d`v'cns`t'm  = d.`v'cns`t'm
// 			}
		}
	}
}


* horizon in days, number of lags and forward
local horizon = 90
local maxlag  = 1

* x-axis and zero line
cap gen days = _n-1 if _n <= `horizon' +1
cap gen zero = 0 	if _n <= `horizon' +1


// Create regional variable
gen region = 1 * inlist(cty,"BRL","COP","MXN","PEN") + ///
             2 * inlist(cty,"HUF","PLN","RUB","TRY") + ///
             3 * inlist(cty,"IDR","MYR","PHP","THB") + ///
			 4 * inlist(cty,"ILS","KRW","ZAR")
label define rnames 1 "Latin America" 2 "Eastern Europe" 3 "Southeast Asia" 4 "Other"
label values region rnames
label variable region "Regions"


* Record session
log using `file_ssn', replace

* LPs
local j = 0
foreach shock in mp1 { // path lsap {
	local ++j
	if `j' == 1 local shk "Target"
	if `j' == 2 local shk "Path"
	if `j' == 3 local shk "LSAP"
	
	foreach group in 1 { // 0 1 {
		if `group' == 0 {
			local grp "AE"
			local vars nom sftsyn // dyp dtp
		}
		else {
			local grp "EM"
			local vars nom sftsyn sftrho sftphi // dyp dtp usyc syn rho phi
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
				local ctrl`v'`t'm l(1/`maxlag').d`v'`t'm l(1/`maxlag').fx
				
				forvalues i = 0/`horizon' {
					// response variables
					capture gen `v'`t'm`i' = (f`i'.`v'`t'm - l.`v'`t'm)
					
					// conditions
					local condition em == `group' // !inlist(cty,"AUD","NZD") // & region == 3
					
// 					// test for cross-sectional independence
// 					if inlist(`i',0,30,60,90) { 
// 						quiet xtreg `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', fe	// exclude meeting after 9/11
// 						xtcsd, pesaran abs
// 					}
					
					// one regression for each horizon
					if `i' == 0 xtreg `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', fe level(95) cluster($id) 			// report on-impact effect
// 					if `i' == 0 xtscc `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', fe level(95) lag(4)
					quiet xtreg `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', fe level(95) cluster($id)
// 					quiet xtscc `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', fe level(95)  lag(4)
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
				ytitle("Basis Points", size(medsmall)) xtitle("Days", size(medsmall)) ylabel(-1(1)5) xlabel(10(20)90) ///
				graphregion(color(white)) plotregion(color(white)) ///
				legend(off) name(`v'`t'm, replace)
				graph export $pathfigs/`shk'/`grp'/`v'`t'm.eps, replace
				
				local graphs`shock'`grp'`t' `graphs`shock'`grp'`t'' `v'`t'm
				drop *_`v'`t'm				// b_, se_ and confidence intervals
			}			// yield component
		
		graph combine `graphs`shock'`grp'`t'', rows(1) ycommon ///
		title("`shock' `grp' `t'm")
		graph export $pathfigs/`shk'/`grp'/`shk'`grp'`v'`t'm.eps, replace
		
		graph drop _all
		}				// tenor
	}					// AE or EM
}						// shock

log close
translate `file_ssn'.smcl `file_ssn'.pdf, replace






// Extract US MPS
// browse date mp1 path lsap if cty == "GBP" & mp1 != .

// Assess censored LCCS
// bysort region: summ phi120m phicns120m // compare phi uncensored and censored
// sort $id $t
// line phi120m phicns120m datem if cty == "RUB"

// // Potential local events
// list date cty dnom120m dsyn120m ddtp120m ddyp120m dphi120m if cty == "BRL" & inlist(date,td(19oct2009),td(04oct2010),td(06jan2011),td(06jul2011),td(08jul2011),td(04jun2013))
// list date cty dnom120m dsyn120m ddtp120m ddyp120m dphi120m if cty == "COP" & inlist(date,td(01dec2004),td(29jun2006),td(10may2007),td(19jul2007),td(06oct2008))
// list date cty dnom120m dsyn120m ddtp120m ddyp120m dphi120m if cty == "HUF" & inlist(date,td(09apr2003),td(14apr2003),td(16apr2003),td(01aug2005),td(01sep2018))
// list date cty dnom120m dsyn120m ddtp120m ddyp120m dphi120m if cty == "IDR" & inlist(date,td(01jul2005),td(01jun2010))
// list date cty dnom120m dsyn120m ddtp120m ddyp120m dphi120m if cty == "KRW" & inlist(date,td(01jan2003),td(14jun2010))
// list date cty dnom120m dsyn120m ddtp120m ddyp120m dphi120m if cty == "PHP" & inlist(date,td(01jan2002),td(28jul2017))
// list date cty dnom120m dsyn120m ddtp120m ddyp120m dphi120m if cty == "PLN" & inlist(date,td(09apr2003),td(14apr2003),td(16apr2003),td(07jun2003),td(28jul2017),td(01dec2017),td(01mar2018))
// list date cty dnom120m dsyn120m ddtp120m ddyp120m dphi120m if cty == "RUB" & inlist(date,td(27sep2013),td(01jan2014))
// list date cty dnom120m dsyn120m ddtp120m ddyp120m dphi120m if cty == "THB" & inlist(date,td(01dec2006))
// list date cty dnom120m dsyn120m ddtp120m ddyp120m dphi120m if cty == "TRY" & inlist(date,td(02jan2006),td(27jan2017),td(25jun2018),td(02oct2018),td(08jul2019))


// // Selected local events
// list date cty dnom120m dsyn120m ddtp120m ddyp120m dphi120m if cty == "TRY" & inlist(date,td(25jun2018),td(02oct2018),td(08jul2019))


// Large US MP shocks
// browse date cty dnom120m dsyn120m drho120m dusyc120m if inlist(date,td(17mar2009),td(18mar2009),td(19mar2009))
// browse date cty dnom120m dsyn120m drho120m dusyc120m if inlist(date,td(15dec2008),td(16dec2008),td(17dec2008))
// browse date cty dnom120m dsyn120m drho120m dusyc120m if inlist(date,td(08aug2011),td(09aug2011),td(10aug2011))
// browse date cty dnom120m dsyn120m drho120m dusyc120m if inlist(date,td(17sep2013),td(18sep2013),td(19sep2013))
// browse date cty dnom120m dsyn120m drho120m dusyc120m if inlist(date,td(27jan2004),td(28jan2004),td(29jan2004))
// browse date cty dnom120m dsyn120m drho120m dusyc120m if inlist(date,td(05may2003),td(06may2003),td(07may2003))
// browse date cty dnom120m dsyn120m drho120m dusyc120m if inlist(date,td(17mar2015),td(18mar2015),td(19mar2015))
// browse date cty dnom120m dsyn120m drho120m dusyc120m if inlist(date,td(14mar2017),td(15mar2017),td(16mar2017))




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

// Standard errors corrected for heteroskedasticity and autocorrelation
// https://www.statalist.org/forums/forum/general-stata-discussion/general/
// 1475615-newey-regression-for-panel-data

// Accesssing values of confidence intervals
// https://www.statalist.org/forums/forum/general-stata-discussion/general/
// 1304264-quickly-accessing-p-values-and-confidence-interval-limits

// Accessing values in a matrix identified by row name and column name
// https://www.stata.com/statalist/archive/2009-03/msg01179.html

// Handling gaps in time series using business calendars
// https://blog.stata.com/2016/02/04/handling-gaps-in-time-series-using-business-calendars/
// https://www.stata.com/manuals13/dbcal.pdf
// https://www.stata.com/manuals13/tstsset.pdf
// https://www.stata.com/statalist/archive/2005-08/msg00479.html

// Time trend in panel data
// https://www.statalist.org/forums/forum/general-stata-discussion/general/1317069-time-trend-in-panel-data

// Country-specific time trends
// https://www.statalist.org/forums/forum/general-stata-discussion/general/1376523-country-specific-time-trends

// Create a group variable
// https://www.statalist.org/forums/forum/general-stata-discussion/general/
// 1355976-how-can-i-create-groups-of-observations-in-a-panel-data





* Packages
// ssc install xtcsd, replace	// to perform the Pesaran’s CD test of cross-sectional independence in FE panel models
// ssc install xtscc, replace	// to get DK standard errors for FE panel models



// * specify significance levels
// scalar sig1 = 0.05	 // 95% confidence interval
// scalar sig2 = 0.1	 // 90% confidence interval

// after horizon loop
// // confidence intervals
// capture {
// gen cih1_`v'`t'm = b_`v'`t'm + invnormal(1-sig1/2)*se_`v'`t'm if _n <= (`horizon' + 1)
// gen cil1_`v'`t'm = b_`v'`t'm - invnormal(1-sig1/2)*se_`v'`t'm if _n <= (`horizon' + 1)

// gen cih2_`v'`t'm = b_`v'`t'm + invnormal(1-sig2/2)*se_`v'`t'm if _n <= (`horizon' + 1)
// gen cil2_`v'`t'm = b_`v'`t'm - invnormal(1-sig2/2)*se_`v'`t'm if _n <= (`horizon' + 1)
// }


// clonevar sftnom120m = nom120m
// replace sftnom120m = f.nom120m if sftcty
// list nom120m if nom120m != sftnom120m
