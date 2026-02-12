/*==================================================
project:       Summary figures from SIGACT
Author:        Ryan Ellis 
E-email:       
url:           
Dependencies:  
----------------------------------------------------
Creation Date:     2 Jul 2024 - 13:34:22
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/

drop _all
cd "C:\Users\ellisrya\OneDrive - Seton Hall University\01.research\JMP\analysis\"

*generate stats and figures from SIGACTS during study period
*get OK from Robert for using full SIGACTS

use "C:\Users\ellisrya\Dropbox\Violence and Cell Phone Access\Data\Clean_data\sigacts_allcats_allyears.dta", clear

*restrict to study period
keep if ym > tm(2010m11)
keep if ym < tm(2012m05)
sort DISTID date

gen n = _n
*totals by date:
bys date: egen all_sigact = count(n)
bys week: egen all_sigact_w = count(n)
bys ym: egen all_sigact_m = count(n)

*totals by type:

bys date: egen all_df = total(df)
bys week: egen all_df_w = total(df)

bys date: egen all_idf = total(idf)
bys week: egen all_idf_w = total(idf)

bys date: egen all_ied = total(ied)
bys week: egen all_ied_w = total(ied)

bys date: egen all_ied_fc = total(ied_fc)
bys week: egen all_ied_fc_w = total(ied_fc)

gen safire = 0
replace safire = 1 if PrimaryCategory=="SAFIRE"

bys date: egen all_safire = total(safire)


*create other categories:

gen threat = 0
replace threat = 1 if PrimaryType=="Threats"

bys date: egen all_threats = total(threat)
bys week: egen all_threats_w = total(threat)
bys ym: egen all_threats_m = total(threat)

gen friendly = 0 
replace friendly = 1 if PrimaryType=="Friendly Action" | PrimaryType=="Friendly Fire" | PrimaryType=="Counter-Insurge" | PrimaryType=="Countery-Insurgency"

bys date: egen all_friends = total(friendly)
bys week: egen all_friends_w = total(friendly)
bys ym: egen all_friends_m = total(friendly)

gen crime = 0
replace crime = 1 if PrimaryType=="Criminal Event"

bys date: egen all_crimes = total(crime)
bys week: egen all_crimes_w = total(crime)
bys ym: egen all_crimes_m = total(crime)

gen insurg = 0
replace insurg = 1 if df==1 | idf==1 | ied==1 | ied_fc==1 | threat==1


gen violence = 0
replace violence = 1 if df==1 | idf==1 | ied==1 | safire==1

bys date: egen all_insurg = total(insurg)
bys week: egen all_insurg_w = total(insurg)
bys ym: egen all_insurg_m = total(insurg)

bys date: egen all_violence = total(violence)

*using prev categories:
gen enemy = 0
replace enemy = 1 if PrimaryType=="Enemy Action" | PrimaryType=="Threats" | PrimaryType=="Explosive Hazard" | PrimaryType=="Explosive Hazar"

bys date: egen all_enemy = total(enemy)

*labels
lab var all_df "Direct Fire"
lab var all_idf "Indirect Fire"
lab var all_ied "IED, detonated"
lab var all_ied_fc "IED, cleared"
lab var all_safire "Surface-Air Fire"
lab var all_threats "Threats"
lab var all_friends "Counter-insurgent"
lab var all_crimes "Crime"
lab var all_insurg "Insurgent activities"
lab var all_sigact "All recorded SIGACTs"
lab var all_violence "Violent activities, insurgent"
lab var all_enemy "Insurgent"

lab var all_df_w "Direct Fire"
lab var all_idf_w "Indirect Fire"
lab var all_ied_w "IED, detonated"
lab var all_ied_fc_w "IED, cleared"
lab var all_threats_w "Threats"
lab var all_friends_w "Counter-Insurgency"
lab var all_crimes_w "Crime"
lab var all_insurg_w "Insurgent Activities"
lab var all_sigact_w "All recorded activities"

lab var date "Date"
format date %tdDDMonCCYY

gen gap = 50
replace gap = 300 if date > td(17jan2011) & date < td(01feb2011)
replace gap = 300 if date > td(20aug2011) & date < td(01nov2011)
lab var gap "CDR imputation gap"

color_style egypt
font_style Arial Narrow

*daily line of all sigacts:
tw line all_sigact date
graph export results/figures/all_sigact.png, replace

tw (area gap date, acolor("160 160 160")) (line all_sigact date, lcolor("255 0 0")), legend(position(6) rows(1) size(medsmall))
graph export results/figures/imputed.png, replace

*daily line of all insurgent activities:
tw (line all_violence date) (line all_threats date) (line all_ied_fc date), legend(position(6) rows(1) size(large))
graph export results/figures/sigacts_insurgent.png, replace

*daily line graph of violence by type:
color_style stevens
tw (line all_df date) (line all_ied date, lpattern(longdash)) (line all_idf date, lpattern(shortdash)) (line all_safire date, lwidth(thick) lpattern(dot)), legend(position(6) rows(2))
graph export results/figures/sigacts_type.png, replace

*daily line graph of incidents by actor:
color_style egypt
tw (line all_enemy date) (line all_friends date, lpattern(dash)) (line all_crimes date, lwidth(thick) lpattern(dot)), legend(position(6) rows(1))
graph export results/figures/sigacts_actor.png, replace







