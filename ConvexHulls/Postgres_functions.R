library(RPostgreSQL)
# Function to connect to the database, 
connectDB <- function(city){
  require(RPostgreSQL)
  # Load in the keys
  source('keys.R')
  # Create DB name, joining city name 
  name = paste("culturalmapper", city, sep = "_")
  pg = dbDriver("PostgreSQL")
  
  # Connect to the database
  con = dbConnect(pg, user = usr,
                  password = pwd,
                  host = hst,
                  port = 5432,
                  dbname = name)
  # Remove the keys
  rm(hst, usr, pwd, envir = .GlobalEnv)
  con
}

# Simple disconnect
disconnectDB <-function(db){
  require(RPostgreSQL)
  dbDisconnect(db)
}

# Load language registry
load_langs <- function(){
  require(jsonlite)
  registry <- fromJSON('../../Cultural_Mapper/Assets/Langauge.json')
  names(registry) <- c('text_lang', 'language')
  registry[1:2]
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
