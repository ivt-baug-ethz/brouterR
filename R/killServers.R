#' Kill all running brouter servers
#'
#'
#' @return
#' @export
#'
#' @keywords internal
#' @noRd
#'
#' @examples
killServers <- function(){
library(stringr)

this <- shell("netstat -ano | findstr :17777", intern=T)
for(i in this){
  pid <- as.numeric(stringr::str_extract(i, "\\b\\w+$"))
  string <- paste("taskkill /F /PID ", pid, sep="")

  shell(string)
  }
}
