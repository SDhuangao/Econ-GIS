clear all
// !ssc install mergemany
// cd C:\Users\user1\Desktop\Projects\Econ-ControlVars\Econ-GIS\Data
global DataPath E:\Desktop\Projects\Econ-ControlVars\Econ-GIS\Data
cd $DataPath
set obs 1
gen test = .
save dataset, replace
// gen pre_i=.
// gen pre_j=""
forvalues i = 0/17 {
	local tem_i=2000+`i'
	forvalues j=1/12 {
        if (`j'>=1 & `j'<=9) { 
        	local tem_j="0"+"`j'" 
        }
        if (`j'>=10) {
         local tem_j="`j'" 
        }
        import delimited "$DataPath\Weather\TEM\SURF_CLI_CHN_MUL_DAY-TEM-12001-`tem_i'`tem_j'.TXT", delimiter(space, collapse) encoding(Big5) clear
        gen year="`tem_i'"
        gen month="`tem_j'"
        save "`tem_i'`tem_j'", replace
        use dataset, clear
        append using "`tem_i'`tem_j'", force
        erase "`tem_i'`tem_j'.dta"
        save dataset, replace 
	}
}
use dataset, clear
drop test
drop in 1

rename v1 station_id
label var station_id 区站号
rename v2 latitude
label var latitude 纬度
rename v3 longitude
label var longitude 经度
rename v4 elevation
label var elevation "观测场拔海高度/m"
rename v5 Year
label var Year 年
rename v6 Month
label var Month 月
rename v7 Day
label var Day 日
rename v8 temperature_avgday
label var temperature_avgday "日平均气温/摄氏度"
replace temperature_avg=temperature_avg/10
rename v9 temperature_maxday
label var temperature_maxday "日最高气温/摄氏度"
replace temperature_maxday=temperature_maxday/10
rename v10 temperature_minday
label var temperature_minday "日最低气温/摄氏度"
replace temperature_minday=temperature_minday/10
drop v11-month
save tem, replace
gen date=mdy(Month,Day,Year)
label var date 日期
format date %td
erase dataset.dta


// clear all
// cd C:\Users\user1\Desktop\Projects\Econ-ControlVars\Econ-GIS\Data\Weather\PRE
clear
set obs 1
gen test = .
save dataset, replace
// gen pre_i=.
// gen pre_j=""
forvalues i = 0/17 {
	local pre_i=2000+`i'
	forvalues j=1/12 {
        if (`j'>=1 & `j'<=9) { 
        	local pre_j="0"+"`j'" 
        }
        if (`j'>=10) {
         local pre_j="`j'" 
        }
        import delimited "$DataPath\Weather\PRE\SURF_CLI_CHN_MUL_DAY-PRE-13011-`pre_i'`pre_j'.TXT", delimiter(space, collapse) encoding(Big5) clear
        gen year="`pre_i'"
        gen month="`pre_j'"
        save "`pre_i'`pre_j'", replace
        use dataset, clear
        append using "`pre_i'`pre_j'", force
        erase "`pre_i'`pre_j'.dta"
        save dataset, replace 
	}
}
use dataset, clear
drop test
drop in 1

rename v1 station_id
label var station_id 区站号
rename v2 latitude
label var latitude 纬度
rename v3 longitude
label var longitude 经度
rename v4 elevation
label var elevation "观测场拔海高度/m"
rename v5 Year
label var Year 年
rename v6 Month
label var Month 月
rename v7 Day
label var Day 日
rename v8 precipitation_20to8
label var precipitation_20to8 "20-8时降水量/mm"
replace precipitation_20to8=0 if precipitation_20to8==32700
replace precipitation_20to8=. if precipitation_20to8==32766
replace precipitation_20to8=precipitation_20to8/10
rename v9 precipitation_8to20
label var precipitation_8to20 "8-20时降水量/mm"
replace precipitation_8to20=0 if precipitation_8to20==32700
replace precipitation_8to20=. if precipitation_8to20==32766
replace precipitation_8to20=precipitation_8to20/10
rename v10 precipitation_day
label var precipitation_day "20-20时累计降水量/mm"
replace precipitation_day=0 if precipitation_day==32700
replace precipitation_day=. if precipitation_day==32766
replace precipitation_day=precipitation_day/10
drop v11-month
gen date=mdy(Month,Day,Year)
label var date 日期
// format date %td
format date %tdCCYY.NN.DD
save pre, replace
erase dataset.dta

