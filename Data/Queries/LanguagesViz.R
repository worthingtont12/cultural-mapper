library(readr)
library(jsonlite)
library(leaflet)
library(magrittr)

chi_lang <- read_csv('Chicago_Lang_161105.csv')
la_lang <- read_csv('LA_Lang_161105.csv')
ist_lang <- read_csv('Istanbul_Lang_161105.csv')

langs <- fromJSON('../Langauge.json')

langs <- langs[,1:2]
names(langs) <- c('text_lang', 'language')

chi_merge <- merge(chi_lang, langs)
la_merge <- merge(la_lang, langs)
ist_merge <- merge(ist_lang, langs)

la_geo <- read_csv('LA_Geotagged.csv')
# Used Find/Replace in Atom's Text editor to replace "" with "/n"
problems<-problems(read_csv('LA_Geotagged.csv'))
# Much better!


la_geo_merge <- merge(la_geo, langs)
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


languages <- Lang_sum[Lang_sum$count > 100 & Lang_sum$language != "English" & Lang_sum$language != "Unknown","language"]

library(RColorBrewer)
library(colorspace)

#colors <- brewer.pal(nrow(la_geo_filter),"Set3")
colors <- rainbow_hcl(length(levels(la_geo_filter$language)))


pal <- colorFactor(colors, domain = levels(la_geo_filter$language))

leaflet() %>%
  addProviderTiles("OpenStreetMap.BlackAndWhite") %>%
  addCircleMarkers(lng=la_geo_filter$long,
                   lat=la_geo_filter$lat,
                   color = pal(la_geo_filter$language),
                   radius = 3,
                   stroke = FALSE, fillOpacity = 0.5,
                   popup = paste0(la_geo_filter$created_at,
                                  "<br>",
                                  la_geo_filter$language)
                    ) %>%
  addLegend("bottomright", pal = pal, values = la_geo_filter$language,
            title = "Languages",
            opacity = 1)



