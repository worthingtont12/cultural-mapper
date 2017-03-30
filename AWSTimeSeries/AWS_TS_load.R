

#### Get the City Data ####
# Load in the helper functions
source("Postgres_functions.R")
source("SpatialUtil.R")

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

# Top topics, by count
top_topics <- clean.topics %>%
  group_by(lang.topic) %>% 
  filter(!is.na(lang.topic)) %>%
  count() %>%
  arrange(desc(n))

#### Smoothing and ARIMA modeling ####
library(forecast)

# Apply 7-day rolling average
counts_filtered <- apply(counts[,-1],2, stats::filter, rep(1/7,7))

# Rebind to dates
counts_filtered <- cbind(counts$date, as.data.frame(counts_filtered))

# ic can be aicc, aic, or bic.
arimaTrace <- function(data, ic = "aicc"){
  require(forecast)
  require(dplyr)
  out <- capture.output({
    fit <- auto.arima(data,ic=ic,trace=T,,stepwise = F, parallel = T)
  })
  fit$trace <- read.table(t <- textConnection(out), sep=":", col.names = c("model",ic)) %>% arrange(AIC)
  close(t)
  fit
}

# Apply to all the columns, save the date
models <- apply(counts[,-1], 2, arimaTrace)

# Apply to the smoothed version
smooth.models <- apply(counts_filtered[,-1], 2, arimaTrace)


extract_coefs <- function(models){
  coefs <- as.data.frame(matrix(NA, nrow = length(names(models)), ncol = 12))
  names(coefs) <- c("topic", "p","d","q","ar1","ar2","ar3","ar4","ma1","ma2","ma3","ma4")
  coefs$topic <- names(models)
  for (i in 1:length(models)){
    coefs$ar1[i] <- models[[i]][[1]]["ar1"]
    coefs$ar2[i] <- models[[i]][[1]]["ar2"]
    coefs$ar3[i] <- models[[i]][[1]]["ar3"]
    coefs$ar4[i] <- models[[i]][[1]]["ar4"]
    coefs$ma1[i] <- models[[i]][[1]]["ma1"]
    coefs$ma2[i] <- models[[i]][[1]]["ma2"]
    coefs$ma3[i] <- models[[i]][[1]]["ma3"]
    coefs$ma4[i] <- models[[i]][[1]]["ma4"]
    coefs$p[i] <- models[[i]][["arma"]][1]
    coefs$d[i] <- models[[i]][["arma"]][6]
    coefs$q[i] <- models[[i]][["arma"]][2]
  }
  coefs
}

coefs <- extract_coefs(models)
smooth.coefs <- extract_coefs(smooth.models)

# Write the outputs to CSV
write.csv(coefs,paste0("Outputs/",db,"_model_coefficients.csv"))
write.csv(smooth.coefs,paste0("Outputs/",db,"_smooth_model_coefficients.csv"))


#### Correlation Clustering ####
library(ggplot2)
library(forecast)

# find the number of unique users by language
unique.users <- clean.topics %>% 
  group_by(lang.topic) %>%
  filter(!is.na(lang.topic)) %>%
  mutate(users = length(unique(user_id))) %>%
  select(lang.topic, users) %>% 
  unique %>%
  arrange(desc(users))

# Top topics, by count
top_topics <- clean.topics %>%
  group_by(lang.topic) %>% 
  count() %>%
  arrange(desc(n))
# Summarize the count by topic, by day
count.TopicDay <- clean.topics %>%
  mutate(day = wday(tzone, label = T)) %>%
  group_by(lang.topic, day, time = as.Date(tzone)) %>%
  tally() %>%
  ungroup %>%
  group_by(lang.topic, day) %>%
  summarise(avg = mean(n))

# Sample cross-correlation plot; 0 is significant, so just use straight correlation
# autoplot(Ccf(counts$`Topic 0 - English`, counts$`Topic 1 - English`))

# Initialize a Data Frame to hold the correlations
corrs <- as.data.frame(matrix(0, nrow = ncol(counts)-1, ncol(counts)))
names(corrs) <- c("topic",names(counts)[-1])

# Insert the correlations (i.e. lag 0) into the above
for (i in 2:ncol(counts)){
  corrs[i-1,1] <- names(counts)[i]
  for (j in 2:ncol(counts)){
    corrs[i-1,j] <- cor(counts[[i]],counts[[j]])
  }
}

