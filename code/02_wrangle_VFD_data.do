/*==================================================
project:       New variables and operations for analysis of VFD data
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
use processed/VFD_data_clean, replace
/*==================================================
              1: General variables and sorting
==================================================*/
// One method for dealing with imputations: drop everything in the widespread 'gap' periods
// This leaves the low-level rate of "normal" imputation alone
// On the other hand, it interrupts the time variable significantly
// This variable allows for filtering in analysis along these lines
gen gap = 0
replace gap = 1 if date > td(17jan2011) & date < td(01feb2011)
replace gap = 1 if date > td(20aug2011) & date < td(01nov2011)

sort identityid date
xtset identityid date

*drop if ym==610 //2010m11 with few observations (145 obs)

egen provid = group(province)


// The following command accomplishes two things: first it combines lat and lon
// to a single unique string. In the process it coarsens both coordinate vars
// to condense very near locations to broad circles with diameter ~1km
gen slat = round(latitude, 0.01)
gen slon = round(longitude, 0.01)
gen latlon = string(slat) + string(slon)

// create user-months, user-weeks, etc., spans anchored to each user's final day
// useful for defining migration events


* Step 1: Identify the final day for each individual
bysort identityid date: egen final_date = max(date)

* Step 2: Calculate the number of days from the final day for each observation
gen days_from_final = final_date - date

* Step 3: Create the "month" variable
gen sv_month = floor(days_from_final / 30)

/*==================================================
              2: Variables for unique locations, districts, and provinces
==================================================*/

// Identify and encode each unique location recorded
egen loc = group(latlon)
// bysort loc: egen freq = count(loc) // some locs are MUCH more common than others (all in Kabul)
// drop freq

// HOME = Monthly modal location (latlon together, then lat & lon separately)
// Home latitude and longitude coded this way are named mslsat and mslon

bys identityid ym: egen mloc = mode(loc), minmode // monthly modal location
gen temp_mslat = slat if loc == mloc & !missing(mloc) // temp slat from mloc
bys identityid ym: egen mslat = max(temp_mslat) // fill in rows
drop temp_mslat
gen temp_mslon = slon if loc == mloc & !missing(mloc) // temp slon from mloc
bys identityid ym: egen mslon = max(temp_mslon) // fill in rows
drop temp_mslon

// Other monthly modal measurements
bys identityid ym: egen mdist = mode(district), minmode // monthly modal district
bys identityid ym: egen mprov = mode(provid), minmode // monthly modal province
gen dtag=(district!=mdist) // different district than monthly mode
gen ptag=(provid!=mprov) // different province than monthly mode
gen loctag=(loc!=mloc) // different location than monthly mode
gen s_dtag=dtag // for sum collapse
gen s_ptag=ptag // for sum collapse
gen s_loctag=(loctag) // for sum collapse

// bys identityid ym: egen meanlat = mean(latitude) // for comparison to modal method
// bys identityid ym: egen meanlon = mean(longitude) // for comparison to modal method

// Variables for distances
geodist slat slon mslat mslon, gen(distance) // coarse from coarse
geodist latitude longitude mslat mslon, gen(dist_mloc2) // fine from coarse
// geodist latitude longitude meanlat meanlon, gen(dist_means) // fine from fine
gen s_distance = distance // for sum collapse
gen s_dist_mloc2 = dist_mloc2 // for sum collapse
// gen s_dist_means = dist_means // for sum collapse

// Radius of Gyration
gen sqdist = distance^2 // researcher choice to use this version of distance
bys identityid ym: egen meansqdist = mean(sqdist)
gen rog = sqrt(meansqdist) //importantly, this metric is dependent on how many usage-days a user has per month!



save processed/VFD_data_wrangled, replace

do scripts/03_internal_mig_algorithm_VFD
compress
save processed/VFD_with_internal, replace
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


