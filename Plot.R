library(ggspatial)
library(sf)
source("theme_map.R")
source("Plot_Functions.R")
Sys.setlocale(category = "LC_ALL", locale = "chs")
haven::read_dta("Data/final_pre_tem.dta")  -> mydf

# Read the data
read_sf("九段线GS（2019）1719号.geojson") -> cn
read_sf("Data/GIS/2019行政区划SHP/县.shp", options = "ENCODING=UTF-8") %>% 
  st_transform(4326)  %>% 
  st_make_valid() %>%
  left_join(mydf, by = c("PAC" = "county_code")) -> mydf

# Plot
Pre_cn(mydf, mydf$pre_year_avg, "区县年累计降水量", subtitle = "2000-2017年平均值    单位: mm\n绘制: Alan", 
       caption = "数据来源：国家气象局")
ggsave("Cumulative_Annual_Rainfall_cn.png", width = 12, height = 12)

Pre_en(mydf, mydf$pre_year_avg, "Cumulative Annual Rainfall", 
       subtitle = "Average from 2000 to 2017  Unit: mm\n By: Alan")
ggsave("Cumulative_Annual_Rainfall.png", width = 10, height = 10)


Tem_en(mydf, mydf$tem_avgday_mean, 
       title = "Daily Average Temperature",
       subtitle = "(Average from 2000 to 2017) Unit: Celsius\n By: Alan",
       breaks = c(0, 3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39),
       palette = "vik")
ggsave("Daily_Average_Temperature.png", width = 10, height = 10)

Tem_en(mydf, mydf$tem_avgday_mean_s, 
       title = "Summer Daily Average Temperature",
       subtitle = "(Average from 2000 to 2017) Unit: Celsius\n By: Alan",
       breaks = c(18, 20, 22, 24, 26, 28, 30, 32),
       palette = "bilbao")
ggsave("Summer_Daily_Average_Temperature.png", width = 10, height = 10)

