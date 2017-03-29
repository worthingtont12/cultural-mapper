library(dplyr)
library(tidyr)
library(lubridate)


unique.users <- clean.topics %>% 
  group_by(lang.topic) %>%
  filter(!is.na(lang.topic)) %>%
  mutate(users = length(unique(user_id))) %>%
  select(lang.topic, users) %>% unique

test.plot2 <- clean.topics %>%
  filter(lang.topic %in% top_langs$lang.topic[1:20]) %>%
  mutate(day = wday(tzone, label = T)) %>%
  group_by(lang.topic, day, time = as.Date(tzone)) %>% 
  count() %>%
  ungroup %>%
  group_by(lang.topic, day) %>%
  summarise(avg = mean(n))

PerUser <- left_join(test.plot2, unique.users, on = lang.topic) %>% mutate(avgPerUser = avg/users)

library(ggplot2)
PerUser %>% 
  filter(lang.topic %in% top_langs$lang.topic[1:10]) %>%
  ggplot(aes(x=day, y = avgPerUser, color = lang.topic, group = lang.topic))+ geom_line()

PerUser %>% 
  filter(lang.topic %in% top_langs$lang.topic[15:20]) %>%
  ggplot(aes(x=day, y = avgPerUser, color = lang.topic, group = lang.topic))+ geom_line()