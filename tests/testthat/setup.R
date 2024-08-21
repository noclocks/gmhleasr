
# setup -------------------------------------------------------------------

library(httr2)
library(httptest2)

options(httptest2.verbose = TRUE)

cfg <- config::get("entrata", file = here::here("config.yml"))

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
