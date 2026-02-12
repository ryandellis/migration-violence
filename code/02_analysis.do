* ==============================================================================
* 02_analysis.do — Main analysis (regressions)
* ==============================================================================

do "_config.do"

* --- Load cleaned data ---
* use "${derived}/clean.dta", clear

* --- Regressions ---
* eststo clear
* eststo m1: reghdfe y x1 x2, absorb(fe1) vce(cluster clustervar)
* eststo m2: reghdfe y x1 x2 x3, absorb(fe1 fe2) vce(cluster clustervar)

* --- Export table ---
* esttab m1 m2 using "${tables}/reg_main.tex", ///
*     replace fragment booktabs label ///
*     se star(* 0.10 ** 0.05 *** 0.01) ///
*     stats(N r2, fmt(%9.0fc %9.3f) labels("Observations" "\$R^2\$")) ///
*     mtitles("(1)" "(2)") alignment(D{.}{.}{-1})

di _n "02_analysis.do complete."