use pre, clear
merge 1:1 station_id Year Month Day using tem
drop _merge
gen summer = ((Month==5&Day>=6) | Month==6 | Month==7 | (Month==8&Day<8))
gen quarter=.
replace quarter=1 if inrange(Month,1,3)
replace quarter=2 if inrange(Month,4,6)
replace quarter=3 if inrange(Month,7,9)
replace quarter=4 if inrange(Month,10,12)
replace latitude = floor(latitude/100) + mod(latitude, 100)/60
replace longitude = floor(longitude/100) + mod(longitude, 100)/60
replace elevation=elevation/10
save pre_tem, replace
erase pre.dta
erase tem.dta

use pre_tem, clear
keep station_id latitude longitude elevation
duplicates drop station_id, force
save station_id, replace

use pre_tem, clear
preserve
collapse (mean) temperature_avgday temperature_maxday temperature_minday, by(station_id)
rename temperature_avgday tem_avgday_mean
label var tem_avgday_mean "日平均温度的平均值"
rename temperature_maxday tem_maxday_mean
label var tem_maxday_mean "日最高温度的平均值"
rename temperature_minday tem_minday_mean
label var tem_minday_mean "日最低温度的平均值"
save tem_mean, replace
restore

preserve
collapse (median) temperature_avgday temperature_maxday temperature_minday, by(station_id)
rename temperature_avgday tem_avgday_median
label var tem_avgday_median "日平均温度的中位数"
rename temperature_maxday tem_maxday_median
label var tem_maxday_median "日最高温度的中位数"
rename temperature_minday tem_minday_median
label var tem_minday_median "日最低温度的中位数"
save tem_median, replace
restore

preserve
collapse (sum) precipitation_day, by(station_id Year)
rename precipitation_day precipitation_year
collapse (mean) precipitation_year, by(station_id)
rename precipitation_year pre_year_avg
label var pre_year_avg "年累计降水量的平均值"
save pre_year_avg, replace
restore

preserve
use station_id, clear
merge 1:1 station_id using tem_mean
tab _merge
drop _merge
erase tem_mean.dta
merge 1:1 station_id using tem_median
tab _merge
drop _merge
erase tem_median.dta
merge 1:1 station_id using pre_year_avg
tab _merge
drop _merge
erase pre_year_avg.dta
save station_id, replace
restore

preserve
keep if summer==1
collapse (mean) temperature_avgday temperature_maxday temperature_minday, by(station_id)
rename temperature_avgday tem_avgday_mean_s
label var tem_avgday_mean_s "夏季 日平均温度的平均值"
rename temperature_maxday tem_maxday_mean_s
label var tem_maxday_mean_s "夏季 日最高温度的平均值"
rename temperature_minday tem_minday_mean_s
label var tem_minday_mean_s "夏季 日最低温度的平均值"
save tem_mean_s, replace
restore

preserve
collapse (median) temperature_avgday temperature_maxday temperature_minday, by(station_id)
rename temperature_avgday tem_avgday_median_s
label var tem_avgday_median_s "夏季 日平均温度的中位数"
rename temperature_maxday tem_maxday_median_s
label var tem_maxday_median_s "夏季 日最高温度的中位数"
rename temperature_minday tem_minday_median_s
label var tem_minday_median_s "夏季 日最低温度的中位数"
save tem_median_s, replace
restore

preserve
collapse (sum) precipitation_day, by(station_id Year)
rename precipitation_day precipitation_summer
collapse (mean) precipitation_summer, by(station_id)
rename precipitation_summer pre_summer_avg
label var pre_summer_avg "夏季 累计降水量的平均值"
save pre_summer_avg, replace
restore

preserve
use station_id, clear
merge 1:1 station_id using tem_mean_s
tab _merge
drop _merge
erase tem_mean_s.dta
merge 1:1 station_id using tem_median_s
tab _merge
drop _merge
erase tem_median_s.dta
merge 1:1 station_id using pre_summer_avg
tab _merge
drop _merge
erase pre_summer_avg.dta
save station_id, replace
restore

