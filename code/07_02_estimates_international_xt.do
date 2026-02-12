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
version 18
drop _all
cd "$AFG_CDR"
use processed/VFD_restricted_1monthmin_with_migration, clear
/*==================================================
              1: basic setup
==================================================*/

foreach i in df idf ied safire {
	by id: egen total_`i'_5km = total(`i'_5km)
	by id: gen `i'perday_5km = total_`i'_5km / count_obs
	by id: gen `i'permon_5km = `i'perday_5km * 30
	by id: gen `i'peryear_5km = `i'perday_5km * 365
}

foreach i in df idf ied safire {
	by id: egen total_`i'_20km = total(`i'_20km)
	by id: gen `i'perday_20km = total_`i'_20km / count_obs
	by id: gen `i'permon_20km = `i'perday_20km * 30
	by id: gen `i'peryear_20km = `i'perday_20km * 365
}

gen region = .
replace region = 1 if provid==14 | provid==16 | provid==21 | provid==22 | provid==28 | provid==29 
replace region = 2 if provid==18 | provid==20 | provid==23 | provid==25
replace region = 3 if provid==1 | provid==3 | provid==19 | provid==32
replace region = 4 if provid==4 | provid==8 | provid==13 | provid==30 | provid==31
replace region = 5 if provid==9 | provid==17 | provid==26 | provid==27
replace region = 6 if provid==6 | provid==11 | provid==15 | provid==24 | provid==33 | provid==34 
replace region = 7 if provid==2 | provid==5 | provid==7 | provid==10 | provid==12

bys id: egen mreg = mode(region), min

gcollapse (max) dropout share_imputed intevermig total_imputed count_obs meanrog potmig potmig2 (sum) total_violence_5km total_violence_20km total_df_5km total_idf_5km total_ied_5km total_safire_5km total_df_20km total_idf_20km total_ied_20km total_safire_20km (first) finalborder mdist mprov mreg, by(id ym)
xtset id ym


/*==================================================
              2: estimation on panel data
==================================================*/
lab var potmig "Pr(External Lenient)"
lab var potmig2 "Pr(External Restrictive)"
lab var intevermig "Pr(Internal)"
lab var count_obs "Days in sample"
lab var share_imputed "Share imputed"
lab var meanrog "Mean ROG (km)"


*(need more labels)
gen ihs5 = asinh(total_violence_5km)
gen ihs20 = asinh(total_violence_20km)
gen runsum5 = sum(total_violence_5km)
gen runsum20 = sum(total_violence_20km)

xtpoisson potmig runsum5 i.ym, fe




