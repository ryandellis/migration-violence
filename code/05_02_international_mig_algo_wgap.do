/*==================================================
project:       Algorithm for inferring international migrants
Author:        Ryan Ellis 
E-email:       ryan.ellis@gatech.edu
url:           
Dependencies:  
----------------------------------------------------
Creation Date:    10 Jul 2024 - 11:01:53
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
do "_config.do"
use "$derived/VFD_restricted_1monthmin_GAP", clear

sort id date


/*==================================================
              1: Original migration algorithm (thanks to DD)
==================================================*/



*----------1.1: dropout date and T-1,...,T-9

bys id: egen finalday = max(date)
g lastday = 0
replace lastday = 1 if finalday == date
local numbers 1 2 3 4 5 6 7 8 9 10 11 12 13
foreach x in `numbers' {
	g lastday_`x' = 0
	replace lastday_`x' = 1 if date==(finalday - `x')
}

compress
format finalday %td

*From this set of user observations, I will identify those with 1) nearness to borders or airports, and/or 2) decreasing distance to borders or airports in their final days in sample.

*In this iteration of the sample, about 77% of users' "final day" is the actual last day collected (4/30/2012). I characterize those with earlier final days as dropouts. Of course there is researcher choice in this characterization, but this is only the first restriction of many to inferring potential migrants. One way to alter this section is to simply shift the date backward in time. However, the clustering of users with a final day on 4/30 suggests this is an OK starting place for analysis.

g dropout = 0
bys id: replace dropout = 1 if finalday < td(30apr2012) // April 30, 2012 is the last day of the sample

*notably, over 30% of the remaining sample are present for every possible day (over 900k obs). This bodes well for any analysis that limits the sample further, by either days present or percentage of days imputed.


*----------1.2: nearness to border crossings
*credit the following program, Daniel Dench
*the program creates a dataset of dropouts on each of their final days, as well as their distance to all known border crossings.
preserve
// 1. restrict to dropouts
keep if lastday==1 & dropout

// 2. calculate distance to known crossings
geonear id latitude longitude using "$derived/feasibleborderpoints", n(nborid latitude longitude) nearcount(17) long

// 3.

generate lastday_over=0

tempfile geos
save `geos'

restore

forvalues x=1(1)13 {
preserve
di "hey"
keep if lastday_`x' & dropout
di "how's"
geonear id latitude longitude using "$derived/feasibleborderpoints", n(nborid latitude longitude) nearcount(17) long
di "it"
generate lastday_over=`x'
di "going?"
append using `geos'
di "friend"
save `geos', replace
restore
}

use `geos', clear

keep if lastday_over == 0
bys id: egen double mindist = min(km_to_nborid)

bys id: gen temp = nborid if km_to_nborid == mindist
bys id: egen finalborder = max(temp)
drop temp



collapse (max) finalborder, by(id)

save "$derived/finalborders_GAP", replace //first pass identifies which is final border





********************************************************************************

* Do the program again, but in wide format, to merge nicely with original dataset:
use "$derived/VFD_restricted_1monthmin_GAP", clear
sort id date
bys id: egen finalday = max(date)
g lastday = 0
replace lastday = 1 if finalday == date
local numbers 1 2 3 4 5 6 7 8 9 10 11 12 13
foreach x in `numbers' {
	g lastday_`x' = 0
	replace lastday_`x' = 1 if date==(finalday - `x')
}
compress
format finalday %td
g dropout = 0
bys id: replace dropout = 1 if finalday < td(30apr2012) // April 30, 2012 is the last day of the sample
preserve
// 1. restrict to dropouts
keep if lastday==1 & dropout

// 2. calculate distance to known crossings
geonear id latitude longitude using "$derived/feasibleborderpoints", n(nborid latitude longitude) nearcount(17)

// 3.
generate lastday_over=0
tempfile geos
save `geos'

restore

forvalues x=1(1)13 {
preserve
di "hey"
keep if lastday_`x' & dropout
di "how's"
geonear id latitude longitude using "$derived/feasibleborderpoints", n(nborid latitude longitude) nearcount(17)
di "it"
generate lastday_over=`x'
di "going?"
append using `geos'
di "friend"
save `geos', replace
restore
}

use `geos', clear


merge m:1 id using "$derived/finalborders_GAP"


