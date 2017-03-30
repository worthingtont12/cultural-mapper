#### Daily Counts & Plots thereof ####

library(ggplot2)
library(dplyr)
library(tidyr)
library(lubridate)


loc.clusters <- read.csv("Outputs/ChicagoTop20Topics_5Clusters.csv")
names(loc.clusters) <- c("lang.topic","cluster")

# find the number of unique users by language
unique.users <- clean.topics %>%
  group_by(lang.topic) %>%
  filter(!is.na(lang.topic)) %>%
  mutate(users = length(unique(user_id))) %>%
  select(lang.topic, users) %>%
  unique %>%
  arrange(desc(users))

# Summarize the count by topic, by day
count.TopicDay <- clean.topics %>%
  mutate(day = wday(tzone, label = T)) %>%
  group_by(lang.topic, day, time = as.Date(tzone)) %>%
  tally() %>%
  ungroup %>%
  group_by(lang.topic, day) %>%
  summarise(avg = mean(n))

# Normalize daily averages by the number of users within each topic
PerUser <- left_join(count.TopicDay, unique.users, on = lang.topic) %>%
  mutate(avgPerUser = avg/users)

# Plot of top 10 topics
PerUser %>%
  filter(lang.topic %in% top_topics$lang.topic[1:10]) %>%
  ggplot(aes(x=day, y = avgPerUser, color = lang.topic, group = lang.topic)) +
  geom_line() +
  ggtitle(paste("Average Tweets per User in",db,"by Day"))  +
  theme(legend.position = "bottom", legend.box = "horizontal") #+
  ggsave(paste0("Outputs/",db,"-TopicDensity_DayHourALL.png"), width = 11, height = 8.5, units = "in")


PerUser %>%
  filter(lang.topic %in% top_topics$lang.topic[15:20]) %>%
  ggplot(aes(x=day, y = avgPerUser, color = lang.topic, group = lang.topic))+ geom_line()


# Plot of top 6 topics
count.TopicDay %>%
  filter(lang.topic %in% top_topics$lang.topic[1:6]) %>%
  ggplot(aes(x=day, y = avg, color = lang.topic, group = lang.topic)) +
  scale_color_discrete() +
  geom_line()

count.TopicDay %>%
  filter(lang.topic %in% top_topics$lang.topic[15:20]) %>%
  ggplot(aes(x=day, y = avg, color = lang.topic, group = lang.topic)) +
  scale_color_discrete() +
  geom_line()