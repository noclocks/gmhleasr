#  ------------------------------------------------------------------------
#
# Title : Test Helpers
#    By : Jimmy Briggs
#  Date : 2024-08-28
#
#  ------------------------------------------------------------------------


# mock response -----------------------------------------------------------

# Helper function to create a mock response
create_mock_response <- function(status_code, body) {
  structure(
    list(
      status_code = status_code,
      headers = list(`Content-Type` = "application/json"),
      body = jsonlite::toJSON(body, auto_unbox = TRUE)
    ),
    class = "response"
  )
}

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

  rlang::abort("Could not find package root")
}
