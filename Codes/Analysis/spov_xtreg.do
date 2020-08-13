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
label variable rtfx "FX Return"
label variable rtoil "Oil Return"
label variable rtspx "SP500 Return"
label variable rtstx "Stock Return"


* Define variables
global x01 sdprm
global x02 sdcyc
global x1  logvix epugbl globalip rtspx rtfx
global x2  inf une $x1


* Panel regressions
local tbllbl "tpucsv"
local j = 0
foreach t in 3 12 24 60 120 {
	local ++j
	quietly xtreg dtp`t'm $x01 if em, fe cluster($idm)
	eststo mtp`j'
	local ++j
	quietly xtreg dtp`t'm $x01 gdp if em, fe cluster($idm)
	eststo mtp`j'
}
esttab mtp* using x.tex, b(a2) se r2(2) nocons nonumbers nonotes label booktabs replace width(0.8\hsize) ///
title(Term Premia and Inflation Volatility)	///
mtitles("3M" "3M" "1Y" "1Y" "2Y" "2Y" "5Y" "5Y" "10Y" "10Y") ///
addnote("Note: Variables in basis points.")
filefilter x.tex "$pathtbls/`tbllbl'.tex", from(\BSbegin{tabular) to(\BSlabel{`tbllbl'}\n\BSbegin{tabular) replace
eststo clear
erase x.tex


local tbllbl "ycdcmp"
foreach t in 120 { // 24
	foreach group in 1 { // 0
		local condition em == `group'
		local j = 0
		foreach v in dyp dtp phi rho {
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
		esttab mdl* using $pathtbls/`tbllbl'.tex, b(2) se(3) r2(2) nocons nonumbers nonotes label booktabs replace width(0.8\hsize) ///
		title(Drivers of Components of the 10-Year Yield)	///
		mtitles("ER" "TP" "CRP" "FWD")  ///
		addnote("Note: Variables in basis points.")
// 		filefilter x.tex "$pathtbls/`tbllbl'.tex", from(\BSbegin{tabular) to(\BSlabel{`tbllbl'}\n\BSbegin{tabular) replace
		eststo clear
// 		erase x.tex
	}	// `group'
}	// `t'
