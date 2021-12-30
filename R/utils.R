
.tabulate_gpx3d <- function(trkseg_list) {

  trkseg_attrs <- attributes(trkseg_list)

  data.frame(
    time = strptime(trkseg_list[["time"]][[1]], "%Y-%m-%dT%H:%M:%SZ"),
    ele  = as.numeric(trkseg_list[["ele"]][[1]]),
    lon  = as.numeric(trkseg_attrs[["lon"]]),
    lat  = as.numeric(trkseg_attrs[["lat"]])
  )

}

.validate_extract_gpx3d <- function(gpx_file, sf_out) {

  if (!grepl(".gpx$", gpx_file)) {
    stop("'gpx_file' must be a path to a file with extension '.gpx'")
  }

  if (!file.exists(gpx_file)) {
    stop("'gpx_file' must be a filepath to an existing .gpx file")
  }

  if (!is.logical(sf_out)) {
    stop("'sf_out' must be TRUE or FALSE")
  }

}

.validate_plot_gpx3d <- function(route_df, route_only) {

  if (!is.data.frame(route_df)) {
    stop("'route_df' must have class data.frame, preferably sf-class")
  }

  if (
    sum(names(route_df) %in% c("time", "ele", "lon", "lat", "distance")) != 5
  ) {
    stop(
      paste(
        "'route_df' must contain columns 'time', 'ele', 'lon', 'lat' and\n",
        "'distance'; optionally 'geometry' if sf-class"
      )

    )
  }

  if (!is.logical(route_only)) {
    stop("'route_only' must be TRUE or FALSE")
  }

}
