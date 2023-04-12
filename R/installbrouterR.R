#' Install the brouterR files to a local path folder
#'
#' @param installationFolderPath installation path
#'
#' @return
#' @export
#'
#' @examples
installbrouterR <- function(installationFolderPath=NULL){

  destfile <- paste(tempdir(), "this.zip", sep="/")
  download.file("https://github.com/mflucas/brouterR/raw/master/Resources.zip", destfile=destfile)
  unzip(zipfile = destfile, exdir=installationFolderPath)

  print("Installation complete")
  print("REMINDER 1/2: Don't forget to install Java JDK 10 or above!!")
  print("REMINDER 2/2: Don't forget to download necessary segments at http://brouter.de/brouter/segments4/ and put them in the segments4 folder before running.")
}
