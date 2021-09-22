********************************************************************************
*** Local Projections
********************************************************************************

*****************************************************************
* 1. Analysis preparation
*****************************************************************

* define the Cholesky ordering 
local pos1	y
local pos2	p
local pos3	pcom
local pos4	ff
local pos5	nbr
local pos6	tr
local pos7	m1

global `pos1' 1
global `pos2' 2
global `pos3' 3
global `pos4' 4
global `pos5' 5
global `pos6' 6
global `pos7' 7

* define t+h variables to be placed in control locals based on Cholesky ordering 
forvalues i=0/15 {
	forvalues j=1/7 {
	
	local f`i'`j' `pos`j''`i'

	}
}

* define impulse and response variables
local rvar y p pcom ff nbr tr m1
local ivar ff

* control set of the 1st, 2nd, and 3rd lag included in every regression	
foreach y of local rvar {	

	local lag123 `lag123' l(1/3).`y'
	}

* generate variables for estimates
foreach y of local rvar {

	gen bs`y'ff = 0 
	gen ses`y'ff = 0 
}

*** define variable specfic control sets
foreach y of local rvar {

	local k = ${`y'}-1
	
	forvalues k=0/`k' {
		forvalues i=0/15 {
			// set of t+h controls if ahead in the Cholesky ordering
			local con`y'`i' `con`y'`i'' `f`i'`k''
		}
	}
}

* hard data drop
drop if d<yq(1960,1) | d>yq(2006,1)

*************************************************************
* 2. Estimate structural form LPs
*************************************************************

* nbr data missing for 2008
forvalues k=12/15 {

	replace nbr`k'=. if d>yq(2005,1)
}

foreach y of local rvar {
	
	local k = ${`y'}
	
	forvalues i=0/14 {
		
		newey `y'`i' `con`y'`i'' `lag123', lag(2)
		
		replace bs`y'ff = _b[L1.ff] if _n==`i'+2
		replace ses`y'ff = _se[L1.ff] if _n==`i'+2

	}
}

global t1 structural
global t2 s
