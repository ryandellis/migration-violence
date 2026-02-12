/*==================================================
project:       Mobility sample statistics
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
use "$derived/VFD_restricted_1monthmin_with_migration", replace

/*==================================================
              1: base level restrictions
==================================================*/


sort id date
xtset id date



// collapse to id level

collapse (max) intevermig potmig potmig2 d_df_5km d_idf_5km d_ied_5km d_ied_fc_5km d_safire_5km d_violence_5km d_violence_all_5km d_df_20km d_idf_20km d_ied_20km d_ied_fc_20km d_safire_20km d_violence_20km d_violence_all_20km count_obs total_imputed share_imputed (sum) df_5km idf_5km ied_5km ied_fc_5km safire_5km violence_5km violence_all_5km df_20km idf_20km ied_20km ied_fc_20km safire_20km violence_20km violence_all_20km s_dtag s_ptag s_distance s_dist_mloc2 (mean) dtag ptag rog distance dist_mloc2, by(id)

// create "per day" variables

foreach var in df_5km idf_5km ied_5km ied_fc_5km safire_5km violence_5km violence_all_5km df_20km idf_20km ied_20km ied_fc_20km safire_20km violence_20km violence_all_20km {
	gen perday_`var' = `var' / count_obs
}

foreach var in perday_df_5km perday_idf_5km perday_ied_5km perday_ied_fc_5km perday_safire_5km perday_violence_5km perday_violence_all_5km perday_df_20km perday_idf_20km perday_ied_20km perday_ied_fc_20km perday_safire_20km perday_violence_20km perday_violence_all_20km {
	gen permon`var' = `var' * 30
}

ren (permonperday_df_5km permonperday_idf_5km permonperday_ied_5km permonperday_ied_fc_5km permonperday_safire_5km permonperday_violence_5km permonperday_violence_all_5km permonperday_df_20km permonperday_idf_20km permonperday_ied_20km permonperday_ied_fc_20km permonperday_safire_20km permonperday_violence_20km permonperday_violence_all_20km) (df5permon idf5permon ied5permon iedfc5permon safire5permon violence5permon all5permon df20permon idf20permon ied20permon iedfc20permon safire20permon violence20permon all20permon)
//labels

lab var count_obs "Days in sample"
lab var share_imputed "Share imputed"
lab var d_violence_5km "All violence"
lab var d_df_5km "Direct fire"
lab var d_idf_5km "Indirect fire"
lab var d_ied_5km "IED"
lab var d_safire_5km "Surface-air"
lab var d_violence_all_5km "All violence"
lab var d_ied_fc_5km "IED, cleared"
lab var violence_5km "All violence"
lab var df_5km "Direct fire"
lab var idf_5km "Indirect fire"
lab var ied_5km "IED"
lab var safire_5km "Surface-air"
lab var violence_all_5km "All violence"
lab var ied_fc_5km "IED, cleared"
lab var perday_violence_5km "All violence"
lab var perday_df_5km "Direct fire"
lab var perday_idf_5km "Indirect fire"
lab var perday_ied_5km "IED"
lab var perday_safire_5km "Surface-air"
lab var perday_violence_all_5km "All violence"
lab var perday_ied_fc_5km "IED, cleared"
lab var d_violence_20km "All violence"
lab var d_df_20km "Direct fire"
lab var d_idf_20km "Indirect fire"
lab var d_ied_20km "IED"
lab var d_safire_20km "Surface-air"
lab var d_violence_all_20km "All violence"
lab var d_ied_fc_20km "IED, cleared"
lab var violence_20km "All violence"
lab var df_20km "Direct fire"
lab var idf_20km "Indirect fire"
lab var ied_20km "IED"
lab var safire_20km "Surface-air"
lab var violence_all_20km "All violence"
lab var ied_fc_20km "IED, cleared"
lab var perday_violence_20km "All violence"
lab var perday_df_20km "Direct fire"
lab var perday_idf_20km "Indirect fire"
lab var perday_ied_20km "IED"
lab var perday_safire_20km "Surface-air"
lab var perday_violence_all_20km "All violence"
lab var perday_ied_fc_20km "IED, cleared"
lab var distance "Km from home"
lab var rog "Radius of gyration (km)"
lab var dtag "Outside home district"
lab var ptag "Outside home province"
lab var intevermig "Internal migrant"
lab var potmig "External migrant (1)"
lab var potmig2 "External migrant (2)"
lab var df5permon "Direct fire"
lab var idf5permon "Indirect fire"
lab var ied5permon "IED"
lab var iedfc5permon "IED, cleared"
lab var safire5permon "Surface-air"
lab var all5permon "All violence"
lab var df20permon "Direct fire"
lab var idf20permon "Indirect fire"
lab var ied20permon "IED"
lab var iedfc20permon "IED, cleared"
lab var safire20permon "Surface-air"
lab var all20permon "All violence"

