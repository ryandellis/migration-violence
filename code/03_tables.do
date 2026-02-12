* ==============================================================================
* 03_tables.do — Summary statistics and other tables
* ==============================================================================

do "_config.do"

* --- Load cleaned data ---
* use "${derived}/clean.dta", clear

* --- Summary statistics ---
* estpost summarize y x1 x2 x3
* esttab using "${tables}/sumstats.tex", ///
*     replace fragment booktabs ///
*     cells("mean(fmt(%9.2f)) sd(fmt(%9.2f)) min max count(fmt(%9.0f))") ///
*     noobs label

di _n "03_tables.do complete."
