*** Begin do file

clear all
set more off

import excel "/Users/Pavel/Documents/GitHub/Book/Ch_Synthetic/Data/Raw/importable_paneltp.xlsx", sheet("Sheet1") firstrow
save "/Users/Pavel/Documents/GitHub/Book/Ch_Synthetic/Data/Raw/importable_paneltp.dta", replace
local mainpath "/Users/Pavel/Documents/GitHub/Book/Ch_Synthetic/"
local datapath "Data/Raw/importable_paneltp.dta"
local logpath "Docs/Tables/tp_panel_regs.txt"
local pdfpath "Docs/Tables/tp_panel_regs.pdf"
local figpath "Docs/Figures/Temp/"

use "`mainpath'//`datapath'"
*use "/Users/Pavel/Documents/GitHub/Book/Ch_Synthetic/Data/Raw/importable_paneltp.dta"

* Change format of dates and some rename variables
gen date2 = date(DATE,"DMY")
format date2 %td
drop DATE
order date2, before(CODE)
rename date2 DATE
rename TPUS USTP10

* Set data as panel data
global id CODE
global t DATE
sort $id $t
xtset $id $t

* Compute monthly returns
gen log_SPX = ln(SPX)
gen log_VIX = ln(VIX)
gen log_OIL = ln(OIL)
gen log_CCY = ln(CCY)
gen log_STX = ln(STX)
by $id: gen RSP = (log_SPX - log_SPX[_n-1])*100
by $id: gen ROI = (log_OIL - log_OIL[_n-1])*100
by $id: gen RFX = (log_CCY - log_CCY[_n-1])*100
by $id: gen RSX = (log_STX - log_STX[_n-1])*100

/* Standarize the exchange rate
egen meanCCY = mean(CCY), by(CODE)
egen stdCCY  = sd(CCY), by(CODE)
gen zCCY     = (CCY - meanCCY) / stdCCY */

* Label variables, labels are used with outreg2
label variable CODE "Countries"
label variable STX "Stock Market"
label variable SPX "S\&P"
label variable OIL "Oil"
label variable USTP10 "USTP10"
label variable log_VIX "log(Vix)"
*label variable zCCY "zCCY"
label variable RSP "Return S\&P"
label variable ROI "Return Oil"
label variable RFX "Return FX"
label variable RSX "Return Stocks"


log using "`mainpath'//`logpath'", text replace
*log using "/Users/Pavel/Documents/GitHub/Book/Ch_Synthetic/Docs/Tables/tp_panel_regs.txt", text replace

* Define variables
global y1 TP
global y2 log_VIX FFR USTP10 SPX INF UNE IP STX OIL
global x1 log_VIX FFR RSP ROI
global x2 log_VIX FFR USTP10 RSP ROI
global x3 INF UNE IP RFX RSX
global x4 log_VIX FFR RSP ROI INF UNE IP RFX RSX
global x5 log_VIX FFR USTP10 RSP INF UNE IP RFX RSX
global x6 log_VIX FFR USTP10 INF UNE IP RFX RSX
*global x7 log_VIX FFR RSP ROI INF UNE IP RFX RSX
global x8 log_VIX FFR USTP10 RSP ROI INF UNE IP RFX RSX

* Summary statistics
describe $id $t $y2
summarize $y2
correlate $y2
xtdescribe
xtsum $id $t $y2

* Panel regressions
/*xtreg $y1 $x1, fe vce(robust)
xtreg $y1 $x2, fe vce(robust)
xtreg $y1 $x3, fe vce(robust)
xtreg $y1 $x4, fe vce(robust)
xtreg $y1 $x5, fe vce(robust)
xtreg $y1 $x6, fe vce(robust)
xtreg $y1 $x7, fe vce(robust)
xtreg $y1 $x8, fe vce(robust)*/

* Save output in Excel file
xtreg $y1 $x1, fe vce(cluster $id)
outreg2 using tp_regs.xls, replace label dec(2) addtext(Country FE, Yes, Time FE, No)
xtreg $y1 $x2, fe vce(cluster $id)
outreg2 using tp_regs.xls, replace label dec(2) addtext(Country FE, Yes, Time FE, No)
xtreg $y1 $x3, fe vce(cluster $id)
outreg2 using tp_regs.xls, append label dec(2) addtext(Country FE, Yes, Time FE, No)
xtreg $y1 $x4, fe vce(cluster $id)
outreg2 using tp_regs.xls, append label dec(2) addtext(Country FE, Yes, Time FE, No)
xtreg $y1 $x5, fe vce(cluster $id)
outreg2 using tp_regs.xls, append label dec(2) addtext(Country FE, Yes, Time FE, No)
*xtreg $y1 $x7, fe vce(cluster $id)
*outreg2 using tp_regs.xls, append label dec(2) addtext(Country FE, Yes)
xtreg $y1 $x8, fe vce(cluster $id)
outreg2 using tp_regs.xls, append label dec(2) addtext(Country FE, Yes, Time FE, No)
xtreg $y1 $x8 i.DATE, fe vce(cluster $id)
outreg2 using tp_regs.xls, append label keep($x8) addtext(Country FE, Yes, Time FE, Yes)

* Test whether the time FE belong to the model
testparm i.DATE

log close
translate "`mainpath'//`logpath'" "`mainpath'//`pdfpath'", replace

*** End do file
