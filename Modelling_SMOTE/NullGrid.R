# Bounding box coordinates
la <- c(-118.723549, 33.694679, -117.929466, 34.33926)

# Function to create the null grid. It takes a bounding box (long, lat, long, 
# lat), grid size in meters (default is 200, the rouhg size of a city block),
# and the zone for casting degrees to meters (using the LongLatToUTM function)

nullGrid <- function(vect, grid = 200, zone){
  require(dplyr)
  # put the vector into a matrix form, convert to meters
  df <- t(matrix(vect,nrow=2))
  df <- LongLatToUTM(df[,1],df[,2],zone)

  # Create sequences from minimum to maximum of longitude and latitude
  longs <- seq(min(df$EW),max(df$EW), grid)
  lats <- seq(min(df$NS),max(df$NS), grid)

  # Create the grid, naming the features accordingly
  temp <- expand.grid(longs, lats)
  names(temp) <- c('EW', 'NS')
  # Add feature indicating no event took place at a given point
  temp %>% mutate(event = 0)
}

# Create the grid for Los Angeles
la.grid <- nullGrid(la,200,11)

# Confirm none of the points of the tweets exist in the grid itself
nrow(intersect(topic_meters %>% select(EW, NS), la.grid %>% select(EW, NS)))
