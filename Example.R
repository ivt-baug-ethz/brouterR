library(brouterR)

x <- readline()
path <- x


brouterR::setServers(pathToBRouter = pathToBRouter)
brouterR::startServers(pathToBRouter = pathToBRouter)

dt2 <- brouterR::calculateRoute(startLat=47.401, startLon=8.5424, endLat=47.408, endLon=8.507)

library(RCurl)
start_time <- Sys.time()
url <- "http://127.0.0.10:17777/brouter?lonlats=8.5424,47.401|8.507,47.408&profile=trekking2&
alternativeidx=0&format=csv&bikerPower=100&totalMass=90&maxSpeed=45&dragCoefficient=0.9&rollingResistance=0.01"
# url2 <- "http://127.0.0.1:17777/brouter?lonlats=8.5424,47.401|8.507,47.408&profile=streetbike_touring&alternativeidx=0&format=csv"
download.file(url, "C:\\Users\\LMF\\polybox\\this.csv")

data2 <- read.table("C:\\Users\\LMF\\polybox\\this.csv", sep="\t", header=TRUE)

data$signalPenalty <- ifelse(grepl("crossing=traffic_signals",data$NodeTags),10,0)
(max(data$Time)+sum(data$signalPenalty))/60
end_time <- Sys.time()
end_time - start_time

brouterR::killServers()

#Test plans
file <- readline
plans <- read.table("C:/Users/LMF/polybox/BetwAcc_EBikeCity/Population/plans.txt", sep=";", header=T)

#Now format the coordinates in lists:
library(stringr)
plans$planCoords <- str_remove(plans$planCoords, "\\[|\\]")

plans$planCoords <- lapply(plans$planCoords, function(x) str_split(x, ","))


#Transform coordinates into table with from_to formatting

library(foreach)
# cl = parallel::makeCluster(11)
# doParallel::registerDoParallel(cl)


trips <-data.frame(statpopId=numeric(0),
                    legNr=numeric(0),
                    startLat=numeric(0),
                    startLon=numeric(0),
                    endLat=numeric(0),
                    endLon=numeric(0)
                    )

trips <- foreach(i=1:nrow(plans), .combine = rbind) %do%{

  statpopId <- plans[i, ]$statpopId
  lst <- plans[i,]$planCoords
  coordList <- lst[[1]][[1]]

  k=1
  for(j in 1:length(coordList)) {
  if(j>1){
  startLon=as.numeric(substr(gsub(".*x=\\s*|\\|.*","",coordList[j-1]),1,9))
  startLat=as.numeric(substr(gsub(".*y=\\s*|].*","",coordList[j-1]),1,9))
  endLon=as.numeric(substr(gsub(".*x=\\s*|\\|.*","",coordList[j]),1,9))
  endLat=as.numeric(substr(gsub(".*y=\\s*|].*","",coordList[j]),1,9))

  thisTrip <-c(statpopId=statpopId, legNr=k,
               startLat=startLat,
               startLon=startLon,
               endLat=endLat,
               endLon=endLon)

  trips <- rbind(trips, as.data.frame(t(thisTrip)))



  k=k+1

  }
  }
}

parallel::stopCluster(cl)

brouterR::setServers(pathToBRouter = pathToBRouter)

trips <- readRDS("C:\\Users\\LMF\\polybox\\BetwAcc_EBikeCity\\tripsFormatted\\trips_1.rds")
#test functions:

pathToBRouter <- readline()
trips$id <- trips$statpopId

library(brouterR)
brouterR::setServers(pathToBRouter = pathToBRouter, nrOfNodes =1)
brouterR::startServers(pathToBRouter = pathToBRouter, noServers=1)

start_time <- Sys.time()
test2 <- brouterR::calculateAggrMetrics(trips[1:1000,], serverNodeId=2)
end_time <- Sys.time()
end_time - start_time

start_time <- Sys.time()
test2 <- brouterR::parallelRouteCalculator(trips[1:1000,], 14, pathToBRouter)
end_time <- Sys.time()
end_time - start_time



test <- brouterR::calculateAggrMetricsForParallel(df, pathToBrouter = pathToBrouter, profile="trekking",
                                                  serverNodeId = 1)


test$speed=3.6*test$distance/test$travelTime

