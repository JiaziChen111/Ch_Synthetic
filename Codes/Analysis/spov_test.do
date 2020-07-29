



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

* Stationarity
gen scbp12m1  = _b[_cons]/(1-_b[l.nom12mpct]) + _b[inf]*scpi12m/(1-_b[l.nom12mpct])  + _b[gdp]*sgdp12m/(1-_b[l.nom12mpct])
gen scbp24m1  = _b[_cons]/(1-_b[l.nom12mpct]) + _b[inf]*scpi24m/(1-_b[l.nom12mpct])  + _b[gdp]*sgdp24m/(1-_b[l.nom12mpct])
gen scbp36m1  = _b[_cons]/(1-_b[l.nom12mpct]) + _b[inf]*scpi36m/(1-_b[l.nom12mpct])  + _b[gdp]*sgdp36m/(1-_b[l.nom12mpct])
gen scbp48m1  = _b[_cons]/(1-_b[l.nom12mpct]) + _b[inf]*scpi48m/(1-_b[l.nom12mpct])  + _b[gdp]*sgdp48m/(1-_b[l.nom12mpct])
gen scbp60m1  = _b[_cons]/(1-_b[l.nom12mpct]) + _b[inf]*scpi60m/(1-_b[l.nom12mpct])  + _b[gdp]*sgdp60m/(1-_b[l.nom12mpct])
gen scbp120m1 = _b[_cons]/(1-_b[l.nom12mpct]) + _b[inf]*scpi120m/(1-_b[l.nom12mpct]) + _b[gdp]*sgdp120m/(1-_b[l.nom12mpct])

* Recursive
// gen scbp12m2  = _b[_cons] + _b[l.cbp]*cbp      + _b[inf]*scpi12m  + _b[gdp]*sgdp12m
gen scbp12m2  = _b[_cons] + _b[l.nom12mpct]*nom12mpct+ _b[inf]*scpi12m  + _b[gdp]*sgdp12m
gen scbp24m2  = _b[_cons] + _b[l.nom12mpct]*scbp12m2 + _b[inf]*scpi24m  + _b[gdp]*sgdp24m
gen scbp36m2  = _b[_cons] + _b[l.nom12mpct]*scbp24m2 + _b[inf]*scpi36m  + _b[gdp]*sgdp36m
gen scbp48m2  = _b[_cons] + _b[l.nom12mpct]*scbp36m2 + _b[inf]*scpi48m  + _b[gdp]*sgdp48m
gen scbp60m2  = _b[_cons] + _b[l.nom12mpct]*scbp48m2 + _b[inf]*scpi60m  + _b[gdp]*sgdp60m
gen scbp120m2 = _b[_cons] + _b[l.nom12mpct]*scbp60m2 + _b[inf]*scpi120m + _b[gdp]*sgdp120m

* SOE assumption
gen scbp12m3  = rr1y + scpi12m
gen scbp24m3  = rr3y + scpi24m
gen scbp36m3  = rr3y + scpi36m
gen scbp48m3  = rr3y + scpi48m
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
