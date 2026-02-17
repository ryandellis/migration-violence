use "C:\Users\ellisrya\Dropbox\migration-violence\data\raw\nrva_survey\Transfer\M_11b.dta" ,clear

ren Q_11_10 number
ren Q_11_14 place
replace number = 0 if number==.
replace place = 99 if place==.


bysort hhid: gen first_in_hh = (_n == 1)
bysort household_id: gen n_rows = _N
bysort hhid: gen n_rows = _N
tab n_rows if first_in_hh
tab number if first_in_hh
gen leaver = !missing(Unique_Mem_ID)


gen one = 1

svyset hhid [pweight=ind_weight]

svy, subpop(leaver): total one, over(place)

di (99797+536301)/28124433
*gives population estimate for combined Iran+Pakistan = 2.26%


*approach for getting inference?
gen target = (place == 6 | place == 7) & leaver

svy: total one target

nlcom(_b[target] / _b[one]) *100

*2.262%
*(.237) se
*[1.797, 2.727]