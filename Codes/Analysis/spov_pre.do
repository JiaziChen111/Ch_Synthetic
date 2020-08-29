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
	if `j' == 1 local datecond date > td(1jan2000) & date < td(1jan2009)	// target
	if `j' == 4 local datecond date > td(1jan2000) & date < td(1jan2020)	// path
	if `j' == 7 local datecond date > td(1jan2009) & date < td(1jan2020)	// lsap
	
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
matrix rownames tablemps = "Target Shocks (absolute values)" "\quad Target Shocks \(>\) 0" "\quad Target Shocks \(<\) 0" "Path Shocks  (absolute values)" "\quad Path Shocks \(>\) 0" "\quad Path Shocks \(<\) 0" "LSAP Shocks  (absolute values)" "\quad LSAP Shocks \(>\) 0" "\quad LSAP Shocks \(<\) 0"
esttab matrix(tablemps, fmt(1 1 1 1 0)) using x.tex, replace fragment noobs nomtitles nonumbers booktabs
filefilter x.tex y.tex, from(\nPath) to(\n\BSmidrule\nPath) replace
filefilter y.tex "$pathtbls/`tbllbl'.tex", from(\nLSAP) to(\n\BSmidrule\nLSAP) replace
erase x.tex
erase y.tex
// 	hist abs`shock' if cty == "CHF" & fomc & abs`shock' != 0
* ------------------------------------------------------------------------------


// main messages of summary statistics in MP announcement days
// magnitude of shocks is generally less than 10 basis points in absolute value
// shocks are not correlated, but on 18-Mar-2009 large easing path and LSAP shocks
// easing shocks are more common than tightening ones


//     Variable |        Obs        Mean    Std. Dev.       Min        Max
// -------------+---------------------------------------------------------
//       absmp1 |         60    6.634633    9.781944       .001     46.501
//      abspath |        162    6.003316    6.497144     .00873   54.61488
//      abslsap |         81    2.226131    3.620153   .0529064    29.9438


summ abs* if cty == "CHF" & fomc
//     Variable |        Obs        Mean    Std. Dev.       Min        Max
// -------------+---------------------------------------------------------
//       absmp1 |        162    2.457272    6.737498          0     46.501
//      abspath |        162    6.003316    6.497144     .00873   54.61488
//      abslsap |        162    1.113065    2.785438          0    29.9438

