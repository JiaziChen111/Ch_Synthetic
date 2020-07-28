* Define variables
global x1 logvix ffr rtspx rtoil
global x2 logvix ffr usyc120m epugbl globalip rtspx rtoil
global x3 inf une ip rtfx rtstx
global x4 logvix ffr rtspx rtoil inf une ip rtfx rtstx
global x5 logvix ffr usyc120m epugbl globalip rtspx inf une ip rtfx rtstx
global x6 logvix ffr usyc120m epugbl globalip inf une ip rtfx rtstx

* Panel regressions
foreach t in 24 120 {
	foreach v in dyp dtp phi {
// 		quietly xtreg `v'`t'm $x1, fe cluster($id)
// 		eststo m1
// 		quietly xtreg `v'`t'm $x2, fe cluster($id)
// 		eststo m2
// 		quietly xtreg `v'`t'm $x3, fe cluster($id)
// 		eststo m3
// 		quietly xtreg `v'`t'm $x4, fe cluster($id)
// 		eststo m4
		quietly xtreg `v'`t'm $x5, fe cluster($id)
// 		quietly xtscc `v'`t'm $x5, fe
		eststo m5
		quietly xtreg `v'`t'm $x6, fe cluster($id)
// 		quietly xtscc `v'`t'm $x6, fe
		eststo m6
		esttab m5 m6
	}
}
