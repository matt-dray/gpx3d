
.tabulate_gpx3d <- function(trkseg_list) {

  trkseg_attrs <- attributes(trkseg_list)

  data.frame(
    time = strptime(trkseg_list[["time"]][[1]], "%Y-%m-%dT%H:%M:%SZ"),
    ele  = as.numeric(trkseg_list[["ele"]][[1]]),
    lon  = as.numeric(trkseg_attrs[["lon"]]),
    lat  = as.numeric(trkseg_attrs[["lat"]])
  )

}

#' Extract Time, Coordinates And Elevation From a GPX File
#'
#' Takes a .gpx file as input and extract the date, time, latitude, longitude
#' and elevation data to a data.frame; converts it to sf-class with the
#' coordinates coerced to a geometry column. Designed for use with .gpx files
#' downloaded from the Apple Health app, which represent individual 'workouts'.
#'
#' @param gpx_file Character. Path to a valid .gpx file.
#'
#' @return sf-class data.frame with columns time, lon, lat, geometry, distance
#'
#' @examples
#' \dontrun{
#' x <- "apple_health_export/workout-routes/route_2021-12-25_9.31am.gpx"
#' extract_gpx3d(x)
#' }
#'
#' @export
extract_gpx3d <- function(gpx_file) {

  gpx_in <- xml2::read_xml(gpx_file)
  gpx_list <- xml2::as_list(gpx_in)

  route_list <- lapply(
    gpx_list$gpx$trk$trkseg,
    function(x) .tabulate_gpx3d(x)
  )

  route_df <- do.call(rbind, route_list)
  rownames(route_df) <- NULL

  route_sf <- sf::st_as_sf(
    route_df,
    coords = c("lon", "lat"),
    crs = 4326,
    remove = FALSE
  )

  # https://stackoverflow.com/questions/49853696/distances-of-points-between-rows-with-sf
  route_sf$lead <- c(
    route_sf$geometry[1],
    route_sf$geometry[as.numeric(rownames(route_sf)) - 1]
  )

  route_sf$distance <- c(
    sf::st_distance(route_sf$geometry, route_sf$lead, by_element = TRUE)
  )

  route_sf[, c("time", "ele", "lon", "lat", "geometry", "distance")]

}

#' Render A 3D Plot Of A Route From A GPX File
#'
#' Create a {ggplot2} plot object with a third dimension thanks to {ggrgl}. The x and y
#' coordinates are the longitude and latitude, the z dimension is the elevation along
#' the route. The chart title includes the total distance, elevation disparity, plus the
#' date and start/end times.
#'
#' @param route_sf sf-class data.frame, output from \code{\link{extract_gpx3d}}.
#' @param route_only Logical. Retain all chart elements if \code{FALSE} (default) or
#'     retain only the route path if \code{FALSE}.
#'
#' @return A 3D rendering of the route path in a {devoutrgl} device.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' x <- "~/Downloads/apple_health_export/workout-routes/route_2021-12-25_9.31am.gpx"
#' y <- extract_gpx3d(x)
#' plot_gpx3d(y)
#' }
plot_gpx3d <- function(route_sf, route_only = FALSE) {

  min_date   <- format(min(route_sf$time), "%Y-%m-%d")
  min_time   <- format(min(route_sf$time), "%H:%M:%S")
  max_time   <- format(max(route_sf$time), "%H:%M:%S")
  total_dist <- round(sum(route_sf$distance, na.rm = TRUE) / 1000, 1)
  min_elev   <- min(route_sf$ele)
  max_elev   <- max(route_sf$ele)
  elev_diff  <- round(max_elev - min_elev)

  route_plot <-
    ggplot2::ggplot() +
    ggplot2::labs(
      title = paste(
        total_dist, "km route with elevation disparity of", elev_diff, "m"
      ),
      subtitle = paste(min_date, "from", min_time, "to", max_time),
      caption = "Made with {ggplot2}, {ggrgl}, {sf}, {xml2}"
    ) +
    ggplot2::xlab("Longitude") +
    ggplot2::ylab("Latitude") +
    ggrgl::geom_path_3d(
      ggplot2::aes(route_sf$lon, route_sf$lat, z = route_sf$ele),
      extrude = TRUE,
      extrude_edge_colour = 'grey20',
      extrude_face_fill = 'grey80',
      extrude_edge_alpha = 0.2
    )

  if (route_only) {
    route_plot <- route_plot +
      ggplot2::theme_void() +
      ggplot2::theme(text = ggplot2::element_blank())
  }

  devoutrgl::rgldev(fov = 30, view_angle = -30)
  print(route_plot)
  invisible(grDevices::dev.off())

}
