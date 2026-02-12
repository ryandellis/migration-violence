/*==================================================
project:       high casualty
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
do "_config.do"


/*==================================================
              1: 
==================================================*/

use "$derived/VFD_restricted_1monthmin_with_migration"
capture drop _merge
merge 1:1 id date using "$derived/all_highcasualty_clean"

gen region = .
replace region = 1 if provid==14 | provid==16 | provid==21 | provid==22 | provid==28 | provid==29 
replace region = 2 if provid==18 | provid==20 | provid==23 | provid==25
replace region = 3 if provid==1 | provid==3 | provid==19 | provid==32
replace region = 4 if provid==4 | provid==8 | provid==13 | provid==30 | provid==31
replace region = 5 if provid==9 | provid==17 | provid==26 | provid==27
replace region = 6 if provid==6 | provid==11 | provid==15 | provid==24 | provid==33 | provid==34 
replace region = 7 if provid==2 | provid==5 | provid==7 | provid==10 | provid==12

bys id: egen mreg = mode(region), min


foreach i in w_tag k_tag both nkill nwound w_tag20 k_tag20 both20 nkill20 nwound20 {
	by id: egen total_`i' = total(`i')
	by id: gen `i'perday = total_`i' / count_obs
	by id: gen `i'permon = `i'perday * 30

}


gcollapse (max) dropout share_imputed intevermig total_imputed count_obs meanrog potmig potmig2 total_w_tag w_tagperday w_tagpermon total_k_tag k_tagperday k_tagpermon total_both bothperday bothpermon total_nkill nkillperday nkillpermon total_nwound nwoundperday nwoundpermon total_w_tag20 w_tag20perday w_tag20permon total_k_tag20 k_tag20perday k_tag20permon total_both20 both20perday both20permon total_nkill20 nkill20perday nkill20permon total_nwound20 nwound20perday nwound20permon (first) finalborder mdist mprov mreg, by(id)

drop w_tagperday k_tagperday bothperday nkillperday nwoundperday w_tag20perday k_tag20perday both20perday nkill20perday nwound20perday

by id: gen jointpermon = k_tagpermon + w_tagpermon
by id: gen joint20permon = k_tag20permon + w_tag20permon


logit potmig jointpermon count_obs meanrog i.mreg, cluster(mprov)
logit potmig joint20permon count_obs meanrog i.mreg, cluster(mprov)
logit intevermig jointpermon count_obs meanrog i.mreg, cluster(mprov)
logit intevermig joint20permon count_obs meanrog i.mreg, cluster(mprov)

count if jointpermon


estimates clear
eststo externalk5: logit potmig jointpermon count_obs meanrog i.mreg, cluster(mprov)
	quietly su potmig
	scalar samp_mean = r(mean)
	estadd scalar samp_mean = samp_mean
	estadd scalar bigN = r(N)
	quietly margins, dydx(jointpermon)
	scalar marg = r(b)[1,1]
	estadd scalar marg = marg
	quietly margins, eyex(jointpermon)
	estadd scalar elas = r(b)[1,1]
	quietly su jointpermon
	estadd scalar x_mean = r(mean)
	estadd local geos = "YES"
	scalar delta = marg / samp_mean
	estadd scalar delta = delta
	scalar drop _all	
	
eststo externalk20: logit potmig joint20permon count_obs meanrog i.mreg, cluster(mprov)
	quietly su potmig
	scalar samp_mean = r(mean)
	estadd scalar samp_mean = samp_mean
	estadd scalar bigN = r(N)
	quietly margins, dydx(joint20permon)
	scalar marg = r(b)[1,1]
	estadd scalar marg = marg
	quietly margins, eyex(joint20permon)
	estadd scalar elas = r(b)[1,1]
	quietly su joint20permon
	estadd scalar x_mean = r(mean)
	estadd local geos = "YES"
	scalar delta = marg / samp_mean
	estadd scalar delta = delta
	scalar drop _all
	
eststo internalk5: logit intevermig jointpermon count_obs meanrog i.mreg, cluster(mprov)
	quietly su intevermig
	scalar samp_mean = r(mean)
	estadd scalar samp_mean = samp_mean
	estadd scalar bigN = r(N)
	quietly margins, dydx(jointpermon)
	scalar marg = r(b)[1,1]
	estadd scalar marg = marg
	quietly margins, eyex(jointpermon)
	estadd scalar elas = r(b)[1,1]
	quietly su jointpermon
	estadd scalar x_mean = r(mean)
	estadd local geos = "YES"
	scalar delta = marg / samp_mean
	estadd scalar delta = delta
	scalar drop _all
	
eststo internalk20: logit intevermig joint20permon count_obs meanrog i.mreg, cluster(mprov)
	quietly su intevermig
	scalar samp_mean = r(mean)
	estadd scalar samp_mean = samp_mean
	estadd scalar bigN = r(N)
	quietly margins, dydx(joint20permon)
	scalar marg = r(b)[1,1]
	estadd scalar marg = marg
	quietly margins, eyex(joint20permon)
	estadd scalar elas = r(b)[1,1]
	quietly su joint20permon
	estadd scalar x_mean = r(mean)
	estadd local geos = "YES"
	scalar delta = marg / samp_mean
	estadd scalar delta = delta
	scalar drop _all


