#' Parallel routes calculation
#'
#' Calculate routes with parallel routine for improved speed. The output is a dataframe containing the travel times, distance, total elevation gain, upward and downward slope and energy expenditure for the route
#' The calculated values are a summary of the detailed csv-file that brouter outputs at a route request. The original file can be called with the calculateRoute function
#' or visualized online at http://www.brouter.de/brouter-web by clicking on the Data option after calculating a route.
#'
#' @param preset A preset of power and weight addition for bikes, e-bikes and s-pedelecs (Swiss norms).
#' @param df A dataframe or datatable containing all origin-destination pairs. The table has to contain the columns 'id', 'startLat', 'startLon', 'endLat', 'endLon' in WGS84 coordinates
#' @param nrOfNodes Number of nodes the router is supposed to run on. Suggested to always use at max 1 core less than the total amount of cores in processor.
#' @param pathToBrouter Path to installation folder of brouter.
#' @param profile The brouter profile to be used in the routing.
#' @param optional Optional arguments: A list containing a combination of column names which have to exactly match the following names: 'bikerPower', 'totalMass', 'dragCoefficient', 'rollingResistance', 'maxSpeed'
#'#'
#' @return A dataframe containing the route 'id', 'travelTime', 'distance', 'energy, 'avgSlopeUp, 'avgSlopeDown'
#' @export
#' @import parallel
#'
#' @examples
#'
multipleBRoutes <- function(preset=NULL, df=NULL, nrOfNodes=1, pathToBrouter=NULL, profile=NULL, optional=NULL){


  brouterR::setServers(pathToBRouter = pathToBrouter, nrOfNodes =nrOfNodes)
  brouterR::startServers(pathToBRouter = pathToBrouter, noServers=nrOfNodes)

  #Prepare data and make checks
  if(is.data.frame(df)==FALSE){
    df <- data.frame(df)
  }

  if(!all((c("startLat", "startLon", "endLat", "endLon", "id")) %in% colnames(df))){
    stop("Coordinates columns missing or wrongly named.
        The following columns are obligatory: 'id','startLat', 'startLon', 'endLat', 'endLon'.")
  }

  colnames <- colnames(df)

  this <- optional %in% colnames
  use <- optional[this]

  serverNode <- rep(1:nrOfNodes,each=ceiling(nrow(df)/nrOfNodes))
  df$serverNode <- serverNode[1:nrow(df)]

  col_order <- c("serverNode", "id", "startLat",
                 "startLon", "endLat", "endLon")

  allCols <- c(col_order, use)

  bikerPower <- 100
  totalMass <- 90
  dragCoefficient <- 0.559
  rollingResistance <- 0.0077
  maxSpeed <- 45

  if(!("bikerPower" %in% use)){
    df$bikerPower <- bikerPower
  }

  if(!("totalMass" %in% use)){
    df$totalMass <- totalMass
  }

  if(!("dragCoefficient" %in% use)){
    df$dragCoefficient <- dragCoefficient
  }

  if(!("rollingResistance" %in% use)){
    df$rollingResistance <- rollingResistance
  }

  if(!("maxSpeed" %in% use)){
    df$maxSpeed <- maxSpeed
  }


  #Override values if preset is passed

  if(preset=="conventionalbike"){
      intersecPen <- 10
      df$maxSpeed <- 26

  }

  #https://www.gribble.org/cycling/power_v_speed.html

    if(preset=="e-bike"){
      #https://www.bosch-ebike.com/us/products/drive-units/
      #Simulate a sports drive
      df$bikerPower <- df$bikerPower*3 #Assuming turbo-mode
      df$bikerPower <- ifelse(df$bikerPower>250, 250, df$bikerPower)
      df$maxSpeed <- 26

     # https://www.bosch-ebike.com/en/everything-about-the-ebike-redirect/rund-ums-ebike/stories-experiences-and-adventures/ebike-weight-this-is-how-much-an-electric-bike-weighs
     #E-bikes weight ca. 22kg, so
       df$totalMass <- df$totalMass+8

      #https://doi.org/10.1016/j.trd.2013.02.001 e-bikes
      intersecPen <- 8
    }

    if(preset=="s-pedelec"){

      df$bikerPower <- df$bikerPower*3
      df$bikerPower <- ifelse(df$bikerPower>750, 750, df$bikerPower)
      df$totalMass <- df$totalMass+10
      df$maxSpeed <-45
      intersecPen <- 7
    }


  allCols <- c("serverNode", "id","startLat",
               "startLon", "endLat", "endLon", "bikerPower", "totalMass", "dragCoefficient", "rollingResistance", "maxSpeed")

  df <- df[,allCols]

  cl = parallel::makeCluster(nrOfNodes)

  env <- new.env()
  env$intersecPen <- intersecPen

  iter <- brouterR::splitForCores(df=df, nrOfNodes=nrOfNodes)
  parallel::clusterExport(cl, c("profile", "grepl", "calculateRoute"))
  parallel::clusterExport(cl, c("intersecPen"), envir = env)

  resultList <- parallel::clusterApplyLB(cl, iter, function(matrix){

    output <-  vector(mode='list', length=nrow(matrix))

    for(i in 1:nrow(matrix)){

      line <- matrix[i, ]
      id=line[2]

     thisRoute <-  tryCatch(
        expr={
          route <- brouterR::calculateRoute(startLat=line[3],
                                            startLon=line[4],
                                            endLat=line[5],
                                            endLon=line[6],
                                            bikerPower=line[7],
                                            totalMass=line[8],
                                            dragCoefficient=line[9],
                                            rollingResistance=line[10],
                                            maxSpeed=line[11],
                                            serverNodeId = line[1],
                                            outputFormat = "df",
                                            profile=profile)

           #Add penalty of 10secs for each traffic light intersection crossed:
          travelTime <- max(route$Time)+sum(base::grepl("traffic_sign", route$NodeTags)==TRUE)*intersecPen
          distance <- sum(route$Distance)
          energy <- max(route$Energy)

          #Calculate average slope:
          dElev <- diff(route$Elevation)
          route <- route[-1,]
          route$dElev <- dElev
          route$slope <- 100*route$dElev/route$Distance


      avgSlopeUp <- mean(route[route$slope>0,]$slope)
          avgSlopeDown <- mean(route[route$slope<0,]$slope)

          thisRoute <-(c(id=id,
                  travelTime=travelTime,
                  distance=distance,
                  energy=energy,
                  avgSlopeUp=avgSlopeUp,
                  avgSlopeDown=avgSlopeDown
                  ))


      },

      error=function(e){

                      thisRoute <- (c(id=id,
                        travelTime=-99,
                        distance=-99,
                        energy=-99,
                        avgSlopeUp=-99,
                        avgSlopeDown=-99
                        ))



      }) #End of tryCatch
      output[[i]] <- thisRoute

    }

      return(output)

    }

    )

  parallel::stopCluster(cl)

  res <- do.call(c, resultList)
  result <-data.frame(t(sapply(res,c)))
  result[result=="NaN"] <- NA

  return(result)

}
