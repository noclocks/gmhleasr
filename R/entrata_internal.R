#' Entrata API Internal Helpers
#'
#' @name entrata_internal
#'
#' @description
#' Internal helper functions for the Entrata API request functions.
#'
#' - `validate_entrata_endpoint_method()`: Validate Entrata API Endpoint and Method
#' - `validate_entrata_method_params()`: Validate Entrata API Method Parameters
#' - `get_default_method()`: Get Default Method by Endpoint
#'
#' @param endpoint Entrata API Endpoint to validate.
#' @param method Entrata API Method to validate.
#' @param method_params List of parameters to validate.
#'
#' @return NULL
#'
#' @keywords internal
#'
#' @seealso [Entrata API Documentation](https://docs.entrata.com/api/v1/documentation/)

#' @rdname entrata_internal
#' @export
#' @keywords internal
#' @importFrom dplyr filter pull
#' @importFrom cli cli_abort
validate_entrata_endpoint_method <- function(endpoint, method) {
  # validate endpoint -------------------------------------------------------
  if (!(endpoint %in% entrata_api_request_endpoint_methods$endpoint)) {
    cli::cli_abort(
      paste0(
        "Invalid Entrata API endpoint: {endpoint}.",
        "Please choose from the available endpoints: ",
        "{.field {entrata_api_request_endpoints}}"
      )
    )
  }

  # validate method ---------------------------------------------------------
  available_methods <- entrata_api_request_endpoint_methods |>
    dplyr::filter(endpoint == !!endpoint) |>
    dplyr::pull(method) |>
    unique()

  if (!(method %in% available_methods)) {
    cli::cli_abort(
      paste0(
        "Invalid Entrata API method: {.field {method}}.",
        "Please choose from the available methods for the {.field {endpoint}/} endpoint: ",
        "{.field {available_methods}}"
      )
    )
  }
}

#' @rdname entrata_internal
#' @export
#' @keywords internal
validate_entrata_method_params <- function(endpoint, method, method_params) {
  return(NULL)
}

#' @rdname entrata_internal
#' @export
#' @keywords internal
#' @importFrom dplyr filter pull
get_default_method <- function(endpoint) {
  available_methods <- entrata_api_request_endpoint_methods |>
    dplyr::filter(endpoint == !!endpoint) |>
    dplyr::pull(method) |>
    unique()

  if (length(available_methods) > 0) {
    return(available_methods[[1]])
  } else {
    return(NULL)
  }
}

#' Create User Agent
#'
#' @description
#' Function to create a user agent string for `HTTP` requests.
#'
#' @param package Package name. Default is "gmhleasr".
#' @param version Package version. Default is the current version of "gmhleasr".
#' @param url Package URL. Default is the URL from the package's `DESCRIPTION` file.
#'
#' @return User agent string.
#' @export
#'
#' @importFrom utils packageVersion
#' @importFrom desc desc_get
#' @importFrom glue glue
#'
#' @examples
#' user_agent("gmhleasr", "0.0.1")
user_agent <- function(
    package = "gmhleasr",
    version = utils::packageVersion("gmhleasr"),
    url = desc::desc_get("URL"),
    overwrite = FALSE) {
  if (is.na(url)) {
    url <- ""
  } else {
    url <- paste0(" (", url, ")")
  }
  glue::glue("{package}/{version}{url}")
}

#' Request Error Helpers
#'
#' @name request_error
#'
#' @description
#' Helper functions for [httr2::req_error()]. These functions are used in
#' conjunction with the `req_error()` function to provide additional information
#' about the error that occurred during the request.
#'
#' @details
#' The Entrata API is unique in that it always returns a `200` status code,
#' regardless of the success or failure of the request. To determine if a request
#' was successful or not, we must inspect the response body. If the response body
#' contains an error message, we can assume that the request was not successful.
#'
#' @section Functions:
#' - `res_err_body()` - Extracts the error code and message from the response
#'   body. Used for the `body` argument in [httr2::req_error()].
#' - `res_is_err()` - Determines if the response is an error. This is used for the
#'   `is_error` argument in [httr2::req_error()].
#' - `res_err_retry()` - Determines if the request should be retried based off
#'   the response's error code.
#'
#' @seealso [httr2::req_error()]
#'
#' @param resp [httr2::response()] object
#'
#' @return
#' - `res_err_body()` - Error message as a string.
#' - `res_is_err()` - Logical value indicating whether the response is an error.
#' - `res_err_retry()` - Logical value indicating whether the request is retryable.
#'
NULL

