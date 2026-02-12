* ==============================================================================
* _config.do — Project configuration for migration-violence
* Run this at the top of every .do file:  do "_config.do"
* ==============================================================================

clear all
set more off
set varabbrev off
macro drop _all
version 19

* --- Project paths ---
* All paths are relative to the code/ directory.
global root      ".."
global raw       "${root}/data/raw"
global derived   "${root}/data/derived"
global tables    "${root}/output/tables"
global figures   "${root}/output/figures"

* --- Data source shortcuts ---
* These replace the old $AFG_CDR global from profile.do.
* Scripts that referenced $AFG_CDR should now use $raw/VFD_data
global VFD       "${raw}/VFD_data"
global dhs       "${raw}/dhs"
global dtm       "${raw}/dtm"
global unhcr     "${raw}/unhcr_query"
global worldbank "${raw}/worldbank"
global gridpop   "${raw}/griddedpop"
global geoquery  "${raw}/geoquery"
global nrva      "${raw}/nrva_survey"
global dismig    "${raw}/Disaggregated_Migration"

* --- Package library (project-local) ---
cap mkdir "${root}/code/libraries/stata"
sysdir set PLUS "${root}/code/libraries/stata"
sysdir set PERSONAL "${root}/code/libraries/stata"

* --- Display settings ---
set linesize 120
