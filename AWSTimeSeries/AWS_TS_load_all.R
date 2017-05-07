#### Get the City Data ####
# Load in the helper functions
source("Postgres_functions.R")
source("SpatialUtil.R")

# Connect To the Database
con <- connectDB(db)

# Pull in the data for a given city, including past the 1-27-17 cutoff.
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
           WHERE timezone('",tz,"',created_at) >= '2016-10-28' ;"))

# Disconnect
disconnectDB(con)

# Save the image!!
#save.image(paste0("~/Cultural_Mapper/AWSTimeSeries/RData/",db,".RData"))


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
  # Extract Date
  mutate(date = as.Date(date,"%d %b %Y")) %>%
  # Filter out languages in the registry, so it's only the topics
  # filter(!(lang.topic %in% registry$language)) %>%
  # Filter out NA values
  filter(!is.na(lang.topic)) %>%
  # Provide the count by day for each topic group.
  group_by(date, lang.topic) %>% count

# Spread the data from long to wide format and sort by date
counts <- counts %>% 
  spread(lang.topic,n) %>%
  arrange(date)

# Turn NAs to 0
counts[is.na(counts)] <- 0

# Top topics, by count
top_topics <- clean.topics %>%
  group_by(lang.topic) %>% 
  filter(!is.na(lang.topic) & date <= "2017-01-27") %>%
  count() %>%
  arrange(desc(n))

#### Smoothing and ARIMA modeling ####
library(forecast)

# find the number of unique users by language
unique.users <- clean.topics %>% 
  group_by(lang.topic) %>%
  filter(!is.na(lang.topic)) %>%
  mutate(users = length(unique(user_id))) %>%
  select(lang.topic, users) %>% 
  unique %>%
  arrange(desc(users))

# Gather the languages
tweetcount <- counts %>% gather(lang.topic,n, -date)

# Normalize the counts per user and spread the data frame
activityPerUser <- left_join(tweetcount,unique.users, by ="lang.topic") %>% 
  rename(tweets = n ) %>%
  mutate(PerUser = tweets/users) %>%
  select(date, lang.topic, PerUser)

activityPerUser <- activityPerUser %>%
  spread(lang.topic,PerUser) %>%
  arrange(date)

activityPerUser[is.na(activityPerUser)] <- 0


# Read the coefficients from CSV
coefs <- read.csv(paste0("Outputs/",db,"_model_coefficients.csv"))

#### Forecasting ####


train <- activityPerUser %>%
  filter(date < "2017-01-28") %>% 
  select(date, one_of(
    as.vector(coefs$lang.topic)))
test <- activityPerUser %>% 
  filter(date >= "2017-01-28") %>% 
  select(date, one_of(
    as.vector(coefs$lang.topic)))

# Function to fit a model with the parameters specified:
# x is the univariate time series, h is the number of predictions, 
# p,d, and q are standard ARIMA parameters, with s being the period
# for seasonality, if applicable.

fit <- function(x,h,p,d,q,P=0,D=0,Q=0,s=1){
  forecast(Arima(x, order = c(p,d,q), seasonal = c(P,D,Q,s)), h=h)
}

# Prepare a data frame to hold the results
CVmodels <- as.data.frame(matrix(nrow = ncol(train)-1, ncol=8))
names(CVmodels) <- c("lang.topic","1day", "2day","3day","4day","5day","6day","7day")
CVmodels$lang.topic <- names(train[2:ncol(train)])

for(topic.i in names(train)[2:ncol(train)]){
  params <- coefs %>%
    select(lang.topic, p,d,q) %>%
    filter (lang.topic == topic.i)
  for (i in 1:7){
    CVresults <- tsCV(train[,topic.i], fit, h=i, p = params$p, d = params$d, q= params$q)
    CVmodels[CVmodels$lang.topic == topic.i,i+1] <- sum(CVresults[!is.na(CVresults)]^2)/sum(!is.na(CVresults))
  }
}

# Mean normalized counts
temp <- as.data.frame(round(sapply(train[2:ncol(train)],mean),4)) %>% 
  mutate(lang.topic = rownames(.))
names(temp)[1] <- "avg"

# Write to a CSV
MSEoutput <- left_join(CVmodels,temp)
write.csv(MSEoutput,paste0("Outputs/",db,"_CV_MSE.csv"))

#### Plotting Series ####
library(ggplot2)

plotting <- CVmodels %>% gather(window,perUser,-lang.topic) %>% group_by(lang.topic)

ggplot(plotting %>% filter(lang.topic %in% coefs$lang.topic[1:20]), aes(x=window, y=perUser)) +
  geom_line(aes(group = lang.topic, color=lang.topic)) + 
  scale_color_discrete() +
  ggtitle(paste("Crossvalidated MSE for Top 20 topics in",db)) +
  ggsave(paste0("Outputs/",db,"-CV_MSE.png"), width = 11, height = 8.5, units = "in")

