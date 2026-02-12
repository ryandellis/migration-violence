/*==================================================
project:       Import and clean unhcr data
Author:        Ryan Ellis 
E-email:       
url:           
Dependencies:  
----------------------------------------------------
Creation Date:     2 Jul 2024 - 13:34:22
Modification Date:   
Do-file version:    01
References:  https://www.unhcr.org/refugee-statistics/        
Output:             
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

import delimited "C:\Users\rellis63\GaTech Dropbox\Ryan Ellis\02_PAPERS\00.JMP\JMP\analysis\processed\5km_highcasualty_matches.csv"
sort id date

keep id date w_tag k_tag both nkill nwound

save "processed/5km_highcasualty_clean", replace



import delimited "C:\Users\rellis63\GaTech Dropbox\Ryan Ellis\02_PAPERS\00.JMP\JMP\analysis\processed\20km_highcasualty_matches.csv", clear
sort id date

keep id date w_tag k_tag both nkill nwound

ren (w_tag k_tag both nkill nwound) (w_tag20 k_tag20 both20 nkill20 nwound20)

save "processed/20km_highcasualty_clean", replace

merge 1:1 id date using "processed/5km_highcasualty_clean"

sort id date




order id date w_tag k_tag both nkill nwound w_tag20 k_tag20 both20 nkill20 nwound20 summary
drop longitude latitude fid event date_2 joint latitude_2 longitude_2 provstate city location _merge



gen double temp = date(date, "DMY")
format temp %td

sort id temp

drop date
rename temp date

compress
save processed/all_highcasualty_clean, replace



