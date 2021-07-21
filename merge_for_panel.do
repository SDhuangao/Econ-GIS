clear all
// !ssc install mergemany
// cd C:\Users\user1\Desktop\Projects\Econ-ControlVars\Econ-GIS\Data
global DataPath E:\Desktop\Projects\Econ-ControlVars\Econ-GIS\Data
cd $DataPath

use pre_tem, clear
keep station_id latitude longitude elevation
duplicates drop station_id, force
save station_id_panel, replace


foreach y of numlist 2000/2017 {
    use pre_tem, clear
    keep if Year == `y'

    preserve
    collapse (mean) temperature_avgday temperature_maxday temperature_minday, by(station_id)
    rename temperature_avgday tem_avgday_mean
    label var tem_avgday_mean "年 日平均温度的平均值"
    rename temperature_maxday tem_maxday_mean
    label var tem_maxday_mean "年 日最高温度的平均值"
    rename temperature_minday tem_minday_mean
    label var tem_minday_mean "年 日最低温度的平均值"
    save tem_mean, replace
    restore

    preserve
    collapse (median) temperature_avgday temperature_maxday temperature_minday, by(station_id)
    rename temperature_avgday tem_avgday_median
    label var tem_avgday_median "年 日平均温度的中位数"
    rename temperature_maxday tem_maxday_median
    label var tem_maxday_median "年 日最高温度的中位数"
    rename temperature_minday tem_minday_median
    label var tem_minday_median "年 日最低温度的中位数"
    save tem_median, replace
    restore

    preserve
    collapse (sum) precipitation_day, by(station_id Year)
    rename precipitation_day precipitation_year
    collapse (mean) precipitation_year, by(station_id)
    rename precipitation_year pre_year_avg
    label var pre_year_avg "年 累计降水量"
    save pre_year_avg, replace
    restore

    preserve
    use station_id_panel, clear
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
    save station_id_panel, replace
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
    label var pre_summer_avg "夏季 累计降水量"
    save pre_summer_avg, replace
    restore

    preserve
    use station_id_panel, clear
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
    save station_id_panel, replace
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
        label var pre_month_avg_month`m' "`m'月 累计降水量"
        save pre_month_avg_m`m', replace
        restore

        preserve
        use station_id_panel, clear
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
        save station_id_panel, replace
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
        label var pre_quarter_avg_quarter`q' "`q'季度 累计降水量"
        save pre_quarter_avg_q`q', replace
        restore

        preserve
        use station_id_panel, clear
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
        gen year = `y'
        save station_id_panel_y`y', replace
        restore
    }
}

clear
foreach y of numlist 2000/2017 {
    append using station_id_panel_y`y'
}
save pre_tem_panel, replace
