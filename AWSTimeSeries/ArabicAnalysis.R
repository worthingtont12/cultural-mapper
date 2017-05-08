#### Analysis of Arabic Tweets in each market ####

#### Grab Arabic Tweets for each market ####

# Starting in Istanbul
source("IST_meta.R")
source("Helpers/Postgres_functions.R")

# Connect To the Database
con <- connectDB(db)

# Pull in the data for a given city
ist.arabic = dbGetQuery(con, paste0("
                                  WITH casted AS(
                                  SELECT id, CAST(created_at as timestamptz) as created_at, source, text_lang, user_id,
                                  user_lang
                                  FROM ",db,"_city_primary
                                  WHERE source ILIKE ANY(ARRAY['%for Blackberry%', '%for Android%', '%tron%',
                                  '%Foursquare%','%Instagram%','%for iOS%',
                                  '%for iPhone%','%for Windows Phone%',
                                  '%for iPad%','Twitter Web Client','%for Mac%']) AND user_lang = 'ar'
                                  )

                                  SELECT timezone('",tz,"',created_at) as tzone,
                                  text_lang, user_lang, user_id, source
                                  FROM casted
                                  WHERE timezone('",tz,"',created_at) > '2016-10-28' AND
                                  timezone('",tz,"',created_at) < '2017-01-28';"))

# Disconnect
disconnectDB(con)

# Chicago
source("CHI_meta.R")
# Connect To the Database
con <- connectDB(db)

# Pull in the data for a given city
chi.arabic = dbGetQuery(con, paste0("
                                    WITH casted AS(
                                    SELECT id, CAST(created_at as timestamptz) as created_at, source, text_lang, user_id,
                                    user_lang
                                    FROM ",db,"_city_primary
                                    WHERE source ILIKE ANY(ARRAY['%for Blackberry%', '%for Android%', '%tron%',
                                    '%Foursquare%','%Instagram%','%for iOS%',
                                    '%for iPhone%','%for Windows Phone%',
                                    '%for iPad%','Twitter Web Client','%for Mac%']) AND user_lang = 'ar'
                                    )

                                    SELECT timezone('",tz,"',created_at) as tzone,
                                    text_lang, user_lang, user_id, source
                                    FROM casted
                                    WHERE timezone('",tz,"',created_at) > '2016-10-28' AND
                                    timezone('",tz,"',created_at) < '2017-01-28';"))

# Disconnect
disconnectDB(con)

# Los Angeles
source("LAX_meta.R")
# Connect To the Database
con <- connectDB(db)

# Pull in the data for a given city
lax.arabic = dbGetQuery(con, paste0("
                                    WITH casted AS(
                                    SELECT id, CAST(created_at as timestamptz) as created_at, source, text_lang, user_id,
                                    user_lang
                                    FROM ",db,"_city_primary
                                    WHERE source ILIKE ANY(ARRAY['%for Blackberry%', '%for Android%', '%tron%',
                                    '%Foursquare%','%Instagram%','%for iOS%',
                                    '%for iPhone%','%for Windows Phone%',
                                    '%for iPad%','Twitter Web Client','%for Mac%']) AND user_lang = 'ar'
                                    )

                                    SELECT timezone('",tz,"',created_at) as tzone,
                                    text_lang, user_lang, user_id, source
                                    FROM casted
                                    WHERE timezone('",tz,"',created_at) > '2016-10-28' AND
                                    timezone('",tz,"',created_at) < '2017-01-28';"))

# Disconnect
disconnectDB(con)

#### Summarize ####
library(tidyverse)
library(lubridate)

# Unique Users in Los Angeles
la.users <- lax.arabic %>%
  select(user_id) %>%
  unique() %>% count %>% as.numeric()

# Daily totals, normalized by number of users in the community
la.series <- lax.arabic %>%
  mutate(date = as.Date(tzone,"%d %b %Y")) %>%
  group_by(date) %>% summarize(LA = n(), LA.norm = n()/la.users)

# Unique Users in Chicago
chi.users <- chi.arabic %>%
  select(user_id) %>%
  unique() %>% count %>% as.numeric()

# Daily totals, normalized by number of users in the community
chi.series <- chi.arabic %>%
  mutate(date = as.Date(tzone,"%d %b %Y")) %>%
  group_by(date) %>% summarize(CHI = n(), CHI.norm = n()/chi.users)

# Unique Users in Istanbul
ist.users <- ist.arabic %>%
  select(user_id) %>%
  unique() %>% count %>% as.numeric()

# Daily totals, normalized by number of users in the community
ist.series <- ist.arabic %>%
  mutate(date = as.Date(tzone,"%d %b %Y")) %>%
  group_by(date) %>% summarize(IST = n(), IST.norm = n()/ist.users)

# Join all three cities together, by data
all <- la.series %>%
  left_join(chi.series, by = "date") %>%
  left_join(ist.series, by = "date")

# Replace NA values with 0's, where appropriate
all[is.na(all)] <- 0

#### Time Series Analysis ####
library(forecast)

# Cross-correlations between cities
par(mfrow=c(3,1))
Ccf(all$LA.norm,diff(all$CHI.norm), main = "LAX vs. CHI")
Ccf(all$LA.norm,all$IST.norm, main = "Arabic: Los Angeles vs. Istanbul")
Ccf(all$IST.norm,diff(all$CHI.norm), main = "IST vs. CHI")

# Regular time series plot
plot(ts(all$LA.norm, freq = 7))
lines(ts(all$CHI.norm, freq = 7), col = "red")
lines(ts(all$IST.norm, freq = 7), col = "green")

# Variance across the time series for each city
apply(all[,c(3,5,7)],2,var)

# Time series plot of the difference between Los Angeles and Istanbul
all %>%
  select(LA.norm, IST.norm) %>%
  transmute(dif = LA.norm-IST.norm) %>%
  ts(start = as.Date(all$date[1])) %>% plot

# Plot normalized time series.
all %>% select(LA.norm, IST.norm,CHI.norm) %>% plot

# Create ARIMA models for each city
apply(all[,c(3,4,7)],2, auto.arima)

# Experimenting with prediction using the above models
chi.arima <- sarima(all$CHI.norm,3,1,1, S=7)
predict(chi.arima,all$CHI.norm)

#### Pretty Cross-Correlations ####
library(ggplot2)

# The forecast package can plot nicer graphics with ggplot2
# CCF plot of LA's normalized per user tally vs. Istanbul's per user tally.
library(ggplot2)
ggCcf(all$LA.norm,all$IST.norm) + ggtitle("")+
  ggsave("Outputs/CCF_Arabic.png",
         width = 3.4,
         height = NA,
         units = "in", dpi = 300)
