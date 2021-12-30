#' A Workout Route Segment
#'
#' An sf-class data.frame with a row per point recorded along a workout route,
#' originally exported as a gpx file from Apple Health and with data exported
#' by the \code{\link{extract_gpx3d}} function.
#'
#' @format An sf-class data.frame with 501 features and 5 fields:
#' \describe{
#'   \item{time}{datetime}
#'   \item{ele}{elevation (metres)}
#'   \item{lon}{longitude}
#'   \item{lat}{latitude}
#'   \item{geomatry}{sf-class POINT geometry of lon-lat}
#'   \item{distance}{units (metres), distance between this point and the previous}
#' }
"gpx_segment"