# Insert 0's for NA values
corrs[is.na(corrs)] <- 0

dissim <- 1-corrs[,-1]
# Create clusters using the correlations as the distance metric
clusters <- hclust(as.dist(dissim))
plot(clusters,  labels = corrs$topic)

# Five clusters
clust <- cutree(clusters, k =5)
write.csv(clust,paste0("Outputs/",db,"AllTopics_5Clusters.csv"))


library(sparcl)
# colors the leaves of a dendrogram
png(paste0("Outputs/",db,"-AllTopicsDendrogram.png"),width = 11, height = 8.5, units = "in", res = 300)
ColorDendrogram(clusters, y = clust, labels = names(clust),
                main = paste("Dendrogram of Topics in",db),
                xlab = "Topics", sub = "",
                branchlength = .2)
dev.off()

# Normalizing tweets per user
tweetcount <- clean.topics %>% 
  mutate(date = as.Date(date,"%d %b %Y")) %>%
  #filter(!(lang.topic %in% registry$language)) %>%
  filter(!is.na(lang.topic)) %>%
  group_by(date, lang.topic) %>% count

activityPerUser <- left_join(tweetcount,unique.users, by ="lang.topic") %>% 
  rename(tweets = n ) %>%
  mutate(PerUser = tweets/users) %>%
  select(date, lang.topic, PerUser)

activityPerUser <- activityPerUser %>%
  spread(lang.topic,PerUser) %>%
  arrange(date)

# Initialize the Data Frame
corrs.norm <- as.data.frame(matrix(0, nrow = ncol(activityPerUser)-1, ncol(activityPerUser)))
names(corrs.norm) <- c("topic",names(activityPerUser)[-1])

# Insert the correlations (i.e. lag 0)
for (i in 2:ncol(activityPerUser)){
  corrs.norm[i-1,1] <- names(activityPerUser)[i]
  for (j in 2:ncol(activityPerUser)){
    corrs.norm[i-1,j] <- cor(activityPerUser[[i]],activityPerUser[[j]])
  }
}

corrs.norm[is.na(corrs.norm)] <- 0

dissim <- 1-corrs.norm[,-1]
# Create clusters using the correlations as the distance metric
clusters2 <- hclust(as.dist(dissim))
plot(clusters2,  labels = corrs.norm$topic)

# Five clusters
norm.clust <- cutree(clusters2, k =5)

png(paste0("Outputs/",db,"-AllTopicsNormDendrogram.png"),width = 11, height = 8.5, units = "in", res = 300)
# colors the leaves of a dendrogram
ColorDendrogram(clusters2, y = norm.clust, labels = names(norm.clust),
                main = paste("Dendrogram of in",db),
                xlab = "Topics", sub = "",
                branchlength = .2)
dev.off()

#### Dendrograms for top 10 Topics  ####

tweetcount <- clean.topics %>% 
  mutate(date = as.Date(date,"%d %b %Y")) %>%
  filter(lang.topic %in% top_topics$lang.topic[1:20]) %>%
  filter(!is.na(lang.topic)) %>%
  group_by(date, lang.topic) %>% count

activityPerUser <- left_join(tweetcount,unique.users, by ="lang.topic") %>% 
  rename(tweets = n ) %>%
  mutate(PerUser = tweets/users) %>%
  select(date, lang.topic, PerUser)

activityPerUser <- activityPerUser %>%
  spread(lang.topic,PerUser) %>%
  arrange(date)

tweetcount <- tweetcount %>%
  spread(lang.topic,n) %>%
  arrange(date)



# Initialize a Data Frame to hold the correlations
corrs <- as.data.frame(matrix(0, nrow = ncol(tweetcount)-1, ncol(tweetcount)))
names(corrs) <- c("topic",names(tweetcount)[-1])

# Insert the correlations (i.e. lag 0) into the above
for (i in 2:ncol(tweetcount)){
  corrs[i-1,1] <- names(tweetcount)[i]
  for (j in 2:ncol(tweetcount)){
    corrs[i-1,j] <- cor(tweetcount[[i]],tweetcount[[j]])
  }
}

# Insert 0's for NA values
corrs[is.na(corrs)] <- 0

dissim <- 1-corrs[,-1]
# Create clusters using the correlations as the distance metric
clusters <- hclust(as.dist(dissim))
plot(clusters,  labels = corrs$topic)

