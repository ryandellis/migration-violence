/*==================================================
project:       Wing-style event studies
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
version 18
drop _all
cd "$AFG_CDR"
use processed/VFD_restricted_1monthmin_with_migration, replace
/*==================================================
              1: Variables and samples
==================================================*/

sort id date
xtset id date

keep id date ym mprov mdist distance d_violence_all_5km dtag ptag cogcf

egen days = group(date), autotype // integer day counter for the following loop:

// EVENT STUDY USING STACKS
// STACKS MUST NOW INCLUDE PRE AND POST TREATMENT DAYS
// FIRST ATTEMPT: USING A 10-DAY STACK FROM (-4 5)

keep id date distance dtag ptag d_violence_all_5km days // keep ptag and dtag later for use as depvars

gen byte treat = .


forvalues i = 10(1)421 {
		preserve
        quietly drop if days < (`i' - 9)
        quietly drop if days > (`i' + 10)
		quietly by id: egen numdays = count(days)
		quietly drop if numdays < 10 // subexp has balanced observations
				
        quietly egen et = group(days)
		quietly xtset id et
        quietly bys id: egen numtreat = total(d_violence_all_5km) // total treatments during stack

        quietly drop if numtreat > 1
        quietly replace treat = 0
        quietly replace treat = 1 if d_violence_all_5km == 1
		// creat ttt variable (some commands need this)
		*quietly gen first = .
		quietly bys id: gen temp = et if treat == 1
		quietly bys id: egen first = min(temp)
		quietly bys id: gen ttt = et - first
		// extend to classic treatment variable (stays on)
		quietly bys id: replace treat = 1 if treat[_n-1] == 1 & treat == 0
		quietly drop if first == 1 // must have at least one period without treatments
    	quietly count
			gen N = r(N)
		quietly count if numtreat==1
			gen Nd = r(N)
		quietly count if numtreat==0
			gen Nc = r(N)
	
		// the above is good to go for canned procedures. 
		// here I want to make a classic lags and leads model,
		// and run with common regression commands
			
		forvalues l = 0/18 {
			gen L`l'event = ttt == `l'
		}
		forvalues l = 1/19 {
			gen F`l'event = ttt == -`l'
		}
		quietly compress
		quietly sort id et
		gen stacknum = `i'
		save processed/bigstacks/bigstack_`i', replace
		
		/*
		reghdfe distance o.F1event F2event-F9event L*event, cluster(id)
			
		forvalues l = 0/8 {
			mat L`l'[(`i'-4), `j'] = e(b)[1,(`l' +10)]
		}
		forvalues l = 1/9 {
			mat F`l'[(`i'-4), `j'] = e(b)[1,`l']
		}
		*/
		quietly drop et ttt temp first numtreat N Nd Nc
		
		di "`i' of 421"
    // Restore the original dataset for the next iteration
    restore   
}

// Create the stacked dataset

use processed/bigstacks/bigstack_10, clear

forvalues i = 11(1)421 {
	
	append using processed/bigstacks/bigstack_`i'
	
}
save processed/bigstacked, replace

// Create weights for WOLS event study
// See Wing et al., 2024 for different weighting schemes and justifications
// This is the 3rd weighting scheme they discuss, based on treatment/control counts in the analytical sample 
use processed/bigstacked, clear
preserve
	gcollapse (mean) N Nd Nc, by(stacknum)
	
	egen totalN = total(N)
	su totalN
	scalar totalN = r(mean)
	
	egen totalNd = total(Nd)
	su totalNd
	scalar totalNd = r(mean)
	
	egen totalNc = total(Nc)
	su totalNc
	scalar totalNc = r(mean)
restore

gen weight = .
replace weight = (N/totalN)/(Nd/totalNd) if numtreat > 0
replace weight = (N/totalN)/(Nc/totalNc) if numtreat < 1


// Regressions

keep dtag ptag distance id days treat et numtreat first ttt ///
	L0event-L18event ///
	F1event-F19event ///
	stacknum weight
compress	

rename et stacktime

sort id stacktime days

order id stacknum days stacktime ttt treat numtreat first distance dtag ptag ///
F19event F18event F17event F16event F15event F14event F13event F12event F11event ///
F10event F9event F8event F7event F6event F5event F4event F3event F2event F1event ///
L0event L1event L2event L3event L4event L5event L6event L7event L8event ///
L9event L10event L11event L12event L13event L14event L15event L16event L17event ///
L18event 

egen newid = group(id stacknum)

sort newid stacktime
xtset newid stacktime


*drop vars for speed
*drop id stacknum days ttt treat numtreat first

est clear
reghdfe ptag F19event-F2event o.F1event L0event-L18event [aw=weight], cluster(newid) absorb(stacktime treat)
coefplot, vert omit drop(_cons *treat *stacktime) xlabel(1 "-19" 2 "-18" 3 "-17" 4 "-16" 5 "-15" 6 "-14" 7 "-13" 8 "-12" 9 "-11" 10 "-10" 11 "-9" 12 "-8" 13 "-7" 14 "-6" 15 "-5" 16 "-4" 17 "-3" 18 "-2" 19 "-1" 20 "0" 21 "1" 22 "2" 23 "3" 24 "4" 25 "5" 26 "6" 27 "7" 28 "8" 29 "9" 30 "10" 31 "11" 32 "12" 33 "13" 34 "14" 35 "15" 36 "16" 37 "17" 38 "18") xtitle("Time since treatment") ytitle("Relative ATET") xline(19) yline(0) scheme(plotplainblind) ciopts(recast(rcap))
graph export results/figures/bigstackedeventstudy_ptaglpm_jmp.png, replace

est clear
reghdfe distance F19event-F2event o.F1event L0event-L18event [aw=weight], cluster(newid) absorb(stacktime treat)
coefplot, vert omit drop(_cons *treat *stacktime) xlabel(1 "-19" 2 "-18" 3 "-17" 4 "-16" 5 "-15" 6 "-14" 7 "-13" 8 "-12" 9 "-11" 10 "-10" 11 "-9" 12 "-8" 13 "-7" 14 "-6" 15 "-5" 16 "-4" 17 "-3" 18 "-2" 19 "-1" 20 "0" 21 "1" 22 "2" 23 "3" 24 "4" 25 "5" 26 "6" 27 "7" 28 "8" 29 "9" 30 "10" 31 "11" 32 "12" 33 "13" 34 "14" 35 "15" 36 "16" 37 "17" 38 "18") xtitle("Time since treatment") ytitle("Relative ATET") xline(19) yline(0) scheme(plotplainblind) ciopts(recast(rcap))
graph export results/figures/bigstackedeventstudy_distance_jmp.png, replace

est clear
reghdfe dtag F19event-F2event o.F1event L0event-L18event [aw=weight], cluster(newid) absorb(stacktime treat)
coefplot, vert omit drop(_cons *treat *stacktime) xlabel(1 "-19" 2 "-18" 3 "-17" 4 "-16" 5 "-15" 6 "-14" 7 "-13" 8 "-12" 9 "-11" 10 "-10" 11 "-9" 12 "-8" 13 "-7" 14 "-6" 15 "-5" 16 "-4" 17 "-3" 18 "-2" 19 "-1" 20 "0" 21 "1" 22 "2" 23 "3" 24 "4" 25 "5" 26 "6" 27 "7" 28 "8" 29 "9" 30 "10" 31 "11" 32 "12" 33 "13" 34 "14" 35 "15" 36 "16" 37 "17" 38 "18") xtitle("Time since treatment") ytitle("Relative ATET") xline(19) yline(0) scheme(plotplainblind) ciopts(recast(rcap))
graph export results/figures/bigstackedeventstudy_dtaglpm_jmp.png, replace
/* 
lincom (F9event +F8event +F7event +F6event +F5event +F4event +F3event +F2event +F1event)/9
local avg = r(estimate)

foreach pre in F9event F8event F7event F6event F5event F4event F3event F2event F1event {
	lincom `pre' - `avg'
	gen b`pre' = r(estimate)
	gen b`pre'ub = r(ub)
	gen b`pre'lb = r(lb)
}


foreach post in L0event L1event L2event L3event L4event L5event L6event L7event L8event {
	lincom `post' - `avg'
	gen b`post' = r(estimate)
	gen b`post'ub = r(ub)
	gen b`post'lb = r(lb)
}


keep b*

gcollapse _all

gen obs = _n

ren (bF9event bF9eventub bF9eventlb bF8event bF8eventub bF8eventlb bF7event bF7eventub bF7eventlb bF6event bF6eventub bF6eventlb bF5event bF5eventub bF5eventlb bF4event bF4eventub bF4eventlb bF3event bF3eventub bF3eventlb bF2event bF2eventub bF2eventlb bF1event bF1eventub bF1eventlb) (b1 b1ub b1lb b2 b2ub b2lb b3 b3ub b3lb b4 b4ub b4lb b5 b5ub b5lb b6 b6ub b6lb b7 b7ub b7lb b8 b8ub b8lb b9 b9ub b9lb)

ren (bL0event bL0eventub bL0eventlb bL1event bL1eventub bL1eventlb bL2event bL2eventub bL2eventlb bL3event bL3eventub bL3eventlb bL4event bL4eventub bL4eventlb bL5event bL5eventub bL5eventlb bL6event bL6eventub bL6eventlb bL7event bL7eventub bL7eventlb bL8event bL8eventub bL8eventlb) (b10 b10ub b10lb b11 b11ub b11lb b12 b12ub b12lb b13 b13ub b13lb b14 b14ub b14lb b15 b15ub b15lb b16 b16ub b16lb b17 b17ub b17lb b18 b18ub b18lb)

reshape long b@ b@ub b@lb, i(obs) j(time)

replace time = time - 10

tw (connected b time) (rspike blb bub time), yline(1.338451) xline(-1)
*/



