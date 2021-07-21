source("theme_map.R")
Sys.setlocale(category = "LC_ALL", locale = "chs")

haven::read_dta("Data/final_pre_tem.dta")  -> mydf

library(ggspatial)
library(sf)
Sys.setlocale(category = "LC_ALL", locale = "chs")

read_sf("九段线GS（2019）1719号.geojson") -> cn
read_sf("Data/GIS/2019行政区划SHP/县.shp", options = "ENCODING=UTF-8") %>% 
  st_transform(4326)  %>% 
  st_make_valid() %>%
  left_join(mydf, by = c("PAC" = "county_code")) -> mydf

ggplot(mydf) + 
  geom_sf(aes(fill = pre_year_avg), size = 0.01, 
          color = "white") + 
  geom_sf(data = cn, size = 0.5, 
          color = "black", fill = NA) +
  coord_sf(crs = "+proj=lcc +lat_1=30 +lat_2=62 +lat_0=0 +lon_0=105 +x_0=0 +y_0=0 +ellps=krass +units=m +no_defs",
           xlim = c(-3500000, 3090000)) + 
  scico::scale_fill_scico(palette = "davos", 
                          name = NULL, 
                          direction = -1,
                          breaks = c(0, 500, 1000, 1500, 2000, 2500, 3000)) + 
  scale_x_continuous(expand = c(0.001, 0.001)) +
  scale_y_continuous(expand = c(0.001, 0.001)) + 
  guides(fill = guide_legend(nrow = 1,
                             label.position = "top")) + 
  annotation_scale(
    width_hint = 0.2,
    text_family = cnfont
  ) + 
  annotation_north_arrow(
    location = "tr", which_north = "false",
    width = unit(1.6, "cm"), 
    height = unit(2, "cm"),
    style = north_arrow_fancy_orienteering(
      text_family = cnfont
    )
  ) + 
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.grid.major = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank()) + 
  labs(title = "区县年累计降水量(平均值，2000-2017)",
       subtitle = "20-20时累计降水量，单位 mm\n绘制：Alan",
       caption = "数据来源：国家气象科学数据共享服务平台\n中国地面气候资料日值数据集（V3.0）")
# // -----------------------------------------------------------------------------------------

ggplot(mydf) + 
  geom_sf(aes(fill = pre_year_avg), size = 0.01, 
          color = "white") + 
  geom_sf(data = cn, size = 0.5, 
          color = "black", fill = NA) +
  coord_sf(crs = "+proj=lcc +lat_1=30 +lat_2=62 +lat_0=0 +lon_0=105 +x_0=0 +y_0=0 +ellps=krass +units=m +no_defs",
           xlim = c(-3500000, 3090000)) + 
  scico::scale_fill_scico(palette = "davos", 
                          name = NULL, 
                          direction = -1,
                          breaks = c(0, 500, 1000, 1500, 2000, 2500, 3000)) + 
  scale_x_continuous(expand = c(0.001, 0.001)) +
  scale_y_continuous(expand = c(0.001, 0.001)) + 
  guides(fill = guide_legend(nrow = 1,
                             label.position = "top")) + 
  annotation_scale(
    width_hint = 0.2,
    text_family = enfont
  ) + 
  annotation_north_arrow(
    location = "tr", which_north = "false",
    width = unit(1.6, "cm"), 
    height = unit(2, "cm"),
    style = north_arrow_fancy_orienteering(
      text_family = cnfont
    )
  ) + 
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.grid.major = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank()) + 
  labs(title = "Cumulative Annual Rainfall (average from 2000 to 2017)",
       subtitle = "Calculated from 20:00-20:00 Cum Rainfall, Unit: mm\n By: Alan",
       caption = "Source: China Meteorological Administration")

# // -----------------------------------------------------------------------------------------

ggplot(mydf) + 
  geom_sf(aes(fill = pre_year_avg), size = 0.01, 
          color = "white") + 
  geom_sf(data = cn, size = 0.5, 
          color = "black", fill = NA) +
  coord_sf(crs = "+proj=lcc +lat_1=30 +lat_2=62 +lat_0=0 +lon_0=105 +x_0=0 +y_0=0 +ellps=krass +units=m +no_defs",
           xlim = c(-3500000, 3090000)) + 
  scico::scale_fill_scico(palette = "lajolla", 
                          name = NULL, 
                          direction = -1,
                          breaks = c(0, 15, 20, 25, 30, 35, 40)) + 
  scale_x_continuous(expand = c(0.001, 0.001)) +
  scale_y_continuous(expand = c(0.001, 0.001)) + 
  guides(fill = guide_legend(nrow = 1,
                             label.position = "top")) + 
  annotation_scale(
    width_hint = 0.2,
    text_family = enfont
  ) + 
  annotation_north_arrow(
    location = "tr", which_north = "false",
    width = unit(1.6, "cm"), 
    height = unit(2, "cm"),
    style = north_arrow_fancy_orienteering(
      text_family = enfont
    )
  ) + 
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.grid.major = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank()) + 
  labs(title = "Summer Daily Max Temperature (average from 2000 to 2017)",
       subtitle = "Unit: Celsius\n By: Alan",
       caption = "Source: China Meteorological Administration")

ggsave("2019各区县降水量.png", width = 9, height = 9)