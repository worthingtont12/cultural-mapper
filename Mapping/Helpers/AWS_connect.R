#### Get the data from AWS ####
source('Postgres_functions.R')

# Create connection to the RDS instance
con <- connectDB(db)

# Get the raw count of items, as well as the aggregate count, grouped by location

new_raw_count = dbGetQuery(con, "SELECT COUNT(*)
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
