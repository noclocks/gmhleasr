
#  ------------------------------------------------------------------------
#
# Title : Mocking Test Helpers
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------

require(jsonlite)

# create a mock response --------------------------------------------------

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

# request body ------------------------------------------------------------

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


# successful response -----------------------------------------------------

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


# error response ----------------------------------------------------------

mock_res_error <- list(
  response = list(
    requestId = "15",
    error = list(
      code = 113,
      message = "Username and/or password is incorrect."
    )
  )
)
