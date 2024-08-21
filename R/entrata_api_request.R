
#  ------------------------------------------------------------------------
#
# Title : Entrata Base API Request
#    By : Jimmy Briggs
#  Date : 2024-08-20
#
#  ------------------------------------------------------------------------


# internal ----------------------------------------------------------------

#' Error Body
#'
#' @description
#' Function for [httr2::req_error()]'s `body` argument
#'
#' @param resp [httr2::response()] object
#'
#' @return Error message as a string.
#'
#' @keywords internal
#'
#' @importFrom httr2 resp_body_json
#' @importFrom purrr pluck
#' @importFrom glue glue
.err_body <- function(resp) {
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

#' Error Function
#'
#' @description
#' Function for [httr2::req_error()]'s `is_error` argument.
#'
#' @param resp [httr2::response()] object
#'
#' @return Logical value indicating whether the response is an error.
#'
#' @keywords internal
#'
#' @importFrom purrr pluck_exists
#' @importFrom httr2 resp_body_json
.err_func <- function(resp) {
  resp_body <- httr2::resp_body_json(resp)
  if (purrr::pluck_exists(resp_body, "response", "error")) {
    return(TRUE)
  }
  return(FALSE)
}

.should_retry <- function(resp) {
  retry_codes <- c(401, 403, 429, 500, 501, 502, 503, 504)
  resp_body <- httr2::resp_body_json(resp)
  err_code <- purrr::pluck(resp_body, "response", "error", "code")
  if (err_code %in% retry_codes) { return(TRUE) }
  return(FALSE)
}

# exported ----------------------------------------------------------------

#' Entrtata API Request
#'
#' @description
#' This function sends an `HTTP` request to the Entrata API.
#'
#' Use this function as a base template to create `HTTP` requests to the
#' Entrata API. This function is used by other functions in this package to
#' create requests to the Entrata API.
#'
#' @param endpoint Entrata API Endpoint to send the request to. Default is `NULL`.
#'   See details for the available endpoints.
#' @param method Entrata API Method to use in the request.
#'   Not to be confused with the `HTTP` request method (i.e. `GET`, `POST`),
#'   this method must be a method that is available in the Entrata API for the
#'   specified `endpoint`. The default value depends on whether the `endpoint`
#'   parameter was provided, if it is available the default value is the first
#'   method listed for that endpoint. If no endpoint is specified, `NULL`
#'   will be used as the method in the request body. See details for available
#'   methods by endpoint and more details on the structure of the request.
#' @param params List of parameters to use in the request. Default is an empty list.
#'   Some endpoint methods have required parameters that must be provided in the
#'   request. See details for more information on the structure of the request
#'   and required parameters by endpoint method.
#' @param ua User Agent string to use in the request. Default is to use [user_agent()].
#' @inheritParams httr2::req_perform
#' @param perform Logical value indicating whether to perform the request.
#'  Default is `FALSE`. If `FALSE`, the function will return the request object
#'  without performing the request. If `TRUE`, the function will perform the
#'  request and return the response object.
#' @param extract Logical value indicating whether to extract the response.
#'   Default is the value of `perform`. If `TRUE`, the function will extract the
#'   response object and return it. If `FALSE`, the function will return the
#'   response object as is.
#' @param max_retries Maximum number of times to retry the request. Default is `3`.
#'   If the request fails, the function will retry the request up to `max_retries`
#'   times before returning an error.
#' @param retry_delay Number of seconds to wait between retries. Default is `1`.
#'   The function will wait `retry_delay` seconds before retrying the request.
#'   The delay between retries will increase exponentially with each retry.
#' @param config Entrata API Configuration Values as a list. Default is to use
#'   `config::get("entrata")` to retrieve the configuration values from a
#'   `config.yml` configuration file. The configuration values should include
#'   the following keys: `username`, `password`, and `base_url`. See details.
#' @param ... Additional arguments not currently in use.
#'
#' @details
#' This function creates a request to the Entrata API using the `httr2` package.
#'
#' Specifically, the function creates an `HTTP POST` request to the Entrata API
#' by appending to the request's URL path the provided endpoint, assigning the
#' `POST` `HTTP` Method, adding the necessary authentication, populating the
#' necessary request headers, and deriving the request's body using the provided
#' `method` name and `params` parameters. See below for details.
#'
#' This is the raw format of the base template request:
#'
#' ```http
#' POST https://gmhcommunities.entrata.com/api/v1
#' Headers:
#' Content-Type: 'application/json; charset=UTF-8'
#' Accept: '*/*'
#' Accept-Language: 'en-US,en;q=0.9'
#' Cache-Control: 'no-cache'
#' Connection: 'keep-alive'
#' Origin: 'https://gmhcommunities.entrata.com'
#' Pragma: 'no-cache'
#' Referer: 'https://gmhcommunities.entrata.com/'
#' Authorization: '<REDACTED>'
#' Body: JSON Encoded Data
#' ```
#'
#' where the `Authorization` header is a `Basic` authentication header with the
#' provided username and password and the body is a JSON encoded data object using
#' the provided `method` and `params`:
#'
#' ```json
#' {
#' "data": {
#'   "auth": {
#'     "type": [
#'       "basic"
#'     ]
#'   },
#'   "requestId": [
#'     15
#'   ],
#'   "method": {
#'     "name": [
#'       "<method>"
#'     ],
#'     "version": [
#'       "r1"
#'     ],
#'     "params": {
#'       "param1": [
#'         "value1"
#'       ],
#'       "param2": [
#'         "value2"
#'       ]
#'     }
#'   }
#' }
#' }
#' ```
#'
#' @seealso [Entrata API Documentation](https://docs.entrata.com/api/v1/documentation/)
#' @seealso [MDN Web Docs: HTTP Caching](https://developer.mozilla.org/en-US/docs/Web/HTTP/Caching)
#' @seealso [httr2::req_auth_basic()], [httr2::request()], [httr2::req_body_json()],
#'   [httr2::req_headers()], [httr2::req_template()], [httr2::req_url_path_append()],
#'   [httr2::req_method()]
#'
#' @export
#'
#' @return [httr2::request()] object with the Entrata API request.
#'
#' @importFrom httr2 req_body_json req_auth_basic req_headers req_method
#' @importFrom httr2 req_url_path_append request
#' @importFrom config get
#' @importFrom glue glue
#' @importFrom rlang abort
#' @importFrom purrr pluck_exists pluck
#' @importFrom fs path_temp
entrata <- function(
  endpoint = NULL,
  method = NULL,
  params = list(NULL),
  ua = user_agent(),
  verbosity = NULL,
  perform = FALSE,
  extract = perform,
  enable_retry = FALSE,
  max_retries = 3,
  retry_delay = 1,
  config = config::get("entrata"),
  ...
) {

  base_url <- config$base_url

  req_body <- list(
    auth = list(
      type = "basic"
    ),
    requestId = 15,
    method = list(
      name = method,
      version = "r1",
      params = params
    )
  ) |>
    purrr::compact()

  username <- config$username
  password <- config$password

  req <- httr2::request(base_url) |>
    httr2::req_url_path_append("api", "v1") |>
    httr2::req_method("POST") |>
    httr2::req_auth_basic(username, password) |>
    httr2::req_headers(
      `Content-Type` = "application/json; charset=UTF-8"
    ) |>
    httr2::req_user_agent(ua) |>
    httr2::req_body_json(req_body) |>
    httr2::req_error(
      is_error = .err_func,
      body = .err_body
    )

  if (enable_retry) {
    req <- req |>
      httr2::req_retry(
        max_tries = max_retries,
        max_seconds = 60,
        is_transient = .should_retry,
        backoff = function(x) { retry_delay * 2^(x - 1) }
      )
  }

  if (!is.null(endpoint)) {
    req <- req |> httr2::req_url_path_append(endpoint)
  }

  if (!perform) {
    return(req)
  }

  res <- req |> httr2::req_perform(verbosity = verbosity)
  return(res)

}


