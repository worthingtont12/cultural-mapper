#### Get the City Data
# Load in the helper functions
source("Postgres_functions.R")
source("SpatialUtil.R")

# Load in the Location metadata
source("IST_meta.R")

# Connect To the Database
con <- connectDB(db)

# Pull in the data for a given city
loc.data = dbGetQuery(con, paste0("
                      WITH casted AS(
	SELECT id, CAST(created_at as timestamptz) as created_at, source, text_lang, user_id,
                      user_lang
                      FROM ",db,"_city_primary
                      WHERE source ILIKE ANY(ARRAY['%for Blackberry%', '%for Android%', '%tron%',
                       '%Foursquare%','%Instagram%','%for iOS%',
                                  '%for iPhone%','%for Windows Phone%',
                                  '%for iPad%','Twitter Web Client','%for Mac%'])
)

SELECT timezone('",tz,"',created_at) as tzone,
text_lang, user_lang, user_id, source
           FROM casted
           WHERE timezone('",tz,"',created_at) > '2016-10-28' AND
                      timezone('",tz,"',created_at) < '2017-01-28';"))

# Disconnect
disconnectDB(con)

#### Merging and Cleaning ####
library(dplyr)
library(lubridate)
library(tidyr)

# Load the Twitter language registry
registry <- load_langs()
# Merge the language by the users' selected language!
data_merge <- left_join(loc.data, registry)
data_merge$language <- as.factor(data_merge$language)
# Clean up the source, Extract the Date
data_merge <- data_merge %>% 
  mutate(source = gsub(pattern = "<.+\">|</a>", "",source),
         date = format(tzone, "%d %b %Y"))

# Merge Topics
clean.topics <- merge_topics(data_merge, "Topic_Data/")

# Remove duplicate files
rm(loc.data, data_merge)

# Aggregate count by date and topic
counts <- clean.topics %>% 
  mutate(date = as.Date(date,"%d %b %Y")) %>%
  filter(!(lang.topic %in% registry$language)) %>%
  group_by(date, lang.topic) %>% count

counts <- counts %>% 
  spread(lang.topic,n) %>%
  arrange(date)

plot.ts(counts$date,counts$`Topic 0 - Turkish`)
