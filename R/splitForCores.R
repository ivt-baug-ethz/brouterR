
#' Split df into list of lists to be passed to each core
#'
#' @param df
#'
#' @return
#' @export
#' @keywords internal
#' @noRd
#'
#' @examples
splitForCores <- function(df, nrOfNodes){

final <- vector(mode='list', length=nrOfNodes)

kk=0
for(i in unique(df$serverNode)){
  kk=kk+1

  x <- df[df$serverNode==i, ]
  # x <- lapply(split(x, row.names(x)), unlist)
  x <- as.matrix(x)

  final[[kk]] <- x
}

return(final)

}

