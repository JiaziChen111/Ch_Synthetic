/* Code for 'Spillovers of U.S. Monetary Policy to Emerging Market Sovereign Yields' 
by Pavel Solís, July 2020

This code uses local projections to estimate the reponse of the bond yields of
emerging markets to a 1 basis point change in the the target, path and LSAP shocks */
* ==============================================================================


* ------------------------------------------------------------------------------
* Preamble (uses Mac OS directory convention)
* ------------------------------------------------------------------------------
cd "/Users/Pavel/Documents/GitHub/Book/Ch_Synthetic"	// Update as necessary
local pathmain `c(pwd)'

global pathdlfs "/Users/Pavel/Dropbox/Dissertation/Book-DB-Sync/Ch_Synt-DB/Codes-DB/August-2020"
global pathdata "`pathmain'/Data/Analytic"
global pathcode "`pathmain'/Codes/Analysis"
global pathtbls "`pathmain'/Docs/Tables"
global pathfigs "`pathmain'/Docs/Figures"
cd $pathdata

global file_src  "$pathdata/dataspillovers.xlsx"
global file_dta1 "$pathdlfs/dataspillovers1.dta"	// original dataset
global file_dta2 "$pathdlfs/dataspillovers2.dta"	// dataset after housekeeping
global file_log  "$pathtbls/impact_regs"
global file_tbl  "$pathtbls/impact_tbls"

* ------------------------------------------------------------------------------
* Dataset
* ------------------------------------------------------------------------------
do "$pathcode/spov_data"
do "$pathcode/spov_vars"
use $file_dta2, clear


* ------------------------------------------------------------------------------
* Analysis
* ------------------------------------------------------------------------------
log using $file_log, replace
do "$pathcode/spov_pre"
do "$pathcode/spov_regs"
log close
translate $file_log.smcl $file_log.pdf, replace


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


* ------------------------------------------------------------------------------
* Packages
* ------------------------------------------------------------------------------
// ssc install xtcsd, replace	// to perform the Pesaran’s CD test of cross-sectional independence in FE panel models
// ssc install xtscc, replace	// to get DK standard errors for FE panel models


* ------------------------------------------------------------------------------
* Sources
* ------------------------------------------------------------------------------
// Standard errors corrected for heteroskedasticity and autocorrelation
// https://www.statalist.org/forums/forum/general-stata-discussion/general/
// 1475615-newey-regression-for-panel-data

// Accesssing values of confidence intervals
// https://www.statalist.org/forums/forum/general-stata-discussion/general/
// 1304264-quickly-accessing-p-values-and-confidence-interval-limits

// Accessing values in a matrix identified by row name and column name
// https://www.stata.com/statalist/archive/2009-03/msg01179.html

// Handling gaps in time series using business calendars
// https://blog.stata.com/2016/02/04/handling-gaps-in-time-series-using-business-calendars/
// https://www.stata.com/manuals13/dbcal.pdf
// https://www.stata.com/manuals13/tstsset.pdf
// https://www.stata.com/statalist/archive/2005-08/msg00479.html

// Time trend in panel data
// https://www.statalist.org/forums/forum/general-stata-discussion/general/1317069-time-trend-in-panel-data

// Country-specific time trends
// https://www.statalist.org/forums/forum/general-stata-discussion/general/1376523-country-specific-time-trends

// Create a group variable
// https://www.statalist.org/forums/forum/general-stata-discussion/general/
// 1355976-how-can-i-create-groups-of-observations-in-a-panel-data

// Use -inlist- with local list
// https://www.statalist.org/forums/forum/general-stata-discussion/general/
// 1315256-use-inlist-with-local-list
