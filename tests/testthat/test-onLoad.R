
#  ------------------------------------------------------------------------
#
# Title : Tests Against .onLoad and .onAttach
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------

testthat::skip_if_not_installed("callr")

test_that("package loads without error", {
  testthat::expect_snapshot(
    callr::r(
      function() {
        library(gmhleasr)
      }
    )
  )
})
