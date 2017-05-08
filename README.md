# Cultural Mapper
Using user-generated text to classify subpopulations in a city.

# Summary
The goal of this project was to try to devise a methodology of grouping individuals in metropolitan areas that didn't rely on census divisions of race or income. The argument is that we can instead group together individuals by their social interests and that this can allow us a more granular approach to looking at subpopulations. This project attempts to do this and examines the spatial and temporal aspects of this idea.

# Data
Over the course of 90 days from 10/29/16-1/26/17 we collected tweets from 3 regions.
* Los Angeles, CA, USA
* Chicago, IL, USA
* Istanbul, Turkey

We chose these 3 regions because we wanted 3 highly populated diverse areas but also wanted to see if we could create a methodology that can be used on cities domestic and international.

# Directory
* AWSTimeSeries - Time Series analsis ran on AWS.
* Analysis - Analyzed time series of clustered data.
* Assets - Dependencies for other processes.
* Data Collection - Scripts used to collect the data.
* Louvain Clustering - Implemented the Louvain Algorithm for clustering of users.
* Mapping - Files used for geographic mapping.
* Parsing - Files used to clean and process the data.
* SQL Queries - Important queries used throughout project.
* Topic Modeling - Implemented topic modeling to cluster twitter users.

# Purpose
This project was completed for the [Data Science Institute](https://dsi.virginia.edu) at UVa in fulfillment of the capstone project for the Master's of Science in Data Science.  

### Project Contributors
* Tyler Worthington (@worthingtont12)
* James Rogol (@jrogol)
* Lander Basterra (@landerbasterra)

### Presentations
* [10th Annual Strategic Multi-layer Assessment Conference](http://www.start.umd.edu/news/strategic-multilayer-assessment-call-poster-proposals) (Joint Base Andrews, MD); April 25-26, 2017 (Poster)
* [SIEDS '17](http://bart.sys.virginia.edu/sieds17/) (Charlottesville, VA); April 28, 2017 (Presentation and Poster)
