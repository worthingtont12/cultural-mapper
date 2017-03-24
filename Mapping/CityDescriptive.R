library(dplyr)
library(ggplot2)

# Subset the data, selecting only the points with over 1000 tweets
temp <- subset(data, geo_point %in%
                 (top_points %>% filter(tweets >1000) %>% select(geo_point))[[1]])

# Aggregate by size
map + geom_count(aes(x = long, y = lat), alpha = .5, color = "red", data = temp) + 
  ggtitle(paste("Top Tweet Locations in",db)) + 
  guides(size = guide_legend("Number of Tweets")) + 
  theme(legend.position = "bottom", legend.box = "horizontal") +
  ggsave(paste0("Outputs/",db,"-TopPoints.pdf"), width = 11, height = 8.5, units = "in")

# See how the top points stack up against the total number of tweets
top_points <- top_points %>% mutate(percent = 100*tweets/sum(tweets))

# top 10 points and source
clean %>% 
  filter(geo_point %in% top_points$geo_point[1:10]) %>%
  group_by(geo_point,source) %>% 
  count() %>%
  arrange(desc(n)) %>%
  mutate(percent = round(100*n/nrow(clean),2)) %>% head(10)


# Top sources
clean %>% 
  group_by(source)%>%
  count() %>%
  arrange(desc(n)) %>%
  mutate(percent = round(100*n/sum(n),2))

# Geo count
library(reshape2)
geo_stats_melt <- melt(geo_stats)

ggplot(geo_stats_melt %>% filter(variable %in% c("noGeo","geo")),
       aes(city)) +
  geom_bar(stat="identity", aes(y = value/100000,fill=variable)) + 
  labs(title = "", x = "City", y = "Tweets (100,000)") +
  scale_fill_brewer(palette = "Set1",name ="", labels = c("Geotagged","Not Geotagged"))+ 
  ggsave("Outputs/Geotagged.pdf", width = 11, height = 8.5, units = "in")
# Language Count
ggplot(geo_stats_melt %>% filter(variable %in% c("es","en","tr","other_lang")),
       aes(city)) +
  geom_bar(stat="identity", aes(y = value/100000,fill=variable)) + 
  labs(title = "", x = "City", y = "Tweets (100,000)") +
  scale_fill_brewer(palette = "Set1",name ="", labels = c("English","Spanish",
                                                          "Turkish","Other"))+ 
  ggsave("Outputs/Languages.pdf", width = 11, height = 8.5, units = "in")

# Source Count
ggplot(geo_stats_melt %>% filter(variable %in% c("IG","FS","other_source")),
       aes(city)) +
  geom_bar(stat="identity", aes(y = value/100000,fill=variable)) + 
  labs(title = "", x = "City", y = "Tweets (100,000)") +
  scale_fill_brewer(palette = "Set1",name ="", labels = c("Instagram","Foursquare","Other")) + 
  ggsave(paste0("Outputs/Sources.pdf"), width = 11, height = 8.5, units = "in")

