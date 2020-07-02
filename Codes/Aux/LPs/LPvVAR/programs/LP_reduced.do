********************************************************************************
*** Local Projections
********************************************************************************

*****************************************************************
* 1. Analysis preparation
*****************************************************************

* define impulse and response variables
local rvar y p pcom ff nbr tr m1
local ivar ff

* define control set
local con l1y l2y l3y l1p l2p l3p l1pcom l2pcom l3pcom l1ff l2ff l3ff ///
				l1nbr l2nbr l3nbr l1tr l2tr l3tr l1m1 l2m1 l3m1 

* create lags of each of the variables				
forvalues i=1/3 {
	foreach v of local rvar {
	gen l`i'`v' = l`i'.`v'
	}
}

* generate variables for estimate storage
foreach y of local rvar {
		
	gen br`y'ff = 0 
	gen ser`y'ff = 0 

}

* hard data drop
drop if d<yq(1960,1) | d>yq(2006,1)

*************************************************************
* 2. Estimate reduced form LPs
*************************************************************

* nbr data missing for 2008
forvalues k=12/15 {

	replace nbr`k'=. if d>yq(2005,1)
}
foreach y of local rvar {
	forvalues i=0/15 {
		
		newey `y'`i' `con', lag(2)
				
		replace br`y'ff = _b[l1ff] if _n==`i'+2
		replace ser`y'ff = _se[l1ff] if _n==`i'+2

	}
}

* create reduced form = r label for graph file
global t1 reduced 
global t2 r
