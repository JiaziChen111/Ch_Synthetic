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

foreach v of varlist ustp* usyp* usrr* { // scbp* scpi* sgdp* 
    replace `v' = `v'*100
}


* Express variables from decimals to basis points
foreach v of varlist usyc* nom* syn* rho* phi* dyp* dtp* myp* mtp* stp* rrt* {
    replace `v' = `v'*10000
}

// foreach v in usyc nom syn rho phi dyp dtp myp mtp stp rrt {
//     foreach t in 3 6 12 24 60 120 {
// 		replace `v'`t'm = 10000*`v'`t'm
// 		// 	gen d`v'`t'm  = d.`v'`t'm
// 	}
// }

// * Time shift
// gen byte westhem = inlist(cty,"BRL","CAD","COP","MXN","PEN") // "AUD","CAD","COP","JPY","NZD","MYR"

// foreach v of varlist nom* dyp* dtp* {
// 	clonevar sft`v' = `v'
// 	replace sft`v' = f.`v' if !westhem	// condition when EM/AE LPs, no condition for individual LPs
// 	// 	replace `v' = f.`v' if !westhem
// }

// foreach t in 3 6 12 24 60 120 {
// // 	clonevar sftrho`t'm = rho`t'm
// // 	clonevar sftsyn`t'm = syn`t'm
// 	clonevar sftphi`t'm = phi`t'm

// // 	replace  sftrho`t'm = f.rho`t'm
// // 	replace  sftsyn`t'm = usyc`t'm + sftrho`t'm
// // 	replace  sftphi`t'm = sftnom`t'm - sftsyn`t'm
// 	replace  sftphi`t'm = sftnom`t'm - syn`t'm
	
// // 	clonevar sftnom`t'm = nom`t'm
// // 	replace  sftnom`t'm = f.nom`t'm if !westhem
// }


* Compute monthly returns (in basis points)
foreach v of varlist spx vix oil fx stx {
    gen log`v' = ln(`v')
	by $id: gen rt`v' = (log`v' - log`v'[_n-1])*10000
}

// gen logspx = ln(spx)
// gen logvix = ln(vix)
// gen logoil = ln(oil)
// gen logccy = ln(fx)
// gen logstx = ln(stx)
// by $id: gen rtspx = (logspx - logspx[_n-1])*10000
// by $id: gen rtoil = (logoil - logoil[_n-1])*10000
// by $id: gen rtfx  = (logccy - logccy[_n-1])*10000
// by $id: gen rtstx = (logstx - logstx[_n-1])*10000
drop log*


* x-axis and zero line
global horizon = 90	// in days
gen days = _n-1 if _n <= $horizon +1
gen zero = 0 	if _n <= $horizon +1


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
