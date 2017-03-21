setwd("~/Box Sync/Capstone Files/Cultural_Mapper/Modelling_SMOTE")
# Source the location metadata and
source("IST_meta.R")

# Load data if already procured
rm(list = ls())
load(file = "ISTData.RData")

# Source the Postgres Functions
source('../ConvexHulls/Postgres_functions.R')

# Source the hull functions
source('../ConvexHulls/HullFunctions.R')

#### Get the data from AWS ####

# Create connection to the RDS instance
con <- connectDB(db)

# Get the raw count of items, as well as the aggregate count, grouped by location

new_raw_count = dbGetQuery(con, "SELECT COUNT(*)
                           FROM geometries_filter
                           ")

top_points = dbGetQuery(con, "SELECT COUNT(*) AS tweets, geo_point
                        FROM geometries_filter
                        GROUP BY geo_point
                        ORDER BY tweets DESC
                        ")

data = dbGetQuery(con, "SELECT *
                  FROM geometries_filter")
# Disconnect
disconnectDB(con)

  
#### Clean and Merge the Data ####
library(dplyr)
library(readr)

# Tidy and assign additional variables
clean <- merge_langs(data)


## Assigning Topics by user
# Read in topic assignments output from python
topic_assignments <- read_csv('English_LA075.csv')

# Merge topic assignments with individual geo-tagged tweets
clean <- inner_join(clean, topic_assignments %>% 
                      select(user_id, top_topic, topic_prob),
                    by = 'user_id')

# Source the Spatial Functions
source("SpatialUtil.R")

# Convert to meters
meters <- LongLatToM(clean$long,clean$lat,epsg)
topic_meters <- cbind(clean,meters)


#### Density Maps ####
library(dplyr)
library(ggplot2)
library(ggmap)

# Get Base Map
map <- ggmap(get_map(location = bbox, source = "stamen", maptype="toner", color = "bw"))

# Find the parameters for ggplot density mapping
# "n" is the number of grid points in each direction
grid.points <- findN(map,200,epsg)
# "h" is bandwidth; calculated using bandwidth.nrd from MASS; uses a bivariate
# Normal kernel on each axis; splancs package uses a quartic kernel


# Initial attempts to color by language fail, as "Filipino" only has 1 tweet.
# Thus, filter out those languages with a count below a certain threshold when plotting
top_langs <- clean %>% group_by(language) %>% 
  count() %>%
  mutate(percent = 100*n/sum(n)) %>%
  arrange(desc(percent))


# There's a concentration towards certain points, why is this? Turns out, the
# top point (1.33% of all tweets) is also from Instagram. So we filter this out
# by source.
clean %>% 
  filter(geo_point %in% top_points$geo_point[1:10]) %>%
  group_by(lat,long,source) %>% 
  count() %>%
  mutate(percent = 100*n/nrow(clean)) %>%
  arrange(desc(n))

# A Look at the distribution of sources
clean %>% 
  group_by(source)%>%
  count() %>%
  arrange(desc(n)) %>%
  mutate(percent = 100*n/sum(n))

#### Convex Hulls by Language ####

# Aggregate counts by language (NA are languages not supported by Twitter)
all_langs <- clean %>%
  group_by(language) %>%
  count() %>%
  mutate(percent = n*100/sum(n)) %>%
  arrange(desc(n))

# Convex Hulls of all points
map + scale_color_brewer(palette = "Set1") +
  stat_chull(aes(x = long, y = lat, color = language),
             data = clean %>%
               filter(language %in% all_langs$language[1:6]), fill = NA)

# Convex Hull w/o Instagram
map + scale_color_brewer(palette = "Set1") +
  stat_chull(aes(x = long, y = lat, color = language),
             data = clean %>%
               filter(source != "Instagram",language %in% all_langs$language[1:6]), fill = NA)

#### Convex Hulls by Topic ####

map + scale_color_brewer(palette = "Set1") +
  stat_chull(aes(x = as.numeric(long), y = as.numeric(lat), color = as.factor(top_topic)),
             data = clean %>% filter(top_topic %in% 0:8), fill = NA)

#### Density Maps ####

# Density plot with all points for top 6 languages
map + scale_color_brewer(palette = "Set1") +
      geom_density2d(aes(x = long, y = lat, color = language),
                     n = grid.points,
                     data = clean %>% filter(source != "Instagram",
                                             language %in% top_langs$lang[1:6])) + 
      facet_grid(day ~ hour.cut)

# Turkish Density by Day - Sundays see the largest time - clear hubs!
map + stat_density2d(aes(x = long, y = lat),
                     data = clean %>% filter(language == "Turkish",
                                             source != "Instagram")) +
  facet_wrap( ~ day, nrow = 2)

# English density by day of the week
map + geom_density2d(aes(x = long, y = lat, 
                         color = ..level..),# bins = 100, size = .1,
                     data = clean[clean$language == "English",]) +
  facet_wrap(~ day, nrow = 2)

# Turkish density by hour of the day
map + stat_density2d(aes(x = long, y = lat, 
                         color = ..level..), #bins = 100, size = .1,
                     n = grid.points,
                     data = clean %>% filter(language == "Turkish",
                                             source != "Instagram")) +
  facet_wrap(~ hour.cut, nrow = 2)


# Turkish density by hour of the day
map + stat_density2d(aes(x = long, y = lat, 
                         color = ..level..), #bins = 100, size = .1,
                     n = grid.points,
                     data = clean %>% filter(language == "Turkish",
                                             source != "Instagram",
                                             hour %in% c(21,22,23))) +
  facet_wrap(~ hour.cut, nrow = 2)



map + geom_point(aes(x = long, y = lat), data = clean %>% filter(language =="Turkish", hour.cut == "9pm-12am"))


map + stat_density2d(aes(x = long, y = lat, 
                         fill = ..level..), geom = "polygon",# bins = 100, size = .1,
                     #n = grid.points,
                     data = clean %>% filter(language == "Turkish",
                                             source != "Instagram",
                                             hour.cut == "8pm-12am"))


map + geom_point(aes(x = long, y = lat,color = "red"),
             data = clean %>% filter(language == "Turkish",
                                    source != "Instagram",
                                    hour == 0)) +
  stat_density2d(aes(x = long, y = lat, fill = ..level..), geom = "polygon",
                 n = 500,
                 data = clean %>% filter(language == "Turkish",
                                         source != "Instagram",
                                         hour == 0)) + facet_wrap(~day,2)


map + geom_point(aes(x=long, y=lat, color = "red"),
                 data = clean %>% filter(language == "Turkish",
                                         source != "Instagram",
                                         hour == 0))
