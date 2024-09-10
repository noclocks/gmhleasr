#  ------------------------------------------------------------------------
#
# Title : Test Helpers
#    By : Jimmy Briggs
#  Date : 2024-08-28
#
#  ------------------------------------------------------------------------

require(rprojroot)
require(cli)

# package root ------------------------------------------------------------

test_package_root <- function() {
  hold <- tryCatch(
    rprojroot::find_package_root_file(),
    error = function(e) NULL
  )

  if (!is.null(hold)) {
    return(hold)
  }

  pkg <- testthat::testing_package()

  hold <- tryCatch(
    rprojroot::find_package_root_file(
      path = file.path("..", "..", pkg)
    ),
    error = function(e) NULL
  )

  if (!is.null(hold)) {
    return(hold)
  }

  cli::cli_abort(
    c(
      "Could not find package root",
      "Please ensure that the package is in a valid directory"
    ),
    call = rlang::caller_env()
  )
}

# skips -------------------------------------------------------------------

skip_on_local <- function() {
  if (is_cicd() || is_github()) {
    return(invisible())
  }
  testthat::skip("Test skipped on CI/CD")
}



