**** Example of How to use the LP ado file

/* ReadMe:
How to Use the LP ado file

The syntax is:

lp (response variable) (shock variable) [if] [in], options

For example, if you want the response of inflation to monetary policy shocks, 
you would have lp y x, where the regression takes the form

y ~ x + c

where y is the response variable, x is the shock variable, and c is controls,
including a constant

Time series and panel data are allowed



Options:

INSTrument: Will instrument the shock variable by the instrument specified

CUMulative: The default left-hand side at horizon H is the forward value 
of the response variable at time t+H, i.e. y(t+h)
Cumulative changes so that the LHS variable is now the difference between 
y(t+h) - y(t-1). Thus we get a cumulative response of y to the shock variable

HORizon: How long of a horizon you would like for the impulse response function.
Default is 12 (12 months if monthly, three years if quarterly, and 12 years 
if annual)

DK(integer), Newey(integer), Cluster, Robust: Various standard error/robustness 
options. DK refers to Driscoll-Kraay type errors. Both DK and Newey require a 
specified integer number of lags

NOCONStant: Constant excluded from regression

SAVE(string): Saves the regression results under an estimates store using the 
name specified, and the graph using the same name (not customizable at the moment)

PRINT: prints a clean table with results at all horizons, with simply the 
coefficient at each horizon

GRAPH: 
** Note: if afterwards you want to save the graph, you can simply follow up
the lp command with a "graph save" or "graph export" command. The graph will be
active, so you can manipulate it using graph edit tools in Stata
** Note for Noah: consider adding graphoptions

CONFidence(real 0.95): Confidence interval for graph. 

SHIFT: manually sets the horizon 0 to have an impact response of zero,
and shifts the contemporaneous impact (i.e. y(t)) to horizon 1.

*/


cls
eststo clear

cd "C:\Users\l1nak01\Dropbox (FRB SF)\LP ado file\Local Projections ado"
use ".\data\testdata.dta", clear

* Note, the shock variable has to come second (even if it is in a lag collection)
* in order for the program to recognize what is the shock
gen ldstir = l.dstir

label var ldstir "Lagged STIR"
label var dlgdpr "Differenced Lagged GDPR"

lp_db dlgdpr ldstir l(1/3).dlgdpr l(1/3).dlcpi l(2/3).dstir cpi, hor(4) graph print shift dk(12) newey(4) save(dlgdpr)
lp_db dlcpi ldstir l(0/3).dlgdpr l(1/3).dlcpi l(2/3).dstir , fe cluster(iso) hor(4) graph print shift save(dlcpi)
lp_db dstir dstir l(0/3).dlgdpr l(0/3).dlcpi l(1/3).dstir, fe cluster(iso) hor(5) graph print save(dstir)





