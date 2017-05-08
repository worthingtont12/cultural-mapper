# Stop Words
Majority of the stop words were downloaded from  the nltk toolkit. The rest were downloaded from Kevin Bougé's website.

NLTK
http://www.nltk.org/index.html

Kevin Bougé's website
https://sites.google.com/site/kevinbouge/stopwords-lists

# Bounding Box Information

Amy X Zhang used Yahoo! GeoPlanet and PlaceFinder API to identify the bounding box coordinates that encompass a collection of  cities.

# Links of Interest for Bounding Box Information
Yahoo! GeoPlanet
http://developer.yahoo.com/geo/geoplanet/

Yahoo! PlaceFinder
http://developer.yahoo.com/geo/placefinder/

Amy X Zhang's Repository
https://github.com/amyxzhang/boundingbox-cities

# Language files

Twitter's API provided a JSON object of supported "production" languages. File was manipulated to collapse similar languages into one category, i.e. English, British English, and Australian English.

The [IANA](www.iana.org) maintains a list of all languages and their corresponding two-letter codes. This was used in identifying languages not featured in the JSON (though ultimately not used in analysis).
