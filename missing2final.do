clear all
// !ssc install mergemany
// cd C:\Users\user1\Desktop\Projects\Econ-ControlVars\Econ-GIS\Data
global DataPath E:\Desktop\Projects\Econ-ControlVars\Econ-GIS\Data
cd $DataPath

import delimited "County_pre_tem.csv", encoding(UTF-8) clear
destring tem_avgday_mean-pre_quarter_avg_quarter4, replace force
drop in 2862
save 2Bmerge, replace

preserve
keep if tem_avgday_mean==.
rename county_code code1
save missing, replace
restore
preserve
keep if tem_avgday_mean!=.
rename county_code code2
save nonmissing, replace
restore

// preserve
use missing, clear
merge 1:m code1 using missing2neighbors.dta
// keep if _merge==3
drop if _merge==2
drop _merge
// drop if code1==710024
merge m:1 code2 using nonmissing.dta, update
drop if _merge==2
// keep if _merge>=3
drop _merge
// restore
foreach v of varlist tem_avgday_mean-pre_quarter_avg_quarter4 {
	bys code1: egen `v'mean = mean(`v')
	replace `v'=`v'mean
	drop `v'mean 
}
drop code2
rename code1 county_code
duplicates drop county_code, force
save missing2nonmissing, replace

use station_id.dta, clear
drop if 1
drop station_id-elevation
append using 2Bmerge
drop if tem_avgday_mean==.
append using missing2nonmissing

mdesc
unique county_code
duplicates list county_code
save final_pre_tem, replace
erase missing.dta
erase missing2nonmissing.dta
erase nonmissing.dta
erase 2Bmerge.dta
