#### This will iterate through each city and Run the Mapping.R script ####

#### Istanbul ####

## Load data if already procured
# rm(list = ls())
# load(file = "Data/IstanbulData.RData")

# Source the location metadata.
source("IST_meta.R")

# Source the Postgres Functions
source('Postgres_functions.R')

# Source the hull functions
source('HullFunctions.R')

# Mapping
source('Mapping.R')

# Save the image for later use
save.image(paste0("Data/",db,"Data.RData"))

#### Chicago ####

## Load data if already procured
# rm(list = ls())
# load(file = "Data/ChicagoData.RData")

# Source the location metadata.
source("CHI_meta.R")

# Source the Postgres Functions
source('Postgres_functions.R')

# Source the hull functions
source('HullFunctions.R')

# Mapping
source('Mapping.R')

# Save the image for later use
save.image(paste0("Data/",db,"Data.RData"))

#### LA ####

## Load data if already procured
# rm(list = ls())
# load(file = "Data/LAData.RData")

# Source the location metadata.
source("LAX_meta.R")

# Source the Postgres Functions
source('Postgres_functions.R')

# Source the hull functions
source('HullFunctions.R')

# Mapping
source('Mapping.R')

# Save the image for later use
save.image(paste0("Data/",db,"Data.RData"))
