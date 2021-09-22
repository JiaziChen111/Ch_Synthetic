*******************
* LOCAL PROJECTIONS FROM JORDA (2005)
* CHITRA MARTI
* BASED ON HELEN IRVIN'S CODE IN LPs_basic_doall.do
* LAST UPDATE: March 2018
*******************
cap program drop lp
program define lp, eclass byable(recall) 
	version 14.1
	preserve //so we don't overwrite your dataset
	ereturn clear
		
	# delimit ;
	syntax varlist(min=2 fv ts) [if] [in]
	,
	[
	INSTrument(varlist min=1)
	CUMulative
	HORizon(integer 12) 
	DK(integer -1) 
	NEWey(integer -1) 
	CLUSTer(varname) 
	Robust
	FE
	NOCONStant
	SAVE(string)
	PRINT
	GRAPH
	CONFidence(real 0.95)
	SHIFT
	]
	;
	# delimit cr
	
	tokenize `varlist'
	local respvar `1'
	local shock `2'
	macro shift 2
	local controlvars "`*'"
	
	
	* If "shift" is specified, we want the 0th horizon to have a coefficient of zero
	if "`shift'" != "" {
		local shift = 1
	}
	else {
		local shift = 0
	}
	*
	*local horizon = `horizon' + `shift'

	
	** TEMPORARY MATRICES TO STORE RESULTS
	tempname matcoef matse
	
	matrix `matcoef' = J(1, `horizon'+1,0)
	matrix `matse' = J(1, `horizon'+1,0)
	
	** DATA MUST BE TSSET (XTSET OPTIONAL)
	qui xtset
	local it = "`r(timevar)'"
	local ix = "`r(panelvar)'" 
	if ("`it'" == "") {
		di as err "time variable not set"
	}
	*
	qui xtset
	tokenize "`r(tdeltas)'"
	local ittitle "`2'" //"month", for example	

	
	** Get Variable Labels
	cap local resptitle: variable label `respvar'
	cap local shocktitle: variable label `shock' //breaks here if the shock is a lag.
	if "`resptitle'" == "" {
		local resptitle "`respvar'"
	}
	if "`shocktitle'" == "" {
		local shocktitle "`shock'"
	}	
	if "`instrument'" != "" {
		cap local insttitle: variable label `instrument'
		if "`insttitle'" == "" {
			local insttitle "`instrument'"
		}
		*
		local subtitle "Instrumented by `insttitle'"
	}
	*
	*
	
	** CHOOSE THE SAMPLE
	marksample touse, novarlist
	markout `touse' `respvar' `shock' `instrument' `controlvars'

	* Confidence Level
	local conf100 = `confidence'*100
	local cinorm = invnormal(`confidence')

	
	* if the control variable has an l[N]. or d., make it nice
	di "`controlvars'"
	local cvars ""
	local c = 1
	foreach var in `controlvars' {
		if strpos("`var'",".") != 0 {
			tempvar `c'
			gen ``c'' = `var'
			local varnam "``c''"
		}
		else {
			local varnam "`var'"
		}
		*
		*
		local cvars "`cvars' `varnam'"
		local ++c
	}
	*	
	* Regression Type
	* command: stores the starting regression type
	* options: stores the options we'll require because of this regression type

	* Newey: same command for OLS and IV
	if ("`newey'" != "-1") {
		local type "newey"
		qui ssc install newey2
		local command newey2
		if (`newey' < 0) {
			di as err "Number of lags for Newey-West errors must be a positive integer"
			exit 459
		}
		local opt "lag(`newey') force"
		*
	}

	* Driscoll-Kraay Errors
	* First, verify the panel variable
	else if ("`dk'" != "-1") {
		if ("`ix'" == "") {
			di as err "Panel variable not set"
			exit 459
		}
		if ("`instrument" != "") {
			local command "ivreg2"	
		}
		*
		else {
			local command "xtscc"
		}
		*
		if (`dk' > 0) {
			local opt "`opt' dkraay(`dk')"
		}
	}
	*

	* Cluster: Gets tacked onto whatever you already have
	if "`cluster'" != ""{
		local opt "`opt' cluster(`cluster')"
	}
	*
	

	* Robust: also tack on	
	if "`robust'" != ""{
		local opt " `opt' robust"
	}
	

	* Plain Fixed Effects
	if ("`fe'" != "") {
		if ("`command'" == "") {	
			if ("`instrument'" != "") {
				local command "xtivreg2"
			}
			*
			else {
				local command "xtreg"
			}
		}
		if "`dk'" == "" {
			local opt "`opt' fe"
		}
		*
	}
	*

	if "`command'" == "" {
		if ("`instrument'" != "") {
			local command "ivreg2"
		}
		*
		else {
			local command "reg"
		}
		*
	}
	*
	
	** GENERATE THE LHS VARIABLES
	if "`cumulative'" != "" {
		tempvar `respvar'0
		qui gen ``respvar'0' = `respvar' - l.`respvar'
		forvalues h=1/`horizon' {
			tempvar `respvar'`h'
			qui gen ``respvar'`h'' = f`h'.`respvar' - l.`respvar'
		}
	}
	*
	tempvar
	else { //default is the forward variable
		tempvar `respvar'0
		qui gen ``respvar'0' = `respvar'
		forvalues h=1/`horizon' {
			tempvar `respvar'`h'
			qui gen ``respvar'`h'' = f`h'.`respvar'
		}
	}
	*

	*** INSTRUMENT IF NECESSARY
	if "`instrument'" != "" {
		local shockcmd "(`shock' = `instrument')"
	}
	*
	else {
		local shockcmd "`shock'"
	}
	*

	
	*di "eststo reg`h': `command' ``respvar'`h'' `shockcmd' `c' if `touse', `opt' `noconstant'"
	forv h = 0/`horizon' {
		qui eststo, title("h=`h'"): qui `command' ``respvar'`h'' `shockcmd' `cvars' if `touse', `opt' `noconstant'
			
		** Store the Results
		mat `matcoef'[1, `h'+1] = _b[`shock']
		mat `matse'[1, `h'+1] = _se[`shock']
		local colnames `colnames' "h=`h'"
		local N = `e(N)' //this will be the last horizon's # of observations
	}
		
	** PRINTING RESULTS
	if "`print'" != "" {		
		mat colnames `matcoef' = `colnames'
		mat colnames `matse' = `colnames'
		
		mat coef = `matcoef'
		mat se = `matse'
		ereturn post coef
		qui estadd mat se
		qui estadd scalar N `N'
		eststo outmat
		cap eststo `save'
		cap mat drop coef 
		cap mat drop se
		esttab outmat, b se mtitles("Coefficient at Horizon") nonumbers
		cap eststo drop outmat
	} 
	*	
		
	** GRAPHING
	* for now, not very customizable
	if "`save'" != "" {
		local savecmd "saving("`save'", replace)"
	}
	*
	if "`graph'" != "" {
		tempvar hz zero coef se upp low
		
		qui gen `hz' = _n - 1
		qui gen `zero' = 0
		qui gen `coef' = 0 in 1
		qui gen `se' = 0 in 1
		qui gen `upp' = .
		qui gen `low' = . 
		
		forv h = 0/`horizon' {
			qui replace `coef' = `matcoef'[1,`h'+1] if `hz' == `h' + `shift'
			qui replace `se' = `matse'[1,`h'+1] if `hz' == `h' + `shift'
		}
		*
	
		
		* Confidence Intervals as Specified
		qui replace `upp' = `coef' + `cinorm'*`se'
		qui replace `low' = `coef' - `cinorm'*`se'
		# delimit ;
		qui keep if _n <= `horizon' + 1; 
		graph twoway 
			rarea `upp' `low' `hz',
					fcolor(gs10) lcolor(white) lpattern(solid) lwidth(medium)
			|| line `coef' `hz',
				lcolor(black)
			|| line `zero' `hz',
				lcolor(black) lwidth(thin)
			legend(off)
			title("Response of `resptitle'")
			subtitle("Shock from `shocktitle'")
			xtitle("Horizon (`ittitle')")
			ytitle("`resptitle'")
			note("`subtitle'")
			graphregion(color(white))
			`savecmd'
		;
		# delimit cr
	}
	*
	
	* allow the user to specify multiple equations under parentheses
	
	
* lp responsevariable shockvariable controlvariables, 
* option: cumulative vs. differenced y variable
* RHS types: shock varaible (directly observed)
* endogenous variables
* instrumental variables
* user specified list of controls
* option: horizon
* make everything else a post estimation command
end

*
