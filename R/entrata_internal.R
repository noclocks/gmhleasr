
#' Entrata API Request Validations
#'
#' @name entrata_request_validation
#'
#' @description
#' Helper functions for validating Entrata API requests.
#'
#' - `validate_entrata_request_endpoint()`: Validate Entrata API Endpoint
#' - `validate_entrata_request_endpoint_method()`: Validate Entrata API Endpoint's Method
#' - `validate_entrata_request_method_params()`: Validate Entrata API Endpoint Method's Parameters
#' - `validate_entrata_request()`: Validate Entrata API Request by performing all validation checks
#'
#' @param endpoint Entrata API Endpoint to validate. Must be one of the available
#'   Entrata API endpoints.
#' @param method Entrata API Endpoint Method to validate. Should be one of the
#'   available methods for the specified endpoint.
#' @param method_params List of method parameters to validate. Should be a named list
#'   corresponding the the specific endpoint/method's available and required parameters.
#' @param arg,arg_endpoint,arg_method,arg_method_params Arguments to use for error messages.
#' @param call Environment to use for error messages. Defaults to the calling environment.
#' @param ... Additional arguments to pass to the underlying validation functions.
#'
#' @seealso [Entrata API Documentation](https://docs.entrata.com/api/v1/documentation/)
#'
#' @return All validation functions are used for their side effects have no
#'   return values, except for `validate_entrata_request()` which will
#'   return `TRUE` if validations pass.
NULL

#' @rdname entrata_request_validation
#' @export
#' @importFrom cli cli_abort
#' @importFrom rlang caller_arg caller_env
validate_entrata_request_endpoint <- function(
  endpoint,
  arg = rlang::caller_arg(endpoint),
  call = rlang::caller_env()
) {

  if (!endpoint %in% entrata_api_request_endpoints) {
    cli::cli_abort(
      message = c(
        "Invalid endpoint: {.field {endpoint}}",
        "{.arg {arg_endpoint}} is not a valid Entrata API endpoint.",
        "Please choose from the available endpoints: {.field {entrata_api_request_endpoints}}"
      ),
      call = call
    )
  }
}

#' @rdname entrata_request_validation
#' @export
#' @importFrom cli cli_abort
#' @importFrom rlang caller_arg caller_env !!
#' @importFrom dplyr filter
validate_entrata_request_endpoint_method <- function(
    endpoint,
    method,
    arg_endpoint = rlang::caller_arg(endpoint),
    arg_method = rlang::caller_arg(method),
    call = rlang::caller_env()
) {

  entrata_api_request_endpoint_methods_filtered <- entrata_api_request_endpoint_methods |>
    dplyr::filter(endpoint == !!endpoint)

  if (!method %in% entrata_api_request_endpoint_methods_filtered$method) {
    cli::cli_abort(
      message = c(
        "Invalid method for endpoint {.field {endpoint}}: {.field {method}}",
        "{.arg {arg_method}} is not a valid method for the {.arg {arg_endpoint}} endpoint.",
        "Please choose from the available methods for the {.arg {arg_endpoint}} endpoint: {.field {entrata_api_request_endpoint_methods[[endpoint]]}}"
      ),
      call = call
    )

  }

}

