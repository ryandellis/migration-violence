* ==============================================================================
* 01_clean_data.do — Data cleaning and preparation
* ==============================================================================

do "_config.do"

* --- Load raw data ---
* import delimited "${raw}/your_data.csv", clear

* --- Cleaning steps ---


* --- Save analysis-ready dataset ---
* save "${derived}/clean.dta", replace

di _n "01_clean_data.do complete."
