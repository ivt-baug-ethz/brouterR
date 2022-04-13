
#' Calculate loops based on input as an element of a list.
#'
#' To be used with lapply!
#'
#' @param elem An element of a list
#' @param profile The routing profile to be used
#'
#' @return
#' @export
#' @keywords internal
#' @noRd
#'
#' @examples
#'
listBasedRouteCalculator <- function(elem=NULL, profile="trekking"){

  profile=profile

  serverNode <- elem[[1]]
  id <- elem[[2]]
  startLat <- elem[[3]]
  startLon <- elem[[4]]
  endLat <- elem[[5]]
  endLon <- elem[[6]]
  bikerPower <- elem[[7]]
  totalMass <- elem[[8]]
  dragCoefficient <- elem[[9]]
  rollingResistance <- elem[[10]]
  maxSpeed <- elem[[11]]


  # print(serverNode)
  # print(id)
  # print(startLat)
  # print(startLon)
  # print(endLat)
  # print(endLon)
  # print(bikerPower)
  # print(totalMass)
  # print(dragCoefficient)
  # print(rollingResistance)
  # print(maxSpeed)
  # print(profile)

  # serverNode <- as.numeric(elem[[1]][1])
  # id <- as.numeric(elem[[1]][2])
  # startLat <- as.numeric(elem[[1]][3])
  # startLon <- as.numeric(elem[[1]][4])
  # endLat <- as.numeric(elem[[1]][5])
  # endLon <- as.numeric(elem[[1]][6])
  # bikerPower <- as.numeric(elem[[1]][7])
  # totalMass <- as.numeric(elem[[1]][8])
  # dragCoefficient <- as.numeric(elem[[1]][9])
  # rollingResistance <- as.numeric(elem[[1]][10])
  # maxSpeed <- as.numeric(elem[[1]][11])



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
                     avgSlopeDown=avgSlopeDown)


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

   return(thisRoute)
 }
