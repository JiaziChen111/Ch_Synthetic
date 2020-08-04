* ==============================================================================
* Clean dataset and generate variables
* ==============================================================================

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

gen byte fomc = mp1 != .
gen byte westhem = inlist(cty,"CAD","BRL","COP","MXN","PEN") // "AUD","CAD","COP","JPY","NZD","MYR"

* Express shocks and variables in basis points
foreach v of varlist mp1 ed4 ed8 onrun10 path lsap {
    replace `v' = 100*`v'
	// 	replace `v' = 0 if `v' == .
}

foreach v in usyc rho phi nom syn dyp dtp { // dyq myq myp mtp {
    foreach t in 12 24 60 120  { // 3 6 	// no problem if not all variables have same tenors since capture
		replace `v'`t'm = 10000*`v'`t'm
		// 	gen d`v'`t'm  = d.`v'`t'm
	}
}

* Time shift
foreach v of varlist nom* dyp* dtp* {
	clonevar sft`v' = `v'
	replace sft`v' = f.`v' // if !westhem
	// 	replace `v' = f.`v' if !westhem
}

foreach t in 12 24 60 120  { // 3 6 
	clonevar sftrho`t'm = rho`t'm
	clonevar sftsyn`t'm = syn`t'm
	clonevar sftphi`t'm = phi`t'm
	replace  sftrho`t'm = f.rho`t'm
	replace  sftsyn`t'm = usyc`t'm + sftrho`t'm
	replace  sftphi`t'm = sftnom`t'm - sftsyn`t'm
	
	clonevar sftnomx`t'm = nom`t'm
	clonevar sftrhox`t'm = rho`t'm
	clonevar sftsynx`t'm = syn`t'm
	clonevar sftphix`t'm = phi`t'm
	
	replace  sftnomx`t'm = f.nom`t'm if !westhem
	replace  sftrhox`t'm = f.rho`t'm if westhem
	replace  sftsynx`t'm = usyc`t'm + f.rho`t'm if westhem
	replace  sftsynx`t'm = f.usyc`t'm + rho`t'm if !westhem
	replace  sftphix`t'm = sftnomx`t'm - sftsynx`t'm
}


* Compute monthly returns (in basis points)
gen logspx = ln(spx)
gen logvix = ln(vix)
gen logoil = ln(oil)
gen logccy = ln(fx)
gen logstx = ln(stx)
by $id: gen rtspx = (logspx - logspx[_n-1])*10000
by $id: gen rtoil = (logoil - logoil[_n-1])*10000
by $id: gen rtfx  = (logccy - logccy[_n-1])*10000
by $id: gen rtstx = (logstx - logstx[_n-1])*10000

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
               2 * (!inlist(cty,"GBP","EUR","JPY") & em == 0)
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
