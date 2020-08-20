
cd "/Users/Pavel/Documents/GitHub/Book/Ch_Synthetic"	// Update as necessary
local pathmain `c(pwd)'

// global pathdlfs "/Users/Pavel/Dropbox/Dissertation/Book-DB-Sync/Ch_Synt-DB/Codes-DB/August-2020"
global pathdata "`pathmain'/Data/Analytic"
global pathcode "`pathmain'/Codes/Analysis"
global pathtbls "`pathmain'/Docs/Tables"
global pathfigs "`pathmain'/Docs/Figures"
cd $pathdata

global file_src  "$pathdata/datarho.xlsx"
global file_dta1 "$pathdata/datarho1.dta"	// original dataset
global file_dta2 "$pathdata/datarho2.dta"	// dataset after housekeeping
global file_log  "$pathtbls/impact_regs"
global file_tbl  "$pathtbls/impact_tbls"

import excel using $file_src, clear firstrow case(lower)
save $file_dta1, replace


use $file_dta1, clear

gen date  = dofc(time)
gen datem = mofd(dofc(time))					// used to label graphs
format date %td
format datem %tmCCYY
order date, first
drop  time
order cty, after(date)

* Create a business calendar from the current dataset
capture {
// bcal create spillovers, from(date) purpose(Convert daily data into business calendar dates) replace
bcal load spillovers
gen bizdate = bofd("spillovers",date)
format %tbspillovers bizdate
}

* Declare panel dataset using business dates
global id imf
global t bizdate
sort  $id $t
xtset $id $t


// capture {

* Express shocks and variables in basis points
gen byte fomc = mp1 != .
foreach v of varlist mp1 ed4 ed8 onrun10 path lsap {
    replace `v' = 100*`v'
	// 	replace `v' = 0 if `v' == .
}

foreach v in rho {
    foreach t in 3 6 12 24 60 120  {
		replace `v'`t'm = 100*`v'`t'm	// in percent not in decimals
	}
}

* Time shift
foreach t in 3 6 12 24 60 120  {
	clonevar sftrho`t'm = rho`t'm
	replace  sftrho`t'm = f.rho`t'm
	
	clonevar lagrho`t'm = rho`t'm
	replace  lagrho`t'm = l.rho`t'm
}

* x-axis and zero line
global horizon = 90	// in days
gen days = _n-1 if _n <= $horizon +1
gen zero = 0 	if _n <= $horizon +1


* Create regional and block variables
gen regionem = 1 * inlist(cty,"BRL","COP","MXN","PEN") + ///
               2 * inlist(cty,"HUF","PLN","RUB","TRY") + ///
               3 * inlist(cty,"IDR","MYR","PHP","THB") + ///
			   4 * inlist(cty,"ILS","KRW","ZAR")
label define rnames 1 "Latin America" 2 "Eastern Europe" 3 "Southeast Asia" 4 "Other"
label values regionem rnames
label variable regionem "EM Regions"

gen regionae = 1 * inlist(cty,"GBP","EUR","JPY") + ///
               2 * (!inlist(cty,"GBP","EUR","JPY") & regionem == 0)
label define bnames 1 "Non-US G3" 2 "A-SOE"
label values regionae bnames
label variable regionae "AE Blocks"

// }	// capture


* Label variables that will be used in figures and tables
#delimit ;
local oldlabels mp1 path lsap;
local newlabels `" "Target" "Path" "LSAP" "';
#delimit cr
local nlbls : word count `oldlabels'
forvalues i = 1/`nlbls' {
	local a : word `i' of `oldlabels'
	local b : word `i' of `newlabels'
	label variable `a' "`b'"
}

save $file_dta2, replace

do "$pathcode/lp_country"
