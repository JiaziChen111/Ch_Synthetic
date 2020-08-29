* ==============================================================================
* Panel regressions with monthly data
* ==============================================================================
use $file_dta2, clear


* Keep monthly data and define panel
keep if eomth
global idm imf
global tm datem
sort  $idm $tm
xtset $idm $tm
drop date eomth
order  datem, first


* Compute monthly returns (in basis points)
foreach v of varlist vix spx oil fx stx epuus epugbl globalip {
    gen log`v' = ln(`v')
	by $idm: gen rt`v' = (log`v' - log`v'[_n-1])*10000
}


* Define variables
global x0 sdprm
global x1 logvix logepuus globalip rtfx rtspx rtoil // vix epugbl globalip	// vix epugbl rtglobalip	// rtvix rtepugbl rtglobalip
global x2 inf une $x1


* Label variables for use in figures and tables
#delimit ;
unab oldlabels : ustp* usyp* rtvix rtfx rtoil rtspx rtstx rtepuus rtepugbl 
				 rtglobalip logepuus logepugbl logvix vix;
local newlabels `" "US TP" "US TP" "US TP" "US TP" "US ER" "US ER" "US ER" "US ER" 
				"Vix" "FX" "Oil" "S\&P" "Stock" "EPU US" "Global EPU" "Global IP" 
				"Log(EPU)" "Log(EPU)" "Log(Vix)" "Vix" "';
#delimit cr
local nlbls : word count `oldlabels'
forvalues i = 1/`nlbls' {
	local a : word `i' of `oldlabels'
	local b : word `i' of `newlabels'
	label variable `a' "`b'"
}


* ------------------------------------------------------------------------------
* Table: TP and UCSV
local tbllbl "f_tpucsv"
eststo clear
local j = 0
foreach t in 3 12 24 60 120 {
	local ++j
	quietly xtreg dtp`t'm $x0 if em, fe cluster($idm)
	eststo mtp`j'
	local ++j
	quietly xtreg dtp`t'm $x0 gdp if em, fe cluster($idm)
	eststo mtp`j'
}
esttab mtp* using "$pathtbls/`tbllbl'.tex", replace fragment cells(b(fmt(a2) star) se(fmt(a2) par)) ///
r2(2) keep($x0 gdp) nomtitles nonumbers nonotes nolines label booktabs collabels(none) ///
mgroups("3M" "1Y" "2Y" "5Y" "10Y", pattern(1 0 1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))  ///
varlabels(, elist(gdp \midrule))
// filefilter x.tex "$pathtbls/`tbllbl'.tex", from(\BS\BS\n) to(\BStabularnewline\n) replace
// erase x.tex
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* Table: Drivers
local tbllbl "f_ycdcmp"
eststo clear
foreach t in 24 120 {
	local ty = `t'/12
	foreach group in 1 { // 0
		local condition em == `group'
		local j = 0
		foreach v in nom syn dyp dtp phi rho {
			local ++j
			if `group' == 0 {
				quietly xtreg `v'`t'm usyp`t'm ustp`t'm $x1 if `condition', fe cluster($idm)
				eststo mdl`j'
			}
			
			if `group' == 1 {
				quietly xtreg `v'`t'm usyp`t'm ustp`t'm $x2 if `condition', fe cluster($idm)
				eststo mdl`j'
			}
		}	// `v' variables
		esttab mdl* using x.tex, replace fragment cells(b(fmt(2) star) se(fmt(2) par)) ///
		r2(2) nocons nomtitles nonumbers nonotes nolines label booktabs collabels(none) ///
		mgroups("Nominal" "Synth." "ESR" "TP" "CRP" "FP", pattern(1 1 1 1 1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))  ///
		varlabels(, elist(rtoil \midrule))
	}	// `group'
	filefilter x.tex "$pathtbls/`tbllbl'`ty'y.tex", from(Observations) to(Obs.) replace
}	// `t'
erase x.tex
* ------------------------------------------------------------------------------
