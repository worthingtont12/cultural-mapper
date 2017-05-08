#### Explore methods for plotting Daily Averages in a City ####

library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)

# Find the total number of tweets per topic, sorted in descending order.
top_langs <- clean.topics %>%
  group_by(lang.topic) %>%
  count() %>%
  arrange(desc(n))

# Find average tweets per topic, per day of the week
test.plot <- clean.topics %>%
  # Extract the human-readable weekday
  mutate(day = wday(tzone, label = T)) %>%
  # Group Tweets by topic, day of the week and date
  group_by(lang.topic, day, time = as.Date(tzone)) %>%
  # Count tweets per topic, per date
  tally() %>%
  # Ungroup, regroup by topic and day of the week
  ungroup %>%
  group_by(lang.topic, day) %>%
  # Find the mean for each day of the week
  summarise(avg = mean(n))

# Plot of top 6 topics, in polar coordinatesm log-scale.
test.plot %>%
  filter(lang.topic %in% top_topics$lang.topic[1:6]) %>%
  ggplot(aes(x=day, y = avg, color = lang.topic, group = lang.topic)) +
  scale_y_log10()+
  scale_color_discrete() +
  geom_line()# +
  coord_polar()

# Plot of the bottom 6 topics, in polar coordinates, log-scale.
test.plot %>%
  filter(lang.topic %in% top_topics$lang.topic[15:20]) %>%
  ggplot(aes(x=day, y = avg, color = lang.topic, group = lang.topic)) +
  scale_y_log10()+
  scale_color_discrete() +
  geom_line() +
  coord_polar()
