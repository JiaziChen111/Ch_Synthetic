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
foreach v of varlist spx oil fx stx {
    gen log`v' = ln(`v')
	by $idm: gen rt`v' = (log`v' - log`v'[_n-1])*10000
}
drop log*
gen logvix = ln(vix)

label variable logvix "Log(Vix)"
label variable rtfx "FX"
label variable rtoil "Oil"
label variable rtspx "S\&P"
label variable rtstx "Stock"


* Define variables
global x0 sdprm
global x1 logvix epugbl rtspx globalip rtoil         rtfx rtstx
// global x2 logvix epugbl rtspx globalip rtoil inf une rtfx rtstx
global x2 logvix epugbl rtspx globalip rtoil inf une rtfx


* Panel regressions

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
// mtitles("3M" "3M" "1Y" "1Y" "2Y" "2Y" "5Y" "5Y" "10Y" "10Y")
// filefilter x.tex "$pathtbls/`tbllbl'.tex", from(\BS\BS\n) to(\BStabularnewline\n) replace
// erase x.tex

* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* Table: Drivers
local tbllbl "ycdcmp"
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
		esttab mdl* using x.tex, b(2) se(3) r2(2) nocons nonumbers nonotes label booktabs replace width(0.8\hsize) ///
		title(Drivers of the `ty'-Year Nominal Yield and Its Components)	///
		mtitles("YLD" "SYN" "ER" "TP" "CRP" "FWD")  ///
		addnote("Note: Dependent variables in basis points. EPU Global, returns for: S\&P, oil, FX.")
		eststo clear
	}	// `group'
	filefilter x.tex y.tex, from(\BSbegin{tabular*}) to(\BSlabel{tab:`tbllbl'`ty'y}\n\BSbegin{tabular*}) replace
	filefilter y.tex "$pathtbls/`tbllbl'`ty'y.tex", from(Observations) to(Obs.) replace
}	// `t'
erase x.tex
erase y.tex
* ------------------------------------------------------------------------------
