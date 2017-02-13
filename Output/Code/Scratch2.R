#### Scratch ####

# This is equivalent to input$lang
temp <- list("Danish")

# create a filtered list by language - rounded has to be character or CT, not LT
subset <- subset(geo_filter) %>% filter(language %in% temp)#input$lang)



# From https://github.com/rstudio/dygraphs/issues/63
dyVisibility <- function (dygraph, visibility = TRUE){
  dygraph$x$attrs$visibility <- visibility
  dygraph
}

library(tidyr)
library(xts)
library(RColorBrewer)

pal <- brewer.pal(9, "Set1")
pal_sub <- pal[1:length(temp)]


countLang <- function(subset){
  require(dplyr)
  require(xts)
  require(tidyr)
  Lang_sum <- subset %>%
    group_by(language, rounded) %>%
    summarise(count=n()) %>%
    spread(language,count, fill = 0) %>%
    arrange(rounded)
  Lang_sum$rounded <- as.POSIXct(Lang_sum$rounded, tz = zone)
  the_xts<-xts(Lang_sum[,-1], order.by=Lang_sum$rounded, tz = zone)
  
  return(the_xts)
}

geo_filter$rounded <- as.character.Date(geo_filter$rounded)


visible <- names(the_xts) %in% temp

test <- dygraph(the_xts) %>%
  dyOptions(colors = pal_sub,
            logscale = F, connectSeparatedPoints = TRUE,
            useDataTimezone = TRUE,
            retainDateWindow = TRUE) %>%
  dyHighlight(highlightSeriesBackgroundAlpha = .2,
              highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyRoller(rollPeriod = 6) %>%
  dyRangeSelector(dateWindow = c(max(Lang_sum$rounded) - as.difftime(7, units = "days"),
                                 max(Lang_sum$rounded))) %>%
  dyVisibility(visibility=visible)

test
test %>% dyVisibility(visibility=visible)



factpal <- colorFactor(pal_sub, subset$language)

map <- leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addCircleMarkers(lng=subset$long,
                   lat=subset$lat,
                   color = factpal(subset$language),
                   radius = 5,
                   stroke = FALSE, fillOpacity = .5,
                   popup = paste0(subset$created_at,
                                  "<br>",
                                  subset$language),
                   group = subset$language
  ) %>%
  addLegend("bottomright", colors = factpal,
            labels = temp,
            title = "Languages",
            opacity = 1) %>%
  addLayersControl(
    overlayGroups = unique(color$language),
    options = layersControlOptions(collapsed = TRUE),
    position = 'topleft'
  ) %>% hideGroup(c("English","Unknown"))










library(dygraphs)
library(xts)
library(tidyr)

attr(la_geo$created_at, "tzone") <- "America/Los_Angeles"
la_geo$rounded <- round(la_geo$created_at, units = 'hours')
head(la_geo)

geo_filter <- la_geo
geo_filter$rounded <- as.character.Date(geo_filter$rounded)
Lang_sum <- geo_filter %>%
  group_by(language, rounded) %>%
  summarise(count=n()) %>%
  spread(language,count, fill = 0) %>%
  arrange(rounded)
Lang_sum$rounded <- as.POSIXct(Lang_sum$rounded, tz = "America/Los_Angeles")
names(Lang_sum[-1])
volume <- colSums(Lang_sum[,-1])
languages <- names(volume[volume > 100])
the_xts<-xts(Lang_sum[,-1], order.by=Lang_sum$rounded, tz = "America/Los_Angeles")
#indexTZ(the_xts) <- "America/Los_Angeles"



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


dygraph(the_xts,
        main = "Tweets per Hour",
        ylab = "Tweets (log scale)") %>%
  dyLegend(showZeroValues = FALSE) %>%
  dyOptions(colors = color_pal$colors,
            logscale = F,
            useDataTimezone = TRUE,
            connectSeparatedPoints = TRUE) %>%
  dyHighlight(highlightSeriesBackgroundAlpha = .2, highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyRoller(rollPeriod = 6) %>%
  dyRangeSelector()


max(Lang_sum$rounded) - as.difftime(1, units = "days")


library(RColorBrewer)
colors <- c(brewer.pal(35, "Set3"),
            brewer.pal(35, "Set1"),
            brewer.pal(35, "Dark2"),
            "#000000", "#F7F7F7","FFE1FF")

library(jsonlite)
registry <- fromJSON('../../Assets/Langauge.json')
registry <- registry[,1:2]
names(registry) <- c('text_lang', 'language')

language <- unique(registry$language)

color_pal <- as.data.frame(cbind(language, colors))
registry <- merge(registry,color_pal)


temp <- list()
temp$raw <- la_geo
temp$reg <- registry
