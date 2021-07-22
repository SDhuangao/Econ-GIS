Pre_cn <- function(data, fill, title, subtitle = "单位 mm\n绘制：Alan", 
                   caption = "数据来源：国家气象科学数据共享服务平台\n中国地面气候资料日值数据集(V3.0)") {
  ggplot(data) + 
    geom_sf(aes(fill = fill), size = 0.01, 
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
    labs(title = title,
         subtitle = subtitle,
         caption = caption)
  # return(k)
}


Pre_en <- function(data, fill, title, subtitle = 
                     "Unit: mm\n By: Alan") {
  ggplot(data) + 
    geom_sf(aes(fill = fill), size = 0.01, 
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
        text_family = enfont
      )
    ) + 
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          panel.grid.major = element_blank(),
          axis.text.x = element_blank(),
          axis.text.y = element_blank()) + 
    labs(title = title,
         subtitle = subtitle,
         caption = "Source: China Meteorological Administration")
}

Tem_en <- function(data, fill, title, 
                   subtitle = "(Average from 2000 to 2017) Unit: Celsius\n By: Alan", 
                   breaks,
                   palette = "lajolla") {
  ggplot(data) + 
    geom_sf(aes(fill = fill), size = 0.01, 
            color = "white") + 
    geom_sf(data = cn, size = 0.5, 
            color = "black", fill = NA) +
    coord_sf(crs = "+proj=lcc +lat_1=30 +lat_2=62 +lat_0=0 +lon_0=105 +x_0=0 +y_0=0 +ellps=krass +units=m +no_defs",
             xlim = c(-3500000, 3090000)) + 
    scico::scale_fill_scico(palette = palette, 
                            name = NULL, 
                            direction = 1,
                            breaks = breaks) + 
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
    labs(title = title,
         subtitle = subtitle,
         caption = "Source: China Meteorological Administration")
}
