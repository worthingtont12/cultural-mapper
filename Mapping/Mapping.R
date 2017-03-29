#### Clean and Merge the Data ####
library(dplyr)
library(readr)

# Tidy and assign additional variables
clean <- merge_langs(data)


## Assigning Topics by user
# Read in topic assignments output from python
clean.topics <- merge_topics(clean, "Topic_Data/")

# Source the Spatial Functions
source("SpatialUtil.R")

# Convert to meters
meters <- LongLatToM(clean.topics$long,clean.topics$lat,epsg)
topic_meters <- cbind(clean.topics,meters)


#### Density Maps ####
library(dplyr)
library(ggplot2)
library(ggmap)

# Get Base Map, removing the 
map <- ggmap(get_map(location = bbox, source = "stamen", maptype="toner", color = "bw")) +
  theme(axis.text.x = element_blank(),
        axis.title.x = element_blank(),
        axis.text.y = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks = element_blank())

# Find the parameters for ggplot density mapping
# "n" is the number of grid points in each direction
grid.points <- findN(map,200,epsg)
# "h" is bandwidth; calculated using bandwidth.nrd from MASS; uses a bivariate
# Normal kernel on each axis; splancs package uses a quartic kernel


# Initial attempts to color by language fail, as "Filipino" only has 1 tweet.
# Thus, filter out those languages with a count below a certain threshold when plotting
top_langs <- clean.topics %>% group_by(lang.topic) %>% 
  count() %>%
  mutate(percent = round(100*n/nrow(clean),2)) %>%
  arrange(desc(percent))

# Why is Turkish so prevalent, with no topic?
clean.topics %>%
  filter(lang.topic == "Turkish") %>%
  group_by(source) %>%
  count() %>%
  arrange(desc(n))
# Windows and "robot" shouldn't be included

# There's a concentration towards certain points, why is this? Turns out, the
# top point (1.33% of all tweets) is also from Instagram. So we filter this out
# by source.
clean %>% 
  filter(geo_point %in% top_points$geo_point[1:10]) %>%
  group_by(lat,long,source) %>% 
  count() %>%
  mutate(percent = round(100*n/nrow(clean),2)) %>%
  arrange(desc(n))

# A Look at the distribution of sources
clean.topics %>% 
  group_by(source)%>%
  count() %>%
  arrange(desc(n)) %>%
  mutate(percent = round(100*n/nrow(clean),2))

#### Convex Hulls by Language ####

# Aggregate counts by language (NA are languages not supported by Twitter)
all_langs <- clean.topics %>%
  group_by(language) %>%
  count() %>%
  mutate(percent = round(100*n/nrow(clean),2)) %>%
  arrange(desc(n))

# Convex Hulls of all points
map + scale_color_brewer(palette = "Set1") +
  stat_chull(aes(x = long, y = lat, color = language),
             data = clean.topics %>%
               filter(language %in% all_langs$language[1:6]), fill = NA) + 
  ggtitle(paste("Convex Hull of Top 6 Languages in",db)) + 
  ggsave(paste0("Outputs/",db,"-ConvHull.png"), width = 11, height = 8.5, units = "in")

# png(temp,file = paste0("Outputs/",db,"%d.png"), width = 500, height = 500, units = "px")
# dev.off()

# Convex Hull w/o Instagram
map + scale_color_brewer(palette = "Set1") +
  stat_chull(aes(x = long, y = lat, color = language),
             data = clean.topics %>%
               filter(source != "Instagram",language %in% all_langs$language[1:6]), fill = NA)+ 
  ggtitle(paste("Convex Hull of Top 6 Languages in",db,"(No Instagram)")) + 
  ggsave(paste0("Outputs/",db,"-ConvHullNoIG.png"), width = 11, height = 8.5, units = "in")

#### Convex Hulls by Topic ####

map + scale_color_brewer(palette = "Set1") +
  stat_chull(aes(x = as.numeric(long), y = as.numeric(lat), color = lang.topic),
             data = clean.topics %>% filter(lang.topic %in% top_langs$lang.topic[0:6]), fill = NA) + 
  ggtitle(paste("Convex Hull of Top 6 Topics in",db,"(No Instagram)")) + 
  ggsave(paste0("Outputs/",db,"-ConvHullTopic.png"), width = 11, height = 8.5, units = "in")

