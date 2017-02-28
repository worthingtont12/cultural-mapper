# Source the Postgres Functions
source('../ConvexHulls/Postgres_functions.R')

# Source the hull functions
source('../ConvexHulls/HullFunctions.R')

#### Get the data from AWS ####

# Create connection to the RDS instance
con <- connectDB("LA")

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

# Read in topic assignments output from python
topic_assignments <- read_csv('English_LA075.csv')

# Merge topic assignments with individual geo-tagged tweets
clean <- inner_join(clean, topic_assignments %>% 
                     select(user_id, top_topic, topic_prob),
                   by = 'user_id')




#### Desciptive Stats ####
library(dplyr)
library(ggplot2)
library(ggmap)

# Subset the data, selecting only the points with over 1000 tweets
temp <- subset(data, geo_point %in%
                 (top_points %>% filter(tweets >1000) %>% select(geo_point))[[1]])

ggplot(temp, aes(x=reorder(geo_point, -table(geo_point)[geo_point])))+geom_bar()

# Clearly, we have a class imbalance. Where is it?

# Get Base LA Map
map <- ggmap(get_map(location = c(-118.723549,33.694679,-117.929466,34.33926)))

# Density plot
map + stat_density2d(aes(x = long, y = lat, fill = ..level.., alpha = ..level..),
                     data = temp)

# Aggregate by size
map + geom_count(aes(x = long, y = lat, alpha = .5), data = temp)

# There's a heavy concentration in Downtown LA - likely due to generic posts
# tagged with the location of "Los Angeles"

# Look at topic assignment distribution
ggplot(clean, aes(x=top_topic))+geom_bar()
# bit of a class imbalance here, as well.


#### Convex Hulls by Language ####

# Aggregate counts by language (NA are languages not supported by Twitter)
lang_sum <- clean %>%
  group_by(language) %>%
  count() %>%
  arrange(desc(n))

# English is the overwhelming majority.

map + scale_color_brewer(palette = "Set1") +
  stat_chull(aes(x = long, y = lat, color = language),
             data = clean %>%
               filter(language %in% lang_sum$language[1:9]), fill = NA)

# English is pretty much the entire map, Spanish (all 18 tweets is much smaller)

all_langs <- data %>%
  group_by(user_lang) %>%
  count() %>%
  arrange(desc(n))
map + scale_color_brewer(palette = "Set1") +
  stat_chull(aes(x = long, y = lat, color = user_lang),
             data = data %>%
               filter(user_lang %in% all_langs$user_lang[1:9]), fill = NA)


#### Convex Hulls by Topic ####

map + scale_color_brewer(palette = "Set1") +
  stat_chull(aes(x = as.numeric(long), y = as.numeric(lat), color = as.factor(top_topic)),
             data = clean %>% filter(top_topic %in% 0:8), fill = NA)

# Subsetting English by topic doesn't help narrow down regions, though.


#### Density Maps ####

# Spanish Density by Day - Sundays see the largest time - clear hubs!
map + stat_density2d(aes(x = long, y = lat, fill = ..level.., alpha = ..level..),
                     data = clean[clean$language == "Spanish",]) +
  facet_wrap( ~ day, nrow = 2)

# English density by day of the week
map + geom_density2d(aes(x = long, y = lat, 
                         color = ..level..), bins = 100, size = .1,
                     data = clean[clean$language == "English",]) +
  facet_wrap(~ day, nrow = 2)

# English density by hour of the day
map + geom_density2d(aes(x = long, y = lat, 
                         color = ..level..), bins = 100, size = .1,
                     data = clean[clean$language == "English",]) +
  facet_wrap(~ hour, nrow = 4)

#### Alpha Hulls by Language ####
source("../ConvexHulls/Alpha Hulls.R")
AlphaHull(clean)

# By topic
AlphaHull(clean, feature = 'top_topic')
