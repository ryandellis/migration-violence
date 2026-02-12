/*==================================================
project:       select high-casu
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
import delimited "C:\Users\ryand\Dropbox (GaTech)\02_PAPERS\00.JMP\JMP\zz_old\data\GTD_event_selection.csv", clear
keep if country_txt == "Afghanistan"
keep if iyear > 2009
keep if iyear < 2013

keep iyear imonth iday country_txt provstate city latitude longitude location summary nkill nwound

gen date = mdy(imonth, iday, iyear)
format date %td

keep if date > td(30nov2010)
keep if date < td(01may2012)

order date nkill nwound latitude longitude provstate city 

gen w_tag = 0
replace w_tag = 1 if nwound > 9 & nwound != .

gen k_tag = 0
replace k_tag = 1 if nkill > 9 & nkill != .

gen joint = 0
replace joint = 1 if w_tag | k_tag

*keep if joint

gen both = 0
replace both = 1 if w_tag & k_tag

gen event = _n

order event date w_tag k_tag joint both nkill nwound latitude longitude provstate city 

drop iyear imonth iday country_txt

save processed/gtd_casualty_all, replace

export delimited using "C:\Users\ryand\Dropbox (GaTech)\02_PAPERS\00.JMP\JMP\analysis\processed\gtd_casualty_all.csv"