#### Density Maps ####

# Density plot with all points for top 6 languages
map + scale_color_brewer(palette = "Set1", name ="Topics") +
  geom_density2d(aes(x = long, y = lat, color = lang.topic), alpha = .5,
                 n = grid.points,
                 data = clean.topics %>% filter(source != "Instagram",
                                                lang.topic %in% top_langs$lang.topic[1:6])) + 
  facet_grid(day ~ hour.cut) + 
  ggtitle(paste("Densities of Top 6 Topics in",db,"by Day by Hour"))  + 
  theme(legend.position = "bottom", legend.box = "horizontal")+ 
  ggsave(paste0("Outputs/",db,"-TopicDensity_DayHour.png"), width = 11, height = 8.5, units = "in")

# Turkish Density by Day - Sundays see the largest time - clear hubs!
map + stat_density2d(aes(x = long, y = lat, fill = ..level..), geom = "polygon",
                     data = clean.topics %>% filter(user_language == all_langs$language[1],
                                                    source != "Instagram")) +
  facet_wrap( ~ day, nrow = 2) +
  scale_fill_distiller(palette = "Spectral") + 
  ggtitle(paste("Density of",all_langs$language[1],"Tweets in",db,"by Day")) + 
  ggsave(paste0("Outputs/",db,"-TopLangDensity_Day.png"), width = 11, height = 8.5, units = "in")

# English density by day of the week
map + stat_density2d(aes(x = long, y = lat, 
                         fill = ..level..), geom = "polygon",
                     data = clean.topics %>%
                       filter(user_language == all_langs$language[2],
                              source != "Instagram")) +
  facet_wrap(~ day, nrow = 2) +
  scale_fill_distiller(palette = "Spectral") + 
  ggtitle(paste("Density of",all_langs$language[2],"Tweets in",db,"by Day")) + 
  ggsave(paste0("Outputs/",db,"-2LangDensity.png"), width = 11, height = 8.5, units = "in")


# Map of top language at midnight
map + stat_density2d(aes(x = long, y = lat, 
                         fill = ..level..), geom = "polygon",
                     n = grid.points,
                     data = clean.topics %>% filter(user_language == all_langs$language[1],
                                                    source != "Instagram",
                                                    hour.cut == "8pm-12am")) +
  facet_wrap(~ day, nrow = 2) + 
  ggtitle(paste("Density of",all_langs$language[1],"Tweets in",db,"at Midnight")) + 
  ggsave(paste0("Outputs/",db,"-TopLangMidnight.png"), width = 11, height = 8.5, units = "in")

# Sunday is highest? Why? Perhaps the NYE effect.

# New Year's Eve
map +
  ggtitle(paste("Density of",all_langs$language[1],"Tweets on New Year's Eve from 12am-4am")) +
  geom_point(aes(x = long, y = lat, color = lang.topic),
             data = clean.topics %>% filter(user_language == all_langs$language[1],
                                            source != "Instagram",
                                            hour.cut == "8pm-12am",
                                            tz >= "2016-12-31",
                                            tz <= "2017-01-01"
             ),  alpha = .1) +
  stat_density2d(aes(x = long, y = lat, 
                     fill = ..level..), geom = "polygon",
                 n = grid.points,
                 data = clean.topics %>% filter(user_language == all_langs$language[1],
                                                source != "Instagram",
                                                hour.cut == "8pm-12am",
                                                tz >= "2016-12-31",
                                                tz <= "2017-01-01"
                 )) + theme(legend.position = "none") +
  scale_fill_distiller(palette = "Spectral") + 
  ggsave(paste0("Outputs/",db,"-TopLangNYE.png"), width = 11, height = 8.5, units = "in")