// offsetting labels for latex:

foreach x of varlist count_obs share_imputed d_df_5km d_idf_5km d_ied_5km d_ied_fc_5km d_safire_5km d_violence_5km d_violence_all_5km d_df_20km d_idf_20km d_ied_20km d_ied_fc_20km d_safire_20km d_violence_20km d_violence_all_20km df_5km idf_5km ied_5km ied_fc_5km safire_5km violence_5km violence_all_5km df_20km idf_20km ied_20km ied_fc_20km safire_20km violence_20km violence_all_20km perday_df_5km perday_idf_5km perday_ied_5km perday_ied_fc_5km perday_safire_5km perday_violence_5km perday_violence_all_5km perday_df_20km perday_idf_20km perday_ied_20km perday_ied_fc_20km perday_safire_20km perday_violence_20km perday_violence_all_20km dtag ptag rog distance intevermig potmig potmig2 df5permon idf5permon ied5permon iedfc5permon safire5permon all5permon df20permon idf20permon ied20permon iedfc20permon safire20permon all20permon{
  local t : var label `x'
  local t = "\hspace{0.25cm} `t'"
  lab var `x' "`t'"
}

// summary of data shape vars, most basic restrictions first

tabstat count_obs share_imputed, c(stat) stat(mean sd min max n)

// summary of exposure vars (ever exposed)

tabstat d_df_5km d_idf_5km d_ied_5km d_ied_fc_5km d_safire_5km d_violence_all_5km d_df_20km d_idf_20km d_ied_20km d_ied_fc_20km d_safire_20km d_violence_all_20km, c(stat) stat(mean sd min max n)

// summary of total exposures

tabstat df_5km idf_5km ied_5km ied_fc_5km safire_5km violence_all_5km df_20km idf_20km ied_20km ied_fc_20km safire_20km violence_all_20km, c(stat) stat(mean sd min max n)

// summary of exposures per day (normalized by count_obs)

tabstat perday_df_5km perday_idf_5km perday_ied_5km perday_ied_fc_5km perday_safire_5km perday_violence_all_5km perday_df_20km perday_idf_20km perday_ied_20km perday_ied_fc_20km perday_safire_20km perday_violence_all_20km , c(stat) stat(mean sd min max n)

// summary of exposures per month

tabstat df5permon idf5permon ied5permon iedfc5permon safire5permon all5permon df20permon idf20permon ied20permon iedfc20permon safire20permon all20permon, c(stat) stat(mean p50 sd min max n)

// summary of mobility vars

tabstat distance rog dtag ptag intevermig potmig potmig2, c(stat) stat(mean sd min max n)

// generate long table at 5km exp:

estpost tabstat d_violence_all_5km d_df_5km d_idf_5km d_safire_5km d_ied_5km violence_all_5km df_5km idf_5km safire_5km ied_5km perday_violence_all_5km perday_df_5km perday_idf_5km perday_safire_5km perday_ied_5km, c(stat) stat(mean sd median max)
	
