# A few sites used to track down UTM Zones and EPSG codes
# http://spatialreference.org/
# http://epsg.io

# LongLatToUTM function adapted from:
# http://stackoverflow.com/questions/18639967/converting-latitude-and-longitude-points-to-utm


# Function to project WGS84 (longitude/latitude) to UTM
LongLatToUTM<-function(long,lat,zone){
  require(rgdal)
  require(sp)
  # Bind the longitude and latitude
  xy <- data.frame(EW = long, NS = lat)
  # Name the columns and set the projection as WGS84
  coordinates(xy) <- c("EW", "NS")
  proj4string(xy) <- CRS("+proj=longlat +datum=WGS84")
  # Transform into UTM with corresponding Zone
  res <- spTransform(xy, CRS(paste0("+proj=utm +zone=",zone," ellps=WGS84")))
  return(as.data.frame(res))
}

LongLatToM <- function (long,lat,epsg){
  require(rgdal)
  # Bind the longitude and latitude
  xy <- data.frame(EW.m = long, NS.m = lat)
  # Name the columns and set the projection as WGS84
  coordinates(xy) <- c("EW.m", "NS.m")
  proj4string(xy) <- CRS("+proj=longlat +datum=WGS84")
  # Project
  res <- spTransform(xy, CRS(paste0("+init=epsg:",epsg)))
  return(as.data.frame(res))
}