# All other Sundays
map +
  geom_point(aes(x = long, y = lat, color = lang.topic), alpha = .1,
             data = clean.topics %>% filter(user_language == all_langs$language[1:6],
                                            source != "Instagram",
                                            hour.cut == "8pm-12am",
                                            tz != strftime("2016-01-01"),
                                            day == "Sun"
             )) +
  stat_density2d(aes(x = long, y = lat, 
                     fill = ..level..), geom = "polygon",
                 n = grid.points,
                 data = clean.topics %>% filter(user_language == all_langs$language[1:6],
                                                source != "Instagram",
                                                hour.cut == "8pm-12am",
                                                tz != strftime("2017-01-01"),
                                                day == "Sun"
                 ))+
  scale_fill_distiller(palette = "Spectral") + 
  theme(legend.position = "none") + 
  ggtitle(paste("Density of",all_langs$language[1],
                "Tweets on Sundays (not including New Year's) from 12am-4am")) + 
  ggsave(paste0("Outputs/",db,"-TopLangSunNoNYE.png"), width = 11, height = 8.5, units = "in")

# Top Topic By Day, By Hour
map + stat_density2d(aes(x = long, y = lat, 
                         fill = ..level..), geom = "polygon",
                     n = grid.points,
                     data = clean.topics %>% filter(lang.topic == top_langs$lang.topic[1],
                                                    source != "Instagram"
                     )) +
  ggtitle(paste("Density of",top_langs$lang.topic[1],
                "Tweets by Day, by Hour")) +
  scale_fill_distiller(palette = "Spectral")+ 
  facet_grid(day ~ hour.cut) + 
ggsave(paste0("Outputs/",db,"-TopTopic_hour_Day.png"), width = 11, height = 8.5, units = "in")

# Top Topic by Hour, Mondays
map + stat_density2d(aes(x = long, y = lat, 
                         fill = ..level..), geom = "polygon",
                     n = grid.points,
                     data = clean.topics %>% filter(lang.topic == top_langs$lang.topic[1],
                                                    source != "Instagram", day == "Mon"
                     )) +
  ggtitle(paste("Density of",top_langs$lang.topic[1],
                "Tweets by Hour in",db,"on Mondays")) +
  scale_fill_distiller(palette = "Spectral")+ 
  facet_grid(~ hour.cut) + 
  ggsave(paste0("Outputs/",db,"-TopTopic_hour_MON.png"), width = 11, height = 8.5, units = "in")


# 2nd Topic By Day, By Hour
map + stat_density2d(aes(x = long, y = lat, 
                         fill = ..level..), geom = "polygon",
                     n = grid.points,
                     data = clean.topics %>% filter(lang.topic == top_langs$lang.topic[2],
                                                    source != "Instagram"
                     )) +
  scale_fill_distiller(palette = "Spectral") + 
  ggtitle(paste("Density of",top_langs$lang.topic[2],
                "Tweets by Day, by Hour")) + 
  facet_grid(day ~ hour.cut) +
ggsave(paste0("Outputs/",db,"-2ndTopic_hour_Day.png"), width = 11, height = 8.5, units = "in")

# 8th Topic By Day, By Hour
map + stat_density2d(aes(x = long, y = lat, 
                         fill = ..level..), geom = "polygon",
                     n = grid.points,
                     data = clean.topics %>% filter(lang.topic == top_langs$lang.topic[8],
                                                    source != "Instagram"
                     )) +
  scale_fill_distiller(palette = "Spectral") + 
  ggtitle(paste("Density of",top_langs$lang.topic[8],
                "Tweets by Day, by Hour")) + 
  facet_grid(day ~ hour.cut) +
ggsave(paste0("Outputs/",db,"-8thTopic_hour_Day.png"), width = 11, height = 8.5, units = "in")

# Top 6 Topics Weekday vs. Weekend
map + stat_density2d(aes(x = long, y = lat, 
                         fill = ..level..), geom = "polygon",
                     n = grid.points,
                     data = clean.topics %>% filter(lang.topic %in% top_langs$lang.topic[1:6],
                                                    source != "Instagram"
                     )) +
  scale_fill_distiller(palette = "Spectral") + 
  ggtitle(paste("Density of Top 6 Topics, Week vs. Weekends")) + 
  facet_grid(weekend~lang.topic) + 
ggsave(paste0("Outputs/",db,"-TopTopics_weekends.png"), width = 11, height = 8.5, units = "in")
