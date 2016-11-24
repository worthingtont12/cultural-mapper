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

# Utility to read and clean a CSV
location <- function(file_in, west, south, east, north){
  require(readr)
  require(jsonlite)
  geo <- read_file(file_in)
  geo <- gsub('\"\"','\"\r\n\"',geo)
  geo <- read_csv(geo)
  
  #registry <- language_reg()
  registry <- fromJSON('../Langauge.json')
  registry <- langs[,1:2]
  names(registry) <- c('text_lang', 'language')
  
  geo_merge <- merge(geo, registry)
  geo_merge$language <- as.factor(geo_merge$language)
  
  geo_filter <- geo_merge[geo_merge$long >= west & geo_merge$long<= east &
                             geo_merge$lat >= south & geo_merge$lat<= north,]
  
  geo_filter$rounded <- round(geo_filter$created_at, units = 'hours')
  return(geo_filter)
}

location_map <- function(geo_filter, threshold = 100){
  require(dplyr)
  require(tidyr)
  
  Lang_sum <- geo_filter %>%
    group_by(language) %>%
    summarise(count=n())
  
  languages <- Lang_sum[Lang_sum$count > threshold,]
  
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
