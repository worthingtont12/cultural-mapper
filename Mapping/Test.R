map + scale_color_brewer(palette = "Set1") +
  stat_chull(aes(x = long, y = lat, color = language),
             data = clean.topics %>%
               filter(language %in% all_langs$language[1:6]), fill = NA) + 
  ggtitle(paste("Convex Hull of Top 6 Languages in",db)) + 
  ggsave(paste0("Outputs/",db,"-ConvHull.pdf"), width = 11, height = 8.5, units = "in")