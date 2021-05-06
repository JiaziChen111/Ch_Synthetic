**************************************************************
***** 		Local Projections, an example 				******
**************************************************************

/*
This example program uses local projections to estimate the impulse reponse of 
the ratio of mortgage lending:GDP to a +1% change in the short term interest rate.

Using JST panel data for 17 countries 
http://www.macrohistory.net/data/

Modified HTI June 2017
*/


clear 
set more off

* pull in data from web 
use http://macrohistory.net/JST/JSTdatasetR2.dta


* this file prepares the data with some transformations, and sets the panel
do data 



*******************
** Set-up of LPs **
*******************

***** LHS variable: the response variable
forvalues i=0/4 {
	
	gen mortgdp`i' = (f`i'.mortgdp - l.mortgdp)
	gen gdp`i'	   = (f`i'.lrgdp - l.lrgdp)
	
}

***** variables to store the impulse response (vector of betas from the LP regressions) and standard errors
gen b_mortgdpstir=.
gen b_gdpstir=.
gen se_mortgdpstir=.
gen se_gdpstir=.

* number of lags
local MaxLPLags 2

* horizon
local horizon 4

* controls in LP regression
* exclude contemporaneous lag of impulse (short term rate) and response (mort:GDP)
local rhsmortgdpstir l(1/`MaxLPLags').dstir l(1/`MaxLPLags').dmortgdp ///
						l(0/`MaxLPLags').dltrate l(0/`MaxLPLags').dlhpy ///
						l(0/`MaxLPLags').dlrgdp l(0/`MaxLPLags').dlcpi ///
						l(0/`MaxLPLags').dlriy  l(0/`MaxLPLags').cay ///
						l(0/`MaxLPLags').dnmortgdp 

* exclude contemporaneous lag of impulse (short term rate) and response (GDP)
local rhsgdpstir 	 l(1/`MaxLPLags').dstir l(0/`MaxLPLags').dmortgdp ///
						l(0/`MaxLPLags').dltrate l(0/`MaxLPLags').dlhpy ///
						l(1/`MaxLPLags').dlrgdp l(0/`MaxLPLags').dlcpi ///
						l(0/`MaxLPLags').dlriy  l(0/`MaxLPLags').cay ///
						l(0/`MaxLPLags').dnmortgdp 
					

					
****************************************************************
*** Baseline LP table Using OLS
****************************************************************

* One regression for each horizon of the response (0-4 years)
forvalues i=0/`horizon' {	
	
	* LP regression
	* always exclude war periods with war==0
	* mortgate LP
	xtreg mortgdp`i' dstir `rhsmortgdpstir' ///
		if war==0,  fe cluster(ccode) 
	eststo ols_mortgdpstir`i'

				
	replace b_mortgdpstir  = _b[dstir] if _n == `i'+1
	replace se_mortgdpstir = _se[dstir] if _n == `i'+1
			

	* GDP LP
	xtreg gdp`i' dstir  `rhsgdpstir' ///
		if war==0,  fe cluster(ccode) 
	eststo ols_gdpstir`i'

				
	replace b_gdpstir  = _b[dstir] if _n == `i'+1
	replace se_gdpstir = _se[dstir] if _n == `i'+1
	

			}



* labels for MORTGDP path tables
label var mortgdp0 "Year 0"
label var mortgdp1 "Year 1"
label var mortgdp2 "Year 2"
label var mortgdp3 "Year 3"
label var mortgdp4 "Year 4"
label var dstir "Change in short term interest rate"

* labels for GDP path tables
label var gdp0 "Year 0"
label var gdp1 "Year 1"
label var gdp2 "Year 2"
label var gdp3 "Year 3"
label var gdp4 "Year 4"

esttab ols_mortgdpstir0 ols_mortgdpstir1 ols_mortgdpstir2 ols_mortgdpstir3 ols_mortgdpstir4 ///
	using table_ols_mortggdp.tex , page replace title("Mortgage LP") ///
	se r2 keep(dstir) nonum ///
	b(2) se(2) sfmt(2) obslast  label star(* 0.10 ** 0.05 *** 0.01)

esttab ols_gdpstir0 ols_gdpstir1 ols_gdpstir2 ols_gdpstir3 ols_gdpstir4 ///
	using table_ols_gdp.tex , page replace title("GDP LP") ///
	se r2 keep(dstir) nonum ///
	b(2) se(2) sfmt(2) obslast  label star(* 0.10 ** 0.05 *** 0.01)
	
eststo clear

******************************************************************************
*** Baseline LP table Using IV. Note: Instrument just to illustrate method
*** instrument is weak so SEs blow up
******************************************************************************
gen b_mortgdpstir_iv=.
gen b_gdpstir_iv=.
gen se_mortgdpstir_iv=.
gen se_gdpstir_iv=.

* One regression for each horizon of the response (0-4 years)
forvalues i=0/`horizon' {	
	
	* LP regression
	* always exclude war periods with war==0
	* mortgate LP
	xtivreg2 mortgdp`i' (dstir=drlnarrow) `rhsmortgdpstir' ///
		if war==0,  fe cluster(ccode) 
	eststo iv_mortgdpstir`i'

				
	replace b_mortgdpstir_iv  = _b[dstir] if _n == `i'+1
	replace se_mortgdpstir_iv = _se[dstir] if _n == `i'+1
			

	* GDP LP
	xtivreg2 gdp`i' (dstir=drlnarrow)  `rhsgdpstir' ///
		if war==0,  fe cluster(ccode) 
	eststo iv_gdpstir`i'

				
	replace b_gdpstir_iv  = _b[dstir] if _n == `i'+1
	replace se_gdpstir_iv = _se[dstir] if _n == `i'+1

			}



	
esttab iv_mortgdpstir0 iv_mortgdpstir1 iv_mortgdpstir2 iv_mortgdpstir3 iv_mortgdpstir4 ///
	using table_iv_mortggdp.tex , page replace title("Mortgage LP - IV") ///
	se r2 keep(dstir) nonum ///
	b(2) se(2) sfmt(2) obslast  label star(* 0.10 ** 0.05 *** 0.01)

esttab iv_gdpstir0 iv_gdpstir1 iv_gdpstir2 iv_gdpstir3 iv_gdpstir4 ///
	using table_iv_gdp.tex , page replace title("GDP LP - IV") ///
	se r2 keep(dstir) nonum ///
	b(2) se(2) sfmt(2) obslast  label star(* 0.10 ** 0.05 *** 0.01)

	eststo clear

****************************************************************
*** Baseline OLS LP graphs
****************************************************************


gen Years = _n-1 if _n <= `horizon' +1

local tmortgdp "Mortgage debt to GDP ratio"
local tgdp "GDP"

* zero line
gen zero = 0 if _n <= `horizon' +1

***** create confidence bands (in this case 90 and 95%) ****
	scalar sig1 = 0.05	 // specify significance level
	scalar sig2 = 0.3	 // specify significance level

	gen up_mortgdpstir = b_mortgdpstir + invnormal(1-sig1/2)*se_mortgdpstir if _n <= (`horizon' + 1)
	gen dn_mortgdpstir = b_mortgdpstir - invnormal(1-sig1/2)*se_mortgdpstir if _n <= (`horizon' + 1)

	gen up2_mortgdpstir = b_mortgdpstir + invnormal(1-sig2/2)*se_mortgdpstir if _n <= (`horizon' + 1)
	gen dn2_mortgdpstir = b_mortgdpstir - invnormal(1-sig2/2)*se_mortgdpstir if _n <= (`horizon' + 1)

	gen up_gdpstir = b_gdpstir + invnormal(1-sig1/2)*se_gdpstir if _n <= (`horizon' + 1)
	gen dn_gdpstir = b_gdpstir - invnormal(1-sig1/2)*se_gdpstir if _n <= (`horizon' + 1)

	gen up2_gdpstir = b_gdpstir + invnormal(1-sig2/2)*se_gdpstir if _n <= (`horizon' + 1)
	gen dn2_gdpstir = b_gdpstir - invnormal(1-sig2/2)*se_gdpstir if _n <= (`horizon' + 1)

* label parameters for Y-axis
/*
local lmortgdp -2
local hmortgdp 2
local cmortgdp 0.2

local ltgdp -2
local htgdp 2
local ctgdp 0.2
*/

************************ OLS version **************************************

	twoway (rarea up_mortgdpstir dn_mortgdpstir  Years, ///
	fcolor(gs12) lcolor(white) lpattern(solid)) ///
	(rarea up2_mortgdpstir dn2_mortgdpstir  Years, ///
	fcolor(gs10) lcolor(white) lpattern(solid)) ///
	(line b_mortgdpstir Years, lcolor(blue) ///
	lpattern(solid) lwidth(thick)) /// 
	(line zero Years, lcolor(black)), ///
	title("`tmortgdp'", color(black) size(medium)) ///
	ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
	graphregion(color(white)) plotregion(color(white)) ///
	legend(off) name(mortgdpstir, replace)
	graph save   mortgdp_LP.gph, replace
	
*	ylabel(`lmortgdp'(`cmortgdp')`hmortgdp', nogrid) ///
	

	twoway (rarea up_gdpstir dn_gdpstir  Years, ///
	fcolor(gs12) lcolor(white) lpattern(solid)) ///
	(rarea up2_gdpstir dn2_gdpstir  Years, ///
	fcolor(gs10) lcolor(white) lpattern(solid)) ///
	(line b_gdpstir Years, lcolor(blue) ///
	lpattern(solid) lwidth(thick)) /// 
	(line zero Years, lcolor(black)), ///
	title("`tgdp'", color(black) size(medium)) ///
	ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
	graphregion(color(white)) plotregion(color(white)) ///
	legend(off) name(gdpstir, replace)

*	ylabel(`ltgdp'(`ctgdp')`htgdp', nogrid) ///
	
	graph save   gdp_LP.gph, replace
	
	graph combine mortgdp_LP.gph gdp_LP.gph, col(2) iscale(1) ycommon ///
	title("Local Projection Responses Using OLS")
	graph save OLS_LP.gph, replace

	
****************************************************************
*** Baseline LPIV graphs
****************************************************************




	gen up_mortgdpstir_iv = b_mortgdpstir_iv + invnormal(1-sig1/2)*se_mortgdpstir_iv if _n <= (`horizon' + 1)
	gen dn_mortgdpstir_iv = b_mortgdpstir_iv - invnormal(1-sig1/2)*se_mortgdpstir_iv if _n <= (`horizon' + 1)

	gen up2_mortgdpstir_iv = b_mortgdpstir_iv + invnormal(1-sig2/2)*se_mortgdpstir_iv if _n <= (`horizon' + 1)
	gen dn2_mortgdpstir_iv = b_mortgdpstir_iv - invnormal(1-sig2/2)*se_mortgdpstir_iv if _n <= (`horizon' + 1)

	gen up_gdpstir_iv = b_gdpstir_iv + invnormal(1-sig1/2)*se_gdpstir_iv if _n <= (`horizon' + 1)
	gen dn_gdpstir_iv = b_gdpstir_iv - invnormal(1-sig1/2)*se_gdpstir_iv if _n <= (`horizon' + 1)

	gen up2_gdpstir_iv = b_gdpstir_iv + invnormal(1-sig2/2)*se_gdpstir_iv if _n <= (`horizon' + 1)
	gen dn2_gdpstir_iv = b_gdpstir_iv - invnormal(1-sig2/2)*se_gdpstir_iv if _n <= (`horizon' + 1)


	twoway (rarea up_mortgdpstir_iv dn_mortgdpstir_iv  Years, ///
	fcolor(gs12) lcolor(white) lpattern(solid)) ///
	(rarea up2_mortgdpstir_iv dn2_mortgdpstir_iv  Years, ///
	fcolor(gs10) lcolor(white) lpattern(solid)) ///
	(line b_mortgdpstir_iv Years, lcolor(blue) ///
	lpattern(solid) lwidth(thick)) /// 
	(line zero Years, lcolor(black)), ///
	title("`tmortgdp'", color(black) size(medium)) ///
	ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
	graphregion(color(white)) plotregion(color(white)) ///
	legend(off) name(mortgdpstir, replace)
	graph save   mortgdp_LPIV.gph, replace
	
*	ylabel(`lmortgdp'(`cmortgdp')`hmortgdp', nogrid) ///
	

	twoway (rarea up_gdpstir_iv dn_gdpstir_iv  Years, ///
	fcolor(gs12) lcolor(white) lpattern(solid)) ///
	(rarea up2_gdpstir_iv dn2_gdpstir_iv  Years, ///
	fcolor(gs10) lcolor(white) lpattern(solid)) ///
	(line b_gdpstir_iv Years, lcolor(blue) ///
	lpattern(solid) lwidth(thick)) /// 
	(line zero Years, lcolor(black)), ///
	title("`tgdp'", color(black) size(medium)) ///
	ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) ///
	graphregion(color(white)) plotregion(color(white)) ///
	legend(off) name(gdpstir, replace)

*	ylabel(`ltgdp'(`ctgdp')`htgdp', nogrid) ///
	
	graph save   gdp_LPIV.gph, replace
	
	graph combine mortgdp_LPIV.gph gdp_LPIV.gph, col(2) iscale(1) ycommon ///
	title("Local Projection Responses Using IV")
	graph save IV_LP.gph, replace
	
	graph combine OLS_LP.gph IV_LP.gph, col(1) row(2) iscale(0.5) ysize(6) ///
	title("Local Projection Example: OLS v IV")
	graph save LP.gph, replace
	
	graph export LP.pdf, replace

graph drop _all
