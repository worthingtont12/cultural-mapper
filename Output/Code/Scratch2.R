install.packages("dygraphs")
install.packages("xts")
library(dygraphs)
library(xts)
lungDeaths <- cbind(mdeaths, fdeaths)


dygraph(lungDeaths) %>% dyRangeSelector()


temp <- paste0(substr(la_geo$created_at, 12, 15), "0")
temp <- paste0(as.Date(la_geo$created_at, format='%a %b %d'), " ", temp, ":00")
the_data <- data.frame(table(tweets$threeMins))
the_data$Var1<-as.POSIXct(as.character(the_data$Var1))
the_xts<-xts(the_data[,2], order.by=the_data[,1])
colnames(the_xts)[1] <- "Tweets"
dygraph(the_xts)


library(tidyr)

la_geo$rounded <- round(la_geo$created_at, units = 'hours')
head(la_geo)

geo_filter <- la_geo
geo_filter$rounded <- as.character.Date(geo_filter$rounded)
Lang_sum <- geo_filter %>%
  group_by(language, rounded) %>%
  summarise(count=n()) %>%
  spread(language,count, fill = 0) %>%
  arrange(rounded)
Lang_sum$rounded <- as.POSIXct(Lang_sum$rounded)
names(Lang_sum[-1])



location_map <- function(geo_filter, threshold = 100){
  require(dplyr)
  require(tidyr)
  geo_filter$rounded <- as.character.Date(geo_filter$rounded)
  Lang_sum <- geo_filter %>%
    group_by(language, rounded) %>%
    summarise(count=n()) %>%
    spread(language,count, fill = 0) %>%
    arrange(rounded)
  Lang_sum$rounded <- as.POSIXct(Lang_sum$rounded)
  volume <- colSums(Lang_sum[,-1])
  languages <- names(volume[volume > threshold])
  the_xts<-xts(Lang_sum[,-1], order.by=Lang_sum$rounded)
  
  #require(colorspace)
  require(RColorBrewer)
  require(leaflet)
  #colors <- rainbow_hcl(length(languages$language))
  colors <- brewer.pal(nrow(languages),"Set3")
  
  
  
  pal <- colorFactor(colors, domain = unique(languages$language))
  
  subset <- geo_filter[geo_filter$language %in% languages$language,]
  
  map <- leaflet() %>%
    addProviderTiles("CartoDB.Positron") %>%
    addCircleMarkers(lng=subset$long,
                     lat=subset$lat,
                     color = pal(subset$language),
                     radius = 5,
                     stroke = FALSE, fillOpacity = .5,
                     popup = paste0(subset$created_at,
                                    "<br>",
                                    subset$language),
                     group = subset$language
    ) %>%
    addLegend("bottomright", pal = pal, values = languages$language,
              title = "Languages",
              opacity = 1) %>% 
    addLayersControl(
      overlayGroups = unique(languages$language),
      options = layersControlOptions(collapsed = TRUE),
      position = 'topleft'
    ) %>% hideGroup(c("English","Unknown"))
  
  return(map)
  
}


temp <- list(x = lungDeaths , y = languages)


dygraph(the_xts) %>%
  dyOptions(colors = RColorBrewer::brewer.pal(32,"Paired")) %>%
  dyHighlight(highlightSeriesBackgroundAlpha = .2, highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyRoller(rollPeriod = 6) %>%
  dyRangeSelector()
