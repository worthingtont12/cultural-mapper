# Source the Postgres Functions
source('../ConvexHulls/Postgres_functions.R')


# Create connection to the RDS instance
con <- connectDB("LA")

# Get the raw count of items, as well as the aggregate count, grouped by location

raw_count = dbGetQuery(con, "SELECT COUNT(*)
                        FROM geometries_filter
                  ")

top_points = dbGetQuery(con, "SELECT COUNT(*) AS tweets, geo_point
                              FROM geometries_filter
                              GROUP BY geo_point
                              ORDER BY tweets DESC
                        ")

data = dbGetQuery(con, "SELECT *
                        FROM geometries_filter")
# Disconnect
disconnectDB(con)

library(dplyr)
top_points <- top_points %>% mutate(per = tweets/raw_count$count)

