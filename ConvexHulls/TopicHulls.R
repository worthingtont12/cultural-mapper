# Load the functions which connect to the database
source("Postgres_functions.R")

# Create connection to the RDS instance
con <- connectDB("LA")

# Load the Latitude, Logitude, & Language from within a week-long test set. As
# points outside the LA area can be geotagged, limit to the exisiting bounding
# box.

new_data = dbGetQuery(con, "SELECT p.user_id, lat, long, m.text_lang, tz,
                  EXTRACT (DAY FROM tz) as day, EXTRACT(HOUR FROM tz) AS hour
                  FROM (SELECT id, CAST(lat AS FLOAT) as lat, CAST(long AS FLOAT) as long,
                  text_lang, timezone('America/Los_Angeles',created_at) as tz
                  FROM geometries_test) AS m LEFT JOIN la_city_primary p
                  ON m.id = p.id
                  WHERE tz >= '2017-01-07' AND  tz <= '2017-01-15' AND
                  lat >= 33.694679 AND lat <= 34.33926 AND
                  long >= -118.723549 AND long <= -117.929466
                  ")


# Disconnect
disconnectDB(con)


# Read in the Topic Models
library(readr)
topics <- read_csv('../../../../Desktop/English_LA.csv')[2:5]

# Merge with the above query
topics_merged <- merge(topics, new_data, all.y = T)


library(dplyr)
# Summarize by count
topic_count <- topics_merged %>% 
  group_by(top_topic) %>% 
  count() %>% arrange(desc(n))

# 27,683 posts have no topic, i.e. user_lang isn't english.. That's...
topic_count[20,2]/nrow(topics_merged)
# 30% of our data!!!

nrow(topics_merged[is.na(topics_merged$top_topic),])

topics_merged[is.na(topics_merged$top_topic),] %>%
  group_by(text_lang) %>% count()
# 26,000 of them are actually english tweets, so what's the user's language?


topics_merged %>% 
  group_by(lat, long) %>% 
  count() %>% 
  arrange(desc(n)) %>%
  filter(n >= 100)

map + geom_point(aes(x = as.numeric(long), y = as.numeric(lat), size = n),
                 data = topics_merged %>% 
                   group_by(lat, long) %>% 
                   count() %>% 
                   arrange(desc(n)) %>%
                   filter(n >= 100))



topics_merged %>% 
  group_by(user_id) %>% 
  count() %>% arrange(desc(n))

map + geom_point(aes(x = as.numeric(long), y = as.numeric(lat), size = n), 
                     data = topics_merged %>% 
                   filter(user_id == 22454941) %>% 
                   group_by(lat, long) %>%
                   count() %>% arrange(desc(n)))

# There are a number of folks with oodles of geotagged posts....but they don't have topics!

library(ggplot2)
library(ggmap)
library(maps)
map + scale_color_brewer(palette = "Set1") +
  stat_chull(aes(x = as.numeric(long), y = as.numeric(lat), color = as.factor(top_topic)),
             data = topics_merged %>% filter(top_topic %in% 0:8), fill = NA)


topic_count %>% 
  filter(!is.na(top_topic)) %>% slice(1:9)


topics_merged %>% 
  filter(!is.na(top_topic)) %>%
  group_by(lat, long) %>% 
  count() %>% 
  arrange(desc(n)) %>%
  filter(n >= 100)
