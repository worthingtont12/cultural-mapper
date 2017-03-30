#### Istanbul ####

# Load data if already procured
rm(list = ls())
load(file = "Data/ISTData.RData")

# Source the location metadata.
source("IST_meta.R")

# Source the Postgres Functions
source('Postgres_functions.R')

# Source the hull functions
source('HullFunctions.R')

# Mapping
source('Mapping.R')

#### Chicago ####

# Load data if already procured
rm(list = ls())
load(file = "Data/CHIData.RData")

# Source the location metadata.
source("CHI_meta.R")

# Source the Postgres Functions
source('Postgres_functions.R')

# Source the hull functions
source('HullFunctions.R')

# Mapping
source('Mapping.R')

#### LA ####

# Load data if already procured
rm(list = ls())
load(file = "Data/LAXData.RData")

# Source the location metadata.
source("LAX_meta.R")

# Source the Postgres Functions
source('Postgres_functions.R')

# Source the hull functions
source('HullFunctions.R')

# Mapping
source('Mapping.R')

