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