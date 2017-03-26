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

# Merge in Humna-readable languages
clean <- merge_langs(loc.data)

# Drop uneccesary columns, extract date
clean <- clean %>%
  select(-dow_sin,-dow_cos,-hour_sin,-hour_cos) %>%
  mutate(date= format(tz, "%d %b %Y"))

# Merge Topics
clean.topics <- merge_topics(clean, "Topic_Data/")