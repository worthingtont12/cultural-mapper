#### This document contains a function which plots alpha hulls by language, as
#### well as helper functions for ploting convex hulls in ggplot2

AlphaHull <- function(df, group = 'language', alpha = .05){
  require(alphahull)
  require(RColorBrewer)
  require(dplyr)
  colors <- brewer.pal(9,"Set1")
  
  # Group tweets by language
  lang_sum <- df %>%
    group_by_(group) %>%
    count() %>%
    arrange(desc(n))
  lang_sum
  
  i <- 1
  temp <- unique(df[,c(2,3,7)])
  
  par(mar=c(5.1, 4.1, 4.1, 8.1), xpd = T)
  
  a <- ahull(temp$long[temp$language == lang_sum$language[i]],
             temp$lat[temp$language == lang_sum$language[i]], alpha)
  plot(a, wpoints = F, col = colors[i], xlab = "Longitude", ylab = "Latitude",
       main = 'Alpha Hulls of Top 9 Languages by Volume')
  i <- i + 1
  
  b <- ahull(temp$long[temp$language == lang_sum$language[i]],
             temp$lat[temp$language == lang_sum$language[i]], alpha)
  plot(b, wpoints = F, add = T, col = colors[i])
  i <- i + 1
  
  c <-ahull(temp$long[temp$language == lang_sum$language[i]],
            temp$lat[temp$language == lang_sum$language[i]], alpha)
  plot(c, points = F, add = T, col = colors[i])
  i <- i + 1
  
  d <- ahull(temp$long[temp$language == lang_sum$language[i]],
             temp$lat[temp$language == lang_sum$language[i]], alpha)
  plot(d, wpoints = F, add = T, col = colors[i])
  i <- i + 1
  
  e <- ahull(temp$long[temp$language == lang_sum$language[i]],
             temp$lat[temp$language == lang_sum$language[i]], alpha)
  plot(e, wpoints = F, add = T, col = colors[i])
  i <- i + 1
  
  f <- ahull(temp$long[temp$language == lang_sum$language[i]],
             temp$lat[temp$language == lang_sum$language[i]], alpha)
  plot(f, wpoints = F, add = T, col = colors[i])
  i <- i + 1
  
  g <- ahull(temp$long[temp$language == lang_sum$language[i]],
             temp$lat[temp$language == lang_sum$language[i]], alpha)
  plot(g, wpoints = F, add = T, col = colors[i])
  i <- i + 1
  
  h <- ahull(temp$long[temp$language == lang_sum$language[i]],
             temp$lat[temp$language == lang_sum$language[i]], alpha)
  plot(h, wpoints = F, add = T, col = colors[i])
  i <- i + 1
  
  j <- ahull(temp$long[temp$language == lang_sum$language[i]],
             temp$lat[temp$language == lang_sum$language[i]], alpha)
  plot(j, wpoints = F, add = T, col = colors[i])
  legend('topright', inset = c(-0.5,0), title = "Languages", legend = lang_sum$language[1:9], fill = colors)
  par(mar=c(0,0,0,0), xpd = F)
}

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