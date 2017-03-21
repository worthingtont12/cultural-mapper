library(RPostgreSQL)
# Function to connect to the database, 
connectDB <- function(city){
  require(RPostgreSQL)
  # Load in the keys
  source('../ConvexHulls/keys.R')
  # Create DB name, joining city name 
  name = paste("culturalmapper", city, sep = "_")
  pg = dbDriver("PostgreSQL")
  
  # Connect to the database
  con = dbConnect(pg, user = usr,
                  password = pwd,
                  host = hst,
                  port = 5432,
                  dbname = name)
  # Remove the keys
  rm(hst, usr, pwd, envir = .GlobalEnv)
  con
}

# Simple disconnect
disconnectDB <-function(db){
  require(RPostgreSQL)
  dbDisconnect(db)
}

# Load language registry
load_langs <- function(){
  require(jsonlite)
  registry <- fromJSON('../../Cultural_Mapper/Assets/Langauge.json')
  names(registry) <- c('user_lang', 'language')
  registry[1:2]
}

# This function converts degrees to radians for future calculations
deg.to.rad <- function(x){
  rad <- x*(pi/180)
  rad
}


# This function merges data with the language registry, and adds in temporal
# variables.
merge_langs <- function(df){
  require(dplyr)
  require(lubridate)
  require(timeDate)
  
  registry <- load_langs()
  # Merge the language by the users' selected language!
  data_merge <- left_join(df, registry)
  data_merge$language <- as.factor(data_merge$language)
  data_merge %>% mutate(
    weekend = isWeekend(tz), # Weekends
    hour = hour(round(tz, unit='hours')), #Extract the rounded hour of the day.
    day = wday(tz, label = T), # Day of the week
    # Binning the hour into 4-hour widths!
    hour.cut = cut(hour,
                   breaks = c(0,4,8,12,16,20,23),
                   include.lowest = T,
                   right = F,
                   ordered_result = T,
                   labels = c("12am-4am","4am-8am",
                              "8am-12pm","12pm-4pm",
                              "4pm-8pm","8pm-12am"))
    ) %>% mutate(
      # Break apart day and month into sin/cos, which will be used to measure
      # distance later.
      dow_sin = sin(deg.to.rad(as.numeric(day)*(360/7))),
      dow_cos = cos(deg.to.rad(as.numeric(day)*(360/7))),
      hour_sin = sin(deg.to.rad(as.numeric(hour)*(360/24))),
      hour_cos = cos(deg.to.rad(as.numeric(hour)*(360/24))),
      # Clean up the source, removing HTML tags
      source = gsub(pattern = "<.+\">|</a>", "",source)
    )
}





# topics_angluar <- topics_merged_clean %>%
#   select(top_topic,lat,long,day,hour,dow) %>%
#   mutate(
#     dow = dow*(360/7),
#     hour = hour*(360/24)
#   ) %>% transmute(
#     top_topic = as.factor(top_topic),
#     lat = lat,
#     long = long,
#     dow_sin = sin(deg.to.rad(dow)),
#     dow_cos = cos(deg.to.rad(dow)),
#     hour_sin = sin(deg.to.rad(hour)),
#     hour_cos = cos(deg.to.rad(hour))
#   )
# 
# 
# as.numeric(wday(data$tz, label = T))


# A function to create Convex Hulls using ggplot2.
# From http://docs.ggplot2.org/current/vignettes/extending-ggplot2.html
require(ggplot2)
StatChull <- ggproto("StatChull", Stat,
                     compute_group = function(data, scales) {
                       data[chull(data$x, data$y), , drop = FALSE]
                     },
                     
                     required_aes = c("x", "y")
)

stat_chull <- function(mapping = NULL, data = NULL, geom = "polygon",
                       position = "identity", na.rm = FALSE, show.legend = NA, 
                       inherit.aes = TRUE, ...) {
  layer(
    stat = StatChull, data = data, mapping = mapping, geom = geom, 
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}


# This file will read in files from a path!
# H/T: https://www.r-bloggers.com/merging-multiple-data-files-into-one-data-frame/
merge_topics <- function(data, path){
  require(readr)
  require(dplyr)
  # Obtain a list of all files in the path
  filenames <- list.files(path = path, full.names = T)
  # For each file in the above which contains the "db" variable (sourced from the
  # metadata file), insert the csv file into a list.
  data.list <- lapply(filenames[grep(db, filenames)],function(x){read_csv(x)} %>%
                        select(user_id, user_language, top_topic, topic_prob))
  # return all of the topics for a given locale.
  temp.topics <- Reduce(function(x,y){rbind(x,y)},data.list)
  # Remove all columns but those necessary
  temp.topics <- temp.topics %>%
    select(user_id, user_language, top_topic, topic_prob)
  # Join the topics with the data
  temp <- left_join(data, temp.topics, by = "user_id")
  # Create a new feature, "lang.topic", which combines a user's language with
  # the corresponding topic if it exists. If not, returns the user's language.
  temp$lang.topic <- ifelse(is.na(head(temp$user_language,100)), 
                            as.character(temp$language),
                            paste("Topic",temp$top_topic,"-",temp$user_language))
  temp
}
