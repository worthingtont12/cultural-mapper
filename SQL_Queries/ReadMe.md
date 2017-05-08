# Database Structure

An Amazon RDS instance running [PostgreSQL](www.PostgreSQL.org) served as the repository for all the tweets pulled in through the Python listeners (See [__Data_Collection__](https://github.com/worthingtont12/cultural-mapper/tree/master/Data_Collection)). An open-source platform with geospatial functionality (through the [PostGIS](www.postgis.net) extension), it was well-suited to this task.

* __psql_tables.txt__ - Details the structure of the tables used. The asterisks should be replaced with the appropriate city name.
  * __*_city_primary__ - The bulk of information culled from a Twitter JSON.
  * __*_city_secondary__ - Geolocation data for applicable tweets.
  * __*_user_desc__ - A User's self-authored description.
  * __*_quoted__ - Where Retweets appear inline with a Tweet, quoted Tweets are not. They were parsed from the JSON and stored here.
* __MaterializedView.txt__ - Contains the SQL query constructing a materialized view used in R Analysis.
* __DocumentingQueries.txt__ - Templates for queries performed by team members during the analysis phase.
