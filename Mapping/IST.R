# Load data if already procured
rm(list = ls())
load(file = "Data/ISTData.RData")

# Source the location metadata.
source("IST_meta.R")

# Source the Postgres Functions
source('Postgres_functions.R')

# Source the hull functions
source('HullFunctions.R')

#### Load AWS Data ####
#source('AWS_connect.R')

### Mapping ####
source('Mapping.R')