/*logit potmig ihs5 meanrog count_obs i.mreg, cluster(mprov)
logit potmig2 ihs5 meanrog count_obs i.mreg, cluster(mprov)
poisson potmig ihs5 meanrog count_obs i.mreg, cluster(mprov) 
poisson potmig2 ihs5 meanrog count_obs i.mreg, cluster(mprov)
probit potmig ihs5 meanrog count_obs i.mreg, cluster(mprov)
probit potmig2 ihs5 meanrog count_obs i.mreg, cluster(mprov)


*----------2.3: simple logit table
est clear
eststo lax5: logit potmig vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_5km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_5km)
	estadd scalar elas = r(b)[1,1]
	quietly su vpermon_5km
	estadd scalar x_mean = r(mean)

eststo strict5: logit potmig2 vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig2
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig2==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_5km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_5km)
	estadd scalar elas = r(b)[1,1]
	quietly su vpermon_5km
	estadd scalar x_mean = r(mean)
	
eststo internal5: logit intevermig vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
	quietly su intevermig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if intevermig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_5km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_5km)
	estadd scalar elas = r(b)[1,1]	
	quietly su vpermon_5km
	estadd scalar x_mean = r(mean)
	
	
*SAME THING AT 20KM

eststo lax20: logit potmig vpermon_20km meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_20km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_20km)
	estadd scalar elas = r(b)[1,1]
	quietly su vpermon_20km
	estadd scalar x_mean = r(mean)

eststo strict20: logit potmig2 vpermon_20km meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig2
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig2==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_20km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_20km)
	estadd scalar elas = r(b)[1,1]
	quietly su vpermon_20km
	estadd scalar x_mean = r(mean)
	
eststo internal20: logit intevermig vpermon_20km meanrog count_obs i.mreg, cluster(mprov)
	quietly su intevermig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if intevermig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_20km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_20km)
	estadd scalar elas = r(b)[1,1]	
	quietly su vpermon_20km
	estadd scalar x_mean = r(mean)	

esttab lax5 lax20 strict5 strict20 internal5 internal20 using results/tables/simple_logit_combo_ctrls.tex, replace style(tex) ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
keep(vpermon_5km vpermon_20km meanrog) order(vpermon_5km vpermon_20km meanrog) collabels(none) compress noobs nonotes nomtitle booktabs ///
scalars("marg dy/dx" "elas $\epsilon$" "x_mean Avg. monthly exp." "bigN Observations" "liln Migrants classified" "samp_mean \% classified") sfmt(4 3 2 0 0 2) ///
mgroups("External (Lenient)" "External (Restrictive)" "Internal", pattern(1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
estimates clear

// margins plots: levels
est clear
logit potmig vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, at (vpermon_5km=(0(1)30)) saving(file1, replace)

est clear
logit potmig2 vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, at(vpermon_5km=(0(1)30)) saving(file2, replace)

combomp file1 file2, recastci(rline) ciopt(lpattern(dash) lcolor(%25)) title("") labels("Lenient Model" "Restrictive Model") legend(position(6) rows(1) size(medium))
graph export results/figures/migration_levels_ctrls.png, replace
****************************
est clear
logit intevermig vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, at (vpermon_5km=(0(1)30)) saving(file1, replace)

est clear
logit dropout vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, at(vpermon_5km=(0(1)30)) saving(file2, replace)

combomp file1 file2, recastci(rline) ciopt(lpattern(dash) lcolor(%25)) title("") labels("Internal Migration" "Attrition") legend(position(6) rows(1) size(medium))
graph export results/figures/nonmig_levels_ctrls.png, replace


*----------2.2:
// margins plots: elasticities
est clear
logit potmig vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, eyex(vpermon_5km) at(vpermon_5km=(0(1)30)) saving(file1, replace)

est clear
logit potmig2 vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, eyex(vpermon_5km) at(vpermon_5km=(0(1)30)) saving(file2, replace)

combomp file1 file2, recastci(rline) ciopt(lpattern(dash) lcolor(%25)) title("") labels("Lenient Model" "Restrictive Model") legend(position(6) rows(1) size(medium))
graph export results/figures/migration_elasticities_ctrls.png, replace


*********
est clear
logit intevermig vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, eyex(vpermon_5km) at (vpermon_5km=(0(1)30)) saving(file1, replace)

est clear
logit dropout vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, eyex(vpermon_5km) at(vpermon_5km=(0(1)30)) saving(file2, replace)

combomp file1 file2, recastci(rline) ciopt(lpattern(dash) lcolor(%25)) title("") labels("Internal Migration" "Attrition") legend(position(6) rows(1) size(medium))
graph export results/figures/nonmig_elasticities_ctrls.png, replace
/*==================================================
              3: marginplots, dydx
==================================================*/
est clear
logit potmig vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, dydx(vpermon_5km) at(vpermon_5km=(0(1)30)) saving(file1, replace)

est clear
logit potmig2 vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, dydx(vpermon_5km) at(vpermon_5km=(0(1)30)) saving(file2, replace)

combomp file1 file2, recastci(rline) ciopt(lpattern(dash) lcolor(%25)) title("") labels("Lenient Model" "Restrictive Model") legend(position(6) rows(1) size(medium))
graph export results/figures/migration_dydx_ctrls.png, replace


*********
est clear
logit intevermig vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, dydx(vpermon_5km) at (vpermon_5km=(0(1)30)) saving(file1, replace)

est clear
logit dropout vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, dydx(vpermon_5km) at(vpermon_5km=(0(1)30)) saving(file2, replace)

combomp file1 file2, recastci(rline) ciopt(lpattern(dash) lcolor(%25)) title("") labels("Internal Migration" "Attrition") legend(position(6) rows(1) size(medium))
graph export results/figures/nonmig_dydx_ctrls.png, replace




*----------3.2:
su vpermon_5km, d




logit potmig vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, dydx(vpermon_5km) at(vpermon_5km=(16.447))

logit potmig2 vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, dydx(vpermon_5km) at(vpermon_5km=(16.447))