foreach m of numlist 1/12 {
    preserve
    keep if Month == `m'
    collapse (mean) temperature_avgday temperature_maxday temperature_minday, by(station_id)
    rename temperature_avgday tem_avgday_mean_month`m'
    label var tem_avgday_mean_month`m' "`m'月 日平均温度的平均值"
    rename temperature_maxday tem_maxday_mean_month`m'
    label var tem_maxday_mean_month`m' "`m'月 日最高温度的平均值"
    rename temperature_minday tem_minday_mean_month`m'
    label var tem_minday_mean_month`m' "`m'月 日最低温度的平均值"
    save tem_mean_m`m', replace
    restore

    preserve
    keep if Month == `m'
    collapse (median) temperature_avgday temperature_maxday temperature_minday, by(station_id)
    rename temperature_avgday tem_avgday_median_month`m'
    label var tem_avgday_median_month`m' "`m'月 日平均温度的中位数"
    rename temperature_maxday tem_maxday_median_month`m'
    label var tem_maxday_median_month`m' "`m'月 日最高温度的中位数"
    rename temperature_minday tem_minday_median_month`m'
    label var tem_minday_median_month`m' "`m'月 日最低温度的中位数"
    save tem_median_m`m', replace
    restore

    preserve
    keep if Month == `m'
    collapse (sum) precipitation_day, by(station_id Year)
    rename precipitation_day precipitation_month
    collapse (mean) precipitation_month, by(station_id)
    rename precipitation_month pre_month_avg_month`m'
    label var pre_month_avg_month`m' "`m'月 累计降水量的平均值"
    save pre_month_avg_m`m', replace
    restore

    preserve
    use station_id, clear
    merge 1:1 station_id using tem_mean_m`m'
    tab _merge
    drop _merge
    erase tem_mean_m`m'.dta
    merge 1:1 station_id using tem_median_m`m'
    tab _merge
    drop _merge
    erase tem_median_m`m'.dta
    merge 1:1 station_id using pre_month_avg_m`m'
    tab _merge
    drop _merge
    erase pre_month_avg_m`m'.dta
    save station_id, replace
    restore
}


foreach q of numlist 1/4 {
    preserve
    keep if quarter == `q'
    collapse (mean) temperature_avgday temperature_maxday temperature_minday, by(station_id)
    rename temperature_avgday tem_avgday_mean_quarter`q'
    label var tem_avgday_mean_quarter`q' "`q'季度 日平均温度的平均值"
    rename temperature_maxday tem_maxday_mean_quarter`q'
    label var tem_maxday_mean_quarter`q' "`q'季度 日最高温度的平均值"
    rename temperature_minday tem_minday_mean_quarter`q'
    label var tem_minday_mean_quarter`q' "`q'季度 日最低温度的平均值"
    save tem_mean_q`q', replace
    restore

    preserve
    keep if quarter == `q'
    collapse (median) temperature_avgday temperature_maxday temperature_minday, by(station_id)
    rename temperature_avgday tem_avgday_median_quarter`q'
    label var tem_avgday_median_quarter`q' "`q'季度 日平均温度的中位数"
    rename temperature_maxday tem_maxday_median_quarter`q'
    label var tem_maxday_median_quarter`q' "`q'季度 日最高温度的中位数"
    rename temperature_minday tem_minday_median_quarter`q'
    label var tem_minday_median_quarter`q' "`q'季度 日最低温度的中位数"
    save tem_median_q`q', replace
    restore

    preserve
    keep if quarter == `q'
    collapse (sum) precipitation_day, by(station_id Year)
    rename precipitation_day precipitation_quarter
    collapse (mean) precipitation_quarter, by(station_id)
    rename precipitation_quarter pre_quarter_avg_quarter`q'
    label var pre_quarter_avg_quarter`q' "`q'季度 累计降水量的平均值"
    save pre_quarter_avg_q`q', replace
    restore

    preserve
    use station_id, clear
    merge 1:1 station_id using tem_mean_q`q'
    tab _merge
    drop _merge
    erase tem_mean_q`q'.dta
    merge 1:1 station_id using tem_median_q`q'
    tab _merge
    drop _merge
    erase tem_median_q`q'.dta
    merge 1:1 station_id using pre_quarter_avg_q`q'
    tab _merge
    drop _merge
    erase pre_quarter_avg_q`q'.dta
    save station_id, replace
    restore
}

