# Write a demo dataset segment from a gpx file in package inst/extdata/

gpx_segment <- extract_gpx3d(
  system.file("extdata", "segment.gpx", package = "gpx3d")
)

usethis::use_data(gpx_segment, overwrite = TRUE)
