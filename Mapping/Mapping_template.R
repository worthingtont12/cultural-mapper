library(ggplot2)

m <- ggplot(faithful, aes(x = eruptions, y = waiting)) +
  geom_point() +
  xlim(0.5, 6) +
  ylim(40, 110)
m + geom_density_2d(size = 1)

m + stat_density_2d(aes(fill = ..level.., alpha = .4), geom = "polygon")

map + geom_point(aes(x = long, y = lat,color = "red"),
                 data = clean %>% filter(language == "Turkish",
                                         source != "Instagram",
                                         hour == 0)) +
  stat_density2d(aes(x = long, y = lat, fill = ..level..), geom = "polygon",
                 n = 500,
                 data = clean %>% filter(language == "Turkish",
                                         source != "Instagram",
                                         hour == 0)) + facet_wrap(~day,2)


map.data <- stat_density_2d(aes(x = long, y = lat,
                                fill = ..level.., alpha = .4), geom = "polygon",
                data = clean %>% filter(language %in% top_langs$language,
                                        source != "Instagram",
                                        hour == 4))
map + map.data



clean %>%
  filter(language %in% top_langs$language,
         source != "Instagram",
         hour == 4) %>%
  group_by(language) %>% count() %>% arrange(desc(n))

language.density <- geom_density_2d(aes(x = long, y = lat,
                                         color = language,
                                        alpha = .4, size = 1),# geom = "polygon",
                                     data = clean %>% filter(language %in% top_langs$language[1:3],
                                                             source != "Instagram"))


map +language.density + facet_grid(day ~ hour.cut)
