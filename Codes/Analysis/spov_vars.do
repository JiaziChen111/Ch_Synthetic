* ==============================================================================
* Clean dataset and generate variables
* ==============================================================================

use $file_dta1, clear


* Dates in Stata format
gen date  = dofc(time)
gen datem = mofd(dofc(time))					// used to label graphs
format date %td
format datem %tmCCYY
order  date, first
drop   time
order  cty, after(date)


* Business calendar based on current dataset
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


* Compute monetary policy shocks
rename path pathold
rename lsap lsapold
reg ed8 mp1 
predict path, r
reg onrun10 mp1 path 
predict lsap, r
corr path pathold // if cty == "CHF"
corr lsap lsapold // if cty == "CHF"
	// very highly correlated, path 0.9995 and lsap 0.9943
drop pathold lsapold ed4 ed8 onrun10
order path lsap, after(mp1)


* Express variables from percent to basis points
gen byte fomc = mp1 != .
foreach v of varlist mp1 path lsap {
    replace `v' = `v'*100
	replace `v' = 0 if `v' == .
}

foreach v of varlist ffr ustp* usyp* usrr* { // scbp* scpi* sgdp* 
    replace `v' = `v'*100
}


* Express variables from decimals to basis points
foreach v of varlist usyc* nom* syn* rho* phi* dyp* dtp* myp* mtp* stp* rrt* {
    replace `v' = `v'*10000
}


* Generate first differences
foreach v of varlist usyc* ustp* usyp* nom* syn* rho* phi* dyp* dtp* {
	gen d`v' = d.`v'
}


* x-axis and zero line
gen days = _n-1 if _n <= 90 +1
gen zero = 0 	if _n <= 90 +1


* Define regions and groups
gen regionem = 1 * inlist(cty,"BRL","COP","MXN","PEN") + ///
               2 * inlist(cty,"HUF","PLN","RUB") + ///
               3 * inlist(cty,"IDR","KRW","MYR","PHP","THB") + ///
			   4 * inlist(cty,"ILS","TRY","ZAR")
label define rnames 1 "Latin America" 2 "Emerging Europe" 3 "Emerging Asia" 4 "MEA"
label values regionem rnames
label variable regionem "EM Regions"

gen regionae = 1 * inlist(cty,"GBP","EUR","JPY") + ///
               2 * (!inlist(cty,"GBP","EUR","JPY") & em == 0)
label define bnames 1 "Non-US G3" 2 "A-SOE"
label values regionae bnames
label variable regionae "AE Blocks"


* Label variables for use in figures and tables
#delimit ;
unab oldlabels : mp1 path lsap sdprm gdp inf une 
				 epugbl globalip nom* syn* rho* phi* dyp* dtp* usyc* ustp* usyp*;
local newlabels `" "Target" "Path" "LSAP" "UCSV-Perm" "GDP Growth" "Inflation" "Unempl." 
	"Global EPU" "Global IP" "Yield" "Yield" "Yield" "Yield" "Yield" "Yield" "Synthetic" "Synthetic" 
	"Synthetic" "Synthetic" "Synthetic" "Synthetic" "Forward Premium" "Forward Premium" "Forward Premium" 
	"Forward Premium" "Forward Premium" "Forward Premium" "Credit Risk" "Credit Risk P." "Credit Risk P." 
	"Credit Risk P." "Credit Risk P." "Credit Risk P." "E. Short Rate" "E. Short Rate" "E. Short Rate" 
	"E. Short Rate" "E. Short Rate" "E. Short Rate" "Term Premium" "Term Premium" "Term Premium" 
	"Term Premium" "Term Premium" "Term Premium" "Yield" "Yield" "Yield" 
	"Yield" "Yield" "Yield" "Term Premium" "Term Premium" "Term Premium" "Term Premium" 
	"Expected Short Rate" "Expected Short Rate" "Expected Short Rate" "Expected Short Rate" "';
#delimit cr
local nlbls : word count `oldlabels'
forvalues i = 1/`nlbls' {
	local a : word `i' of `oldlabels'
	local b : word `i' of `newlabels'
	label variable `a' "`b'"
}

save $file_dta2, replace
