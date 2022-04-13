
<!-- README.md is generated from README.Rmd. Please edit that file -->

# brouterR


This is a R-Wrapper for the brouter, an open-source, OSM-based offline bicycle routing engine. The brouter has the advantage of using customizable routing profiles, which can take personal capabilities and preferences into account. There is a kinetic model embedded, which accounts for weight, maximum speed and power. For more info see: \  

-General Info: http://brouter.de/brouter/index.html  
-Info on routing profiles: http://brouter.de/brouter/costfunctions.html    
-Online demo: http://brouter.de/brouter-web   
-Original Github-Repo: https://github.com/abrensch/brouter  


## Installation
```{r example, results = FALSE,message=FALSE, warning=FALSE}
require(devtools)
install_github("https://github.com/mflucas/brouterR")
```

This R-Wrapper is based on the brouter offline server for computers. For running it, you need to download and extract the latest brouter version's containing a .jar file and some profiles here: http://brouter.de/brouter/revisions.html   

You have to download the segments for the world regions or generate one yourself from OSM and put it in a "segments4" folder within the folder where the .jar file and the "profiles2" file is placed. 

Segments can be downloaded from here (worldwide coverage): http://brouter.de/brouter/segments4/    

It is also possible to create your own: https://github.com/abrensch/brouter/blob/master/misc/readmes/mapcreation.md    

Once the the setup is complete, the R-functions in the package can be run. 


## Example


TODO
