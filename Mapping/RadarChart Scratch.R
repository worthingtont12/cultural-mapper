library(dplyr)
library(tidyr)

test.plot <- clean.topics %>%
  filter(lang.topic %in% top_langs$lang.topic[1:20]) %>%
  group_by(lang.topic, day, time = as.Date(tz)) %>% 
  tally() %>%
  ungroup %>%
  group_by(lang.topic, day) %>%
  summarise(avg = log(mean(n)))

library(ggplot2)
test.plot %>% ggplot(aes(x=day, y = avg, color = lang.topic, group = lang.topic))+ geom_line() + coord_polar()
test.plot2 <- test.plot %>%
  ungroup %>%
  spread(lang.topic, avg)
library(radarchart)

chartJSRadar(test.plot2, showToolTipLabel = T)

# devtools::install_github("ricardo-bion/ggradar", 
#                          dependencies=TRUE)
library(ggradar)



rownames(test.plot2) <- test.plot2$lang.topic
  select(-lang.topic)
ggradar(test.plot2, 
        font.radar = "Helvetica",
        grid.max = round(max(test.plot2))+1)
