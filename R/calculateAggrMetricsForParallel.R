#' Calculate aggregate metrics for each route.
#'
#' The output is a dataframe containing the travel time, distance, total elevation gain, upward and downward slope and energy expenditure for each route.
#' If brouter is not able to calculate the route, all variables will be returned with the value -99. Reasons for this may be coordinates outside the downloaded segment, or too far away from any nearby road.
#'
#' @param pathToBrouter Path to installation folder of brouter
#' @param profile The routing profile
#' @param x The list
#'
#' @return
#' @export
#' @keywords internal
#'
#' @examples
#'

calculateAggrMetricsForParallel <- function(x=NULL, pathToBrouter=NULL, profile="trekking"){


    thisResult <- listBasedRouteCalculator(x, profile)

    return(thisResult)

}
