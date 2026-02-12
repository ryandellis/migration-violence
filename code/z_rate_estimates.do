*back of the envelope calcs of rates of forced migration into PAK and IRN

*flows of refugees and asylum seekers from https://www.unhcr.org/refugee-statistics/insights/explainers/forcibly-displaced-flow-data.html

*AFG yearly population from https://population.un.org/wpp/

*result = ratio of national population forcibly displaced into PAK or IRN:
*2010: .0034892
*2011: .0033669
*2012: .0033264

*approx 0.34%

import excel "C:\Users\ryand\Downloads\UNHCR_Flow_Data.xlsx", sheet("DATA") firstrow case(lower)

sort originiso year
keep if originiso=="AFG"
drop origin asylum asylumregion
keep if asylumiso=="PAK" | asylumiso=="IRN"
keep if year > 2009
keep if year < 2013
drop originname asylumname
order originiso year count asylumiso pt
sort year asylumiso pt
bys year asylumiso: egen total = total(count)
collapse (max) total, by(asylumiso year)

bys year: egen yeartotal = total(total)
bro
collapse yeartotal, by(year)

gen pop=.

replace pop = 28284089 if year==2010
replace pop = 29347708 if year==2011
replace pop = 30560034 if year==2012
gen pct = yeartotal/pop