#' @rdname request_error
#' @export
#' @importFrom httr2 resp_body_json
#' @importFrom purrr pluck
#' @importFrom glue glue
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

#' Request Retry Helpers
#'
#' @name request_retry
#'
#' @description
#' Helper functions for [httr2::req_retry()]. These functions are used in
#' conjunction with the `req_retry()` function to provide additional information
#' about the retry behavior of the request.
#'
#' This is particularly necessary when working with the [entrata_reports()]
#' functions that call the `/reports` endpoint's `getReportData` method since
#' this method returns a "queue id" that must be used to check the status of the
#' report generation via a call to the `/queue` endpoint's `getQueueStatus` method
#' passing it the "queue id" as a parameter.
#'
#' @details
#' The [httr2::req_retry()] function alters the HTTP request during
#' [httr2::req_perform()] so that it will automatically retry in the case
#' of a "transient" error. This is useful when working with APIs that may
#' experience temporary issues that can be resolved by retrying the request.
#'
#' @section Functions:
#' - `req_should_retry()` - Determines if the request should be retried based off
#'   the response's status code.
#' - `req_retry_is_transient()` - Determines if the request is transient and should
#'   be retried (applicable for the `/queue` endpoint's `getQueueStatus` method).
#' - `req_retry_backoff()` - Determines the backoff time for the request retry in
#'   seconds.
#' - `req_retry_after()` - Determines the time to wait before retrying the request
#'   based off the response headers.
#'
#' @seealso [httr2::req_retry()]
#'
#' @param resp [httr2::response()] object
#'
#' @return
#' - `req_should_retry()` - Logical value indicating whether the request should be
#'  retried.
#' - `req_retry_is_transient()` - Logical value indicating whether the request is
#'   transient and should be retried.
#' - `req_retry_backoff()` - The backoff time in seconds.
#' - `req_retry_after()` - The time to wait before retrying the request.
#'
NULL


#' @rdname request_retry
#' @export
#' @importFrom httr2 resp_body_json
#' @importFrom purrr pluck pluck_exists
req_should_retry <- function(resp) {
  retry_codes <- c(401, 403, 429, 500, 501, 502, 503, 504)
  resp_body <- httr2::resp_body_json(resp)
  if (!purrr::pluck_exists(resp_body, "response", "error")) {
    return(FALSE)
  }
  err_code <- purrr::pluck(resp_body, "response", "error", "code")
  if (err_code %in% retry_codes) {
    return(TRUE)
  }
  return(FALSE)
}

#' @rdname request_retry
#' @export
#' @importFrom httr2 resp_body_json
#' @importFrom purrr pluck_exists
req_retry_is_transient <- function(resp) {
  if (res_is_err(resp)) {
    return(TRUE)
  }
  resp_body <- httr2::resp_body_json(resp)
  if (purrr::pluck_exists(resp_body, "response", "error")) {
    return(TRUE)
  }
  return(FALSE)
}

#' @rdname request_retry
#' @export
req_retry_backoff <- function(n) {
  2^(n - 1)
}

#' @rdname request_retry
#' @export
#' @importFrom httr2 resp_body_json resp_headers
#' @importFrom purrr pluck
req_retry_after <- function(resp) {
  resp_headers <- resp |>
    purrr::pluck("headers") |>
    toupper()

  if ("X-RATELIMIT-RESET" %in% resp_headers) {
    rate_limit_reset <- as.numeric(httr2::resp_headers[["X-RATELIMIT-RESET"]])
    diff <- rate_limit_reset - as.numeric(unclass(Sys.time()))
    return(diff)
  }

  return(0)
}
