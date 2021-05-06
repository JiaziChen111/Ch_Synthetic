***** What this program does *********************************************

* 1. data.do 			reads in data and does simple transformations

* 2. LP_reduced.do 		runs a reduced form LP
* 3. LP_graphs.do 		plots the reduced form LP estimates 
* 4. VAR_reduced.do 	estimates and plots the reduced form VAR estimates 

* 5. LP_structural.do 	runs a structural LP
* 6. LP_graphs.do 		plots the structural LP estimates 
* 7. VAR_structural.do 	estimates and plots the structural VAR estimates 

*** Setup ****************************************************************

clear
set more off
set scheme s1color
cd "U:\Early\Jorda\EC\LPvVAR\programs"

capture log close
log using ../log/LPvVAR.log, replace

**************************************************************************

do data

*do LP_reduced
*do LP_graphs
*do VAR_reduced

*do LP_structural
*do LP_graphs
do VAR_structural
