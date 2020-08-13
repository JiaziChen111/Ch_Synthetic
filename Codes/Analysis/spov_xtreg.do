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


* Define variables
global x0 sdprm
global x01 logvix epugbl
global x02 $x01 globalip
global x03 rtfx rtoil rtspx
global x04 $x02 $x03
global x10 $x02 ffr inf une
global x20 $x02     inf une
global x30 $x02 ffr
global x40 $x10 $x03
global x50 $x20 $x03


* Panel regressions
foreach t in 24 120 {
	foreach v in dyp {
		quietly xtreg `v'`t'm $x10 if em, fe cluster($idm)
		eststo myp1
		quietly xtreg `v'`t'm usyp`t'm $x20 if em, fe cluster($idm)
		eststo myp2
		quietly xtreg `v'`t'm ustp`t'm $x10 if em, fe cluster($idm)
		eststo myp3
		quietly xtreg `v'`t'm usyp`t'm ustp`t'm $x20 if em, fe cluster($idm)
		eststo myp4
		quietly xtreg `v'`t'm usyp`t'm ustp`t'm $x50 if em, fe cluster($idm)
		eststo myp5
		esttab myp1 myp2 myp3 myp4 myp5
	}
}

foreach t in 24 120 {
	foreach v in dtp {
		quietly xtreg `v'`t'm $x0 if em, fe cluster($idm)
		eststo mtp1
		quietly xtreg `v'`t'm $x0 gdp if em, fe cluster($idm)
		eststo mtp2
		quietly xtreg `v'`t'm ustp`t'm $x10 if em, fe cluster($idm)
		eststo mtp3
		quietly xtreg `v'`t'm usyp`t'm ustp`t'm $x20 if em, fe cluster($idm)
		eststo mtp4
		quietly xtreg `v'`t'm usyp`t'm ustp`t'm $x50 if em, fe cluster($idm)
		eststo mtp5
		esttab mtp1 mtp2 mtp3 mtp4 mtp5
	}
}

foreach t in 24 120 {
	foreach v in phi {
		quietly xtreg `v'`t'm $x01 if em, fe cluster($idm)
		eststo mphi1
		quietly xtreg `v'`t'm ustp`t'm $x01 if em, fe cluster($idm)
		eststo mphi2
		quietly xtreg `v'`t'm ustp`t'm $x10 if em, fe cluster($idm)
		eststo mphi3
		quietly xtreg `v'`t'm ustp`t'm $x40 if em, fe cluster($idm)
		eststo mphi4
		quietly xtreg `v'`t'm ustp`t'm usyp`t'm $x50 if em, fe cluster($idm)
		eststo mphi5
		esttab mphi1 mphi2 mphi3 mphi4 mphi5
	}
}

foreach t in 24 120 {
	foreach v in rho {
		quietly xtreg `v'`t'm $x01 if em, fe cluster($idm)
		eststo mrho1
		quietly xtreg `v'`t'm ustp`t'm $x01 if em, fe cluster($idm)
		eststo mrho2
		quietly xtreg `v'`t'm ustp`t'm $x10 if em, fe cluster($idm)
		eststo mrho3
		quietly xtreg `v'`t'm ustp`t'm $x40 if em, fe cluster($idm)
		eststo mrho4
		quietly xtreg `v'`t'm ustp`t'm usyp`t'm $x50 if em, fe cluster($idm)
		eststo mrho5
		esttab mrho1 mrho2 mrho3 mrho4 mrho5
	}
}

quietly xtreg dyp120m usyp120m ustp120m $x04 if em, fe cluster($idm)
eststo mem1
quietly xtreg dtp120m usyp120m ustp120m $x04 if em, fe cluster($idm)
eststo mem2
quietly xtreg phi120m usyp120m ustp120m $x04 if em, fe cluster($idm)
eststo mem3
quietly xtreg rho120m usyp120m ustp120m $x04 if em, fe cluster($idm)
eststo mem4
esttab mem1 mem2 mem3 mem4

quietly xtreg dyp120m usyp120m ustp120m $x04 if !em, fe cluster($idm)
eststo mae1
quietly xtreg dtp120m usyp120m ustp120m $x04 if !em, fe cluster($idm)
eststo mae2
quietly xtreg phi120m usyp120m ustp120m $x04 if !em, fe cluster($idm)
eststo mae3
quietly xtreg rho120m usyp120m ustp120m $x04 if !em, fe cluster($idm)
eststo mae4
esttab mae1 mae2 mae3 mae4



foreach t in 120 { // 24 
	foreach group in 0 1 {
		local condition em == `group'
		local j = 0
		foreach v in dyp dtp phi rho {
			local ++j
			if `group' == 0 {
				quietly xtreg `v'`t'm usyp`t'm ustp`t'm $x04 if `condition', fe cluster($idm)
				eststo mdl`j'
			}
			
			if `group' == 1 {
				quietly xtreg `v'`t'm usyp`t'm ustp`t'm $x04 inf une if `condition', fe cluster($idm)
				eststo mdl`j'
			}
		}	// `v' variables
		esttab mdl*
		eststo clear
	}	// `group'
}	// `t'
