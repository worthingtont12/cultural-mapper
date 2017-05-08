#### Run AWS_TS_load_all.R for all Cities ####
# Remove existing Data
rm(list =ls())

# Load in the Los Angeles metadata
source("LAX_meta.R")
source("AWS_TS_load_all.R")
save.image(paste0("~/Cultural_Mapper/AWSTimeSeries/RData/",db,".RData"))

# Remove existing Data
rm(list =ls())

# Load in the Istanbul metadata
source("IST_meta.R")
source("AWS_TS_load_all.R")
save.image(paste0("~/Cultural_Mapper/AWSTimeSeries/RData/",db,".RData"))


# Remove existing Data
rm(list =ls())

# Load in the Chicago metadata
source("CHI_meta.R")
source("AWS_TS_load_all.R")
save.image(paste0("~/Cultural_Mapper/AWSTimeSeries/RData/",db,".RData"))