esttab externalk5 externalk20 internalk5 internalk20 using "$tables/casualty_logit_combo.tex", replace style(tex) ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
keep(jointpermon joint20permon meanrog) order(jointpermon joint20permon meanrog) collabels(none) compress noobs nonotes nomtitle booktabs eqlabels("") eform ///
scalars("samp_mean Dependent var. mean" "marg Average marginal effect" "delta $\Delta$ over baseline" "elas Elasticity" "x_mean Mean monthly exposure" "bigN Observations" "geos Geographic controls" ) sfmt(4 4 4 4 2 0 0) ///
mgroups("External (Lenient)" "Internal", pattern(1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
estimates clear


lab var jointpermon "Monthly High-Casualty Exposures (5km)"
lab var joint20permon "Monthly High-Casualty Exposures (20km)"
lab var meanrog "Mean ROG (km)"

*kill only

estimates clear
eststo externalk5: logit potmig k_tagpermon count_obs meanrog i.mreg, cluster(mprov)
	quietly su potmig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(k_tagpermon)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(k_tagpermon)
	estadd scalar elas = r(b)[1,1]	
	quietly su k_tagpermon
	estadd scalar x_mean = r(mean)	
	
eststo externalk20: logit potmig k_tag20permon count_obs meanrog i.mreg, cluster(mprov)
	quietly su potmig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(k_tag20permon)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(k_tag20permon)
	estadd scalar elas = r(b)[1,1]	
	quietly su k_tag20permon
	estadd scalar x_mean = r(mean)	
	
eststo internalk5: logit intevermig k_tagpermon count_obs meanrog i.mreg, cluster(mprov)
	quietly su intevermig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if intevermig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(k_tagpermon)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(k_tagpermon)
	estadd scalar elas = r(b)[1,1]	
	quietly su k_tagpermon
	estadd scalar x_mean = r(mean)	
	
eststo internalk20: logit intevermig k_tag20permon count_obs meanrog i.mreg, cluster(mprov)
	quietly su intevermig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if intevermig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(k_tag20permon)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(k_tag20permon)
	estadd scalar elas = r(b)[1,1]	
	quietly su k_tag20permon
	estadd scalar x_mean = r(mean)	


esttab externalk5 externalk20 internalk5 internalk20 using "$tables/casualty_logit_combo_ktag.tex", replace style(tex) ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
keep(k_tagpermon k_tag20permon meanrog) order(k_tagpermon k_tag20permon meanrog) collabels(none) compress noobs nonotes nomtitle booktabs ///
scalars("marg dy/dx" "elas $\epsilon$" "x_mean Avg. monthly exp." "bigN Observations" "liln Migrants classified" "samp_mean \% classified") sfmt(4 3 2 0 0 2) ///
mgroups("External (Lenient)" "Internal", pattern(1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
estimates clear


*wound only

estimates clear
eststo externalk5: logit potmig w_tagpermon count_obs meanrog i.mreg, cluster(mprov)
	quietly su potmig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(w_tagpermon)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(w_tagpermon)
	estadd scalar elas = r(b)[1,1]	
	quietly su w_tagpermon
	estadd scalar x_mean = r(mean)	
	
eststo externalk20: logit potmig w_tag20permon count_obs meanrog i.mreg, cluster(mprov)
	quietly su potmig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(w_tag20permon)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(w_tag20permon)
	estadd scalar elas = r(b)[1,1]	
	quietly su w_tag20permon
	estadd scalar x_mean = r(mean)	
	
eststo internalk5: logit intevermig w_tagpermon count_obs meanrog i.mreg, cluster(mprov)
	quietly su intevermig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if intevermig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(w_tagpermon)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(w_tagpermon)
	estadd scalar elas = r(b)[1,1]	
	quietly su w_tagpermon
	estadd scalar x_mean = r(mean)	
	
eststo internalk20: logit intevermig w_tag20permon count_obs meanrog i.mreg, cluster(mprov)
	quietly su intevermig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if intevermig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(w_tag20permon)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(w_tag20permon)
	estadd scalar elas = r(b)[1,1]	
	quietly su w_tag20permon
	estadd scalar x_mean = r(mean)	


esttab externalk5 externalk20 internalk5 internalk20 using "$tables/casualty_logit_combo_wtag.tex", replace style(tex) ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
keep(w_tagpermon w_tag20permon meanrog) order(w_tagpermon w_tag20permon meanrog) collabels(none) compress noobs nonotes nomtitle booktabs ///
scalars("marg dy/dx" "elas $\epsilon$" "x_mean Avg. monthly exp." "bigN Observations" "liln Migrants classified" "samp_mean \% classified") sfmt(4 3 2 0 0 2) ///
mgroups("External (Lenient)" "Internal", pattern(1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
estimates clear






*Plots
est clear
logit potmig jointpermon count_obs meanrog i.mreg, cluster(mprov)
margins, at(jointpermon=(0(.1)2)) saving(file1, replace)
marginsplot
est clear
logit intevermig jointpermon count_obs meanrog i.mreg, cluster(mprov)
margins, at(jointpermon=(0(.1)2)) saving(file2, replace)
marginsplot
combomp file1 file2, recastci(rline) ciopt(lpattern(dash) lcolor(%25)) title("") labels("External (Lenient)" "Internal") legend(position(6) rows(1) size(medium))
graph export "$figures/highcasualty_levels.png", replace

est clear
logit potmig joint20permon count_obs meanrog i.mreg, cluster(mprov)
margins, at(joint20permon=(0(.1)2)) saving(file1, replace)
marginsplot
est clear
logit intevermig joint20permon count_obs meanrog i.mreg, cluster(mprov)
margins, at(joint20permon=(0(.1)2)) saving(file2, replace)
marginsplot
combomp file1 file2, recastci(rline) ciopt(lpattern(dash) lcolor(%25)) title("") labels("External (Lenient)" "Internal") legend(position(6) rows(1) size(medium))
graph export "$figures/highcasualty20_levels.png", replace




