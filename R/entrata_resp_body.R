
#  ------------------------------------------------------------------------
#
# Title : Entrata API Response Body
#    By : Jimmy Briggs
#  Date : 2024-09-09
#
#  ------------------------------------------------------------------------

# Entrata Specific Parser for Response Body JSON
# Should try perform `resp_body_json` and then pluck the `response` object

entrata_resp_body_json <- function(resp) {

  resp_body <- httr2::resp_body_json(resp)

  if (!purrr::pluck_exists(resp_body, "response")) {
    cli::cli_alert_danger("Response does not contain a 'response' object.")
    return(resp)
  }

  resp_request_id <- purrr::pluck(
    resp_body,
    "response",
    "requestId"
  )

  resp_code <- purrr::pluck(
    resp_body,
    "response",
    "code"
  )

  resp_result <- purrr::pluck(
    resp_body,
    "response",
    "result"
  )

  out <- list(
    request_id = resp_request_id,
    code = resp_code,
    result = resp_result
  )

}

entrata_resp_is_error <- function(resp) {

  resp_body <- httr2::resp_body_json(resp)

  if (purrr::pluck_exists(resp_body, "response", "error")) {
    return(TRUE)
  }

  return(FALSE)

}

entrata_resp_error_body <- function(resp) {

  if (!entrata_resp_is_error(resp)) {
    cli::cli_alert_info("Response is not an error.")
    return(NULL)
  }

  err <- httr2::resp_body_json(resp) |>
    purrr::pluck("response", "error")
  err_code <- err$code
  err_msg <- err$message

  cli::cli_bullets(
    c(
      "i" = "HTTP Error Status Code: {err_code}",
      "i" = "HTTP Error Message: {err_msg}"
    )
  )

  return(err)
}

res_err_body <- function(resp) {
  err <- httr2::resp_body_json(resp) |>
    purrr::pluck(
      "response",
      "error"
    )
  err_code <- err$code
  err_msg <- err$message
  return(
    glue::glue(
      "Error Code: {err_code}\n",
      "Error Message: {err_msg}"
    )
  )
}

#' @rdname request_error
#' @export
#' @importFrom purrr pluck_exists
#' @importFrom httr2 resp_body_json
res_is_err <- function(resp) {
  resp_body <- httr2::resp_body_json(resp)
  if (purrr::pluck_exists(resp_body, "response", "error")) {
    return(TRUE)
  }
  return(FALSE)
}
