library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)

top_langs <- clean.topics %>%
  group_by(lang.topic) %>% 
  count() %>%
  arrange(desc(n))

test.plot <- clean.topics %>%
  mutate(day = wday(tzone, label = T)) %>%
  group_by(lang.topic, day, time = as.Date(tzone)) %>%
  tally() %>%
  ungroup %>%
  group_by(lang.topic, day) %>%
  summarise(avg = mean(n))

# Plot of top 6 topics
test.plot %>%
  filter(lang.topic %in% top_topics$lang.topic[1:6]) %>%
  ggplot(aes(x=day, y = avg, color = lang.topic, group = lang.topic)) +
  scale_y_log10()+
  scale_color_discrete() +
  geom_line()# +
  coord_polar()

test.plot %>%
  filter(lang.topic %in% top_topics$lang.topic[15:20]) %>%
  ggplot(aes(x=day, y = avg, color = lang.topic, group = lang.topic)) +
  scale_y_log10()+
  scale_color_discrete() +
  geom_line() +
  coord_polar()


test.plot %>%
  filter(lang.topic %in% top_topics$lang.topic[2]) %>%
  ggplot(aes(x=day, y = avg, color = lang.topic, group = lang.topic)) +
  #scale_y_log10()+
  scale_color_discrete() +
  geom_line() +
  coord_polar()
