*blumenstock 2024 algorithm for internal migration

*egen distid = group(district) if district !=.
bys identityid ym: egen d2 = mode(provid) if provid !=., max

gcollapse d2, by(identityid ym)
xtset identityid ym
gen d1 = L.d2
gen d3 = F.d2
gen d4 = FF.d2

order identityid ym d1 d2 d3 d4

gen intresident = .
gen intmigrant = .
gen intother = .
replace intresident = 1 if d1==d2 & d3==d4 & d2==d3
replace intmigrant = 1 if d1==d2 & d3==d4 & d2!=d3 & d3!=. & d4!=. 
replace intother = 1 if intresident==. & intmigrant==.

gen str status = "internal migrant" if intmigrant==1
replace status = "internal resident" if intresident==1
replace status = "internal other" if intother==1

*indicator = 1 if individual is ever categorized as migrant during sample time:

egen intevermig = max(intmigrant), by(identityid)
replace intevermig = 0 if intevermig==.

*count of times individual was categoriezed as migrant:

egen countinternal = total(intmigrant), by(identityid)
replace countinternal = 0 if countinternal==.

*merge back into original daily data
merge 1:m identityid ym using processed/VFD_data_wrangled







