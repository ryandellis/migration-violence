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
use "$derived/VFD_restricted_1monthmin_with_migration", clear

*for each id, we need a "panel" of alternatives.
*this would be the simplest case:

*id		choice				migrate
***********************************
*1		internal			0
*1		international		1

*more complicated would be like this:

*id		choice				migrate
***********************************
*1		internal 1			0
*1		internal 2			0
*1		internal 3			0
*1		internal 4			0
*1		internal 5			0
*1		international 1		0
*1		international 2 	1	
*1		international 3		0
		*...*

fre finalborder
replace finalborder = 35 if finalborder == 6
replace finalborder = 36 if finalborder == 10
replace finalborder = 37 if finalborder == 14
replace finalborder = 38 if finalborder == 20
replace finalborder = 39 if finalborder == 22
replace finalborder = 40 if finalborder == 42
replace finalborder = 41 if finalborder == 64
replace finalborder = 42 if finalborder == 141
replace finalborder = 43 if finalborder == 205
replace finalborder = 44 if finalborder == 238
replace finalborder = 45 if finalborder == 305
replace finalborder = 46 if finalborder == 310
replace finalborder = 47 if finalborder == 333
replace finalborder = 48 if finalborder == 22167
replace finalborder = 49 if finalborder == 22567
replace finalborder = 50 if finalborder == 22972

label define crossings2 35 "Termez" 36 "Dogharoun" 37 "Spin Boldak" 38 "Milak" 39 "Torkham" 40 "Bazar Mushtarak" 41 "Turgundi" 42 "Danda Wa Patan" 43 "Andkhoi" 44 "Gulam Khan" 45 "Ai-Khanum" 46 "Sherkhan-Bandar" 47 "Nawa Pass" 48 "Hairatan" 49 "Guldani" 50 "Shin Nari"

label values finalborder crossings2
*****************************************************
gen last = 0
by id: replace last = 1 if count_obs == _n
gen final_loc = provid if last
replace final_loc = finalborder if finalborder!=. & potmig == 1

gen final_loc2 = provid if last
replace final_loc2 = finalborder if finalborder!=. & potmig2 ==1

gen final_full = provid if last
replace final_full = finalborder if finalborder!=. // generates version with all options, even ones no one chose
		
gen region = .
replace region = 1 if provid==14 | provid==16 | provid==21 | provid==22 | provid==28 | provid==29 
replace region = 2 if provid==18 | provid==20 | provid==23 | provid==25
replace region = 3 if provid==1 | provid==3 | provid==19 | provid==32
replace region = 4 if provid==4 | provid==8 | provid==13 | provid==30 | provid==31
replace region = 5 if provid==9 | provid==17 | provid==26 | provid==27
replace region = 6 if provid==6 | provid==11 | provid==15 | provid==24 | provid==33 | provid==34 
replace region = 7 if provid==2 | provid==5 | provid==7 | provid==10 | provid==12

bys id: egen mreg = mode(region), min
*bys id: egen mprov = mode(provid), min

*first, collapse to cross-section (try panel later)

gcollapse (sum) df_5km idf_5km ied_5km ied_fc_5km safire_5km violence_5km violence_all_5km df_20km idf_20km ied_20km ied_fc_20km safire_20km violence_20km violence_all_20km (max) d_df_5km d_idf_5km d_ied_5km d_ied_fc_5km d_safire_5km d_violence_5km d_violence_all_5km d_df_20km d_idf_20km d_ied_20km d_ied_fc_20km d_safire_20km d_violence_20km d_violence_all_20km share_imputed intevermig total_imputed count_obs meanrog potmig potmig2 final_loc final_loc2 final_full vperday* vpermon* vperyear* (first) mreg mprov, by(id)

*******************************
** easy model (3 choices)    **
*******************************
lab var potmig "$Pr{M^l_i = 1}$"
lab var potmig2 "$Pr{M^s_i = 1}$"
lab var vpermon_5km "Monthly 5km exposures"
lab var vpermon_20km "Monthly 20km exposures"
lab var intevermig "$Pr{M^internal_i = 1}$"
lab var count_obs "Days in sample"
lab var share_imputed "Share imputed"
lab var meanrog "Mean ROG (km)"

expand 3
sort id
by id: gen alts = _n

