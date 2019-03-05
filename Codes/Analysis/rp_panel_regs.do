*** Begin do file

clear all
set more off

*import excel "\\Client\C$\Users\Pavel\Dropbox\Dissertation\Book\Ch_X\Data\importable_paneltp.xlsx", sheet("importable_paneltp") firstrow
*save "\\Client\C$\Users\Pavel\Dropbox\Dissertation\Book\Ch_X\Data\importable_paneltp.dta", replace

local mainpath "\\Client\C$\Users\Pavel\Dropbox\Dissertation\Book\Ch_X\"
*local mainpath "V:\Users\Pavel\Dropbox\Global-Financial-Cycle\Databases"
*local mainpath "C:\Users\msolism1\Dropbox\Dissertation\Book\Ch_X\Data"
local datapath "Data\importable_paneltp.dta"
local logpath "Docs\Tables\rp_panel_regs.txt"
local pdfpath "Docs\Tables\rp_panel_regs.pdf"
local figpath "Docs\Figures"

use "`mainpath'\\`datapath'"
destring INF UNE IP RSP ROI RFX RSX, replace force

gen log_VIX = ln(VIX)

global id CODE
global t DATE

global x1 log_VIX FFR SPX USTP5 USTP10 OIL CCY RFX STX INF UNE IP

global x21 TP5
global x22 TP10

global x5 log_VIX FFR SPX OIL 
global x61 log_VIX FFR USTP5 SPX OIL
global x62 log_VIX FFR USTP10 SPX OIL
global x7 CCY STX INF UNE IP
global x3 log_VIX FFR SPX OIL CCY STX INF UNE IP
global x41 log_VIX FFR USTP5 CCY STX INF UNE IP
global x42 log_VIX FFR USTP10 CCY STX INF UNE IP

global x43 log_VIX FFR USTP5 RFX STX INF UNE IP
global x44 log_VIX FFR USTP10 RFX STX INF UNE IP

log using "`mainpath'\\`logpath'", text replace

describe $id $t $x1
summarize $x1 
*if ($id != 223) & ($id != 534) & ($id != 548) & ($id != 964) & ($t < tq(2015q4))
correlate $x1

* Set data as panel data
sort $id $t
xtset $id $t
*xtdescribe
*xtsum $id $t $x1

xtreg $x21 $x5, fe vce(robust)
xtreg $x21 $x61, fe vce(robust)
xtreg $x21 $x7, fe vce(robust)
xtreg $x21 $x3, fe vce(robust)
xtreg $x21 $x41, fe vce(robust)
xtreg $x21 $x43, fe vce(robust)

xtreg $x22 $x5, fe vce(robust)
xtreg $x22 $x62, fe vce(robust)
xtreg $x22 $x7, fe vce(robust)
xtreg $x22 $x3, fe vce(robust)
xtreg $x22 $x42, fe vce(robust)
xtreg $x22 $x44, fe vce(robust)

*forvalues j=2/3 {
*	xtreg ${x`j'} x5, fe
*}

log close
translate "`mainpath'\\`logpath'" "`mainpath'\\`pdfpath'"

*** End do file
