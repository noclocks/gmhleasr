# entrata default request body structure ----------------------------------

entrata_default_req_body <- list(
  auth = list(
    type = "basic"
  ),
  requestId = 15,
  method = list(
    name = NULL,
    params = list()
  )
)


# entrata default response body structure ---------------------------------

entrata_default_resp_body <- list(
  response = list(
    requestId = 15,
    code = 200,
    result = list()
  )
)
