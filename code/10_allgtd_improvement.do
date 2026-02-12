/*==================================================
project:       high casualty (improved, using all GTD)
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

merge 1:1 id date using "$derived/allgtd_clean"

gen region = .
replace region = 1 if provid==14 | provid==16 | provid==21 | provid==22 | provid==28 | provid==29 
replace region = 2 if provid==18 | provid==20 | provid==23 | provid==25
replace region = 3 if provid==1 | provid==3 | provid==19 | provid==32
replace region = 4 if provid==4 | provid==8 | provid==13 | provid==30 | provid==31
replace region = 5 if provid==9 | provid==17 | provid==26 | provid==27
replace region = 6 if provid==6 | provid==11 | provid==15 | provid==24 | provid==33 | provid==34 
replace region = 7 if provid==2 | provid==5 | provid==7 | provid==10 | provid==12

bys id: egen mreg = mode(region), min


foreach var in gtd5km w_tag k_tag both nkill nwound gtd20km w_tag20 k_tag20 both20 nkill20 nwound20 {
	replace `var' = 0 if `var' == .
}

drop w_tag k_tag both w_tag20 k_tag20 both20 // let's reformulate into bands

foreach var in nkill nkill20 {
	gen `var'_0 = 0
	replace `var'_0 = 1 if `var' == 0
	gen `var'_2 = 0
	replace `var'_2 = 1 if `var' < 3 & `var' > 0
	gen `var'_5 = 0
	replace `var'_5 = 1 if `var' < 6 & `var' > 2
	gen `var'_9 = 0
	replace `var'_9 = 1 if `var' < 10 & `var' > 5
	gen `var'_plus = 0
	replace `var'_plus = 1 if `var' > 10
}



gcollapse (max) dropout intevermig count_obs meanrog potmig potmig2 share_imputed (first) mdist mprov mreg (sum) gtd5km gtd20km nkill nkill20 nkill_0 nkill_2 nkill_5 nkill_9 nkill_plus nkill20_0 nkill20_2 nkill20_5 nkill20_9 nkill20_plus violence_all_5km violence_all_20km, by(id)

foreach var in nkill nkill20 nkill_0 nkill_2 nkill_5 nkill_9 nkill_plus nkill20_0 nkill20_2 nkill20_5 nkill20_9 nkill20_plus gtd5km gtd20km violence_all_5km violence_all_20km{
	gen `var'_pm = `var'*30 / count_obs
}


lab var nkill_0_pm "0 killed"
lab var nkill20_0_pm "0 killed"
lab var nkill_2_pm "1-2 killed"
lab var nkill_5_pm "3-5 killed"
lab var nkill_9_pm "6-9 killed"
lab var nkill_plus_pm "10+ killed"
lab var nkill20_2_pm "1-2 killed"
lab var nkill20_5_pm "3-5 killed"
lab var nkill20_9_pm "6-9 killed"
lab var nkill20_plus_pm "10+ killed"
lab var violence_all_5km_pm "SIGACTs 5km"
lab var violence_all_20km_pm "SIGACTs 20km"
lab var meanrog "ROG"

*main results for comparison/check
logit potmig violence_all_5km_pm count_obs meanrog share_imputed i.mreg, cluster(mprov) or
logit potmig2 violence_all_5km_pm count_obs meanrog share_imputed i.mreg, cluster(mprov) or

*need to decide: should the SIGACT exposure variable remain?

reg potmig nkill_0_pm nkill_2_pm nkill_5_pm nkill_9_pm nkill_plus_pm meanrog share_imputed i.mreg, cluster(mprov)

logit potmig violence_all_5km_pm nkill_plus_pm count_obs meanrog share_imputed i.mreg, cluster(mprov) or
*TABLES

estimates clear
eststo bands5km: logit potmig violence_all_5km_pm nkill_2_pm nkill_5_pm nkill_9_pm nkill_plus_pm count_obs meanrog share_imputed i.mreg, cluster(mprov) or
	quietly su potmig
	scalar samp_mean = r(mean)
	estadd scalar samp_mean = samp_mean
	estadd scalar bigN = r(N)
	quietly margins, dydx(nkill_2_pm)
	scalar marg2 = r(b)[1,1]
	scalar delta2 = marg2 / samp_mean
	estadd scalar delta2 = delta2
	quietly margins, dydx(nkill_5_pm)
	scalar marg5 = r(b)[1,1]
	scalar delta5 = marg5 / samp_mean
	estadd scalar delta5 = delta5
	quietly margins, dydx(nkill_9_pm)
	scalar marg9 = r(b)[1,1]
	scalar delta9 = marg9 / samp_mean
	estadd scalar delta9 = delta9
	quietly margins, dydx(nkill_plus_pm)
	scalar margp = r(b)[1,1]
	scalar deltap = margp / samp_mean
	estadd scalar deltap = deltap
	estadd local geos = "YES"
	scalar drop _all	
	
eststo bands20km: logit potmig violence_all_20km_pm nkill20_2_pm nkill20_5_pm nkill20_9_pm nkill20_plus_pm count_obs meanrog share_imputed i.mreg, cluster(mprov) or
	quietly su potmig
	scalar samp_mean = r(mean)
	estadd scalar samp_mean = samp_mean
	estadd scalar bigN = r(N)
	quietly margins, dydx(nkill20_2_pm)
	scalar marg2 = r(b)[1,1]
	scalar delta2 = marg2 / samp_mean
	estadd scalar delta2 = delta2
	quietly margins, dydx(nkill20_5_pm)
	scalar marg5 = r(b)[1,1]
	scalar delta5 = marg5 / samp_mean
	estadd scalar delta5 = delta5
	quietly margins, dydx(nkill20_9_pm)
	scalar marg9 = r(b)[1,1]
	scalar delta9 = marg9 / samp_mean
	estadd scalar delta9 = delta9
	quietly margins, dydx(nkill20_plus_pm)
	scalar margp = r(b)[1,1]
	scalar deltap = margp / samp_mean
	estadd scalar deltap = deltap
	estadd local geos = "YES"
	scalar drop _all	

esttab bands5km bands20km using "$tables/bands_logit_sigact.tex", replace style(tex) depvars ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
keep(violence_all_5km_pm nkill_2_pm nkill_5_pm nkill_9_pm nkill_plus_pm violence_all_20km_pm nkill20_2_pm nkill20_5_pm nkill20_9_pm nkill20_plus_pm meanrog) order(violence_all_5km_pm nkill_2_pm nkill_5_pm nkill_9_pm nkill_plus_pm violence_all_20km_pm nkill20_2_pm nkill20_5_pm nkill20_9_pm nkill20_plus_pm) collabels(none) compress noobs nonotes nomtitle booktabs eqlabels("") eform ///
scalars("samp_mean Dependent var. mean" "delta2 $\Delta$ over baseline (1-2)" "delta5 $\Delta$ over baseline (3-5)" "delta9 $\Delta$ over baseline (6-9)" "deltap $\Delta$ over baseline (10+)" "bigN Observations" "geos Geographic controls" ) sfmt(4 4 4 4 4 2 0)
estimates clear

*Plots

logit potmig violence_all_5km_pm nkill_2_pm nkill_5_pm nkill_9_pm nkill_plus_pm count_obs meanrog share_imputed i.mreg, cluster(mprov) or
coefplot, vert keep(nkill_2_pm nkill_5_pm nkill_9_pm nkill_plus_pm) eform ytitle("Multiplicative Odds of Migration") xtitle("Monthly Exposures by Number Killed") yline(1, lcolor(red) lwidth(thick)) recast(bar) citop cirecast(rcap) ciopts(lcolor(black*.8)) barwidth(.8)
graph export "$figures/killbarslenient5km.png", replace

logit potmig violence_all_20km_pm nkill20_2_pm nkill20_5_pm nkill20_9_pm nkill20_plus_pm count_obs meanrog share_imputed i.mreg, cluster(mprov) or
coefplot, vert keep(nkill20_2_pm nkill20_5_pm nkill20_9_pm nkill20_plus_pm) eform ytitle("Multiplicative Odds of Migration") xtitle("Monthly Exposures by Number Killed") yline(1, lcolor(red) lwidth(thick)) recast(bar) citop cirecast(rcap) ciopts(lcolor(black*.8)) barwidth(.8)
graph export "$figures/killbarslenient20km.png", replace

logit potmig2 violence_all_5km_pm nkill_2_pm nkill_5_pm nkill_9_pm nkill_plus_pm count_obs meanrog share_imputed i.mreg, cluster(mprov) or
coefplot, vert keep(nkill_2_pm nkill_5_pm nkill_9_pm nkill_plus_pm) eform ytitle("Multiplicative Odds of Migration") xtitle("Monthly Exposures by Number Killed") yline(1, lcolor(red) lwidth(thick)) recast(bar) citop cirecast(rcap) ciopts(lcolor(black*.8)) barwidth(.8)
graph export "$figures/killbarsrestrictive5km.png", replace

logit potmig2 violence_all_20km_pm nkill20_2_pm nkill20_5_pm nkill20_9_pm nkill20_plus_pm count_obs meanrog share_imputed i.mreg, cluster(mprov) or
coefplot, vert keep(nkill20_2_pm nkill20_5_pm nkill20_9_pm nkill20_plus_pm) eform ytitle("Multiplicative Odds of Migration") xtitle("Monthly Exposures by Number Killed") yline(1, lcolor(red) lwidth(thick)) recast(bar) citop cirecast(rcap) ciopts(lcolor(black*.8)) barwidth(.8)
graph export "$figures/killbarsrestrictive20km.png", replace

logit intevermig violence_all_5km_pm nkill_2_pm nkill_5_pm nkill_9_pm nkill_plus_pm count_obs meanrog share_imputed i.mreg, cluster(mprov) or
coefplot, vert keep(nkill_2_pm nkill_5_pm nkill_9_pm nkill_plus_pm) eform ytitle("Multiplicative Odds of Migration") xtitle("Monthly Exposures by Number Killed") yline(1, lcolor(red) lwidth(thick)) recast(bar) citop cirecast(rcap) ciopts(lcolor(black*.8)) barwidth(.8)
graph export "$figures/killbarsinternal5km.png", replace

logit intevermig violence_all_20km_pm nkill20_2_pm nkill20_5_pm nkill20_9_pm nkill20_plus_pm count_obs meanrog share_imputed i.mreg, cluster(mprov) or
coefplot, vert keep(nkill20_2_pm nkill20_5_pm nkill20_9_pm nkill20_plus_pm) eform ytitle("Multiplicative Odds of Migration") xtitle("Monthly Exposures by Number Killed") yline(1, lcolor(red) lwidth(thick)) recast(bar) citop cirecast(rcap) ciopts(lcolor(black*.8)) barwidth(.8)
graph export "$figures/killbarsinternal20km.png", replace

************************
*margins?

// logit potmig violence_all_5km_pm nkill_2_pm nkill_5_pm nkill_9_pm nkill_plus_pm count_obs meanrog share_imputed i.mreg, cluster(mprov) or
// margins, at(nkill_2_pm=(0(.5)4))
// marginsplot
// margins, at(nkill_5_pm=(0(.5)4))
// marginsplot
// margins, at(nkill_9_pm=(0(.5)4))
// marginsplot
// margins, at(nkill_plus_pm=(0(.5)4))
// marginsplot

