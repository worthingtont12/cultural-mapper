# Time Series Analysis with Amazon Web Services
### Time flies when you're in the cloud.

Running RStudio in AWS enabled the team to keep data within the AWS ecosystem, and limited external data transfers. Louis Aslett graciously maintains Amazon Machine Images for RStudio ([link](http://www.louisaslett.com/RStudio_AMI/)), the latest version of which provided the basis for an AWS EC2 instance.

## Structure
* __Outputs__ - Contains the plots and tables rendered.
* __Topic_Data__ - Contains the topics assignments produced via topic modeling
* __Helpers__ - Functions used elsewhere

## Files
* __*_meta.R files__ - Files for LA, Chicago and Istanbul. The bounding boxes, timezones, and geographic projections are contained, allowing the same code to be run on multiple cities.
* __AllCities_load_all.R__ - Runs __AWS_TS_load_all.R__ for each city, saving the results to the __Outputs__ directory.
* __ArabicAnalysis.R__ - Specific to the Arabic communities, which were distinct from other groups in LA and Istanbul
* __AWS_TS_load_all.R__ - Queries databases for all tweets after 10/28/16, the start of the study period.
  * Creates ARIMA models, extracts and saves coefficients and model structure.
  * Creates Heirarchical clusters of All and Top 20 topics.
  * Estimates Forecasts for 1 to 7 day windows.
* __AWS_TS_load.R__ - Modified version of the above, but limited to the 92-day study period
* __DailyAvgPlot.R__ - Depends on city data obtained __AWS_TS_load_all.R__ Experimenting with representations of daily averages. Radial plots were attempted, but obscured the variations, and were not used.
* __Helpers/Postgres_functions.R__ - Simplified connections and queries to the PostgreSQL database (AWS-specific). Calls __Helpers/SpatialUtil.R__.
* __Helpers/keys.R__ - Contains strings `usr` (PostgreSQL user name),`pwd` (PostgreSQL password), and `hst` (AWS PostgreSQL host). Called by


## Packages
* `forecast`
* `tidyverse`
* `RPostgreSQL`
* `lubridate`
* `sparcl` (colors dendrograms)
