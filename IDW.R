library(haven)
library(tidyverse)
library(sf)
library(sp)
library(gstat)
library(readr)
library(rgdal)
# to read and calculate correctly, change locale of R to Simplified Chinese, this only
# works once, so we need to set locale every time (which is good for English environment)
Sys.setlocale(category = "LC_ALL", locale = "chs")

read_dta("Data/station_id.dta") %>%
  dplyr::filter(station_id != 54287) -> pre_tem
st_as_sf(pre_tem, coords = c("longitude", "latitude"), crs = 4326) -> pre_tem_sf

# Make grids of the country, convert to sf, then convert to sp
read_sf("Data/GIS/2019行政区划SHP/省.shp") %>% # read shp to sf obj
  st_transform(4326) %>% # WGS84 coordinate coding
  st_combine() %>% # because this is Province shp file, need to combine them together
  st_make_grid(n = c(500, 500)) %>% # 500 X 500 grids
  st_coordinates() %>%
  as_tibble() -> grid
coordinates(grid) = ~X+Y
gridded(grid) = TRUE

# convert pre_tem sf to sp, use idw method, then convert back to sf
pre_tem_sf %>% 
  st_coordinates() %>% 
  as_tibble() %>% 
  cbind(st_drop_geometry(pre_tem_sf)) -> pre_tem_sp
coordinates(pre_tem_sp) = ~X+Y

# gstat::idw(tem_avgday_mean~1, pre_tem_sp, grid) %>% 
#   as_tibble() %>% 
#   st_as_sf(coords = c("X", "Y"), crs = 4326) %>% 
#   dplyr::select(tem_avgday_mean = var1.pred) -> grid_idw

# Make county sf, aggregate data to county level (grids to counties)
read_sf("Data/GIS/2019行政区划SHP/县.shp", options = "ENCODING=UTF-8") %>% 
  st_transform(4326)  %>% 
  st_make_valid() -> County
# aggregate(x = grid_idw, by = County, FUN = mean) %>%
#   bind_cols(st_drop_geometry(County)) -> county_data

varlist <- as.character(colnames(pre_tem[-1:-4]))
for (v in varlist) {
  if(!file.exists(paste0("Data/County_pre_tem/", v, ".rds"))) {
    print(paste0(v, ".rds does not exist, continue..."))
    gstat::idw(as.formula(paste0(v, "~1")), pre_tem_sp, grid) %>%
      as_tibble() %>%
      st_as_sf(coords = c("X", "Y"), crs = 4326) %>%
      dplyr::select(v = var1.pred) %>%
      set_names(c(v, "geometry")) %>%
      aggregate(x = ., by = County, FUN = mean) %>%
      bind_cols(st_drop_geometry(County)[1]) %>%
      st_drop_geometry() %>%
      readr::write_rds(paste0("Data/County_pre_tem/", v, ".rds"))
  }
}

County %>%
  st_drop_geometry() %>%
  rename(County_code = PAC, County = NAME, Province_code = 省代码, Province = 
           省, City_code = 市代码, City = 市, Level = 类型) %>% 
  select(County_code, County, City_code, City, Province_code, Province, Level) -> 
  County_data

for (v in varlist) {
  if(file.exists(paste0("Data/County_pre_tem/", v, ".rds"))) {
    print(paste0(v, ".rds exists, continue..."))
    County_data %>%
    cbind(., read_rds(paste0("Data/County_pre_tem/", v, ".rds"))) %>%
    dplyr::select(!starts_with("PAC")) -> County_data
  }
}

write_csv(County_data, "Data/County_pre_tem.csv")

# # check for counties that did not get assigned and assign neighboring value
# county_data %>% 
#   dplyr::filter(is.na(tem_avgday_mean_s))
# county_data %>% 
#   st_drop_geometry() %>% 
#   dplyr::filter(is.na(tem_avgday_mean_s)) %>% 
#   distinct(PAC) %>% 
#   pull() -> codemiss
# 
# County %>% 
#   dplyr::filter(PAC %in% codemiss) %>% 
#   select(code1 = PAC) -> county1
# 
# County %>% 
#   dplyr::filter(!PAC %in% codemiss) %>% 
#   select(code2 = PAC) -> county2
# 
# # 地理匹配
# county1 %>% 
#   st_intersection(county2) %>% 
#   st_drop_geometry() -> neighboring
# 
# # 把降水量匹配上去：
# county_data %>% 
#   st_drop_geometry() %>% 
#   as_tibble() %>% 
#   dplyr::filter(is.na(tem_avgday_mean_s)) -> df1
# county_data %>% 
#   st_drop_geometry() %>% 
#   as_tibble() %>% 
#   dplyr::filter(!is.na(tem_avgday_mean_s)) -> df2
# 
# df1 %>% 
#   left_join(neighboring, by = c("PAC" = "code1")) %>% 
#   left_join(df2, by = c("code2" = "PAC")) %>% 
#   group_by(PAC) %>% 
#   mutate(tem_avgday_mean_s.x = mean(tem_avgday_mean_s.y, na.rm = T)) %>% 
#   select(PAC, tem_avgday_mean_s = tem_avgday_mean_s.x) %>% 
#   ungroup() %>% 
#   distinct() -> df3
# 
# bind_rows(df2, df3) %>% 
#   select(tem_avgday_mean_s, PAC) %>% 
#   left_join(st_drop_geometry(County)) %>% 
#   rename(县代码 = PAC, 县 = NAME) %>% 
#   arrange(省代码, 省, 市代码, 市, 县代码, 县)  %>% 
#   select(省代码, 省, 市代码, 市, 县代码, 县, tem_avgday_mean_s) -> df6


# county_data %>%
#   st_simplify(dTolerance = 0.1) -> county_data_sim
# ggplot(county_data_sim) +
#   geom_sf(aes(fill=tem_avgday_mean_s)) 


# varlist <- as.character(colnames(pre_tem[-1:-4]))
# length(varlist)
# pre_tem %>%
#   as_tibble() -> pre_tem_ti
# pre_tem_sp@data %>% 
#   mutate_at(c("tem_avgday_mean", "tem_maxday_mean"), .funs = function(v){
#     gstat::idw(v ~ 1, pre_tem_sp, grid) %>%
#       as_tibble() %>%
#       st_as_sf(coords = c("X", "Y"), crs = 4326) %>%
#       dplyr::select(v = var1.pred) -> grid_idw
#   })
# for (v in varlist) {
#   print(v)
#   # print(get(v))
#   # print(class(get(v)))
#   gstat::idw(get(v) ~ 1, pre_tem_sp, grid) %>%
#     as_tibble() %>%
#     st_as_sf(coords = c("X", "Y"), crs = 4326) %>%
#     dplyr::select(v = var1.pred) -> grid_idw
#   aggregate(x = grid_idw, by = County, FUN = mean) %>%
#     bind_cols(st_drop_geometry(County)) %>%
#     assign(paste0("county", as.character(v)), .)
#   
# }