# gpx3d 0.0.0.9002

* Added `sf_out` argument to allow user to strip sf-class from `extract_gpx3d()` if desired.
* Added demo gpx `segment.gpx` and output file `gpx_segment`.
* Used in-package .gpx file in the README demo.
* Improved input handling.
* Added tests.

# gpx3d 0.0.0.9001

* BREAKING: rename functions for consistency (`extract_gpx_route()` to `extract_gpx3d()`, `plot_gpx_route()` to `plot_gpx3d()`).

# gpx3d 0.0.0.9000

* Added exported functions `extract_gpx_route()` and `plot_gpx_route()`.
* Created package structure, added NEWS, CoC, license, README.
* Added GitHub Actions for R CMD check and test coverage.
