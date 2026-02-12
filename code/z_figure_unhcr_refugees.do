/*==================================================
project:       Create figure from unhcr data
Author:        Ryan Ellis 
E-email:       ryan.ellis@gatech.edu
url:           
Dependencies:  
----------------------------------------------------
Creation Date:     2 Jul 2024 - 13:42:35
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/

do "_config.do"
use "$derived/unhcr_totals", clear

color_style pissaro, n(4)
font_style Arial Narrow
/*==================================================
              1: Restrict sample, create figure
==================================================*/

keep if country=="Iran (Islamic Rep. of)" | country=="Pakistan" | country=="Tajikistan"
encode country, gen(id)
xtset id year

replace refugees = refugees/1000000




tw (tsline refugees if id==1, lwidth(thick)) (tsline refugees if id==2, lwidth(thick) lpattern(longdash)) (tsline refugees if id==3, lwidth(thick) lpattern(shortdash)), xtitle("") ytitle("") legend(label(1 "Iran") label(2 "Pakistan") label(3 "Tajikistan") position(6) rows(1) size(medium))
gr export "$figures/unhcr_refugees_tsline.png", replace



exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


