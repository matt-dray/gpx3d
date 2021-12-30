test_that("extract works as expected", {

  x <- system.file("extdata", "segment.gpx", package = "gpx3d")
  y <- extract_gpx3d(x)
  z <- extract_gpx3d(x, FALSE)

  expect_length(y, 6)
  expect_type(y, "list")
  expect_identical(class(y), c("sf", "data.frame"))

  expect_length(z, 5)
  expect_type(z, "list")
  expect_identical(class(z), "data.frame")

  expect_error(extract_gpx3d("nonexistent.gpx"))

  expect_error(suppressWarnings(extract_gpx3d(mtcars)))
  expect_error(extract_gpx3d(1))
  expect_error(extract_gpx3d("x"))
  expect_error(extract_gpx3d(FALSE))

  expect_error(extract_gpx3d(x, mtcars))
  expect_error(extract_gpx3d(x, 1))
  expect_error(extract_gpx3d(x, "x"))

})

test_that("plot works as expected", {

  expect_error(plot_gpx3d(mtcars))
  expect_error(plot_gpx3d(1))
  expect_error(plot_gpx3d("x"))
  expect_error(plot_gpx3d(FALSE))

  expect_error(plot_gpx3d(gpx_segment, mtcars))
  expect_error(plot_gpx3d(gpx_segment, 1))
  expect_error(plot_gpx3d(gpx_segment, "x"))

})