# Five clusters
clust <- cutree(clusters, k =5)
write.csv(clust,paste0("Outputs/",db,"Top20Topics_5Clusters.csv"))


library(sparcl)
# colors the leaves of a dendrogram
png(paste0("Outputs/",db,"-Top20TopicsDendrogram.png"),width = 11, height = 8.5, units = "in", res = 300)
ColorDendrogram(clusters, y = clust, labels = names(clust),
                main = paste("Dendrogram of Top 20 Topics in",db),
                xlab = "Topics", sub = "",
                branchlength = .2)
dev.off()
# Initialize the Data Frame
corrs.norm <- as.data.frame(matrix(0, nrow = ncol(activityPerUser)-1, ncol(activityPerUser)))
names(corrs.norm) <- c("topic",names(activityPerUser)[-1])

# Insert the correlations (i.e. lag 0)
for (i in 2:ncol(activityPerUser)){
  corrs.norm[i-1,1] <- names(activityPerUser)[i]
  for (j in 2:ncol(activityPerUser)){
    corrs.norm[i-1,j] <- cor(activityPerUser[[i]],activityPerUser[[j]])
  }
}

corrs.norm[is.na(corrs.norm)] <- 0

dissim <- 1-corrs.norm[,-1]
# Create clusters using the correlations as the distance metric
clusters2 <- hclust(as.dist(dissim))
plot(clusters2,  labels = corrs.norm$topic)

# Five clusters
norm.clust <- cutree(clusters2, k =5)

png(paste0("Outputs/",db,"-Top20TopicsNormDendrogram.png"),width = 11, height = 8.5, units = "in", res = 300)
# colors the leaves of a dendrogram
ColorDendrogram(clusters2, y = norm.clust, labels = names(norm.clust), 
                main = paste("Dendrogram of Top 20 Topics in",db),
                xlab = "Topics", sub = "",
                branchlength = .2)
dev.off()



#### Daily Counts & Plots thereof ####

# library(ggplot2)
# library(dplyr)
# library(tidyr)
# library(lubridate)
# 
# # find the number of unique users by language
# unique.users <- clean.topics %>% 
#   group_by(lang.topic) %>%
#   filter(!is.na(lang.topic)) %>%
#   mutate(users = length(unique(user_id))) %>%
#   select(lang.topic, users) %>% 
#   unique %>%
#   arrange(desc(users))
# 
# # Summarize the count by topic, by day
# count.TopicDay <- clean.topics %>%
#   mutate(day = wday(tzone, label = T)) %>%
#   group_by(lang.topic, day, time = as.Date(tzone)) %>%
#   tally() %>%
#   ungroup %>%
#   group_by(lang.topic, day) %>%
#   summarise(avg = mean(n))
# 
# # Normalize daily averages by the number of users within each topic
# PerUser <- left_join(count.TopicDay, unique.users, on = lang.topic) %>%
#   mutate(avgPerUser = avg/users)
# 
# # Plot of top 10 topics
# PerUser %>% 
#   filter(lang.topic %in% top_topics$lang.topic[1:10]) %>%
#   ggplot(aes(x=day, y = avgPerUser, color = lang.topic, group = lang.topic)) + 
#   geom_line() + 
#   ggtitle(paste("Average Tweets per User in",db,"by Day"))  + 
#   theme(legend.position = "bottom", legend.box = "horizontal") #+ 
#   ggsave(paste0("Outputs/",db,"-TopicDensity_DayHourALL.png"), width = 11, height = 8.5, units = "in")
#   
# 
# PerUser %>% 
#   filter(lang.topic %in% top_topics$lang.topic[15:20]) %>%
#   ggplot(aes(x=day, y = avgPerUser, color = lang.topic, group = lang.topic))+ geom_line()
# 
# 
# # Plot of top 6 topics
# count.TopicDay %>%
#   filter(lang.topic %in% top_topics$lang.topic[1:6]) %>%
#   ggplot(aes(x=day, y = avg, color = lang.topic, group = lang.topic)) +
#   scale_color_discrete() +
#   geom_line()
# 
# count.TopicDay %>%
#   filter(lang.topic %in% top_topics$lang.topic[15:20]) %>%
#   ggplot(aes(x=day, y = avg, color = lang.topic, group = lang.topic)) +
#   scale_color_discrete() +
#   geom_line()