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

# Projecting to meters using EPSG transforms
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

# A function to find the number of grid points in each direction. It takes a
# ggmap object, the spacing of grid points in meters, the utm zone or EPSG
# number, and the projection as arguments. Internally, it calls either
# LongLatToUTM of LongLatToM (the latter by default)

findN <- function(map, grid = 200, zone,proj="epsg"){
  require(dplyr)
  # extract the coordinates for the map's bounding box, and convert to meters
  df <- cbind(range(map$data$lon),range(map$data$lat))
  if (proj == "utm"){df <- LongLatToUTM(df[,1],df[,2],zone)
  } else {
    df <- LongLatToM(df[,1],df[,2],zone)
  }
  # Divide the difference (in meters) by the size of the grid to determine the
  # number of points in each direction
  lat.diff <- diff(df$NS.m)/grid
  long.diff <- diff(df$EW.m)/grid

  return (c(lat.diff, long.diff))
}

# Function to create the null grid. It takes a bounding box (long, lat, long,
# lat), grid size in meters (default is 200, the rough size of a city block),
# and the zone for casting degrees to meters (using the LongLatToUTM function)

nullGrid <- function(vect, grid = 200, zone,proj="epsg"){
  require(dplyr)
  # put the vector into a matrix form, convert to meters
  df <- t(matrix(vect,nrow=2))
  if (proj == "utm"){df <- LongLatToUTM(df[,1],df[,2],zone)
  } else {
    df <- LongLatToM(df[,1],df[,2],zone)
  }

  # Create sequences from minimum to maximum of longitude and latitude
  longs <- seq(min(df$EW),max(df$EW), grid)
  lats <- seq(min(df$NS),max(df$NS), grid)

  # Create the grid, naming the features accordingly
  temp <- expand.grid(longs, lats)
  names(temp) <- c('EW', 'NS')
  # Add feature indicating no event took place at a given point
  temp %>% mutate(event = 0)
}
