#' Set up servers for running brouter
#'
#' @param nrOfNodes Define number of parallel nodes. Defaults to 1
#' @param nodeRAM Define RAM allocated to each node. Defaults to 128mb
#' @param pathToBRouter Set the path to brouter directory with correct folder structure.
#'
#' @return
#' @export
#'
#' @examples
#'
setServers <- function(nrOfNodes=1, nodeRAM=128, pathToBRouter=NULL){

  pathToBRouter <- gsub("/","\\", pathToBRouter, fixed=T)
  pathToBRouterWrite <- gsub("\\", "\\\\", pathToBRouter, fixed=T)
  
  drive <- substr(pathToBRouter,1,2)

  controller=c()
  for(i in 1:nrOfNodes){
    fileName=paste("server", "_",i,".bat", sep="")
    fileCreate=paste(pathToBRouter,"\\",fileName,sep="")
    content <- paste0(
      "start /min cmd /C \"", drive, " && cd ", pathToBRouterWrite, 
      " && java -Xmx", nodeRAM, "M -Xms", nodeRAM, 
      "M -Xmn8M -DmaxRunningTime=300 -cp brouter-1.6.3_brouterR-all.jar btools.server.RouteServer segments4 profiles2 customprofiles 17777 5 127.0.0.", i, "\""
    )
    contrLine <- paste("wscript ", "\"",pathToBRouterWrite,"\\","invisible.vbs","\" ", "\"",pathToBRouterWrite,"\\",
                       fileName,"\"",sep="")
    controller <- c(controller,contrLine)
    write(content,fileCreate)
  }
  #Write controllers
  FileName = paste(pathToBRouter, "\\", "wscript.sh", sep="")
  fileConn<-file(FileName)
  writeLines(controller, fileConn)
  close(fileConn)

  #Write vbs script to run everything invisibly (not pop up all the cmd prompts)
  invisible <- "CreateObject(\"Wscript.Shell\").Run \"\"\"\" & WScript.Arguments(0) & \"\"\"\", 0, False"
  write(invisible, paste(pathToBRouter,"\\invisible.vbs", sep=""))

  print("--Servers set")
}
