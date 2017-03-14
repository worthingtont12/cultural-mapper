z <- clean %>% 
  select_('lat', 'long', 'geo_point', feature) %>%
  distinct_('geo_point', feature, .keep_all = T)


a <- ahull(z$long[z[, feature] == 16],
           z$lat[z[, feature] == 16], .5)
plot(a, wpoints = F, col = 'red', xlab = "Longitude", ylab = "Latitude",
     main = 'Alpha Hulls of Top 9 Languages by Volume')