lab def alts 1 "Stay" 2 "Internal" 3 "External"
lab val alts alts

gen choice = .
replace choice = 1 if intevermig == 0 & potmig == 0
replace choice = 2 if intevermig == 1
replace choice = 3 if potmig == 1 // this absorbs the few external migrants who also had internal migration episodes (that's okay)

gen choice2 = .
replace choice2 = 1 if intevermig == 0 & potmig2 == 0
replace choice2 = 2 if intevermig == 1
replace choice2 = 3 if potmig2 == 1 

lab var choice alts
lab var choice2 alts
by id: gen chosen = (alts == choice)
by id: gen chosen2 = (alts == choice2)
order id alts choice chosen choice2 chosen2

// at this point, with no variables included about the alternatives, could estimate a cmclogit

//lets include a single alternative-specific var = 1 for presence of taliban internally

gen taliban = 0
replace taliban = 1 if alts == 1 | alts == 2

cmset id alts
eststo lax5cmc: cmclogit chosen, casevars(vpermon_5km meanrog count_obs i.mreg) cluster(mprov) // yay
	quietly su potmig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig==1
	estadd scalar liln = r(N)
	quietly su vpermon_5km
	estadd scalar x_mean = r(mean)

eststo strict5cmc: cmclogit chosen2, casevars(vpermon_5km meanrog count_obs i.mreg) cluster(mprov) // yay
	quietly su potmig2
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig2==1
	estadd scalar liln = r(N)
	quietly su vpermon_5km
	estadd scalar x_mean = r(mean)
	
eststo lax20cmc: cmclogit chosen, casevars(vpermon_20km meanrog count_obs i.mreg) cluster(mprov) // yay
	quietly su potmig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig==1
	estadd scalar liln = r(N)
	quietly su vpermon_20km
	estadd scalar x_mean = r(mean)

eststo strict20cmc: cmclogit chosen2, casevars(vpermon_20km meanrog count_obs i.mreg) cluster(mprov) // yay
	quietly su potmig2
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig2==1
	estadd scalar liln = r(N)
	quietly su vpermon_20km
	estadd scalar x_mean = r(mean)

esttab lax5cmc lax20cmc strict5cmc strict20cmc using "$tables/cmclogit_combo.tex", replace style(tex) ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
keep(vpermon_5km vpermon_20km meanrog) order(vpermon_5km vpermon_20km meanrog) collabels(none) compress noobs nonotes nomtitle booktabs ///
scalars("x_mean Avg. monthly exp." "bigN Observations" "liln Migrants classified" "samp_mean \% classified") sfmt(2 0 0 2) ///
mgroups("Lenient Model" "Restrictive Model", pattern(1 0 1 0 ) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))	
	
	
	
	
	
// conditional logit can tell if we need nests
// make an alternative-specific variable:
gen ambient_violence = 0
su vpermon_5km, d
replace ambient_violence = r(p50) if alts == 1 | alts == 2


gen vInt = (alts == 2) * vpermon_5km // interactions mimic the nests
gen vExt = (alts == 3) * vpermon_5km //?

clogit chosen ambient_violence vInt vExt, group(id)
estimates store fullset
clogit chosen ambient_violence vInt if alts != 1, group(id)
hausman . fullset // testing IIA odds change if we include staying, move to nested logit



// NESTED LOGIT


nlogitgen top = alts(Remain: Stay, Displace: Internal | External)
nlogittree alts top, choice(chosen)
nlogit chosen || top: vpermon_5km meanrog, base(Remain) || alts:, case(id)




*******************************
** hard model (~50 choices)  **
*******************************

*expand 47
*sort id // final_loc has 46 location choices, we need 1 more for "stay"
*by id: gen alts = _n

*...tbc


























/*
forvalues x = 1/12 {
	replace border`x' = 0 if border`x'==.
}

forvalues x = 1/34 {
	replace prov`x' = 0 if prov`x'==.
}

foreach var in border1 border2 border3 border4 border5 border6 border7 border8 border9 border10 border11 border12 prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8 prov9 prov10 prov11 prov12 prov13 prov14 prov15 prov16 prov17 prov18 prov19 prov20 prov21 prov22 prov23 prov24 prov25 prov26 prov27 prov28 prov29 prov30 prov31 prov32 prov33 prov34 {
	rename `var' choice_`var'
}
*/



