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
do "_config.do"
use "$derived/VFD_with_internal", replace
/*==================================================
              1: 
==================================================*/
egen id = group(identityid)
drop identityid
sort id date
xtset id date

*drop if gap==1

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

*save "$derived/VFD_baseline_unrestricted", replace // baseline with minimal restrictions

// restriction based on minimum days needed to be classified internal migrant
drop if count_obs < 31

save "$derived/VFD_restricted_1monthmin_GAP", replace



