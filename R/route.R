
#' Extract A Dataframe From A GPX File
#'
#' Takes a .gpx file as input and extracts the date, time, latitude, longitude
#' and elevation data to a data.frame. Geometry and point distances are
#' calculated with coercion to sf-class. Designed for use with .gpx files
#' downloaded from the Apple Health app, which represent individual workouts.
#'
#' @param gpx_file Character. Path to a valid .gpx file.
#' @param sf_out Logical. Retain sf-class in output (defaults to TRUE), or output
#'     as a data.frame only (FALSE)? Package {sf} is used within the function to
#'     calculate distance between points.
#'
#' @details The function usess the {sf} package to create a 'geometry' column
#'     from which distances can be generated between points along the route. You
#'     may want to retain the sf class for further geospatial analysis,
#'     otherwise you can output a regular data.frame with \code{sf_out = FALSE},
#'     which strips the sf metadata and the 'geometry' column.
#'
#' @return A data.frame, sf-class by default, with columns 'time' (datetime),
#'    'ele' (double), 'lon' (double), 'lat' (double) and 'distance'
#'    (units, metres); 'geometry' (POINT) if sf-class is retained with
#'    \code{sf_out = TRUE}.
#'
#' @examples
#' \dontrun{extract_gpx3d(gfx_segment)}
#'
#' @export
extract_gpx3d <- function(gpx_file, sf_out = TRUE) {

  .validate_extract_gpx3d(gpx_file, sf_out)

  gpx_in <- xml2::read_xml(gpx_file)
  gpx_list <- xml2::as_list(gpx_in)

  route_list <- lapply(
    gpx_list$gpx$trk$trkseg,
    function(x) .tabulate_gpx3d(x)
  )

  route_df <- do.call(rbind, route_list)
  rownames(route_df) <- NULL

  route_df <- sf::st_as_sf(
    route_df,
    coords = c("lon", "lat"),
    crs = 4326,
    remove = FALSE
  )

  # https://stackoverflow.com/questions/49853696/distances-of-points-between-rows-with-sf
  route_df$lead <- c(
    route_df$geometry[1],
    route_df$geometry[as.numeric(rownames(route_df)) - 1]
  )

  route_df$distance <- c(
    sf::st_distance(route_df$geometry, route_df$lead, by_element = TRUE)
  )

  route <- route_df[, c("time", "ele", "lon", "lat", "geometry", "distance")]

  if (!sf_out) {
    route_df <- as.data.frame(route_df)
    route <- route_df[, c("time", "ele", "lon", "lat", "distance")]
  }

  return(route)

}

#' Render A 3D Plot Of A Route From A GPX File
#'
#' Create a {ggplot2} plot object with a third dimension thanks to {ggrgl}. The
#' x and y coordinates are the longitude and latitude, the z dimension is the
#' elevation along the route. The chart title includes the total distance,
#' elevation disparity, plus the date and start/end times.
#'
#' @param route_df A data.frame, optionally sf-class. Output from must be in the
#'     format output via \code{\link{extract_gpx3d}}.
#' @param route_only Logical. Retain all chart elements if \code{FALSE}
#'     (default) or retain only the route path if \code{FALSE}.
#'
#' @return An interactive 3D rendering of the route path in a {devoutrgl}
#'     device.
#'
#' @examples
#' \dontrun{
#' x <- extract_gpx3d(gfx_segment)
#' plot_gpx3d(y)
#' }
#'
#' @export
plot_gpx3d <- function(route_df, route_only = FALSE) {

  .validate_plot_gpx3d(route_df, route_only)

  min_date   <- format(min(route_df$time), "%Y-%m-%d")
  min_time   <- format(min(route_df$time), "%H:%M:%S")
  max_time   <- format(max(route_df$time), "%H:%M:%S")
  total_dist <- round(sum(route_df$distance, na.rm = TRUE) / 1000, 1)
  min_elev   <- min(route_df$ele)
  max_elev   <- max(route_df$ele)
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
      ggplot2::aes(route_df$lon, route_df$lat, z = route_df$ele),
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
