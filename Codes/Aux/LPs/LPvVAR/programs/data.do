import excel using ../data/haver.xlsx, sheet(data) firstrow

gen d = qofd(date)
format d %tq
tsset d

order d
drop date
drop if d==.
destring _all, replace

gen dpcom=d.pcom
tssmooth ma sdpcom=dpcom, window(2 1 2)

replace y = log(y)
replace p = log(p)
replace pcom = sdpcom
replace tr = log(tr)
replace nbr = log(nbr)
replace m1 = log(m1)
replace m2 = log(m2)

local rvar y p pcom ff nbr tr m1

foreach y of local rvar {
	* generate dependent variables
	forvalues i=0/15 {
		if `i'==0 {
		gen `y'0=`y'
		}
		if `i'>0 {
		gen `y'`i' = f`i'.`y'
		}
	}
}
