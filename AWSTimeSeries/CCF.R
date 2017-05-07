library(forecast)

# Initialize the Data Frame
df <- as.data.frame(matrix(NA, nrow = ncol(counts)-1, ncol(counts)))
names(df) <- c("topic",names(counts)[-1])

# Insert the correlations (i.e. lag 0)
for (i in 2:ncol(counts)){
  df[i-1,1] <- names(counts)[i]
  for (j in 2:ncol(counts)){
    df[i-1,j] <- cor(counts[[i]],counts[[j]])
  }
}

# Create clusters using the correlations as the distance metric
clusters <- hclust(as.dist(df[,-1]))
plot(clusters,  labels = df[,1])

# Five clusters
clust <- cutree(clusters, k =5)

# install.packages('sparcl')
library(sparcl)
# colors the leaves of a dendrogram
y = cutree(clusters, k = 5)
ColorDendrogram(clusters, y = y, labels = names(y), main = "Dendrogram of Languages",
                xlab = "Topics", sub = "",
                branchlength = .2)

# Working on normalizing tweets per user
tweetcount <- clean.topics %>% 
  mutate(date = as.Date(date,"%d %b %Y")) %>%
  filter(!(lang.topic %in% registry$language)) %>%
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
df2 <- as.data.frame(matrix(NA, nrow = ncol(activityPerUser)-1, ncol(activityPerUser)))
names(df2) <- c("topic",names(activityPerUser)[-1])

# Insert the correlations (i.e. lag 0)
for (i in 2:ncol(activityPerUser)){
  df2[i-1,1] <- names(activityPerUser)[i]
  for (j in 2:ncol(activityPerUser)){
    df2[i-1,j] <- cor(activityPerUser[[i]],activityPerUser[[j]])
  }
}

# Create clusters using the correlations as the distance metric
clusters2 <- hclust(as.dist(df2[,-1]))
plot(clusters2,  labels = df2[,1])

# Five clusters
norm.clust <- cutree(clusters2, k =5)

# install.packages('sparcl')
library(sparcl)
# colors the leaves of a dendrogram
y2 = cutree(clusters2, k = 5)
ColorDendrogram(clusters, y = y2, labels = names(y), main = "Dendrogram of Top 20 Topics in Istanbul",
                xlab = "Topics", sub = "",
                branchlength = .2)

# Are they similar?
rbind(clust, norm.clust)

par(mfrow=c(2,1))
plot(clusters2,  labels = df2[,1])
plot(clusters,  labels = df[,1])


png()
plot(clusters,  labels = df[,1])
dev.off()