#' @rdname entrata_request_validation
#' @export
#' @importFrom cli cli_abort
#' @importFrom rlang caller_arg caller_env
validate_entrata_request_method_params <- function(
    endpoint,
    method,
    method_params,
    arg_endpoint = rlang::caller_arg(endpoint),
    arg_method = rlang::caller_arg(method),
    arg_method_params = rlang::caller_arg(method_params),
    call = rlang::caller_env()
) {

  expected_params <- entrata_api_request_parameters[[endpoint]][[method]]

  if (is.null(expected_params)) {
    cli::cli_alert_info(
      c(
        "No parameters are expected for the {.field {method}} method."
      )
    )
  } else {
    for (param_name in names(method_params)) {
      if (!param_name %in% names(expected_params)) {
        cli::cli_alert_warning(
          c(
            "Unexpected parameter: {.field {param_name}}"
          )
        )
      } else {
        param_info <- expected_params[[param_name]]
        param_value <- method_params[[param_name]]

        if (param_info$required && is.null(param_value)) {
          cli::cli_abort(
            c(
              "Required parameter is missing: {.field {param_name}}",
              "The {.field {param_name}} parameter is required for the {.field {method}} method.",
              "Please provide a value for the {.field {param_name}} parameter."
            ),
            call = call
          )
        }

        if (!is.null(param_value)) {
          if (param_info$type == "integer" && !is.integer(param_value)) {
            cli::cli_abort(
              c(
                "Parameter {.field {param_name}} should be an integer."
              ),
              call = call
            )
          } else if (param_info$type == "string" && !is.character(param_value)) {
            cli::cli_abort(
              c(
                "Parameter {.field {param_name}} should be a string."
              ),
              call = call
            )
          } else if (param_info$type == "date" && !inherits(param_value, "Date")) {
            cli::cli_abort(
              c(
                "Parameter {.field {param_name}} should be a Date object."
              ),
              call = call
            )
          } else if (param_info$type == "boolean" && !is.logical(param_value)) {
            cli::cli_abort(
              c(
                "Parameter {.field {param_name}} should be a logical value."
              ),
              call = call
            )
          } else if (param_info$type == "boolean_string" && !is_boolean_string(param_value)) {
            cli::cli_abort(
              c(
                "Parameter {.field {param_name}} should be a boolean string."
              ),
              call = call
            )
          }
          if (!is.null(param_info$multiple) && param_info$multiple && length(param_value) > 1 && !is.vector(param_value)) {
            cli::cli_abort(
              c(
                "Parameter {.field {param_name}} should be a vector for multiple values."
              ),
              call = call
            )
          }
        }
      }
    }
  }
}

#' @rdname entrata_request_validation
#' @export
#' @importFrom rlang caller_arg caller_env
validate_entrata_request <- function(
    endpoint,
    method,
    method_params,
    arg_endpoint = rlang::caller_arg(endpoint),
    arg_method = rlang::caller_arg(method),
    arg_method_params = rlang::caller_arg(method_params),
    call = rlang::caller_env(),
    ...
) {

  validate_entrata_request_endpoint(
    endpoint,
    arg_endpoint,
    call
  )

  validate_entrata_request_endpoint_method(
    endpoint,
    method,
    arg_endpoint,
    arg_method,
    call
  )

  validate_entrata_request_method_params(
    endpoint,
    method,
    method_params,
    arg_endpoint,
    arg_method,
    arg_method_params,
    call
  )

  return(TRUE)

}

#' Validate Entrata Report Name
#'
#' @description This function checks if a provided report name exists in the
#' list of available Entrata reports. If the report name is not valid,
#' an error is thrown with suggestions for valid report names.
#'
#' @param report_name A character string representing the report name to validate.
#' @param arg The argument name for the report name. Default is the caller's argument name.
#' @param call The calling environment. Default is the caller's environment.
#' @param ... Additional arguments to pass to the underlying validation functions.
#'
#' @return NULL. Throws an error if the report name is invalid.
#'
#' @export
#'
#' @importFrom cli cli_alert_info cli_abort
#' @importFrom dplyr filter pull
#' @importFrom rlang caller_arg caller_env
validate_entrata_report_name <- function(
  report_name,
  arg = rlang::caller_arg(report_name),
  call = rlang::caller_env(),
  ...
) {

  report_names <- get_entrata_reports_list(latest_only = TRUE) |>
    dplyr::pull("report_name") |>
    unique()

  if (!report_name %in% report_names) {

    cli::cli_abort(
      c(
        "The report name provided, {.arg report_name}, is not valid.",
        "Please choose from the available report names: ",
        "{.field {report_names}}",
        "If you are unsure of the available report names, you can use the ",
        "`get_entrata_reports_list()` function to retrieve the list of available reports."
      ),
      call = call
    )

  } else {

    cli::cli_alert_info(
      c(
        "The report name provided, {.arg report_name}, is valid."
      )
    )

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
    url = desc::desc_get(
      "URL",
      system.file("DESCRIPTION", package = package)
    )[[1]],
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
#' @importFrom dplyr filter pull
#' @importFrom rlang !!
get_default_method <- function(endpoint) {
  available_methods <- entrata_api_request_endpoint_methods |>
    dplyr::filter(endpoint == !!endpoint) |>
    dplyr::pull("method") |>
    unique()

  if (length(available_methods) > 0) {
    return(available_methods[[1]])
  } else {
    return(NULL)
  }
}
