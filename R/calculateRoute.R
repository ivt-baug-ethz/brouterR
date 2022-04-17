#' Calculate route between two points
#'
#' The route between two points is calculated for the given coordinates. The default values for rolling resistance and drag coefficient
#' correspond to values found by Tengatti and Bigazzi (2018): Physical characteristics and resistance parameters of typical urban cyclists.
#' brouterR ignores the bikerPower, totalMass, dragCoefficient, rollingResistance and maxSpeed available in the brouter routing profiles and uses the values provided via R instead.
#' This functions needs the server to be set manually before running it with the setServers and then the startServers functions.
#'
#' @param startLat Latitude of start location
#' @param startLon Longitude of start location
#' @param endLat Latitude of end location
#' @param endLon Longitude of end location
#' @param profile Routing profile. Defaults to "trekking"
#' @param outputFormat one of "df" or "linestring" (as an st_linestring object with XYZ dimensions). Defaults to "df"
#' @param serverNodeId The node where the server is running on. Defaults to 1. Do not change for single core usage.
#' @param bikerPower The total average power put on the pedals in Watts. Defaults to 100W
#' @param totalMass The total weight of biker, bike and cargo in kg. Defaults to 90kg
#' @param dragCoefficient The wind drag coefficient in m2. Defaults to 0.559
#' @param rollingResistance The rolling resistance of the underground. Default value assumes dry asphalt, 0.0077
#' @param maxSpeed The maximum speed achieved by the bike in km/h. Defaults to 45 km/h.
#'
#' @return Either a dataframe of the track (outputFormat="df"), or a st_linestring (outputFormat="linestring") containing elevation information
#' @export
#' @import sf
#' @import sp
#' @import plotKML
#'
#' @examples
#'
#'
calculateRoute <- function(startLat, startLon, endLat, endLon, bikerPower=100, totalMass=90,
                           dragCoefficient=0.559, rollingResistance=0.0077, maxSpeed=45, profile="trekking", outputFormat="df",serverNodeId=1){

  data <- tryCatch(
    {
  url <- paste("http://127.0.0.",serverNodeId,":17777/brouter?lonlats=",
               startLon,",",startLat,"|",endLon,",",endLat,"&profile=",(profile),"&alternativeidx=0&format=",outputFormat,
               "&bikerPower=",bikerPower,
               "&totalMass=",totalMass,
               "&dragCoefficient=",dragCoefficient,
               "&rollingResistance=",rollingResistance,
               "&maxSpeed=",maxSpeed,
               sep="")

  if(outputFormat=="df"){
    download.file(url, paste(tempdir(), "\\this.txt", sep=""), quiet=T)
    data <- utils::read.table(paste(tempdir(), "\\this.txt", sep=""), sep="\t", header=TRUE)

  } else if(outputFormat=="linestring"){
    download.file(url, paste(tempdir(), "\\this.gpx", sep=""), quiet=T)
    gpx <- plotKML::readGPX(paste(tempdir(), "\\this.gpx", sep=""))
    gpx <- gpx$tracks[[1]][[1]]
    sp::coordinates(gpx) <- ~ lon + lat
    gpx@proj4string <- CRS("+init=epsg:2056")

    sfRoute <- sf::st_as_sf(gpx, dim="XYZ")

    #Now tranform to an sf linestring object
    z <- as.numeric(gpx$ele)
    m <- sf::st_coordinates(sfRoute)
    m_xyz <- cbind(m,z)

    this <- sf::st_linestring(as.matrix(m_xyz), dim="XYZ")
    sfRoute <- sf::st_sfc(this, crs = sf::st_crs(sfRoute))

    data <- sfRoute
  }
  },     error=function(e){
        stop(e)
        print("Did you start the servers with startServers before calling this function? Did you provide all necessary inputs?")
    }
  )
 return(data)
}


