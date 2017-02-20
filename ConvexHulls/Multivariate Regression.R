# filter out the geo-tagged tweets that are not topic modelled (these are
# filtered out by the python scripts)

topics_merged_clean <- topics_merged %>%
  filter(!is.na(user_language))

# Set the seed, to create the training indices (reproducably)
set.seed(12345)
train <- sample.int(nrow(topics_merged_clean),nrow(topics_merged_clean)/2)

train

# Need to project the coordinates for distance purposes...
require(rgdal)
require(sp)
# http://spatialreference.org/ref/epsg/3497/
# H/T: http://stackoverflow.com/questions/18639967/converting-latitude-and-longitude-points-to-utm

LongLatToUTM<-function(x,y,zone){
  xy <- data.frame(ID = 1:length(x), EW = x, NS = y)
  coordinates(xy) <- c("EW", "NS")
  proj4string(xy) <- CRS("+proj=longlat +datum=WGS84")  ## for example
  res <- spTransform(xy, CRS(paste("+proj=utm +zone=",zone," ellps=WGS84",sep='')))
  return(as.data.frame(res))
}

meters <- LongLatToUTM(topics_merged_clean$long,topics_merged_clean$lat,11)

topic_meters <- cbind(topics_merged_clean,meters[,2:3])

# Create a model on 50% of the data


generate_folds <- function(df, k){
  require(dplyr)
  set.seed(12345)
  df %>% mutate(fold = sample.int(k, nrow(df), replace = T))
  
}

topic_meters <- generate_folds(topic_meters,2)


model_predict <- lm(cbind(EW,NS)~as.factor(day)+as.factor(hour)+top_topic+topic_prob, 
                    data = topic_meters[topic_meters$fold == 1,])

summary(model_predict)

# Predict with the test set!
preds <- predict(model_predict,newdata = topic_meters[topic_meters$fold != 1,])

plot(x=topic_meters$EW[topic_meters$fold != 1], y=topic_meters$NS[topic_meters$fold != 1], col='red')
points(model_predict$fitted.values)



# From the R help:
by_cyl <- mtcars %>% group_by(cyl)


# Since by_cly is grouped by cylinder, it runs models for each level! Neat!
models <- by_cyl %>% do(
  mod_linear = lm(mpg ~ disp, data = .),
  mod_quad = lm(mpg ~ poly(disp, 2), data = .)
)


compare <- models %>% do(aov = anova(.$mod_linear, .$mod_quad))
compare %>% summarise(p.value = aov$`Pr(>F)`)
