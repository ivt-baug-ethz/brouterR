#' Plot html map view of route
#'
#' Uses the leaflet package to plot the route on a map.
#'
#' @param route A route result from calculateRoute as an st_linestring object.
#' @param plotOnViewer If the map should directly be plotted on RStudio-Viewer or not. If TRUE, nothing is returned, if FALSE, the function returns an object, which can be saved to file using the saveWidget function of the htmlwidgets package.
#' @param backgroundTile A background tile of your choice (see list of options in leaflet::providers$)
#' @param tileOpacity Opacity of background tiles.
#' @param routeOpacity Opacity of displayed route.
#' @param routeColour Colour of displayed route.
#' @param routeWeight Weight of displayed route.
#'
#' @param
#' @return
#' @export
#' @import leaflet
#'
#' @examples
#'
#'
plotRoute <- function(route=NULL, plotOnViewer=TRUE, backgroundTile=providers$OpenStreetMap, tileOpacity=0.8, routeOpacity=0.8, routeColour="blue", routeWeight=2){
  map <- leaflet::leaflet() %>%
    leaflet::addProviderTiles(backgroundTile, options = providerTileOptions(opacity = tileOpacity)) %>%
    leaflet::addPolylines(data=st_zm(route), opacity = routeOpacity, color = routeColour, weight=routeWeight)

  if(plotOnViewer==TRUE){
    map
  } else {
    return(map)
  }

}

