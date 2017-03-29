library(dplyr)

# Create Topic count without NAs
topic_count_clean <-topics_merged_clean %>%
  filter(!is.na(top_topic)) %>%
  group_by(top_topic) %>% count()

summary(topic_count_clean$n) # 3292

# SD w/o majority class
sd(topic_count_clean$n[topic_count_clean$top_topic != 0]) #1720



topics_merged_clean %>% 
  filter(!is.na(top_topic)) %>%
  select(-c(3,4)) %>% head

# Oversample classes 

library(smotefamily)

test <- SMOTE(topics_merged_clean %>% 
        filter(!is.na(top_topic)) %>%
        select(c(5,6,8)), topics_merged_clean$top_topic[!is.na(topics_merged_clean$top_topic)],
      K = 5, dup_size = 200)
