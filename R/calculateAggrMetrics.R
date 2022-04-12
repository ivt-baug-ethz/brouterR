#' Calculate aggregate metrics for each route.
#'
#' Single core version for calculating aggregate metrics for routes based on calculateRoute. The output is a dataframe containing the travel time, distance, total elevation gain, upward and downward slope and energy expenditure for each route.
#' Optionally, the dataframe can contain the columns 'bikerPower', 'totalMass', 'dragCoefficient', 'rollingResistance' and 'maxSpeed'. In this case these parameters will be passed to the route calculation. If these columns are not available, default values will be used.
#' If brouter is not able to calculate the route, all variables will be returned with the value -99. Reasons for this may be coordinates outside the downloaded segment, or too far away from any nearby road.
#'
#'
#' @param df A dataframe or datatable containing all origin-destination pairs. The table has to contain the columns 'startLat', 'startLon', 'endLat', 'endLon' in WGS84 coordinates
#' @param pathToBrouter Path to installation folder of brouter
#'
#' @return
#' @export
#'
#' @examples
#'
#'

calculateAggrMetrics <- function(df, pathToBRouter, profile="trekking"){

    brouterR::setServers(pathToBRouter = pathToBRouter, nrOfNodes =1)
  brouterR::startServers(pathToBRouter = pathToBRouter, noServers=1)

  #Prepare data and make checks
  if(is.data.frame(df)==FALSE){
    df <- data.frame(df)
  }

  if(!any((c("startLat", "startLon", "endLat", "endLon", "id")) %in% colnames(df))){
    stop("Coordinates columns not existing or wrongly named.
        Coordinates have to be in columns named 'startLat', 'startLon', 'endLat', 'endLon'.
         A column named 'id' is also expected.")
  }


  optional <- c('bikerPower', 'totalMass', 'dragCoefficient', 'rollingResistance', 'maxSpeed')
  colnames <- colnames(df)

  this <- optional %in% colnames

  use <- optional[this]

  aggrMetrics <- data.frame(id=numeric(0),
                            travelTime=numeric(0),
                            distance=numeric(0),
                            energy=numeric(0),
                            avgSlopeUp=numeric(0),
                            avgSlopeDown=numeric(0))

  bikerPower <- 100
  totalMass <- 90
  dragCoefficient <- 0.559
  rollingResistance <- 0.0077
  maxSpeed <- 0.559


  for(ii in 1:nrow(df)){
    startLat <- df[ii, ]$startLat
    startLon <- df[ii, ]$startLon
    endLat <- df[ii, ]$endLat
    endLon <- df[ii, ]$endLon
    id <- df[ii, ]$id

    if("bikerPower" %in% use){
      bikerPower <- df[ii, ]$bikerPower
    }

    if("totalMass" %in% use){
      totalMass <- df[ii, ]$totalMass
    }

    if("dragCoefficient" %in% use){
      dragCoefficient <- df[ii, ]$dragCoefficient
    }

    if("rollingResistance" %in% use){
      rollingResistance <- df[ii, ]$rollingResistance
    }

    if("maxSpeed" %in% use){
      maxSpeed <- df[ii, ]$maxSpeed
    }

    thisRoute <- tryCatch(
      {
      route <- brouterR::calculateRoute(startLat, startLon, endLat, endLon, bikerPower=bikerPower, totalMass=totalMass,
                                        dragCoefficient=dragCoefficient, rollingResistance=rollingResistance, maxSpeed=maxSpeed, serverNodeId = 1,
                                        profile=profile)



      travelTime <- max(route$Time)
      distance <- sum(route$Distance)
      energy <- max(route$Energy)

      #Calculate average slope:

      dElev <- diff(route$Elevation)
      route <- route[-1,]
      route$dElev <- dElev
      route$slope <- 100*route$dElev/route$Distance

      avgSlopeUp <- mean(route[route$slope>0,]$slope)
      avgSlopeDown <- mean(route[route$slope<0,]$slope)



      thisRoute <- c(id=id,
                     travelTime=travelTime,
                     distance=distance,
                     energy=energy,
                     avgSlopeUp=avgSlopeUp,
                     avgSlopeDown=avgSlopeDown
                     )
      }, error=function(e){
        thisRoute <- c(id=id,
                       travelTime=-99,
                       distance=-99,
                       energy=-99,
                       avgSlopeUp=-99,
                       avgSlopeDown=-99)
})
      aggrMetrics <- rbind(aggrMetrics, as.data.frame(t(thisRoute)))

  }

  return(aggrMetrics)

}
