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

# Source the Spatial Functions
source("SpatialUtil.R")

meters <- LongLatToUTM(clean$long,clean$lat,11)

topic_meters <- cbind(clean,meters)

## Assigning Topics by user
# Read in topic assignments output from python
clean.topics <- merge_topics(clean, "Topic_Data/")

# Source the Spatial Functions
source("SpatialUtil.R")

# Convert to meters
meters <- LongLatToM(clean.topics$long,clean.topics$lat,epsg)
topic_meters <- cbind(clean.topics,meters)


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
map + geom_count(aes(x = long, y = lat, alpha = .5, color = "red"), data = temp)

# There's a heavy concentration in Downtown LA - likely due to generic posts
# tagged with the location of "Los Angeles"

# See how the top points stack up against the total number of tweets
top_points <- top_points %>% mutate(percent = 100*tweets/sum(tweets))
# The central point is over 10% of the data.

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


#### Multivariate Regression ####
library(dplyr)


# A function to generate test folds
generate_folds <- function(df, k){
  require(dplyr)
  set.seed(12345)
  df %>% mutate(fold = sample.int(k, nrow(df), replace = T))
  
}

# Set aside a 50-50 train/test set
topic_meters <- generate_folds(topic_meters,2)

# Set up a multivariate model
model_predict <- lm(cbind(EW.m,NS.m)~dow_sin+dow_cos+hour_sin+hour_cos+top_topic+topic_prob, 
                    data = topic_meters[topic_meters$fold == 1,])

summary(model_predict)

# The residuals of the model are the differences in lattitude and longitude, 
# respectively. Summing the squares of these values and taking the square root
# provides us with Euclidean Distance.

mean(sqrt(rowSums(model_predict$residuals^2)))/1000

# Error is 13.574km for the training set.

# Predict with the test set!
preds <- predict(model_predict,newdata = topic_meters[topic_meters$fold != 1,])

topic_meters %>% 
  filter(fold != 1) %>% 
  transmute((EW.m-preds[,1])^2, (NS.m-preds[,2])^2) %>%
  rowSums %>% 
  sqrt %>%
  mean(na.rm=T)

# The Eclidean error here is also approximately 13.5km.

plot(x=topic_meters$EW[topic_meters$fold != 1], y=topic_meters$NS[topic_meters$fold != 1], col='red')
points(preds)

# Everything is underestimated towards the center, no doubt due to the high
# concentration of points there.

clean %>% 
  filter(geo_point %in% top_points$geo_point[1:10]) %>%
  group_by(geo_point,source) %>% 
  count() %>%
  arrange(desc(n)) %>%
  mutate(percent = round(100*n/nrow(clean),2)) %>% head(10)



clean %>% 
  group_by(source)%>%
  count() %>%
  arrange(desc(n)) %>%
  mutate(percent = 100*n/sum(n))

# All of the top points come from Instagram - which accounts for 88.6 percent of
# all geo-tagged tweets!

# remodel, ignoring the top point

model_no_center <- lm(cbind(EW.m,NS.m)~dow_sin+dow_cos+hour_sin+hour_cos+top_topic+topic_prob, 
                      data = topic_meters[topic_meters$fold == 1 & 
                                            topic_meters$geo_point != top_points$geo_point[1],]
                      )

summary(model_no_center)

mean(sqrt(rowSums(model_no_center$residuals^2)))

# Error is 14.386km for the training set.

# Predict with the test set!
preds <- predict(model_no_center,newdata = topic_meters[topic_meters$fold != 1 &
                                                          topic_meters$geo_point != top_points$geo_point[1],])

topic_meters %>% 
  filter(fold != 1,
         geo_point != top_points$geo_point[1]) %>% 
  transmute((EW.m-preds[,1])^2, (NS.m-preds[,2])^2) %>%
  rowSums %>%
  sqrt %>%
  mean(na.rm=T)

# Error is 14.410km for test set.

# Let's try it without Instagram posts
model_no_IG <- lm(cbind(EW.m,NS.m)~dow_sin+dow_cos+hour_sin+hour_cos+lang.topic+topic_prob, 
                      data = topic_meters[topic_meters$fold == 1 & 
                                            topic_meters$source != "Instagram" &
                                            topic_meters$topic_prob >0,]
)

summary(model_no_IG)

mean(sqrt(rowSums(model_no_IG$residuals^2)))

# Error is 16.58km for the training set.

# Predict with the test set!
preds <- predict(model_no_IG,newdata = topic_meters[topic_meters$fold != 1 &
                                                          topic_meters$source != "Instagram",])

topic_meters %>% 
  filter(fold != 1,
         source != "Instagram") %>% 
  transmute((EW.m-preds[,1])^2, (NS.m-preds[,2])^2) %>%
  rowSums %>%
  sqrt %>%
  mean(na.rm=T)

# Training data error is also 16.58km

# Residuals vs. Fitted Values
plot(rstudent(model_no_IG)[,'EW']~model_no_IG$fitted.values[,'EW'])
plot(rstudent(model_no_IG)[,'NS']~model_no_IG$fitted.values[,'NS'])
# These don't have a constant variance at all....


# Remove topics
model_no_IG_topics <- lm(cbind(EW.m,NS.m)~dow_sin+dow_cos+hour_sin+hour_cos, 
                  data = topic_meters[topic_meters$fold == 1 & 
                                        topic_meters$source != "Instagram" &
                                        topic_meters$topic_prob >0,]
)

summary(model_no_IG_topics)

mean(sqrt(rowSums(model_no_IG_topics$residuals^2)))

# Error is 16.58km for the training set.

# Predict with the test set!
preds <- predict(model_no_IG_topics,newdata = topic_meters[topic_meters$fold != 1 &
                                                      topic_meters$source != "Instagram",])

topic_meters %>% 
  filter(fold != 1,
         source != "Instagram") %>% 
  transmute((EW-preds[,1])^2, (NS-preds[,2])^2) %>%
  rowSums %>%
  sqrt %>%
  mean

anova(model_no_IG_topics,model_no_IG)
# But the ANOVA shows that the model with the topics/probability is
# statistically significant!


#### Multivariate Random Forests ####
library(MultivariateRandomForest)
library(dplyr)

# This threw an error....
mvrf.test <- build_forest_predict(topic_meters %>% 
                                  filter(fold == 1, source != "Instagram") %>%
                                  select(text_lang,user_lang,source,weekend,hour,day,top_topic,topic_prob),
                                topic_meters %>% 
                                  filter(fold == 1, source != "Instagram") %>%
                                  select(EW, NS),
                                n_tree = 500, m_feature = round(sqrt(8)),min_leaf=9,
                                topic_meters %>% 
                                  filter(fold != 1, source != "Instagram") %>%
                                  select(text_lang,user_lang,source,weekend,hour,day,top_topic,topic_prob))


# cforest also allows for multivariate response.
library(partykit)

cforest.test <- cforest(cbind(EW,NS)~text_lang+user_lang+source+weekend+hour+day+top_topic+topic_prob, 
                        data = topic_meters[topic_meters$fold == 1 & 
                                              topic_meters$source != "Instagram",],
                        ntree = 500, trace = T)
