AlphaHull <- function(df, feature = 'language', alpha = .05){
  require(alphahull)
  require(RColorBrewer)
  require(dplyr)
  colors <- brewer.pal(9,"Set1")
  lang_sum <- df %>%
    group_by_(feature) %>%
    count() %>%
    arrange(desc(n))
  
  i <- 1
  temp <- df %>% 
    select_('lat', 'long', 'geo_point', feature) %>%
    distinct_('geo_point', feature, .keep_all = T)
  
  par(mar=c(5.1, 4.1, 4.1, 8.1), xpd = T)
  
  a <- ahull(temp$long[temp[,feature] == lang_sum[1,i]],
             temp$lat[temp[,feature] == lang_sum[1,i]], alpha)
  plot(a, wpoints = F, col = colors[i], xlab = "Longitude", ylab = "Latitude",
       main = 'Alpha Hulls of Top 9 Languages by Volume')
  i <- i + 1
  
  b <- ahull(temp$long[temp[,feature] == lang_sum[1,i]],
             temp$lat[temp[,feature] == lang_sum[1,i]], alpha)
  plot(b, wpoints = F, add = T, col = colors[i])
  i <- i + 1
  
  c <-ahull(temp$long[temp[,feature] == lang_sum[1,i]],
            temp$lat[temp[,feature] == lang_sum[1,i]], alpha)
  plot(c, points = F, add = T, col = colors[i])
  i <- i + 1
  
  d <- ahull(temp$long[temp[,feature] == lang_sum[1,i]],
             temp$lat[temp[,feature] == lang_sum[1,i]], alpha)
  plot(d, wpoints = F, add = T, col = colors[i])
  i <- i + 1
  
  e <- ahull(temp$long[temp[,feature] == lang_sum[1,i]],
             temp$lat[temp[,feature] == lang_sum[1,i]], alpha)
  plot(e, wpoints = F, add = T, col = colors[i])
  i <- i + 1
  
  f <- ahull(temp$long[temp[,feature] == lang_sum[1,i]],
             temp$lat[temp[,feature] == lang_sum[1,i]], alpha)
  plot(f, wpoints = F, add = T, col = colors[i])
  i <- i + 1
  
  g <- ahull(temp$long[temp[,feature] == lang_sum[1,i]],
             temp$lat[temp[,feature] == lang_sum[1,i]], alpha)
  plot(g, wpoints = F, add = T, col = colors[i])
  i <- i + 1
  
  h <- ahull(temp$long[temp[,feature] == lang_sum[1,i]],
             temp$lat[temp[,feature] == lang_sum[1,i]], alpha)
  plot(h, wpoints = F, add = T, col = colors[i])
  i <- i + 1
  
  j <- ahull(temp$long[temp[,feature] == lang_sum[1,i]],
             temp$lat[temp[,feature] == lang_sum[1,i]], alpha)
  plot(j, wpoints = F, add = T, col = colors[i])
  legend('topright', inset = c(-0.5,0), title = "Languages", legend = lang_sum[,feature][1:9], fill = colors)
  par(mar=c(0,0,0,0), xpd = F)
}
