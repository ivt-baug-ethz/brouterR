#' Calculate aggregate metrics for each route.
#'
#' The output is a dataframe containing the travel time, distance, total elevation gain, upward and downward slope and energy expenditure for each route.
#' If brouter is not able to calculate the route, all variables will be returned with the value -99. Reasons for this may be coordinates outside the downloaded segment, or too far away from any nearby road.
#'
#' @param pathToBrouter Path to installation folder of brouter
#' @param line The line of the matrix passed
#' @param profile The routing profile
#'
#' @return
#' @export
#' @keywords internal
#'
#' @examples
#'

calculateAggrMetricsForParallelOLDVERSION <- function(matrix=NULL, pathToBrouter=NULL, profile="trekking"){

output <-  vector(mode='list', length=nrow(matrix))
profile <- profile


for(i in 1:nrow(matrix)){

  line <- matrix[i, ]

    # aggrMetrics <- data.frame(id=numeric(0),
    #                         travelTime=numeric(0),
    #                         distance=numeric(0),
    #                         energy=numeric(0),
    #                         avgSlopeUp=numeric(0),
    #                         avgSlopeDown=numeric(0))



    startLat <- line[3]
    startLon <- line[4]
    endLat <- line[5]
    endLon <- line[6]
    id <- line[2]
    serverNode <- line[1]

    bikerPower <- 100
    totalMass <- 90
    dragCoefficient <- 0.559
    rollingResistance <- 0.0077
    maxSpeed <- 45

    if("bikerPower" %in% colnames(line)){
      bikerPower <- line[,"bikerPower"]
    }

    if("totalMass" %in% colnames(line)){
      totalMass <- line[,"totalMass"]
    }

    if("dragCoefficient" %in% colnames(line)){
      dragCoefficient <- line[,"dragCoefficient"]
    }

    if("rollingResistance" %in% colnames(line)){
      rollingResistance <- line[,"rollingResistance"]
    }

    if("maxSpeed" %in% colnames(line)){
      maxSpeed <- line[,"maxSpeed"]
    }


    thisRoute <- tryCatch(
    {
      route <- brouterR::calculateRoute(startLat, startLon, endLat, endLon, bikerPower=bikerPower, totalMass=totalMass,
                                        dragCoefficient=dragCoefficient, rollingResistance=rollingResistance, maxSpeed=maxSpeed, serverNodeId = serverNode,
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
    # aggrMetrics <- rbind(aggrMetrics, as.data.frame(t(thisRoute)))
    # return(thisRoute)

      },

  error=function(e){
    thisRoute <- c(id=id,
                   travelTime=-99,
                   distance=-99,
                   energy=-99,
                   avgSlopeUp=-99,
                   avgSlopeDown=-99
    )


  }
    )


output[[i]] <-thisRoute
}

return(output)
}
