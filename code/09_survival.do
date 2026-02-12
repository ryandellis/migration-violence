/*==================================================
project:       Estimate the effects on international migration
Author:        Ryan Ellis 
E-email:       ryan.ellis@gatech.edu
url:           
Dependencies:  
----------------------------------------------------
Creation Date:    14 Jul 2024 - 14:08:07
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

/*==================================================
              1: basic setup
==================================================*/

*imputation issues?
bys date: egen avgcog = mean(cogcf)
*drop if avgcog > .35

bys id: egen maxfinalday = max(finalday)

replace maxfinalday = 19113 if maxfinalday == .



*regions
gen region = .
replace region = 1 if provid==14 | provid==16 | provid==21 | provid==22 | provid==28 | provid==29 
replace region = 2 if provid==18 | provid==20 | provid==23 | provid==25
replace region = 3 if provid==1 | provid==3 | provid==19 | provid==32
replace region = 4 if provid==4 | provid==8 | provid==13 | provid==30 | provid==31
replace region = 5 if provid==9 | provid==17 | provid==26 | provid==27
replace region = 6 if provid==6 | provid==11 | provid==15 | provid==24 | provid==33 | provid==34 
replace region = 7 if provid==2 | provid==5 | provid==7 | provid==10 | provid==12

bys id: egen mreg = mode(region), min


*month of dropout controls:
gen final_ym = mofd(final_date) // final date is true dates, not altered by dropping imputation gaps

gcollapse (max) maxfinalday finalday final_date newdate final_ym dropout potmig potmig2 intevermig count_obs total_violence_5km vperday_5km vpermon_5km vperyear_5km total_violence_20km vperday_20km vpermon_20km vperyear_20km meanrog finalborder (first) mdist mprov mreg, by(id)


* External (lax), at 5km
stset count_obs, failure(potmig) // USE COUNT_OBS FOR ANALYSIS TIME
*sts graph, by(potmig)
stcox vpermon_5km meanrog i.mreg, vce(cluster id)
stcurve, survival at1(vpermon_5km = 0) at2((mean) vpermon_5km) at3(vpermon_5km = 4.52458) ///
	range(30 425) ///
	ylabel(, nogrid) xlabel(,nogrid) ///
	xtitle("Days in sample") title("(1) Lenient") ///
	leg(cols(2) pos(6) lab(1 "Zero monthly exposures") lab(2 "Mean monthly exp.") lab(3 "Mean +1 s.d.") size(medium)) name(external1, replace) 
gr export "$figures/survival_ext_lax_5km.png", replace

* External (strict), at 5km
stset count_obs, failure(potmig2)
*sts graph, by(potmig2)
stcox vpermon_5km meanrog i.mreg, vce(cluster mprov)
stcurve, survival at1(vpermon_5km = 0) at2((mean) vpermon_5km) at3(vpermon_5km = 4.52458) ///
	range(30 425) ///
	ylabel(, nogrid) xlabel(,nogrid) ///
	xtitle("Days in sample") title("(2) Restrictive") ///
	leg(cols(2) pos(6) lab(1 "Zero monthly exposures") lab(2 "Mean monthly exp.") lab(3 "Mean +1 s.d.") size(medium)) name(external2, replace)
gr export "$figures/survival_ext_strict_5km.png", replace


* Internal, at 5km
stset count_obs, failure(intevermig)
stcox vpermon_5km meanrog i.mreg, vce(cluster id)
stcurve, survival at1(vpermon_5km = 0) at2((mean) vpermon_5km) at3(vpermon_5km = 4.52458) ///
	range(30 425) ///
	ylabel(, nogrid) xlabel(,nogrid) ///
	xtitle("Days in sample") title("(3) Internal") ///
	leg(cols(2) pos(6) lab(1 "Zero monthly exposures") lab(2 "Mean monthly exp.") lab(3 "Mean +1 s.d.") size(medium)) name(internal, replace)
gr export "$figures/survival_internal_5km.png", replace


* Dropout, at 5km
stset count_obs, failure(dropout)
stcox vpermon_5km meanrog i.mreg, vce(cluster id)
stcurve, survival at1(vpermon_5km = 0) at2((mean) vpermon_5km) at3(vpermon_5km = 4.52458) ///
	range(30 425) ///
	ylabel(, nogrid) xlabel(,nogrid) ///
	xtitle("Days in sample") title("(4) All Attrition") ///
	leg(cols(2) pos(6) lab(1 "Zero monthly exposures") lab(2 "Mean monthly exp.") lab(3 "Mean +1 s.d.") size(medium)) name(dropout, replace)
gr export "$figures/survival_dropout_5km.png", replace


graph combine external1 external2, scheme(cblind1)
graph export "$figures/survival_combo.png", replace



graph combine external1 external2 internal dropout, scheme(cblind1) ycommon





