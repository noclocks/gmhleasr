#  ------------------------------------------------------------------------
#
# Title : Test Helpers
#    By : Jimmy Briggs
#  Date : 2024-08-28
#
#  ------------------------------------------------------------------------


# mocks -------------------------------------------------------------------

mock_req_body <- list(
  auth = list(
    type = "basic"
  ),
  requestId = 15,
  method = list(
    name = "getStatus",
    version = "r1",
    params = list()
  )
)

mock_res_success <- list(
  response = list(
    requestId = "15",
    code = 200,
    result = list(
      status = "Success",
      message = "API service is available and running."
    )
  )
)

mock_res_error <- list(
  response = list(
    requestId = "15",
    error = list(
      code = 113,
      message = "Username and/or password is incorrect."
    )
  )
)


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
