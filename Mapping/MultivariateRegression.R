#### Multivariate Regression Test - Predict location by Topic and Time ####


# filter out the geo-tagged tweets that are not topic modeled (these are
# filtered out by the python scripts)

topics_merged_clean <- topics_merged %>%
  filter(!is.na(user_language))

# Set the seed, to create the training indices (reproducably)
set.seed(12345)
train <- sample.int(nrow(topics_merged_clean),nrow(topics_merged_clean)/2)


# Need to project the coordinates for distance purposes...
source('../Helpers/SpatialUtil.R')

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


head(model_predict$residuals)
head(model_predict$model)
head(topic_meters[topic_meters$fold ==1,])
head(model_predict$fitted.values)

#
temp <- model_predict$model[0:1]


topic_meters[6,c('EW','NS')]-temp[2,1]

temp <- model_predict$fitted.values

topic_meters[5,c('EW','NS')]-temp[1,]

model_predict$residuals[1:2,]^2
# So this is the distance in X, Y - square both, sum, and sqrt for distance!
