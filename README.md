# COVID19

This is a project to track neighbourhood-level inequalities across cities that are releasing spatially dis-aggregated data.


## Data ##

All_cities_zip.csv includes data by zipcode for 6 cities - Seattle, Boston, New York City, Detroit, Philadelphia and Chicago obtained between 24th and 28th April. The geographical identifier is "custom_zip", which is different from a zip code because Boston aggregates some zipcodes. 

To merge to zip-code level covariate data, use the zip_lookup.csv which maps the custom-zips to actual zips. Due to Boston's aggregation, some custom-zips are repeated. Join zip-code level data to the lookup table, group by and summarize by custom-zip (mean, pop weighted mean or sum depending on the variable), and then join to case data in All_cities_zip.

