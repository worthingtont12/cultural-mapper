# Utility to read and clean a CSV
location <- function(file_in, tz, west, south, east, north){
  # Basic Cleaning - to be replaced with RPostgreSQL query!
  require(readr)
  require(jsonlite)
  geo <- read_file(file_in)
  geo <- gsub('\"\"','\"\r\n\"',geo)
  geo <- read_csv(geo)
  
  # Merge human-readable list of Twitter-supported languages. 
  registry <- fromJSON('../../Assets/Langauge.json')
  registry <- registry[,1:2]
  names(registry) <- c('text_lang', 'language')
  
  geo_merge <- merge(geo, registry)
  geo_merge$language <- as.factor(geo_merge$language)
  
  # Convert created_at from UTC to Time zone of Choice
  attr(geo_merge$created_at, "tzone") <- tz
  
  # Filter out tweets eminating from beyond the boundaries
  geo_filter <- geo_merge[geo_merge$long >= west & geo_merge$long<= east &
                             geo_merge$lat >= south & geo_merge$lat<= north,]
  
  # Create feature - Time rounded to the nearest hour
  geo_filter$rounded <- round(geo_filter$created_at, units = 'hours')
  geo_filter$rounded <- as.character.Date(geo_filter$rounded)
  
  
  # colors <- colors()
  # geo_filter <- merge(geo_filter, colors)
  
  geo_center <- list(long = (west+east)/2, lat = (north+south)/2 )
  
  output <- list(zone = tz, data = geo_filter, center = geo_center)
  return(output)
}

# Create Leaflet Maps
location_map <- function(data, pal = brewer.pal(9, "Set1")){
  require(dplyr)
  require(tidyr)
  require(RColorBrewer)
  require(leaflet)
  
  subset <- data$data
  subset$rounded <- NULL
  
  # Lang_sum <- subset %>%
  #   group_by(language, color) %>%
  #   summarise(count=n())
  # 
  # languages <- Lang_sum[Lang_sum$count > threshold,]
  
  # color <- colors()
  palF <- colorFactor(pal,
                     levels = unique(subset$language),
                     ordered = TRUE)
  
  # subset <- geo_filter#[geo_filter$language %in% languages$language,]
  
  map <- leaflet() %>%
    addProviderTiles("CartoDB.Positron") %>%
    addCircleMarkers(lng=subset$long,
               lat=subset$lat,
               color = pal[1],
               radius = 5,
               stroke = FALSE, fillOpacity = .5,
               popup = paste0(subset$created_at,
                              "<br>",
                              subset$language),
               group = subset$language
    ) %>%
    # addLegend("bottomright", colors = unique(subset$color),
    #           labels = unique(subset$language),
    #           title = "Languages",
    #           opacity = 1) %>%
    # addLayersControl(
    #   overlayGroups = unique(subset$language),
    #   options = layersControlOptions(collapsed = TRUE),
    #   position = 'topleft'
    # ) %>%
    hideGroup(unique(subset$language)) %>%
    showGroup(c("Spanish"))
  
  return(map)
  
}

# Create Dygraph Time series.
location_dygraph <-function(data){
  require(dygraphs)
  require(xts)
  require(dplyr)
  require(tidyr)
  require(RColorBrewer)
  geo_filter <- data$data
  zone <- data$zone
  #color_pal <- colors()
  
  # geo_filter$rounded <- as.character.Date(geo_filter$rounded)
  the_xts <- countLang(geo_filter, zone)
  # language <- names(the_xts)
  
  output <- createDygraph(the_xts)
  
  return(output)
  
}


createDygraph <- function(the_xts, pal = brewer.pal(9, "Set1")){
  dygraph(the_xts,
          main = "Tweets per Hour",
          ylab = "Tweets") %>%
    dyLegend(showZeroValues = FALSE) %>%
    dyOptions(colors = pal,
              logscale = F, connectSeparatedPoints = TRUE,
              useDataTimezone = TRUE,
              retainDateWindow = TRUE) %>%
    dyHighlight(highlightSeriesBackgroundAlpha = .2,
                highlightSeriesOpts = list(strokeWidth = 3)) %>%
    dyRoller(rollPeriod = 6) %>%
    dyRangeSelector(dateWindow = c(max(index(the_xts)) - as.difftime(7, units = "days"),
                                   max(index(the_xts)) - as.difftime(6, units = "days")))
}

# Aggregate count by language per rounded hour
countLang <- function(subset, zone){
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





# Outdated Utility reading in IANA languages.
language_reg <- function(){
  library(readr)
  # Read in official IANA language registry
  temp <- read_lines('http://www.iana.org/assignments/language-subtag-registry/language-subtag-registry', skip = 2)
  
  # Create a data frame with an observation for each subtag
  registry <- data.frame(matrix(nrow = sum(grepl('Subtag',temp)), ncol = 2))
  names(registry) <- c('text_lang', 'language')
  j = 0
  # Place each subtag and Description in the appropriate column, based on a regular expression
  for (i in seq_along(temp)){
    if (grepl('Subtag',temp[i])){
      j = j + 1
      registry$text_lang[j] <- strsplit(temp[i],': ')[[1]][2]
    } else if (grepl('Description',temp[i])){
      registry$language[j] <- strsplit(temp[i],': ')[[1]][2]
    }
    else {next}
  }
  return(registry)
}

# Outdated Utility for creating Colors.
colors <- function(path = '../../Assets/Langauge.json'){
  require(jsonlite)
  registry <- fromJSON(path)
  registry <- registry[,1:2]
  names(registry) <- c('text_lang', 'language')
  
  language <- unique(registry$language)
  language <- sort(language)
  
  # require(RColorBrewer)
  # color <- c(brewer.pal(12, "Set3"),
  #             brewer.pal(9, "Set1"),
  #             brewer.pal(8, "Dark2"),
  #             "#000000", "#F7F7F7","#FFE1FF")
  
  # Need 33 colors (32 + 1 for OTHER)
  blues <- c("blue","darkblue","cyan","darkcyan","cornflowerblue",
             "darkslateblue","darkslategray",
             "deepskyblue3","deepskyblue4")
  reds <- c("thistle1","coral3","darkorange1", "darkorange3",
            "darkorchid1","darkorchid4","red","darkred",
            "deeppink3","deeppink4")
  greens <- c("aquamarine3","aquamarine4","green","darkgreen",
              "darkolivegreen1", "darkolivegreen4")
  yellows <- c("chocolate1","chocolate4", "darkgoldenrod1","darkgoldenrod4",
               "yellow")
  neutrals <- c("black","mistyrose")
  
  color <- c(blues, reds, greens, yellows, neutrals)
  
  color_pal <- as.data.frame(cbind(language, color))
  registry <- merge(registry,color_pal)
  registry$color <- as.character(registry$color)
  registry <- rbind(registry,c("Other",NA,"gray39"))
  return(registry)
}

 # From   https://github.com/rstudio/dygraphs/issues/63
dyVisibility <- function (dygraph, visibility = TRUE){
  dygraph$x$attrs$visibility <- visibility
  dygraph
}

#  dyVisibility(visibility=c(TRUE,FALSE, TRUE))