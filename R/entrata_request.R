#  ------------------------------------------------------------------------
#
# Title : Entrata Base API Request
#    By : Jimmy Briggs
#  Date : 2024-08-20
#
#  ------------------------------------------------------------------------


# internal ----------------------------------------------------------------


# exported ----------------------------------------------------------------

#' Entrata API Request
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
#' @param method_version Entrata API Method Version to use in the request. Default is `"r1"`.
#'   Some endpoints have multiple versions of the same method. The version
#'   should be provided as a string. See details for more information on the
#'   structure of the request and available versions by endpoint method.
#' @param method_params List of parameters to use in the request body's `"method"`
#'   object. Default is an empty list. The parameters should be provided as a
#'   named list where the names are the parameter names and the values are the
#'   parameter values. See details for more information on the structure of the
#'   request and available parameters by endpoint method.
#'   The default value depends on whether the `endpoint` parameter was provided,
#'   if it is available the default value is an empty list. If no endpoint is
#'   specified, `NULL` will be used as the method in the request body.
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
#' @param enable_retry Logical value indicating whether to enable request retry.
#'   Default is `FALSE`. If `TRUE`, the function will enable request retry with
#'   the default retry settings. If `FALSE`, the function will not enable request
#'   retry.
#' @param timeout Numeric value indicating the request timeout in seconds.
#'   Default is `NULL`. If provided, the function will set the request timeout
#'   to the provided value in seconds.
#' @param dry_run Logical value indicating whether to perform a dry run of the request.
#'   Default is `FALSE`. If `TRUE`, the function will perform a dry run of the
#'   request before performing the actual request (or if `perform` is not set,
#'   will return the request object without performing the request).
#' @param progress Logical value indicating whether to show progress of the request.
#'   Only useful for long running requests. Default is `FALSE`. If `TRUE`, the
#'   function will show the progress of the request.
#' @param config Entrata API Configuration Values as a list. Default is to use
#'   `config::get("entrata")` to retrieve the configuration values from a
#'   `config.yml` configuration file. The configuration values should include
#'   the following keys: `username`, `password`, and `base_url`. See details.
#' @param ... Additional arguments to pass to the request object.
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
    method_version = "r1",
    method_params = list(NULL),
    ua = user_agent(),
    verbosity = NULL,
    perform = FALSE,
    extract = perform,
    enable_retry = FALSE,
    timeout = NULL,
    dry_run = FALSE,
    progress = FALSE,
    config = config::get("entrata"),
    ...
) {

  base_url <- config$base_url

  if (is.null(method)) {
    method <- get_default_method(endpoint)
  }

  validate_entrata_endpoint_method(endpoint, method)
  validate_entrata_method_params(endpoint, method, method_params)

  req_body <- list(
    auth = list(
      type = "basic"
    ),
    requestId = 15,
    method = list(
      name = method,
      version = method_version,
      params = method_params
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
    httr2::req_error(
      is_error = res_is_err,
      body = res_err_body
    ) |>
    httr2::req_body_json(req_body) |>
    httr2::req_verbose(
      header_req = TRUE,
      header_resp = TRUE,
      body_req = TRUE,
      body_resp = TRUE,
      info = TRUE,
      redact_headers = TRUE
    )

  if (!is.null(endpoint)) {
    req <- req |> httr2::req_url_path_append(endpoint)
  }

  if (enable_retry) {
    req <- req |>
      httr2::req_retry(
        max_tries = 5,
        max_seconds = 60,
        is_transient = req_retry_is_transient,
        backoff = req_retry_backoff
      )
  }

  if (!is.null(timeout) && is.numeric(timeout)) {
    req <- req |>
      httr2::req_timeout(seconds = timeout)
  }

  if (progress) {
    req <- req |>
      httr2::req_progress()
  }

  if (dry_run) {
    cli::cli_alert_info(
      "Dry Run: Request will not be performed. Redacted headers are shown."
    )
    httr2::req_dry_run(req, quiet = FALSE, redact_headers = TRUE)
  }

  if (!perform) {
    return(req)
  }

  res <- req |> httr2::req_perform(verbosity = verbosity)
  return(res)
}
