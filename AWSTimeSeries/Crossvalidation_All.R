rm(list =ls())

# Load in the Location metadata
source("LAX_meta.R")
source("AWS_TS_load_all.R")
save.image(paste0("~/Cultural_Mapper/AWSTimeSeries/RData/",db,".RData"))


rm(list =ls())

# Load in the Location metadata
source("IST_meta.R")
source("AWS_TS_load_all.R")
save.image(paste0("~/Cultural_Mapper/AWSTimeSeries/RData/",db,".RData"))

rm(list =ls())

# Load in the Location metadata
source("CHI_meta.R")
source("AWS_TS_load_all.R")
save.image(paste0("~/Cultural_Mapper/AWSTimeSeries/RData/",db,".RData"))