summ abs* if cty == "CHF"
//     Variable |        Obs        Mean    Std. Dev.       Min        Max
// -------------+---------------------------------------------------------
//       absmp1 |      4,773    .0834021    1.315123          0     46.501
//      abspath |      4,773    .2037581    1.614358          0   54.61488
//      abslsap |      4,773    .0377785    .5499061          0    29.9438


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
filefilter y.tex x.tex, from(sd) to("S. Dev.") replace
filefilter x.tex y.tex, from(\BS\BS\n) to(\BS\BS\n&) replace
filefilter y.tex x.tex, from(&\BSmidrule\nEmerging) to(\BSmidrule\nEmerging) replace
filefilter x.tex y.tex, from("Emerging Markets") to("Synthetic&Emerging Markets\n%") replace
filefilter y.tex x.tex, from("Advanced Countries") to("&Advanced Countries\n%") replace
filefilter x.tex y.tex, from(Y\BS\BS\n\BSmidrule\nSynthetic&Emerging) to(Y\BS\BS\n\BSmidrule\nNominal&Emerging) replace
filefilter y.tex x.tex, from(&\BSmidrule) to(\BScmidrule(lr){2-8}) replace
filefilter x.tex y.tex, from("Emerging Markets") to("\BSmulticolumn{7}{c}{Emerging Markets}\t\BS\BS") replace
filefilter y.tex x.tex, from("Advanced Countries") to("\BSmulticolumn{7}{c}{Advanced Countries}\t\BS\BS") replace
filefilter x.tex y.tex, from(Nominal) to("\BSmultirow{7}{*}{Nominal Yields}") replace
filefilter y.tex x.tex, from(Synthetic) to("\BSmultirow{7}{*}{Synthetic Yields}") replace
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
filefilter y.tex x.tex, from(8\BS\BS\n\BSmidrule\nAverage) to("8\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Term Premium}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
filefilter x.tex "$pathtbls/`tbllbl'.tex", from(7\BS\BS\n\BSmidrule\nAverage) to("7\BS\BS\n\BSmidrule\n&\BSmulticolumn{6}{c}{Credit Risk Premium}\t\BS\BS\n\BScmidrule(lr){2-7}\nAverage") replace
erase x.tex
erase y.tex
* ------------------------------------------------------------------------------


* ------------------------------------------------------------------------------
* Table: Summary statistics for components of nominal yields - Advanced countries
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
	// obs=302; 12m 0.8997; 60m 0.9581; 120m 0.9480
corr myp120m nom24m syn24m if em
	// obs=2,514; nom24m 0.7392; syn24m 0.7134
corr mtp12m mtp60m mtp120m stp12m stp60m stp120m
	// obs=302; 12m 0.9384; 60m 0.9601; 120m 0.9468


* ------------------------------------------------------------------------------
* Check daily changes after time shift on days w/ large shocks
* ------------------------------------------------------------------------------	
foreach v of varlist sft* usyc* {
  gen d`v' = d.`v'
  }
browse date cty dsftnom120m dsftsyn120m dsftrho120m dusyc120m dsftphi120m if inlist(date,td(18mar2009))
browse date cty dsftnom120m dsftsyn120m dsftrho120m dusyc120m dsftphi120m if inlist(date,td(18mar2009))
browse date cty dsftnom120m dsftsyn120m dsftrho120m dusyc120m dsftphi120m if inlist(date,td(16dec2008))
browse date cty dsftnom120m dsftsyn120m dsftrho120m dusyc120m dsftphi120m if inlist(date,td(9aug2011))
browse date cty dsftnom120m dsftsyn120m dsftrho120m dusyc120m dsftphi120m if inlist(date,td(18sep2013))
browse date cty dsftnom120m dsftsyn120m dsftrho120m dusyc120m dsftphi120m if inlist(date,td(28jan2004))
browse date cty dsftnom120m dsftsyn120m dsftrho120m dusyc120m dsftphi120m if inlist(date,td(6may2003))
browse date cty dsftnom120m dsftsyn120m dsftrho120m dusyc120m dsftphi120m if inlist(date,td(18mar2015))
browse date cty dsftnom120m dsftsyn120m dsftrho120m dusyc120m dsftphi120m if inlist(date,td(15mar2007))


* ------------------------------------------------------------------------------
* Assess TP estimates against empirical measures
* ------------------------------------------------------------------------------
	// Daily data
reg nom120m nom3m if em == 0
predict tpresae10y3m, resid
reg nom120m nom24m if em == 0
predict tpresae10y2y, resid

reg syn120m syn3m if em
predict tpresem10y3m, resid
reg syn120m syn24m if em
predict tpresem10y2y, resid

corr dtp120m tpresae10y3m tpresae10y2y if !em
	// tpresae10y3m 0.7504; tpresae10y2y 0.6938
corr dtp120m tpresem10y3m tpresem10y2y if em
	// tpresem10y3m 0.3811; tpresem10y2y 0.1739

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

corr mtp120m tpnomr10y3m tpnomr10y2y if em == 0
	// obs=2,290; tpnomr10y3m 0.6595; tpnomr10y2y 0.6270
corr mtp120m tpsynr10y3m tpsynr10y2y if em
	// obs=2,646; tpsynr10y3m 0.4284; tpsynr10y2y 0.2429; even lower values for tpnomr10y3m tpnomr10y2y 


	// Monthly data
reg nom120m nom3m if eomth & em == 0
predict mtpresae10y3m, resid
reg nom120m nom24m if eomth & em == 0
predict mtpresae10y2y, resid

reg syn120m syn3m if eomth & em
predict mtpresem10y3m, resid
reg syn120m syn24m if eomth & em
predict mtpresem10y2y, resid

corr mtp120m mtpresae10y3m mtpresae10y2y if em == 0
	// tpresae10y3m 0.7497; tpresae10y2y 0.6917
corr mtp120m mtpresem10y3m mtpresem10y2y if em
	// tpresem10y3m 0.3809; tpresem10y2y 0.1692


	// Slope
gen slopesyn10y3m = syn120m - syn3m
gen slopenom10y3m = nom120m - nom3m
gen slopesyn10y2y = syn120m - syn24m
gen slopenom10y2y = nom120m - nom24m

corr mtp120m slopesyn10y3m slopenom10y3m if em == 0
	// obs=2,171; slopesyn1~3m 0.4738; slopenom1~3m 0.5205
corr mtp120m slopesyn10y3m slopenom10y3m if em
	// obs=2,514; slopesyn1~3m -0.0944; slopenom1~3m -0.0507; similar w/ daily data (obs=52,230)

corr mtp120m slopesyn10y2y slopenom10y2y if em == 0
	// obs=2,171; slopesyn1~2y 0.4093; slopenom1~2y 0.4282
corr mtp120m slopesyn10y2y slopenom10y2y if em
	// obs=2,514; slopesyn1~2y -0.1373; slopenom1~2y -0.1723; similar w/ daily data (obs=52,230)


corr mtp120m tpresem10y3m tpresem10y2y slopesyn10y3m slopesyn10y2y if em
//              |  mtp120m tprese~m tprese~y slopes~m slopes~y
// -------------+---------------------------------------------
//      mtp120m |   1.0000
// tpresem10y3m |   0.3811   1.0000
// tpresem10y2y |   0.1739   0.7233   1.0000
// slopesyn1~3m |  -0.1450   0.7020   0.5834   1.0000
// slopesyn1~2y |  -0.2399   0.3881   0.8227   0.6983   1.0000
// improves after removing BRL, RUB, TRY but remains low


corr mtp120m tpresae10y3m tpresae10y2y slopenom10y3m slopenom10y2y if em == 0
//              |  mtp120m tpresa~m tpresa~y slopen~m slopen~y
// -------------+---------------------------------------------
//      mtp120m |   1.0000
// tpresae10y3m |   0.7504   1.0000
// tpresae10y2y |   0.6938   0.9354   1.0000
// slopenom1~3m |   0.4584   0.8548   0.8470   1.0000
// slopenom1~2y |   0.3500   0.7164   0.8454   0.9250   1.0000


* ------------------------------------------------------------------------------
* Relationship b/w TP and PHI
* ------------------------------------------------------------------------------
corr dtp* rho* if em
	// positively correlated
corr dtp* phi* if em
	// negatively correlated, correlations fluctuate b/w -0.4 and -0.5

* ------------------------------------------------------------------------------
* Relationship b/w TP and PHI w/ EPU
* ------------------------------------------------------------------------------
corr dtp* epu if cty == "BRL"
corr phi* epu if cty == "BRL"
//              |    dtp3m    dtp6m   dtp12m   dtp24m   dtp60m  dtp120m      epu
// -------------+---------------------------------------------------------------
//          epu |  -0.0133   0.0275   0.0665   0.0764   0.0306  -0.0133   1.0000

//              |    phi3m    phi6m   phi12m   phi24m   phi60m  phi120m      epu
// -------------+---------------------------------------------------------------
//          epu |  -0.1082  -0.1475*  -0.1022  -0.1504*  -0.1083   0.0994   1.0000
// unrelated w/ TP, negative w/ PHI

corr dtp* epu if cty == "COP"
corr phi* epu if cty == "COP"
//              |    dtp3m    dtp6m   dtp12m   dtp24m   dtp60m  dtp120m      epu
// -------------+---------------------------------------------------------------
//          epu |   0.0755   0.1093   0.1484*   0.1886**   0.2971***   0.4083***   1.0000

//              |    phi3m    phi6m   phi12m   phi24m   phi60m  phi120m      epu
// -------------+---------------------------------------------------------------
//          epu |  -0.0498  -0.0602  -0.0827  -0.0496   0.0491  -0.1089   1.0000
// positive w/ TP

corr dtp* epu if cty == "KRW"
corr phi* epu if cty == "KRW"
//              |    dtp3m    dtp6m   dtp12m   dtp24m   dtp60m  dtp120m      epu
// -------------+---------------------------------------------------------------
//          epu |  -0.3206  -0.3280  -0.3420  -0.3671  -0.3789  -0.3241   1.0000 All ***

//              |    phi3m    phi6m   phi12m   phi24m   phi60m  phi120m      epu
// -------------+---------------------------------------------------------------
//          epu |   0.1766**   0.2224   0.2350   0.2346   0.2597   0.3117   1.0000 Rest ***
// negative w/ TP, positive w/ PHI

corr dtp* epu if cty == "MXN"
corr phi* epu if cty == "MXN"
//              |    dtp3m    dtp6m   dtp12m   dtp24m   dtp60m  dtp120m      epu
// -------------+---------------------------------------------------------------
//          epu |   0.3725   0.3650   0.3543   0.3512   0.3970   0.4575   1.0000 All ***

//              |    phi3m    phi6m   phi12m   phi24m   phi60m  phi120m      epu
// -------------+---------------------------------------------------------------
//          epu |  -0.2584  -0.2441  -0.1854**  -0.1525**  -0.1918**  -0.3642   1.0000 Rest ***
// positive w/ TP, negative w/ PHI

corr dtp* epu if cty == "RUB"
corr phi* epu if cty == "RUB"
//              |    dtp3m    dtp6m   dtp12m   dtp24m   dtp60m  dtp120m      epu
// -------------+---------------------------------------------------------------
//          epu |   0.1820**   0.2446   0.2796   0.2525   0.1440*   0.0550   1.0000 Rest *** except last

//              |    phi3m    phi6m   phi12m   phi24m   phi60m  phi120m      epu
// -------------+---------------------------------------------------------------
//          epu |  -0.0119   0.0125   0.0424   0.0465   0.1882**   0.1732**   1.0000
// positive w/ both


* ------------------------------------------------------------------------------
* Relationship b/w TP and PHI w/ Vix
* ------------------------------------------------------------------------------
corr dtp* vix if em
// obs=54,995
corr dtp* vix if em == 0
// obs=47,730
//              |    dtp3m    dtp6m   dtp12m   dtp24m   dtp60m  dtp120m      vix
// -------------+---------------------------------------------------------------
//          vix |   0.0183   0.0045   0.0062   0.0305   0.1043   0.1665   1.0000 All *** except 2nd/3rd
//          vix |   0.2972   0.2992   0.2960   0.2901   0.3003   0.3102   1.0000

corr phi* vix if em
// obs=52,230
corr phi* vix if em == 0
// obs=45,267
//              |    phi3m    phi6m   phi12m   phi24m   phi60m  phi120m      vix
// -------------+---------------------------------------------------------------
//          vix |  -0.0693  -0.0002   0.1103   0.1805   0.1707   0.0139   1.0000 All *** except 2nd
//          vix |   0.2971   0.3295   0.2896   0.3315   0.2654  -0.1180   1.0000

// TP and PHI correlate positively w/ Vix, much stronger for AE
// For EM: PHI more correlated w/ Vix for 1Y, 2Y, 5Y
// For EM: TP more correlated w/ Vix for 10Y


* ------------------------------------------------------------------------------
* Relationship b/w TP and PHI w/ EPU US, EPU Global, and Global Activity
* ------------------------------------------------------------------------------
corr epuus vix if cty == "CHF"
	// positive 0.44

corr vix epuus epugbl if cty == "CHF"
// obs=229
//              |      vix    epuus   epugbl
// -------------+---------------------------
//          vix |   1.0000
//        epuus |   0.4564   1.0000
//       epugbl |   0.1417   0.3212   1.0000


corr dtp* epuus if em
// obs=54,995
corr dtp* epuus if em == 0
// obs=47,730
corr dtp* epugbl if em
// obs=2,646
corr dtp* epugbl if em == 0
// obs=2,290
//              |    dtp3m    dtp6m   dtp12m   dtp24m   dtp60m  dtp120m      vix
// -------------+---------------------------------------------------------------
//        epuus |  -0.0664  -0.0938  -0.1026  -0.0956  -0.0624  -0.0277   1.0000 All ***
//        epuus |   0.1130   0.0960   0.0717   0.0544   0.0719   0.0935   1.0000 All ***
//       epugbl |  -0.1030  -0.1317  -0.1540  -0.1837  -0.2215  -0.2320   1.0000 All ***
//       epugbl |  -0.2841  -0.3244  -0.3751  -0.4158  -0.4274  -0.4179   1.0000 All ***
// EM: negative but stronger w/ EPU global
// AE: positive w/ EPU US but negative w/ EPU global


corr phi* epuus if em
// obs=52,230
corr phi* epuus if em == 0
// obs=45,267
corr phi* epugbl if em
// obs=2,514
corr phi* epugbl if em == 0
// obs=2,177
//              |    phi3m    phi6m   phi12m   phi24m   phi60m  phi120m      vix
// -------------+---------------------------------------------------------------
//        epuus |   0.0283   0.0716   0.1355   0.1785   0.1742   0.1013   1.0000 All ***
//        epuus |   0.1230   0.1393   0.1172   0.1130   0.0543  -0.1279   1.0000 All ***
//       epugbl |  -0.0050  -0.0090  -0.0184  -0.0049   0.0401**   0.1221***   1.0000
//       epugbl |   0.1349   0.1449   0.1346   0.0673  -0.1524  -0.1418   1.0000 All ***
// EM: positive



corr dtp* globalip if em
corr dtp* globalki  if em
corr dtp* globalsc if em
// obs=2,646
//              |    dtp3m    dtp6m   dtp12m   dtp24m   dtp60m  dtp120m      vix
// -------------+---------------------------------------------------------------
//     globalip |   0.0639   0.0780   0.0889   0.0888   0.0446  -0.0007   1.0000
//     globalki |   0.0468   0.0727   0.1134   0.1698   0.2337   0.2495   1.0000
//     globalsc |   0.1089   0.1357   0.1550   0.1653   0.1428   0.1065   1.0000
// positive and strong

corr phi* globalip if em
corr phi* globalki  if em
corr phi* globalsc if em
// obs=2,514
//              |    phi3m    phi6m   phi12m   phi24m   phi60m  phi120m      vix
// -------------+---------------------------------------------------------------
//     globalip |   0.1159   0.1186   0.1016   0.0718   0.0209x  -0.0135x   1.0000
//     globalki |   0.1116   0.1271   0.1187   0.1059   0.0218x  -0.1073   1.0000
//     globalsc |   0.0479   0.0182x  -0.0825  -0.1201  -0.1749  -0.1892   1.0000
// positive and turn negative




levelsof $id, local(levels)
// foreach t in 3 24 {
	foreach l of local levels {
		di "`l'"
// 		if !inlist(`l',193,156,146,128,134,112,158,142,196,144) pwcorr dtp`t'm phi`t'm if imf == `l', sig
		if !inlist(`l',193,156,146,128,134,112,158,142,196,144) summ dtp* if imf == `l'
	// 	if !inlist(`l',233,536,922,964) corr dtp120m phi120m if imf == `l'
	}
// }


// levelsof $id, local(levels)
// foreach l of local levels {
// 	di "`l'"
// 	summ `ycs' if imf == `l' & eomth
// }
