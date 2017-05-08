# Load the functions which connect to the database
source("../Helpers/Postgres_functions.R")
source("../Helpers/HullFunctions.R")

# Create connection to the RDS instance
con <- connectDB("LA")

# Load the Latitude, Logitude, & Language from within a week-long test set. As
# points outside the LA area can be geotagged, limit to the exisiting bounding
# box.

data = dbGetQuery(con, "SELECT lat, long, text_lang, tz,
                        EXTRACT (DAY FROM tz) as day, EXTRACT(HOUR FROM tz) AS hour
                  FROM (SELECT CAST(lat AS FLOAT) as lat, CAST(long AS FLOAT) as long,
                            text_lang, timezone('America/Los_Angeles',created_at) as tz
                       FROM geometries_test) AS foo
                  WHERE tz >= '2017-01-07' AND  tz <= '2017-01-15' AND
                    lat >= 33.694679 AND lat <= 34.33926 AND
                    long >= -118.723549 AND long <= -117.929466
                  ")
# Disconnect
disconnectDB(con)

# Load the languages, merge into the data
registry <- load_langs()
data_merge <- merge(data, registry)
data_merge$language <- as.factor(data_merge$language)
data_merge$weekend <- isWeekend(data_merge$tz)

# Clean data (as original query wasn't geo-bound)
data_merge <- data_merge[data_merge$lat >= 33.694679 & data_merge$lat <= 34.33926 &
                           data_merge$long <= -118.723549 & data_merge$long >= -117.929466,]

# https://chitchatr.wordpress.com/2011/12/30/convex-hull-around-scatter-plot-in-r/

hull <-chull(data_merge[3:2])
# Needs to be closed!
hull <- c(hull, hull[1])

plot(data_merge[3:2])
lines(data_merge[hull,3], data_merge[hull,2])


# Summarize by languages
require(dplyr)
require(timeDate)
lang_sum <- data_merge %>%
  group_by(language) %>%
  count() %>%
  arrange(desc(n))
lang_sum

require(ggplot2)
require(ggmap)
require(maps)

# Get Base LA Map
map <- ggmap(get_map(location = c(-118.723549,33.694679,-117.929466,34.33926)))

# Convex hulls for the top 9 languages
map + scale_color_brewer(palette = "Set1") +
      stat_chull(aes(x = as.numeric(long), y = as.numeric(lat), color = language),
                 data = data_merge %>%
                   filter(language %in% lang_sum$language[1:9]), fill = NA)

map + stat_density2d(aes(x = as.numeric(long), y = as.numeric(lat), fill = ..level.., alpha = ..level..),
                     data = data_merge[data_merge$language == "English",]) +
  facet_wrap( ~ day, nrow = 2)

# English density by day of the week
map + geom_density2d(aes(x = as.numeric(long), y = as.numeric(lat),
                         color = ..level..), bins = 100, size = .1,
                     data = data_merge[data_merge$language == "English",]) +
      facet_wrap(~ day, nrow = 2)

# English density by hour of the day
map + geom_density2d(aes(x = as.numeric(long), y = as.numeric(lat),
                         color = ..level..), bins = 100, size = .1,
                     data = data_merge[data_merge$language == "English",]) +
  facet_wrap(~ hour, nrow = 4)

# English density by week day vs. weekend by hour?

data_merge %>% group_by(isWeekday(tz, 3:7)) %>% count()

map + geom_density2d(aes(x = as.numeric(long), y = as.numeric(lat),
                         color = ..level..), bins = 100, size = .1,
                     data = data_merge[data_merge$language == "English",]) +
  facet_grid(. ~ weekend)

map + geom_density2d(aes(x = as.numeric(long), y = as.numeric(lat),
                         color = ..level..), bins = 100, size = .1,
                     data = data_merge[data_merge$language == "English",]) +
  facet_wrap( ~ weekend + hour)


# Next, try alpha hulls, svms; facet wraps days of the week, hours of the day by language

# Alpha Hulls
source('Alpha Hulls.R')
AlphaHull(data_merge)
# Needs work with legends, et al

for (i in 1:9){
  print(lang_sum$language[i])
}
