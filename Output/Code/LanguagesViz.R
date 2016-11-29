library(readr)
library(jsonlite)
library(leaflet)
library(magrittr)
library(dplyr)

chi_lang <- read_csv('Chicago_Lang_161105.csv')
la_lang <- read_csv('LA_Lang_161105.csv')
ist_lang <- read_csv('Istanbul_Lang_161105.csv')

langs <- fromJSON('../Langauge.json')

langs <- langs[,1:2]
names(langs) <- c('text_lang', 'language')

# Read in IANA languges
source('Registry.R')
registry <- language_reg()

#langs2 <- merge(langs, registry, by = "text_lang", all = TRUE)

chi_merge <- merge(chi_lang, registry)
la_merge <- merge(la_lang, registry)
ist_merge <- merge(ist_lang, registry)

la_geo <- read_csv('LA_Geotagged.csv')
# Used Find/Replace in Atom's Text editor to replace "" with "/n"
problems<-problems(read_csv('LA_Geotagged.csv'))
# Much better!


la_geo_merge <- merge(la_geo, registry)
la_geo_merge <- unique(la_geo_merge)
la_geo_merge <- la_geo_merge[complete.cases(la_geo_merge),]


# Filter out those not in LA
## TO DO: Write this as a function!
la_geo_filter <- la_geo_merge[la_geo_merge$long >= -118.723549 & la_geo_merge$long<= -117.929466 &
                                la_geo_merge$lat >= 33.694679 & la_geo_merge$lat<= 34.33926,]
la_geo_filter$language <- as.factor(la_geo_filter$language)
length(levels(la_geo_filter$language))

library(dplyr)
Lang_sum <- la_geo_filter %>%
  group_by(language) %>%
  summarise(count=n())


languages <- Lang_sum[Lang_sum$count > 100,]

library(RColorBrewer)
library(colorspace)

#colors <- brewer.pal(nrow(languages),"Set3")
colors <- rainbow_hcl(length(languages$language))


pal <- colorFactor(colors, domain = unique(languages$language))

subset <- la_geo_filter[la_geo_filter$language %in% languages$language,]

map <- leaflet() %>%
  addProviderTiles("OpenStreetMap.BlackAndWhite") %>%
  addCircles(lng=subset$long,
                   lat=subset$lat,
                   color = pal(subset$language),
                   radius = 100,
                   stroke = FALSE, fillOpacity = 1,
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
  ) %>% hideGroup(c("English","Undetermined"))

map

library(htmlwidgets)
saveWidget(widget = map, file ='languagemap.html')
