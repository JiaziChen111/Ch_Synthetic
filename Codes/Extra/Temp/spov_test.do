



use $file_dta1, clear

drop if em == 0									// drop AEs
drop if eomth == 0								// keep end-of-month data
gen date  = dofc(time)
gen datem = mofd(dofc(time))					// used to label graphs
format date %td
format datem %tm
order datem, first
drop  time em eomth
order cty, after(datem)
gen month = month(date)

* Declare panel dataset using business dates
global id imf
global t datem
sort  $id $t
xtset $id $t

foreach v in nom syn real {
	foreach t in 12 24 36 48 60 120 {
		cap gen `v'`t'mpct  = `v'`t'm*100
	}
}


// gen cbpfit1 = .
// levelsof $id, local(levels) 
// foreach l of local levels {
// 	if !inlist(`l',199) quiet regress cbp l.cbp inf gdp if imf == `l'
// 	predict temp, xb
// 	replace cbpfit1 = temp if imf == `l'
// 	drop temp
// }

// quiet regress cbp l.cbp inf gdp
quiet regress nom12mpct l.nom12mpct inf gdp
// predict cbpfit2, xb

// quiet xtreg cbp l.cbp inf gdp
// predict cbpfit3, xb

// scalar betai = _b[l.cbp]
scalar betai = _b[l.nom12mpct]

* Stationarity
gen scbp12m1  = _b[_cons]/(1-betai) + _b[inf]*scpi12m/(1-betai)  + _b[gdp]*sgdp12m/(1-betai)
gen scbp24m1  = _b[_cons]/(1-betai) + _b[inf]*scpi24m/(1-betai)  + _b[gdp]*sgdp24m/(1-betai)
gen scbp36m1  = _b[_cons]/(1-betai) + _b[inf]*scpi36m/(1-betai)  + _b[gdp]*sgdp36m/(1-betai)
gen scbp48m1  = _b[_cons]/(1-betai) + _b[inf]*scpi48m/(1-betai)  + _b[gdp]*sgdp48m/(1-betai)
gen scbp60m1  = _b[_cons]/(1-betai) + _b[inf]*scpi60m/(1-betai)  + _b[gdp]*sgdp60m/(1-betai)
gen scbp120m1 = _b[_cons]/(1-betai) + _b[inf]*scpi120m/(1-betai) + _b[gdp]*sgdp120m/(1-betai)

* Recursive
// gen scbp12m2  = _b[_cons] + _b[l.cbp]*cbp      + _b[inf]*scpi12m  + _b[gdp]*sgdp12m
gen scbp12m2  = _b[_cons] + betai*nom12mpct+ _b[inf]*scpi12m  + _b[gdp]*sgdp12m
gen scbp24m2  = _b[_cons] + betai*scbp12m2 + _b[inf]*scpi24m  + _b[gdp]*sgdp24m
gen scbp36m2  = _b[_cons] + betai*scbp24m2 + _b[inf]*scpi36m  + _b[gdp]*sgdp36m
gen scbp48m2  = _b[_cons] + betai*scbp36m2 + _b[inf]*scpi48m  + _b[gdp]*sgdp48m
gen scbp60m2  = _b[_cons] + betai*scbp48m2 + _b[inf]*scpi60m  + _b[gdp]*sgdp60m
gen scbp120m2 = _b[_cons] + betai*scbp60m2 + _b[inf]*scpi120m + _b[gdp]*sgdp120m

* SOE assumption
gen scbp12m3  = rr1y + scpi12m
// gen scbp24m3  = rr3y + scpi24m
// gen scbp36m3  = rr3y + scpi36m
// gen scbp48m3  = rr3y + scpi48m
gen scbp60m3  = rr5y + scpi60m
gen scbp120m3 = rr10y + scpi120m

* Combine them
// gen scbp120mavg = (scbp120m1 + scbp120m3)/2

corr scbp120m scbp120m1 scbp120m2 scbp120m3
	// 10Y stationary and SOE highly correlated 0.83
corr scbp60m scbp60m1 scbp60m2 scbp60m3
	// 5Y stationary and SOE highly correlated 0.75
corr scbp12m1 scbp12m2 scbp12m3
	// 1Y recursive and SOE highly correlated 0.7
corr scbp60m1 scbp120m1 scbp60m3 scbp120m3
	// 5Y and 10Y highly correlated SOE 0.93, stationary 0.96
corr syn12mpct scbp12m3
corr syn60mpct scbp60m3
corr syn120mpct scbp120m3
	// high correlation b/w synthetic and SOE 0.75-0.77


* Evaluate them
// All options compared
levelsof $id, local(levels)
foreach t in 12 24 36 48 60 120 {
	foreach l of local levels {
		line scbp`t'm1  scbp`t'm2  scbp`t'm3  cbp syn`t'mpct datem if $id == `l'
		graph export $pathfigs/Surveys/CBP/scbp`t'm`l'.eps, replace
	}
}

// SOE 1Y 5Y 10Y separately
levelsof $id, local(levels)
foreach t in 12 60 120 {
	foreach l of local levels {
		if `t' == 12 line syn`t'mpct scbp`t'm2 scbp`t'm3 datem if $id == `l'
		if `t' == 60 line syn`t'mpct scbp`t'm scbp`t'm3 scbp120m3 datem if $id == `l'
		if `t' == 120 line nom`t'mpct syn`t'mpct scbp`t'm3 scbp`t'm1 datem if $id == `l'
		graph export $pathfigs/Surveys/CBP/SOEscbp`t'm`l'.eps, replace
	}
}

// SOE 1Y 5Y 10Y together
levelsof $id, local(levels)
foreach l of local levels {
	line syn12mpct scbp12m3 scbp60m3 scbp120m3 datem if $id == `l'
	graph export $pathfigs/Surveys/CBP/SOE`l'.eps, replace
}




* ------------------------------------------------------------------------------
* On impact regressions
log using $file_log, replace
local horizon = 1	// in days
foreach t in 24 120 {
	foreach group in 1 { // 0
		if `group' == 0 local grp "AE"
		if `group' == 1 local grp "EM"
		
		foreach v in nom dyp dtp phi rho {
			local j = 0
			foreach shock in mp1 path lsap {
				local ++j
				if `j' == 1 {
					local shk "Target"
					local datecond date > td(1jan2000) & date < td(1jan2009)
				}
				if `j' == 2 {
					local shk "Path"
					local datecond date > td(1jan2000) & date < td(1jan2020)
				}
				if `j' == 3 {
					local shk "LSAP"
					local datecond date > td(1jan2009) & date < td(1jan2020)
				}
			
			// controls
			local ctrl`v'`t'm l(2).`v'`t'm l(1).fx 	// l(1/`maxlag').d`v'`t'm l(1/`maxlag').fx
			
			// conditions
			local condition em == `group' & `datecond' //	& `region' == 4
			
			forvalues i = 0/`horizon' {
				// response variables
				capture gen `v'`t'm`i' = (f`i'.`v'`t'm - l.`v'`t'm)
				
				// regression
				xtreg `v'`t'm`i' `shock' `ctrl`v'`t'm' if `condition', fe level(90) cluster($id)
				drop `v'`t'm`i'
				} // `i' horizon
			} // `shock'
		}	// `v' variables
// 		esttab mdl* using x.tex, b(2) se(3) r2(2) nocons nonumbers nonotes label booktabs replace width(0.8\hsize) ///
	}	// `group'
// 	filefilter x.tex "$pathtbls/`tbllbl'`ty'y.tex", from(\BSbegin{tabular*}) to(\BSlabel{tab:`tbllbl'`ty'y}\n\BSbegin{tabular*}) replace
}	// `t'
log close
translate $file_log.smcl $file_log.pdf, replace
erase $file_log.smcl

* ------------------------------------------------------------------------------
* Additional
* ------------------------------------------------------------------------------
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


