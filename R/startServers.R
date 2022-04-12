#' Start running servers
#'
#' @param pathToBrouterDir path to Brouter directory
#' @param noServers number of servers, defaults to 1
#'
#' @return none
#' @export
#'
#' @keywords internal
#'
#' @examples
#'
startServers <- function(pathToBRouter=NULL, noServers=1){

  oldwd <- getwd()
  setwd(pathToBRouter)

  shell.exec("wscript.sh")

  setwd(oldwd)
}
