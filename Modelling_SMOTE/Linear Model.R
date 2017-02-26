head(model_predict$residuals)
head(model_predict$model)
head(topic_meters[topic_meters$fold ==1,])
head(model_predict$fitted.values)

# 
temp <- model_predict$model[0:1]


topic_meters[5,c('EW','NS')]-temp[1,1]

temp <- model_predict$fitted.values

topic_meters[5,c('EW','NS')]-temp[1,]

model_predict$residuals[1]
# So this is the distance in X, Y - square both, sum, and sqrt for distance!

temp <- model_predict$residuals[1:2,]



library(ggplot2)
library(ggmap)
library(maps)
library(dplyr)
map + scale_color_brewer(palette = "Set1") +
  geom_point(aes(x = long, y = lat, color = as.factor(top_topic), alpha = .05),
             data = topic_meters %>% filter(top_topic %in% 0:8))

map + stat_density2d(aes(x = long, y = lat, fill = ..level..),
                     data = topic_meters)




topic_meters[5,]
round(topic_meters[5,'tz'], units='hours')$hour