esttab, cells("mean sd p50 max")
estout, cells("mean sd p50 max")

esttab using "$tables/sumstat5km1_1monthmin.tex", replace ///
	refcat(d_violence_all_5km "\vspace{0.1em} \\ \emph{Panel A: Violence (Ever exposed)}" violence_all_5km "\vspace{0.1em} \\ \emph{Panel B: Violence (Total exposures)}" perday_violence_all_5km "\vspace{0.1em} \\ \emph{Panel C: Violence (Per day)}", nolabel) ///
	cells("mean(fmt(2)) sd(fmt(2)) p50(fmt(2)) max(fmt(0))") nostar unstack nonumber ///
  compress nomtitle nonote noobs label booktabs ///
  collabels("Mean" "SD" "Med" "Max")


est clear

// generate long table at 20km exp:

estpost tabstat d_violence_all_20km d_df_20km d_idf_20km d_safire_20km d_ied_20km violence_all_20km df_20km idf_20km safire_20km ied_20km perday_violence_all_20km perday_df_20km perday_idf_20km perday_safire_20km perday_ied_20km, c(stat) stat(mean sd median max)
	
esttab, cells("mean sd p50 max")
estout, cells("mean sd p50 max")

esttab using "$tables/sumstat20km1_1monthmin.tex", replace ///
	refcat(d_violence_all_20km "\vspace{0.1em} \\ \emph{Panel A: Violence (Ever exposed)}" violence_all_20km "\vspace{0.1em} \\ \emph{Panel B: Violence (Total exposures)}" perday_violence_all_20km "\vspace{0.1em} \\ \emph{Panel C: Violence (Per day)}", nolabel) ///
	cells("mean(fmt(2)) sd(fmt(2)) p50(fmt(2)) max(fmt(0))") nostar unstack nonumber ///
  compress nomtitle nonote noobs label booktabs ///
  collabels("Mean" "SD" "Med" "Max")
  
// generate short table, monthly only at 5km:

estpost tabstat all5permon df5permon idf5permon safire5permon ied5permon, c(stat) stat(mean sd min max n)

esttab, cells("mean sd max")
estout, cells("mean sd max")

esttab using "$tables/sumstat_monthly.tex", replace ///
	refcat(all5permon "\vspace{0.1em} \\ \emph{Average monthly rate of exposure}", nolabel) ///
	cells("mean(fmt(3)) sd(fmt(3)) max(fmt(0))") nostar unstack nonumber ///
	compress nomtitle nonote noobs label booktab collabels("Mean" "SD" "Max")

// generate summary of migration vars:

estpost tabstat distance rog dtag ptag intevermig potmig potmig2, c(stat) stat(mean sd median max)

esttab, cells("mean sd p50 max")
estout, cells("mean sd p50 max")

esttab using "$tables/sumstat_mig_1monthmin.tex", replace ///
	refcat(distance "\vspace{0.1em} \\ \emph{Panel A: Mobility}" intevermig "\vspace{0.1em} \\ \emph{Panel B: Migration}", nolabel) ///
	cells("mean(fmt(2)) sd(fmt(2)) p50(fmt(2)) max(fmt(0))") nostar unstack nonumber ///
  compress nomtitle nonote noobs label booktabs ///
  collabels("Mean" "SD" "Med" "Max")

  
  
  
  
  
  
  
  // balance table?


xtile quartile = perday_violence_5km, nq(4)
xtile decile = perday_violence_5km, nq(10)

tab quartile
gen dummy = inlist(quartile, 1,4)

global vars dist_mloc2 rog dtag ptag intevermig

est clear
estpost ttest $vars, by(dummy)
ereturn list
esttab using "$tables/balance_quartiles.tex", replace ///
	cells("mu_1(fmt(3)) mu_2 b(star) se(par) count(fmt(0))") ///
	collabels("Q1" "Q4" "Diff." "SE" "N") ///
	star(* 0.10 ** 0.05 *** 0.01) label booktabs nonum gaps noobs compress


