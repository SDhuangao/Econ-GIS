theme_set(
  theme_ipsum(base_family = cnfont) + 
    theme(axis.ticks = element_blank(),
          axis.text = element_blank(),
          panel.grid.major = element_line(color = "#b3bdbf", 
                                          size = 0.2),
          panel.background = element_rect(color = NA, 
                                          fill = "grey90"),
          plot.background = element_rect(color = NA, 
                                         fill = "grey90"),
          legend.position = "top",
          legend.key.width = unit(4.5, "lines"),
          legend.key.height = unit(0.6, "lines"),
          plot.title = 
            element_text(hjust = 0.5,
                         margin = margin(t = 24, b = 6)),
          plot.subtitle = 
            element_text(hjust = 0.5,
                         margin = margin(t = 0, b = 0)),
          plot.caption = 
            element_text(hjust = 0.5, color = "#7d92af",
                         margin = margin(t = 0, b = 24)))
)
