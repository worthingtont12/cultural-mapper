source('Registry.R')
ist_geo <- location('../../Data/Queries/Istanbul.csv',
                    "Asia/Istanbul",
                    28.448009, 40.802731, 29.45787, 41.23595)
ist_map <- location_map(ist_geo)
ist_map
ist_dygraph <- location_dygraph(ist_geo)
ist_dygraph


la_geo <- location('../../Data/Queries/LA_Geotagged.csv', 
                   "America/Los_Angeles",
                   -118.723549, 33.694679, -117.929466, 34.33926)
la_map <- location_map(la_geo, 2000)
la_map
la_dygraph <- location_dygraph(la_geo)
la_dygraph

chi_geo <- location('../../Data/Queries/Chicago_sample.csv',
                    "America/Chicago",
                    -87.968437, 41.624851, -87.397217, 42.07436)
chi_map <- location_map(chi_geo)
chi_map

library(htmlwidgets)
saveWidget(widget = chi_map, file ='chi_languagemap.html')
saveWidget(widget = la_map, file ='la_languagemap.html')
saveWidget(widget = ist_map, file ='ist_languagemap.html')

library(ggplot2)
la_hist <- ggplot(la_geo, aes(x=language)) + geom_bar(stat = 'count') 
la_hist

la_line <- ggplot(la_geo, aes(x= created_at, y = 'count', group = language)) + geom_line()
la_line


ggplot(data = ist_geo, aes(x = created_at)) + geom_freqpoly() +
  scale_y_log10() + 
  aes(group = language, color  = language)

ggplot(data = chi_geo[chi_geo$created_at > '2016-11-02' & chi_geo$created_at < '2016-11-04',
                      ], aes(x = created_at)) + geom_freqpoly() +
  scale_y_log10() + 
  aes(group = language, color  = language)

ggplot(data = la_geo, aes(x = rounded)) + geom_freqpoly() +
  scale_y_log10() + 
  aes(group = language, color  = language)

