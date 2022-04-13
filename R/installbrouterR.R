#' Install the brouterR files to a local path folder
#'
#' @param installationFolderPath installation path
#'
#' @return
#' @export
#'
#' @examples
installbrouterR <- function(installationFolderPath=NULL){

  paths <- .libPaths()

  for(i in 1:length(paths)){
    path <- paths[i]
    if(any(list.files(path)=="brouterR")){


    }
  }

  print("Installation complete")
  print("Don't forget to download necessary segments at http://brouter.de/brouter/segments4/ and put them in the segments4 folder before running.")
}
