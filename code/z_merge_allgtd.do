/*==================================================
project:       after matching in qgis
Author:        Ryan Ellis 
     
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
version 18
drop _all
cd "$AFG_CDR"


/*==================================================
              1: 
==================================================*/

import delimited "C:\Users\ryand\Dropbox (GaTech)\02_PAPERS\00.JMP\JMP\analysis\processed\5km_all_gtd_matches.csv"
sort id date

gen gtd5km = 1

keep id date w_tag k_tag both nkill nwound gtd5km

save "processed/5km_allgtd_clean", replace



import delimited "C:\Users\ryand\Dropbox (GaTech)\02_PAPERS\00.JMP\JMP\analysis\processed\20km_all_gtd_matches.csv", clear
sort id date

gen gtd20km = 1

keep id date w_tag k_tag both nkill nwound gtd20km

ren (w_tag k_tag both nkill nwound) (w_tag20 k_tag20 both20 nkill20 nwound20)

save "processed/20km_allgtd_clean", replace

merge 1:1 id date using "processed/5km_allgtd_clean"

sort id date




order id date gtd5km w_tag k_tag both nkill nwound gtd20km w_tag20 k_tag20 both20 nkill20 nwound20 



gen double temp = date(date, "DMY")
format temp %td

sort id temp

drop date
rename temp date

order id date
drop _merge
compress


foreach var in gtd5km w_tag k_tag both nkill nwound {
	replace `var' = 0 if `var' ==.
}

save processed/allgtd_clean, replace

*use processed/allgtd_clean, clear

