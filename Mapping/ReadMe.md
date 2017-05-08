# Geospatial Analysis


## Structure
* __Outputs__ - Contains the plots and tables rendered.
* __Topic_Data__ - Contains the topics assignments produced via topic modeling
* __Helpers__ - Functions used elsewhere
* __Data__ - Stores .RData images of queries, when run locally
* __Shiny__ - Workings of the Shiny App.

## Files
* __*_meta.R files__ - Files for LA, Chicago and Istanbul. The bounding boxes, timezones, and geographic projections are contained, allowing the same code to be run on multiple cities.
* __All_Maps.R__ - Iterates through cities, mapping as it goes. Data can be loaded is saved, or queried from the database.
* __Mapping_Template.R__ - Can Be called after city data is loaded. Here, plots trends in Istanbul.
* __MultivariateRegression.R__ - Brief exploration of predicting location from Topic assignments and timestamps.
* __SourcesSumary.R__ - Summary statistics for each city, as well as Daily/Hourly plots for Los Angeles.
* __ConvexHulls.R__ - Preliminary explorations of Convex and Alpha Hulls in Los Angeles (over a test period, by language)
* __Helpers/Postgres_functions.R__ - Simplified connections and queries to the PostgreSQL database (AWS-specific).
* __Helpers/SpatialUtil.R__ - Geospatial Utilities.
* __Helpers/keys.R__ - Contains strings `usr` (PostgreSQL user name),`pwd` (PostgreSQL password), and `hst` (AWS PostgreSQL host). Called by __Prostgres_functions.R__
* __Shiny/Output.R__ - Create Shiny-based stand-alone web-apps and Summary statistics for cities.
* __Shiny/ReactiveShinyDraft.R__ - Shiny app for visualizing languages. Template based on Los Angeles.
* __Shiny/Registry.R__ - Helper functions for the Shiny App.


## Packages
* `tidyverse`
* `RPostgreSQL`
* `lubridate`
* `shiny`
* `reshape2`
* `ggmap`
* `readr`
* `leaflet`
* `dygraphs`
* `rdgal`
* `RColorBrewer`
