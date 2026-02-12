/*==================================================
project:       Figures and statistics for sample restriction (gap dropped)
Author:        Ryan Ellis 
E-email:       ryan.ellis@gatech.edu
url:           
Dependencies:  
----------------------------------------------------
Creation Date:     2 Jul 2024 - 15:32:12
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
version 18
drop _all
cd "$AFG_CDR"
use processed/VFD_with_internal, replace
/*==================================================
              1: 
==================================================*/
egen id = group(identityid)
drop identityid
sort id date
xtset id date

drop if gap==1

// How many IDs are "all imputed"? surely drop those

by id: egen total_imputed = sum(cogcf)
by id: egen count_obs = count(cogcf)
gen all_imputed = total_imputed == count_obs

preserve
collapse (max) all_imputed, by(id)
count if all_imputed==1
count
restore // 117 of 15,052 IDs, about 0.77% of the sample
drop if all_imputed == 1
drop if count_obs < 2 // same as VFD paper, establish minimum restriction baseline

// What about the share of imputed days, per user? If the share is super high,
// it might be wise to drop them too, depending

by id: gen share_imputed = total_imputed / count_obs


/*
preserve
collapse (max) share_imputed, by(id)
replace share_imputed = share_imputed*100
histogram share_imputed, xtitle("% of days imputed") ytitle("") title("Histogram: Share of obs. imputed" "for individual users")
restore

preserve
collapse (max) share_imputed, by(id)
replace share_imputed = share_imputed*100
dstat cdf share_imputed
dstat graph
restore

// What about raw number of days in sample? Surely we don't want to compare
// users who have a single day with our full-sample users?

preserve
collapse (max) count_obs, by(id)
histogram count_obs, xtitle("") ytitle("") title("Histogram: Days in sample" "for individual users")
restore

preserve
collapse (max) count_obs, by(id)
dstat cdf count_obs
dstat graph
restore
*/



*********************RESTRICTION CHOICES

// Drop some unneccessary vars
drop d1 d2 d3 d4 intresident intother status num_dates _merge ///
	cdr_month gap latlon loc mloc mslat mslon loctag s_loctag all_imputed ///
	df_10km ied_10km idf_10km safire_10km ied_fc_10km d_df_10km d_ied_10km ///
	d_idf_10km d_safire_10km d_ied_fc_10km slat slon 
egen newdate = group(date_id)
drop date_id

order id date week ym longitude latitude district provid province df_5km idf_5km ied_5km ied_fc_5km safire_5km violence_5km violence_all_5km d_df_5km d_idf_5km d_ied_5km d_ied_fc_5km d_safire_5km d_violence_5km d_violence_all_5km df_20km idf_20km ied_20km ied_fc_20km safire_20km violence_20km violence_all_20km d_df_20km d_idf_20km d_ied_20km d_ied_fc_20km d_safire_20km d_violence_20km d_violence_all_20km 

compress

save processed/VFD_baseline_unrestricted, replace // baseline with minimal restrictions

// restriction based on minimum days needed to be classified internal migrant
drop if count_obs < 31

save processed/VFD_restricted_1monthmin, replace
////////////////////////// Identifying 'runs' of imputation


// Count the length of each run of consecutive 1s
by id: gen consec_imputed = 0
by id: replace consec_imputed = consec_imputed[_n-1] + 1 if cogcf == 1

// Count the length of each run of consecutive 0s
by id: gen consec_true = 0
by id: replace consec_true = consec_true[_n-1] + 1 if cogcf == 0

// Determine the maximum run length of 1s per id
by id: egen max_consec_imputed = max(consec_imputed)

// Determine the maximum run length of 0s per id
by id: egen max_consec_true = max(consec_true)

// Identify the end of each run
by id: gen end_of_run_1 = (consec_imputed > 0 & (cogcf[_n+1] != 1 | _n == _N))
by id: gen end_of_run_0 = (consec_true > 0 & (cogcf[_n+1] != 0 | _n == _N))

// Calculate the average run length of 1s per id
by id: egen temp_1 = mean(consec_imputed) if end_of_run_1
by id: egen avgrun_imputed = max(temp_1)

// Calculate the average run length of 0s per id
by id: egen temp_0 = mean(consec_true) if end_of_run_0
by id: egen avgrun_true = max(temp_0)
drop temp*

///////////////////////////////////////////////////
// restricting

gen tag = 0

su total_imputed, d
replace tag = 1 if total_imputed >= r(p99)

su share_imputed, d
replace tag = 1 if share_imputed >= r(p99)

su avgrun_imputed, d
replace tag = 1 if avgrun_imputed >= r(p99)

su max_consec_imputed, d
replace tag = 1 if max_consec_imputed >= r(p99)

su count_obs, d
replace tag = 1 if count_obs <= r(p1)

preserve
drop if tag == 1
compress
save processed/VFD_restricted_99th, replace // drop 99th pctile of several problematic indicators
restore

replace tag = 0

su total_imputed, d
replace tag = 1 if total_imputed >= r(p90)

su share_imputed, d
replace tag = 1 if share_imputed >= r(p90)

su avgrun_imputed, d
replace tag = 1 if avgrun_imputed >= r(p90)

su max_consec_imputed, d
replace tag = 1 if max_consec_imputed >= r(p90)

su count_obs, d
replace tag = 1 if count_obs <= r(p10)

preserve
drop if tag == 1
compress
save processed/VFD_restricted_90th, replace // drop 90th pctile of several problematic indicators
restore

preserve
drop if cogcf == 1
compress 
save processed/VFD_restricted_no_impute, replace // drop any imputed values


