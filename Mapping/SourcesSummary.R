#### Plotting Sources ####

getSources <- function(db){
  require(dplyr)
  # Create connection to the RDS instance
  con <- connectDB(tolower(db))

  # Get the raw count of items, as well as the aggregate count, grouped by location

  getdata = dbGetQuery(con, "SELECT source
                       FROM geometries_filter")
  getdata <- getdata %>%
    mutate(source = gsub(pattern = "<.+\">|</a>", "",source),
           city = db)

  # Disconnect
  disconnectDB(con)
  return(getdata)
}

source("IST_meta.R")
IST <- getSources(db)

source("CHI_meta.R")
CHI <- getSources(db)

source("LAX_meta.R")
LAX <- getSources(db)

allsources <- rbind(IST, CHI, LAX)

counts <- allsources %>%
  mutate(source = recode(source,
                        Instagram = "Instagram",
                        Foursquare = "Foursquare",
                        .default = "Other")) %>%
  group_by(source, city) %>%
  summarize(value = n())
counts$source <- factor(counts$source, levels = c('Other', 'Foursquare', 'Instagram'))
counts$city[counts$city == "LA"] <- "Los Angeles"

library(ggplot2)
library(RColorBrewer)
ggplot(counts,
       aes(city)) +
  geom_bar(stat="identity", aes(y = value/100000,
                                fill= source)) +
  labs(y = "Tweets (100,000)") +
  scale_fill_manual(values = rev(brewer.pal(3,"Set1")),name ="",
                    breaks = c("Instagram", "Foursquare","Other")) +
  theme(legend.position = "none", legend.box.margin = margin(0,0,0,0),
        axis.title.x = element_blank(),
        plot.margin = margin(0,10,10,10),
        axis.text.x = element_text(size = 21))+
  ggsave(paste0("Outputs/NewSources_nolegend.png"), width = 9.1198, height = 8.156, units = "in")

ggplot(counts,
       aes(city)) +
  geom_bar(stat="identity", aes(y = value/100000,
                                fill= source)) +
  labs(y = "Tweets (100,000)") +
  scale_fill_manual(values = rev(brewer.pal(3,"Set1")),name ="",
                    breaks = c("Instagram", "Foursquare","Other")) +
  theme(legend.position = "bottom", legend.box.margin = margin(0,0,0,0),
        axis.title.x = element_blank(),
        plot.margin = margin(0,10,10,10),
        axis.text.x = element_text(size = 21))+
  ggsave(paste0("Outputs/NewSources.png"), width = 9.1198, height = 8.156, units = "in")


#### LA by Day by Hour ####
library(ggmap)

source("LAX_meta.R")

con <- connectDB(tolower(db))

LA.all <- dbGetQuery(con,
                     "SELECT *
                     FROM geometries_filter")
disconnectDB(con)


#### Clean and Merge the Data ####
library(dplyr)
library(readr)

# Tidy and assign additional variables
LA.clean <- merge_langs(LA.all)


## Assigning Topics by user
# Read in topic assignments output from python
clean.topics <- merge_topics(LA.clean, paste0("Topic_Data/",csv))

top_langs <- clean.topics %>% group_by(lang.topic) %>%
  count() %>%
  mutate(percent = round(100*n/nrow(clean.topics),2)) %>%
  arrange(desc(percent))

# Source the Spatial Functions
source("SpatialUtil.R")

# Convert to meters
meters <- LongLatToM(clean.topics$long,clean.topics$lat,epsg)
topic_meters <- cbind(clean.topics,meters)

LAX.map <- ggmap(get_map(location = bbox, source = "stamen", maptype="toner", color = "bw")) +
  theme(axis.text.x = element_blank(),
        axis.title.x = element_blank(),
        axis.text.y = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks = element_blank())

map <- LAX.map
grid.points <- findN(map,200,epsg)
# Density plot with all points for top 6 languages
map + scale_color_brewer(palette = "Set1", name ="Topics") +
  geom_density2d(aes(x = long, y = lat, color = lang.topic), alpha = .5,
                 n = grid.points,
                 data = clean.topics %>% filter(source != "Instagram",
                                                lang.topic %in% top_langs$lang.topic[1:6])) +
  facet_grid(day ~ hour.cut) +
  theme(legend.position = "bottom", legend.box = "horizontal",
        legend.box.margin = margin(0,0,0,0),
        plot.margin = margin(0,10,10,10)) +
  ggsave(paste0("Outputs/",db,"-TopicDensity_DayHour_NEW.png"), width = 6.4808, height = 8.0727, units = "in")
