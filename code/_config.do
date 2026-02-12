* ==============================================================================
* _config.do — Project-level Stata configuration
* Run this at the top of every .do file:  do "_config.do"
* ==============================================================================

clear all
set more off
set varabbrev off
macro drop _all
version 19                          // Pin Stata version for reproducibility

* --- Project root (auto-detect) ---
* This assumes scripts run from the code/ directory.
global root ".."
global raw    "${root}/data/raw"
global derived "${root}/data/derived"
global tables  "${root}/output/tables"
global figures "${root}/output/figures"

* --- Package library (project-local) ---
cap mkdir "${root}/code/libraries/stata"
sysdir set PLUS "${root}/code/libraries/stata"
sysdir set PERSONAL "${root}/code/libraries/stata"

* --- Display settings ---
set linesize 120
