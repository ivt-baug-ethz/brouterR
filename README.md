
<!-- README.md is generated from README.Rmd. Please edit that file -->

# brouterR


This is a R-Wrapper for the brouter, an open-source, OSM-based offline bicycle routing engine. The brouter has the advantage of using customizable routing profiles, which can take personal capabilities and preferences into account. There is a kinetic model embedded, which accounts for weight, maximum speed and power. For more info see: 

-General Info: http://brouter.de/brouter/index.html  
-Info on routing profiles: http://brouter.de/brouter/costfunctions.html    
-Online demo: http://brouter.de/brouter-web   
-Original Github-Repo: https://github.com/abrensch/brouter  


## Installation
```{r example, results = FALSE,message=FALSE, warning=FALSE}
require(devtools)
install_github("https://github.com/mflucas/brouterR")

#Install brouter to a local folder:
brouterR::installbrouterR(pathToLocalFolder)

```

This R-Wrapper is based on the brouter offline server for computers. For running it, you first need to install it using the specified brouterR function. This is required since the original brouter-.jar file is modified for use with brouterR. 

IMPORTANT: You first have to manually download the segments for the world regions or generate one yourself from OSM and put it in a "segments4" folder within the installation folder of the brouter.

Segments can be downloaded from here (worldwide coverage): http://brouter.de/brouter/segments4/

The following text is copied from http://github.com/abrensch/brouter  

Routing data files are organised as 5*5 degree files, with the filename containing the south-west corner of the square, which means:

You want to route near West48/North37 -> you need W50_N35.rd5
You want to route near East7/North47 -> you need E5_N45.rd5
These data files, called "segments" across BRouter, are generated from OpenStreetMap data and stored in a custom binary format (rd5) for improved efficiency of BRouter routing.

Download them from brouter.de
Segments files from the whole planet are generated weekly at https://brouter.de/brouter/segments4/.

You can download one or more segments files, covering the area of the planet you want to route, into the misc/segments4 directory.

Generate your own segments files
You can also generate the segments files you need directly from a planet dump of OpenStreetMap data (or a GeoFabrik extract).

More documentation of this is available in the misc/readmes/mapcreation.md file.





Once the the setup is complete, the R-functions in the package can be run. 


## Routing

There are 3 main functions for running the brouter. All can use as input parameters on individual biker and route characteristics (bikerPower,totalMass,dragCoefficient,rollingResistance,maxSpeed). If not provided, default values are used. 

### calculateRoute
Calculates a single route, the output can either a SpatialPointsDataFrame (Object of package "sp"), containing street segments and elevation points of the routing, or it can be a csv file, containing further details on the route.   
IMPORTANT: Before running this function, the local servers need to be set up and started manually with the setServers and startServers functions. 

### parallelRoutesCalculator
Speed-optimized function for calculating routes. This is achieved by a parallelization of the routing tasks (the number of nodes needs to be actively provided). 
This function automatically sets and starts the servers before routing is done. 
The output is a series of variables (total travel time, total distance, total elevation gain, upward and downward slope and energy expenditure for the route), which are aggregated from the .csv file output. 
For this function to be used, the input dataframe has to have columns for start and end coordinates of each route named as startLat, startLon, endLat, endLon, otherwise the router does not work. 

### calculateAggrMetrics
Single core version of parallelRoutesCalculator. 


