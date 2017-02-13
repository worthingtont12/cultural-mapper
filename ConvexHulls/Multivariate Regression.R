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
# http://spatialreference.org/ref/epsg/3497/

location.meters <- project(cbind(topics_merged_clean$long,
                                 topics_merged_clean$lat),
                           proj = '+init=espg:3497')

# Needs to be in WG84


# Create a model on 50% of the data
model_predict <- lm(cbind(lat,long)~as.factor(day)+as.factor(hour)+top_topic+topic_prob+text_lang, 
                    data = topics_merged_clean, subset = train)

summary(model_predict)

# Predict with the test set!
preds <- predict(model_predict,newdata = test)




# From the R help:
by_cyl <- mtcars %>% group_by(cyl)


# Since by_cly is grouped by cylinder, it runs models for each level! Neat!
models <- by_cyl %>% do(
  mod_linear = lm(mpg ~ disp, data = .),
  mod_quad = lm(mpg ~ poly(disp, 2), data = .)
)


compare <- models %>% do(aov = anova(.$mod_linear, .$mod_quad))
compare %>% summarise(p.value = aov$`Pr(>F)`)
