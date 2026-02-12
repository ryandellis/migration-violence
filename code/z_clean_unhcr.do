/*==================================================
project:       Import and clean unhcr data
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

import delimited "$unhcr/csv_edit"

drop countryoforigin countryoforiginiso countryofasylumiso

// rename variables for consistency and ease of use:
ren (countryofasylum refugeesunderunhcrsmandate asylumseekers idpsofconcerntounhcr) (country refugees asylees idps)

save "$derived/unhcr_totals", replace

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