gen km_to_final = .
forvalues x = 1/17 {
	replace km_to_final = km_to_nid`x' if nid`x' == finalborder
}

// view distribution of final borders:
preserve
keep if lastday_over == 0
fre finalborder
kdensity km_to_final
restore

*save dataset and merge back into original data
// keep id date finalday lastday lastday_* dropout count_obs nid* km_to_nid* lastday_over

label define crossings 6 "Termez" 10 "Dogharoun" 14 "Spin Boldak" 20 "Milak" 22 "Torkham" 42 "Bazar Mushtarak" 64 "Turgundi" 141 "Danda Wa Patan" 205 "Andkhoi" 238 "Gulam Khan" 305 "Ai-Khanum" 310 "Sherkhan-Bandar" 333 "Nawa Pass" 22167 "Hairatan" 22567 "Guldani" 22971 "Karwan Rah" 22972 "Shin Nari"

label values finalborder crossings



save "$derived/dropouts_GAP", replace









/*==================================================
              2: 
==================================================*/

use "$derived/dropouts_GAP", replace
drop _merge
*----------2.1: next is to implement restrictions based on distance and bearing
sort id -lastday_over
by id: gen distance_change = km_to_final - km_to_final[_n-1] if _n > 1

by id: egen avg_distance_change = mean(distance_change)

* Determine if the average change indicates a decrease
gen general_trend = .
replace general_trend = -1 if avg_distance_change < 0  // General decrease
replace general_trend = 1 if avg_distance_change > 0   // General increase
replace general_trend = 0 if avg_distance_change == 0  // No change
*----------2.2:

drop nid1 km_to_nid1 nid2 km_to_nid2 nid3 km_to_nid3 nid4 km_to_nid4 nid5 km_to_nid5 nid6 km_to_nid6 nid7 km_to_nid7 nid8 km_to_nid8 nid9 km_to_nid9 nid10 km_to_nid10 nid11 km_to_nid11 nid12 km_to_nid12 nid13 km_to_nid13 nid14 km_to_nid14 nid15 km_to_nid15 nid16 km_to_nid16 nid17 km_to_nid17 lastday_1 lastday_2 lastday_3 lastday_4 lastday_5 lastday_6 lastday_7 lastday_8 lastday_9 lastday_10 lastday_11 lastday_12 lastday_13

compress
/*==================================================
              3: merge back to full dataset
==================================================*/


*----------3.1:
merge 1:1 id date using "$derived/VFD_restricted_1monthmin_GAP"

*----------3.2:
sort id date
*generate average ROGs by user:
by id: egen meanrog = mean(rog)


*extend zeros for dropouts:
replace dropout = 0 if dropout==.


*implement restrictions (tag potential migrants)

gen potmig = 0
forvalues x = 1/4 {
	gen res`x' = 0 // each var is a restriction
}
by id: replace res1 = 1 if dropout == 1
by id: replace res2 = 1 if km_to_final < 75 & lastday == 1
by id: replace res3 = 1 if distance > .1*meanrog & lastday == 1
by id: replace res4 = 1 if avg_distance_change < 0
by id: replace potmig = 1 if res1 == 1 & res2 == 1 & res3 == 1 & res4 == 1



*implement 2nd set of restrictions (strict vs. lax)
gen potmig2 = 0
forvalues x = 1/4 {
	gen res2_`x' = 0 // each var is a restriction
}
by id: replace res2_1 = 1 if dropout == 1
by id: replace res2_2 = 1 if km_to_final < 50 & lastday == 1
by id: replace res2_3 = 1 if distance > .2*meanrog & lastday == 1
by id: replace res2_4 = 1 if avg_distance_change < 0
by id: replace potmig2 = 1 if res2_1 == 1 & res2_2 == 1 & res2_3 == 1 & res2_4 == 1



by id: egen total_violence_5km = total(violence_all_5km)
by id: gen vperday_5km = total_violence_5km / count_obs
by id: gen vpermon_5km = vperday_5km * 30
by id: gen vperyear_5km = vperday_5km * 365

by id: egen total_violence_20km = total(violence_all_20km)
by id: gen vperday_20km = total_violence_20km / count_obs
by id: gen vpermon_20km = vperday_20km * 30
by id: gen vperyear_20km = vperday_20km * 365


drop _merge res* sqdist meansqdist

compress

save "$derived/VFD_restricted_1monthmin_with_migration_GAP", replace



exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