*IED estimation
est clear
eststo lax5: logit potmig iedpermon_5km meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(iedpermon_5km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(iedpermon_5km)
	estadd scalar elas = r(b)[1,1]
	quietly su iedpermon_5km
	estadd scalar x_mean = r(mean)

eststo strict5: logit potmig2 iedpermon_5km meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig2
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig2==1
	estadd scalar liln = r(N)
	quietly margins, dydx(iedpermon_5km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(iedpermon_5km)
	estadd scalar elas = r(b)[1,1]
	quietly su iedpermon_5km
	estadd scalar x_mean = r(mean)
	
eststo internal5: logit intevermig iedpermon_5km meanrog count_obs i.mreg, cluster(mprov)
	quietly su intevermig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if intevermig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(iedpermon_5km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(iedpermon_5km)
	estadd scalar elas = r(b)[1,1]	
	quietly su iedpermon_5km
	estadd scalar x_mean = r(mean)
	
	
*SAME THING AT 20KM

eststo lax20: logit potmig iedpermon_20km meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(iedpermon_20km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(iedpermon_20km)
	estadd scalar elas = r(b)[1,1]
	quietly su iedpermon_20km
	estadd scalar x_mean = r(mean)

eststo strict20: logit potmig2 iedpermon_20km meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig2
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig2==1
	estadd scalar liln = r(N)
	quietly margins, dydx(iedpermon_20km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(iedpermon_20km)
	estadd scalar elas = r(b)[1,1]
	quietly su iedpermon_20km
	estadd scalar x_mean = r(mean)
	
eststo internal20: logit intevermig iedpermon_20km meanrog count_obs i.mreg, cluster(mprov)
	quietly su intevermig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if intevermig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(iedpermon_20km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(iedpermon_20km)
	estadd scalar elas = r(b)[1,1]	
	quietly su iedpermon_20km
	estadd scalar x_mean = r(mean)	

esttab lax5 lax20 strict5 strict20 internal5 internal20 using results/tables/simple_logit_combo_ied.tex, replace style(tex) ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
keep(iedpermon_5km iedpermon_20km meanrog) order(iedpermon_5km iedpermon_20km meanrog) collabels(none) compress noobs nonotes nomtitle booktabs ///
scalars("marg dy/dx" "elas $\epsilon$" "x_mean Avg. monthly exp." "bigN Observations" "liln Migrants classified" "samp_mean \% classified") sfmt(4 3 2 0 0 2) ///
mgroups("External (Lenient)" "External (Restrictive)" "Internal", pattern(1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
estimates clear




***********************************************
*POISSON version of main estimates
***********************************************
est clear
eststo lax5: poisson potmig vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_5km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_5km)
	estadd scalar elas = r(b)[1,1]
	quietly su vpermon_5km
	estadd scalar x_mean = r(mean)

eststo strict5: poisson potmig2 vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig2
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig2==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_5km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_5km)
	estadd scalar elas = r(b)[1,1]
	quietly su vpermon_5km
	estadd scalar x_mean = r(mean)
	
eststo internal5: poisson intevermig vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
	quietly su intevermig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if intevermig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_5km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_5km)
	estadd scalar elas = r(b)[1,1]	
	quietly su vpermon_5km
	estadd scalar x_mean = r(mean)
	
	
*SAME THING AT 20KM

eststo lax20: poisson potmig vpermon_20km meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_20km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_20km)
	estadd scalar elas = r(b)[1,1]
	quietly su vpermon_20km
	estadd scalar x_mean = r(mean)

eststo strict20: poisson potmig2 vpermon_20km meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig2
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig2==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_20km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_20km)
	estadd scalar elas = r(b)[1,1]
	quietly su vpermon_20km
	estadd scalar x_mean = r(mean)
	
eststo internal20: poisson intevermig vpermon_20km meanrog count_obs i.mreg, cluster(mprov)
	quietly su intevermig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if intevermig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_20km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_20km)
	estadd scalar elas = r(b)[1,1]	
	quietly su vpermon_20km
	estadd scalar x_mean = r(mean)	

esttab lax5 lax20 strict5 strict20 internal5 internal20 using results/tables/simple_poisson_combo_ctrls.tex, replace style(tex) ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
keep(vpermon_5km vpermon_20km meanrog) order(vpermon_5km vpermon_20km meanrog) collabels(none) compress noobs nonotes nomtitle booktabs ///
scalars("marg dy/dx" "elas $\epsilon$" "x_mean Avg. monthly exp." "bigN Observations" "liln Migrants classified" "samp_mean \% classified") sfmt(4 3 2 0 0 2) ///
mgroups("External (Lenient)" "External (Restrictive)" "Internal", pattern(1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
estimates clear


*show that migrants are experiencing more violence?


*sanity check table
dtable vpermon_5km vpermon_20km, by(potmig, nototals test) export(results/tables/sanitycheck.tex, tableonly replace) 
dtable vpermon_5km vpermon_20km, by(potmig2, nototals test) export(results/tables/sanitycheck.tex, append) 
dtable vpermon_5km vpermon_20km, by(intevermig, nototals test) export(results/tables/sanitycheck.tex, append) 

logit potmig vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, dydx(vpermon_5km)
margins if potmig==0, dydx(vpermon_5km)
margins if potmig==1, dydx(vpermon_5km)

logit potmig2 vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, dydx(vpermon_5km)
margins if potmig2==0, dydx(vpermon_5km)
margins if potmig2==1, dydx(vpermon_5km)

logit intevermig vpermon_5km meanrog count_obs i.mreg, cluster(mprov)
margins, dydx(vpermon_5km)
margins if intevermig==0, dydx(vpermon_5km)
margins if intevermig==1, dydx(vpermon_5km)



*threshold? test of bohra massey 2011
gen sqvpm5 = vpermon_5km^2
gen sqvpm20 = vpermon_20km^2
lab var sqvpm5 "(5km Exposure)^2"
lab var sqvpm20 "(20km Exposure)^2"

est clear
eststo lax5: logit potmig vpermon_5km sqvpm5 meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_5km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_5km)
	estadd scalar elas = r(b)[1,1]
	quietly su vpermon_5km
	estadd scalar x_mean = r(mean)

eststo strict5: logit potmig2 vpermon_5km sqvpm5 meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig2
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig2==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_5km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_5km)
	estadd scalar elas = r(b)[1,1]
	quietly su vpermon_5km
	estadd scalar x_mean = r(mean)
	
eststo internal5: logit intevermig vpermon_5km sqvpm5 meanrog count_obs i.mreg, cluster(mprov)
	quietly su intevermig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if intevermig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_5km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_5km)
	estadd scalar elas = r(b)[1,1]	
	quietly su vpermon_5km
	estadd scalar x_mean = r(mean)
	
	
*SAME THING AT 20KM

eststo lax20: logit potmig vpermon_20km sqvpm20 meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_20km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_20km)
	estadd scalar elas = r(b)[1,1]
	quietly su vpermon_20km
	estadd scalar x_mean = r(mean)

