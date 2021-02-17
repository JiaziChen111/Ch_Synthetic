* ==============================================================================
* Preliminary analysis
* ==============================================================================
use $file_dta2, clear


* ------------------------------------------------------------------------------
* MP shocks
* ------------------------------------------------------------------------------

// browse date mp1 path lsap if cty == "CHF" & mp1 != .
summ mp1 path lsap if cty == "CHF" & mp1 != .
pwcorr mp1 path lsap if cty == "CHF" & mp1 != ., sig // not statistically different from zero
// corrgram mp1 if cty == "CHF" & mp1 != ., lags(4)
// ac mp1 if cty == "CHF" & mp1 != ., lags(4)

line mp1 path lsap datem if cty == "CHF"
twoway (line mp1 datem if cty == "CHF" & date < td(1jan2009), lpattern("-")) (line path datem if cty == "CHF", lpattern("l")) (line lsap datem if cty == "CHF" & date >= td(1jan2009), lpattern("-.")), ytitle("Basis Points", size(medsmall)) xtitle("")
graph export $pathfigs/MPS/USmps.eps, replace

* ------------------------------------------------------------------------------
* Table: Summary statistics for U.S. monetary policy shocks
local tbllbl "f_mpsstats"
matrix drop _all
local j = 0
foreach shock in mp1 path lsap {
	local ++j
	if `j' == 1 local datecond date > td(1jan2000) & date < td(1jan2020)	// target
	if `j' == 4 local datecond date > td(1jan2000) & date < td(1jan2020)	// path
	if `j' == 7 local datecond date > td(1oct2008) & date < td(1jan2020)	// lsap
	
	estpost summ abs`shock' if cty == "CHF" & fomc & `datecond' // & abs`shock' != 0
	if `j' == 1 {
		matrix t`j' = ( e(mean) \ e(sd) \ e(min) \ e(max) \ e(count) )
		matrix rownames t1 = "Mean" "Std. Dev." "Min." "Max." "Obs"
		matrix t`j' = t`j''
	}
	else {
		matrix t`j' = ( e(mean) \ e(sd) \ e(min) \ e(max) \ e(count) )'
	}
	local ++j
	estpost summ `shock' if cty == "CHF" & fomc & `shock' > 0
	matrix t`j' = ( e(mean) \ e(sd) \ e(min) \ e(max) \ e(count) )'
	local ++j
	estpost summ `shock' if cty == "CHF" & fomc & `shock' < 0
	matrix t`j' = ( e(mean) \ e(sd) \ e(min) \ e(max) \ e(count) )'
}
matrix tablemps = ( t1 \ t2 \ t3 \ t4 \ t5 \ t6 \ t7 \ t8 \ t9 )
matrix rownames tablemps = "Target Surprises (abs. values)" "\quad Target Surprises \(>\) 0" "\quad Target Surprises \(<\) 0" "Path Surprises  (abs. values)" "\quad Path Surprises \(>\) 0" "\quad Path Surprises \(<\) 0" "LSAP Surprises  (abs. values)" "\quad LSAP Surprises \(>\) 0" "\quad LSAP Surprises \(<\) 0"
esttab matrix(tablemps, fmt(1 1 1 1 0)) using x.tex, replace fragment noobs nomtitles nonumbers booktabs
filefilter x.tex y.tex, from(Path) to("Forward Guidance") replace
filefilter y.tex x.tex, from(LSAP) to("Asset Purchase") replace
filefilter x.tex y.tex, from(\nForward) to(\n\BSmidrule\nForward) replace
filefilter y.tex "$pathtbls/`tbllbl'.tex", from(\nAsset) to(\n\BSmidrule\nAsset) replace
erase x.tex
erase y.tex
// 	hist abs`shock' if cty == "CHF" & fomc & abs`shock' != 0
* ------------------------------------------------------------------------------


// main messages of summary statistics in MP announcement days
// magnitude of shocks is generally less than 10 basis points in absolute value
// shocks are not correlated, but on 18-Mar-2009 large easing path and LSAP shocks
// easing shocks are more common than tightening ones

summ absmp1 if cty == "CHF" & fomc & absmp1 != 0
summ abspath if cty == "CHF" & fomc & abspath != 0
summ abslsap if cty == "CHF" & fomc & abslsap != 0
//     Variable |        Obs        Mean    Std. Dev.       Min        Max
// -------------+---------------------------------------------------------
//       absmp1 |         80    5.226712      8.8187       .001     46.501
//      abspath |        162    6.003316    6.497144     .00873   54.61488
//      abslsap |         86    2.224245     3.54366   .0529064    29.9438


summ abs* if cty == "CHF" & fomc
//     Variable |        Obs        Mean    Std. Dev.       Min        Max
// -------------+---------------------------------------------------------
//       absmp1 |        162    2.581093    6.710528          0     46.501
//      abspath |        162    6.003316    6.497144     .00873   54.61488
//      abslsap |        162    1.180772    2.805264          0    29.9438

summ abs* if cty == "CHF"
//     Variable |        Obs        Mean    Std. Dev.       Min        Max
// -------------+---------------------------------------------------------
//       absmp1 |      4,773    .0876047    1.318245          0     46.501
//      abspath |      4,773    .2037581    1.614358          0   54.61488
//      abslsap |      4,773    .0400765    .5578797          0    29.9438


pwcorr mp1 path if cty == "CHF" & fomc & date <  td(1jan2009), sig
//              |      mp1 
// -------------+----------
//         path |  -0.0163 
//              |   0.8854

pwcorr path lsap if cty == "CHF" & fomc & date >= td(1jan2009), sig
//              |     path 
// -------------+----------
//         lsap |   0.2602 
//              |   0.0190

pwcorr path lsap if cty == "CHF" & fomc & date >= td(1jan2009) & date != td(18mar2009), sig
//              |     path 
// -------------+----------
//         lsap |   0.0130 
//              |   0.9091


* ------------------------------------------------------------------------------
* Yield curves
* ------------------------------------------------------------------------------

foreach v in nom syn dyp dtp phi {
	local ycs = ""
	foreach t in 3 6 12 24 60 120 {
		capture gen pct`v'`t'm = `v'`t'm/100
		local ycs `ycs' pct`v'`t'm
	}
	tabstat `ycs' if eomth, by(ae) statistics(mean sd min max) nototal
}

* ------------------------------------------------------------------------------
* Table: Summary statistics for nominal and synthetic yields
local tbllbl "f_yldcrvstats"
local clbl 3M 6M 1Y 2Y 5Y 10Y
local repapp replace
local j = 0
foreach v in nom syn {
	local ++j
	local ycs = ""
	local fmt = ""
	foreach t in 3 6 12 24 60 120 {
		capture gen pct`v'`t'm = `v'`t'm/100
		local ycs `ycs' pct`v'`t'm
		local fmt `fmt' pct`v'`t'm(fmt(1))
	}
	eststo clear
	estpost tabstat `ycs' if eomth, by(ae) statistics(mean sd) nototal
	if `j' == 1 {
		esttab using x.tex, replace fragment cells("`fmt'") collabels(`clbl') noobs nonote nomtitle nonumber booktabs
	}
	else {
		esttab using x.tex, append fragment cells("`fmt'") collabels(none) noobs nonote nomtitle nonumber booktabs
	}
}
drop pct*
filefilter x.tex y.tex, from(mean) to(Average) replace
filefilter y.tex x.tex, from(sd) to("Std. D.") replace
filefilter x.tex y.tex, from(\BS\BS\n) to(\BS\BS\n&) replace
filefilter y.tex x.tex, from(&\BSmidrule\nEmerging) to(\BSmidrule\nEmerging) replace
filefilter x.tex y.tex, from("Emerging Markets") to("Synthetic&Emerging Markets\n%") replace
filefilter y.tex x.tex, from("Advanced Economies") to("&Advanced Economies\n%") replace
filefilter x.tex y.tex, from(Y\BS\BS\n\BSmidrule\nSynthetic&Emerging) to(Y\BS\BS\n\BSmidrule\nNominal&Emerging) replace
filefilter y.tex x.tex, from(&\BSmidrule) to(\BScmidrule(lr){2-8}) replace
filefilter x.tex y.tex, from("Emerging Markets") to("\BSmulticolumn{7}{c}{Emerging Markets}\t\BS\BS") replace
filefilter y.tex x.tex, from("Advanced Economies") to("\BSmulticolumn{7}{c}{Advanced Economies}\t\BS\BS") replace
filefilter x.tex y.tex, from(Nominal) to("\BSmultirow{7}{*}{Nominal}") replace
filefilter y.tex x.tex, from(Synthetic) to("\BSmultirow{7}{*}{Synthetic}") replace
filefilter x.tex y.tex, from(3M&) to("  & 3M&") replace
filefilter y.tex "$pathtbls/`tbllbl'.tex", from(%&) to(\BScmidrule(lr){2-8}\n%&) replace
erase x.tex
erase y.tex
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: Summary statistics for components of nominal yields - Emerging markets
local tbllbl "f_dcmpstats"
local clbl 3M 6M 1Y 2Y 5Y 10Y
local repapp replace
local j = 0
foreach v in dyp dtp phi {
	local ++j
	local ycs = ""
	local fmt = ""
	foreach t in 3 6 12 24 60 120 {
		capture gen pct`v'`t'm = `v'`t'm/100
		local ycs `ycs' pct`v'`t'm
		local fmt `fmt' pct`v'`t'm(fmt(1))
	}
	eststo clear
	estpost tabstat `ycs' if em & eomth, statistics(mean sd)
	if `j' == 1 {
		esttab using x.tex, replace fragment cells("`fmt'") collabels(`clbl') noobs nonote nomtitle nonumber booktabs
	}
	else {
		esttab using x.tex, append fragment cells("`fmt'") collabels(none) noobs nonote nomtitle nonumber booktabs
	}
}
drop pct*
filefilter x.tex y.tex, from(mean) to(Average) replace
filefilter y.tex x.tex, from(sd) to("S. Dev.") replace
filefilter x.tex y.tex, from(Y\BS\BS\n\BSmidrule\nAverage) to("Y\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Expected Short Rate}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
filefilter y.tex x.tex, from(1\BS\BS\n\BSmidrule\nAverage) to("1\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Term Premium}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
filefilter x.tex "$pathtbls/`tbllbl'.tex", from(0\BS\BS\n\BSmidrule\nAverage) to("0\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Credit Risk Compensation}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
erase x.tex
erase y.tex
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* Table: Summary statistics for components of nominal yields - Emerging markets (Pre-GFC)
local tbllbl "f_dcmpstatspregfc"
local clbl 3M 6M 1Y 2Y 5Y 10Y
local repapp replace
local j = 0
foreach v in dyp dtp phi {
	local ++j
	local ycs = ""
	local fmt = ""
	foreach t in 3 6 12 24 60 120 {
		capture gen pct`v'`t'm = `v'`t'm/100
		local ycs `ycs' pct`v'`t'm
		local fmt `fmt' pct`v'`t'm(fmt(1))
	}
	eststo clear
	estpost tabstat `ycs' if em & eomth & date < td(1sep2008), statistics(mean sd)
	if `j' == 1 {
		esttab using x.tex, replace fragment cells("`fmt'") collabels(`clbl') noobs nonote nomtitle nonumber booktabs
	}
	else {
		esttab using x.tex, append fragment cells("`fmt'") collabels(none) noobs nonote nomtitle nonumber booktabs
	}
}
drop pct*
filefilter x.tex y.tex, from(mean) to(Average) replace
filefilter y.tex x.tex, from(sd) to("S. Dev.") replace
filefilter x.tex y.tex, from(Y\BS\BS\n\BSmidrule\nAverage) to("Y\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Expected Short Rate}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
filefilter y.tex x.tex, from(1\BS\BS\n\BSmidrule\nAverage) to("1\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Term Premium}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
filefilter x.tex "$pathtbls/`tbllbl'.tex", from(0\BS\BS\n\BSmidrule\nAverage) to("0\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Credit Risk Premium}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
erase x.tex
erase y.tex
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* Table: Summary statistics for components of nominal yields - Emerging markets (Post-GFC)
local tbllbl "f_dcmpstatspostgfc"
local clbl 3M 6M 1Y 2Y 5Y 10Y
local repapp replace
local j = 0
foreach v in dyp dtp phi {
	local ++j
	local ycs = ""
	local fmt = ""
	foreach t in 3 6 12 24 60 120 {
		capture gen pct`v'`t'm = `v'`t'm/100
		local ycs `ycs' pct`v'`t'm
		local fmt `fmt' pct`v'`t'm(fmt(1))
	}
	eststo clear
	estpost tabstat `ycs' if em & eomth & date >= td(1sep2008), statistics(mean sd)
	if `j' == 1 {
		esttab using x.tex, replace fragment cells("`fmt'") collabels(`clbl') noobs nonote nomtitle nonumber booktabs
	}
	else {
		esttab using x.tex, append fragment cells("`fmt'") collabels(none) noobs nonote nomtitle nonumber booktabs
	}
}
drop pct*
filefilter x.tex y.tex, from(mean) to(Average) replace
filefilter y.tex x.tex, from(sd) to("S. Dev.") replace
filefilter x.tex y.tex, from(Y\BS\BS\n\BSmidrule\nAverage) to("Y\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Expected Short Rate}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
filefilter y.tex x.tex, from(1\BS\BS\n\BSmidrule\nAverage) to("1\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Term Premium}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
filefilter x.tex "$pathtbls/`tbllbl'.tex", from(0\BS\BS\n\BSmidrule\nAverage) to("0\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Credit Risk Premium}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
erase x.tex
erase y.tex
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* Table: Summary statistics for components of nominal yields - Emerging markets (No Truncated)
local tbllbl "f_dcmpstatsnotrunc"
local clbl 3M 6M 1Y 2Y 5Y 10Y
local repapp replace
local j = 0
foreach v in dyp dtp oldphi {
	local ++j
	local ycs = ""
	local fmt = ""
	foreach t in 3 6 12 24 60 120 {
		capture gen pct`v'`t'm = `v'`t'm/100
		local ycs `ycs' pct`v'`t'm
		local fmt `fmt' pct`v'`t'm(fmt(1))
	}
	eststo clear
	estpost tabstat `ycs' if em & eomth, statistics(mean sd)
	if `j' == 1 {
		esttab using x.tex, replace fragment cells("`fmt'") collabels(`clbl') noobs nonote nomtitle nonumber booktabs
	}
	else {
		esttab using x.tex, append fragment cells("`fmt'") collabels(none) noobs nonote nomtitle nonumber booktabs
	}
}
drop pct*
filefilter x.tex y.tex, from(mean) to(Average) replace
filefilter y.tex x.tex, from(sd) to("S. Dev.") replace
filefilter x.tex y.tex, from(Y\BS\BS\n\BSmidrule\nAverage) to("Y\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Expected Short Rate}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
filefilter y.tex x.tex, from(1\BS\BS\n\BSmidrule\nAverage) to("1\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Term Premium}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
filefilter x.tex "$pathtbls/`tbllbl'.tex", from(0\BS\BS\n\BSmidrule\nAverage) to("0\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Credit Risk Premium}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
erase x.tex
erase y.tex
* ------------------------------------------------------------------------------

* ------------------------------------------------------------------------------
* Table: Summary statistics for components of nominal yields - Advanced economies
local tbllbl "f_dcmpstats_AE"
local clbl 3M 6M 1Y 2Y 5Y 10Y
local repapp replace
local j = 0
foreach v in dyp dtp {
	local ++j
	local ycs = ""
	local fmt = ""
	foreach t in 3 6 12 24 60 120 {
		capture gen pct`v'`t'm = `v'`t'm/100
		local ycs `ycs' pct`v'`t'm
		local fmt `fmt' pct`v'`t'm(fmt(1))
	}
	eststo clear
	estpost tabstat `ycs' if !em & eomth, statistics(mean sd)
	if `j' == 1 {
		esttab using x.tex, replace fragment cells("`fmt'") collabels(`clbl') noobs nonote nomtitle nonumber booktabs
	}
	else {
		esttab using x.tex, append fragment cells("`fmt'") collabels(none) noobs nonote nomtitle nonumber booktabs
	}
}
drop pct*
filefilter x.tex y.tex, from(mean) to(Average) replace
filefilter y.tex x.tex, from(sd) to("S. Dev.") replace
filefilter x.tex y.tex, from(Y\BS\BS\n\BSmidrule\nAverage) to("Y\BS\BS\n\BSmidrule\n&\BSmulticolumn{5}{c}{Expected Short Rate}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
filefilter y.tex "$pathtbls/`tbllbl'.tex", from(4\BS\BS\n\BSmidrule\nAverage) to("4\BS\BS\n\BSmidrule\n&\BSmulticolumn{5}{c}{Term Premium}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
erase x.tex
erase y.tex
* ------------------------------------------------------------------------------

// Save in esttab table as in tabstat (post #4)
// https://www.statalist.org/forums/forum/general-stata-discussion/general/
// 5559-using-estpost-estout-esttab-to-format-summary-stats


* ------------------------------------------------------------------------------
* Assess estimates against surveys
* ------------------------------------------------------------------------------
corr myp12m myp60m myp120m scbp12m scbp60m scbp120m 
	// obs=189; 12m 0.8584; 60m 0.8206; 120m 0.7988
corr myp120m nom24m syn24m if em
	// obs=2,489; nom24m 0.7412; syn24m 0.7857
corr mtp12m mtp60m mtp120m stp12m stp60m stp120m
	// obs=189; 12m 0.6940; 60m 0.8636; 120m 0.9302


* ------------------------------------------------------------------------------
* Check daily changes on days w/ large shocks
* ------------------------------------------------------------------------------	
browse date cty dnom120m dsyn120m drho120m dusyc120m dphi120m if inlist(date,td(6may2003),td(28jan2004),td(15mar2007),td(16dec2008),td(18mar2009),td(9aug2011),td(18sep2013),td(18mar2015))


* ------------------------------------------------------------------------------
* Assess TP estimates against empirical measures
* ------------------------------------------------------------------------------
	// Daily data
reg nom120m nom3m if !em
predict tpresae10y3m, resid
reg nom120m nom24m if !em
predict tpresae10y2y, resid

reg syn120m syn3m if em
predict tpresem10y3m, resid
reg syn120m syn24m if em
predict tpresem10y2y, resid

corr dtp120m tpresae10y3m tpresae10y2y if !em
	// tpresae10y3m 0.7505; tpresae10y2y 0.6916
corr dtp120m tpresem10y3m tpresem10y2y if em
	// tpresem10y3m 0.5295; tpresem10y2y 0.3787

gen tpsynr10y3m = .
gen tpsynr10y2y = .
gen tpnomr10y3m = .
gen tpnomr10y2y = .
levelsof $id, local(levels) 
foreach l of local levels {
	quiet reg syn120m syn3m if imf == `l'
	predict tpres3m, resid
	replace tpsynr10y3m = tpres3m if imf == `l'
	
	quiet reg syn120m syn24m if imf == `l'
	predict tpres2y, resid
	replace tpsynr10y2y = tpres2y if imf == `l'
	
	drop tpres3m tpres2y
	
	quiet reg nom120m nom3m if imf == `l'
	predict tpres3m, resid
	replace tpnomr10y3m = tpres3m if imf == `l'
	
	quiet reg nom120m nom24m if imf == `l'
	predict tpres2y, resid
	replace tpnomr10y2y = tpres2y if imf == `l'
	
	drop tpres3m tpres2y
}

corr mtp120m tpnomr10y3m tpnomr10y2y if !em
	// obs=2,290; tpnomr10y3m 0.6576; tpnomr10y2y 0.6231
corr mtp120m tpsynr10y3m tpsynr10y2y if em
	// obs=2,607; tpsynr10y3m 0.3481; tpsynr10y2y 0.2924; even lower values for tpnomr10y3m tpnomr10y2y 


	// Monthly data
reg nom120m nom3m if eomth & !em
predict mtpresae10y3m, resid
reg nom120m nom24m if eomth & !em
predict mtpresae10y2y, resid

reg syn120m syn3m if eomth & em
predict mtpresem10y3m, resid
reg syn120m syn24m if eomth & em
predict mtpresem10y2y, resid

corr mtp120m mtpresae10y3m mtpresae10y2y if !em
	// tpresae10y3m 0.7503; tpresae10y2y 0.6911
corr mtp120m mtpresem10y3m mtpresem10y2y if em
	// tpresem10y3m 0.5275; tpresem10y2y 0.3756


	// Slope
gen slopesyn10y3m = syn120m - syn3m
gen slopenom10y3m = nom120m - nom3m
gen slopesyn10y2y = syn120m - syn24m
gen slopenom10y2y = nom120m - nom24m

corr mtp120m slopesyn10y3m slopenom10y3m if !em
	// obs=2,171; slopesyn1~3m 0.4756; slopenom1~3m 0.5235
corr mtp120m slopesyn10y3m slopenom10y3m if em
	// obs=2,489; slopesyn1~3m 0.0839; slopenom1~3m 0.1847

corr mtp120m slopesyn10y2y slopenom10y2y if !em
	// obs=2,171; slopesyn1~2y 0.4090; slopenom1~2y 0.4294
corr mtp120m slopesyn10y2y slopenom10y2y if em
	// obs=2,514; slopesyn1~2y 0.0271; slopenom1~2y 0.0765


corr mtp120m tpresae10y3m tpresae10y2y slopenom10y3m slopenom10y2y if !em
//              |  mtp120m tpresa~m tpresa~y slopen~m slopen~y
// -------------+---------------------------------------------
//      mtp120m |   1.0000
// tpresae10y3m |   0.7498   1.0000
// tpresae10y2y |   0.6922   0.9357   1.0000
// slopenom1~3m |   0.4617   0.8559   0.8484   1.0000
// slopenom1~2y |   0.3519   0.7176   0.8463   0.9253   1.0000


corr mtp120m tpresem10y3m tpresem10y2y slopesyn10y3m slopesyn10y2y if em
//              |  mtp120m tprese~m tprese~y slopes~m slopes~y
// -------------+---------------------------------------------
//      mtp120m |   1.0000
// tpresem10y3m |   0.5327   1.0000
// tpresem10y2y |   0.3766   0.7363   1.0000
// slopesyn1~3m |   0.0061   0.7241   0.6189   1.0000
// slopesyn1~2y |  -0.0702   0.3991   0.8240   0.7112   1.0000


* ------------------------------------------------------------------------------
* Relationship b/w TP and PHI
* ------------------------------------------------------------------------------
corr dtp* rho* if em
	// positively correlated
corr dtp* phi* if em
	// negatively correlated, correlations fluctuate b/w -0.2 and 0

* ------------------------------------------------------------------------------
* Relationship b/w TP and PHI w/ EPU
* ------------------------------------------------------------------------------
corr dtp* epu if cty == "BRL"
corr phi* epu if cty == "BRL"
// negative w/ TP at long end, negative w/ PHI

corr dtp* epu if cty == "COP"
corr phi* epu if cty == "COP"
// negative w/ both

corr dtp* epu if cty == "KRW"
corr phi* epu if cty == "KRW"
// negative w/ TP, positive w/ PHI

corr dtp* epu if cty == "MXN"
corr phi* epu if cty == "MXN"
// positive w/ TP, negative w/ PHI

corr dtp* epu if cty == "RUB"
corr phi* epu if cty == "RUB"
// negative w/ TP, mixed w/ PHI


* ------------------------------------------------------------------------------
* Relationship b/w TP and PHI w/ Vix
* ------------------------------------------------------------------------------
corr dtp* vix if !em
corr dtp* vix if em

corr phi* vix if !em
corr phi* vix if em

// TP and PHI correlate positively w/ Vix, much stronger for AE
// For EM: PHI more correlated w/ Vix


* ------------------------------------------------------------------------------
* Relationship b/w TP and PHI w/ EPU US, EPU Global, and Global Activity
* ------------------------------------------------------------------------------
corr epuus vix if cty == "CHF"
	// positive 0.446

corr vix epuus epugbl if cty == "CHF"
// obs=229
//              |      vix    epuus   epugbl
// -------------+---------------------------
//          vix |   1.0000
//        epuus |   0.4564   1.0000
//       epugbl |   0.1417   0.3212   1.0000


corr dtp* epuus if !em
corr dtp* epuus if em
corr dtp* epugbl if !em
corr dtp* epugbl if em
// EM: close to zero w/ EPU US
// AE: positive w/ EPU US 
// Both negative w/ EPU global


corr phi* epuus if !em
corr phi* epuus if em
corr phi* epugbl if !em
corr phi* epugbl if em
// mostly positive for both


corr dtp* globalip if em
corr dtp* globalki  if em
corr dtp* globalsc if em
// positive but weak

corr phi* globalip if em
corr phi* globalki  if em
corr phi* globalsc if em
// decreases w/ maturity


levelsof $id, local(levels)
foreach l of local levels {
	di "`l'"
	if !inlist(`l',193,156,146,128,134,112,158,142,196,144) corr dtp120m stp120m if imf == `l'
// 	if !inlist(`l',193,156,146,128,134,112,158,142,196,144) corr dyp120m scbp120m if imf == `l'
}

levelsof $id, local(levels)
foreach v of varlist usyc* ustp* usyp* {
	di "`v'"
	foreach l of local levels {
		di "`l'"
		if !inlist(`l',193,156,146,128,134,112,158,142,196,144) pperron `v' if imf == `l', trend
	}
}

levelsof $id, local(levels)
foreach v of varlist usyc* ustp* usyp* {
	di "`v'"
		pperron `v' if cty == "ZAR", trend
}
