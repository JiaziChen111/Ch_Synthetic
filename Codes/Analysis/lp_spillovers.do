* Code for 'Emerging Markets Sovereign Yields and U.S. Monetary Policy' 
* by Pavel Solís, June 2020
* \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////////////////


* ==============================================================================
* Preamble
* ==============================================================================
* Define working directories and filenames
cd "/Users/Pavel/Documents/GitHub/Book/Ch_Synthetic"	// Update as necessary
local pathmain `c(pwd)'
/* Mac OS */
global pathdata "`pathmain'/Data/Analytic"
global pathcode "`pathmain'/Codes/Analysis"
global pathtbls "`pathmain'/Docs/Tables"
global pathfigs "`pathmain'/Docs/Figures"
global pathfltx "`pathmain'/Docs/Figures/Latex"
cd $pathdata


* ==============================================================================
* Load/clean dataset and generate variables
* ==============================================================================
set excelxlsxlargefile on
import excel using dataspillovers.xlsx, clear firstrow case(lower)
gen date = dofc(time)
gen datem = mofd(dofc(time))					// used to label graphs
format date %td
format datem %tmCCYY
order date, first
drop time
order cty, after(date)

* Label variables that will be used in figures and tables
#delimit ;
local oldlabels mp1;
local newlabels `" "US MPS" "';
#delimit cr
local nlbls : word count `oldlabels'
forvalues i = 1/`nlbls' {
	local a : word `i' of `oldlabels'
	local b : word `i' of `newlabels'
	label variable `a' "`b'"
}

save dataspillovers.dta, replace
use dataspillovers.dta, clear


* ==========================================================================
* Create the Panel Dataset
* ==========================================================================

global id imf
global t date
sort $id $t
xtset $id $t

* MP shocks
pwcorr mp1 path lsap if cty == "GBP", sig // not statistically different from zero
summ mp1 path lsap if cty == "GBP"
line mp1 path lsap date if cty == "GBP"

xtreg D.nom120m mp1 if em == 1, fe
xtreg D.syn120m mp1 if em == 1, fe
xtreg D.nom120m mp1 if em == 0, fe

xtreg D.dyp120m mp1 if em == 1, fe
xtreg D.dyp120m mp1 if em == 0, fe

xtreg D.dtp120m mp1 if em == 1, fe
xtreg D.dtp120m mp1 if em == 0, fe

xtreg D.phi120m mp1 if em == 1, fe