eststo strict20: logit potmig2 vpermon_20km sqvpm20 meanrog count_obs i.mreg, cluster(mprov)
	quietly su potmig2
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if potmig2==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_20km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_20km)
	estadd scalar elas = r(b)[1,1]
	quietly su vpermon_20km
	estadd scalar x_mean = r(mean)
	
eststo internal20: logit intevermig vpermon_20km sqvpm20 meanrog count_obs i.mreg, cluster(mprov)
	quietly su intevermig
	estadd scalar samp_mean = r(mean)*100
	estadd scalar bigN = r(N)
	quietly count if intevermig==1
	estadd scalar liln = r(N)
	quietly margins, dydx(vpermon_20km)
	estadd scalar marg = r(b)[1,1]
	quietly margins, eyex(vpermon_20km)
	estadd scalar elas = r(b)[1,1]	
	quietly su vpermon_20km
	estadd scalar x_mean = r(mean)	

esttab lax5 lax20 strict5 strict20 internal5 internal20 using results/tables/quadtratic.tex, replace style(tex) ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
keep(vpermon_5km vpermon_20km sqvpm5 sqvpm20) order(vpermon_5km sqvpm5 vpermon_20km sqvpm20) collabels(none) compress noobs nonotes nomtitle booktabs ///
scalars("marg dy/dx" "elas $\epsilon$" "x_mean Avg. monthly exp." "bigN Observations" "liln Migrants classified" "samp_mean \% classified") sfmt(4 3 2 0 0 2) ///
mgroups("External (Lenient)" "External (Restrictive)" "Internal", pattern(1 0 1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
estimates clear


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


