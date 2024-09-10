#  ------------------------------------------------------------------------
#
# Title : Entrata Validation
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------

#' Entrata API Request Validations
#'
#' @name entrata_validation
#'
#' @description
#' Helper functions for validating Entrata API requests.
#'
#' @param endpoint Entrata API Endpoint to validate.
#' @param method Entrata API Endpoint Method to validate.
#' @param method_params List of method parameters to validate.
#' @param report_name Report name to validate.
#' @param ... Additional arguments to pass to the underlying validation functions.
#'
#' @return All validation functions are used for their side effects and have no
#'   return values, except for `validate_entrata_request()` which will
#'   return `TRUE` if validations pass.
#'
#' @seealso
#' [Entrata API Documentation](https://docs.entrata.com/api/v1/documentation/)
#'
#' @importFrom cli cli_abort cli_alert_info cli_alert_warning
#' @importFrom rlang abort inform warn
#' @importFrom dplyr filter pull
NULL

#' @rdname entrata_validation
#' @export
validate_entrata_request_endpoint <- function(endpoint) {
  if (!endpoint %in% entrata_api_request_endpoints) {
    cli::cli_abort(c(
      "Invalid Entrata API endpoint: {.val {endpoint}}",
      "i" = "Valid endpoints are: {.val {entrata_api_request_endpoints}}"
    ))
  }
}

#' @rdname entrata_validation
#' @export
validate_entrata_request_endpoint_method <- function(endpoint, method) {
  valid_methods <- entrata_api_request_endpoint_methods |>
    dplyr::filter(endpoint == !!endpoint) |>
    dplyr::pull(method)

  if (!method %in% valid_methods) {
    cli::cli_abort(c(
      "Invalid method {.val {method}} for endpoint {.val {endpoint}}",
      "i" = "Valid methods for this endpoint are: {.val {valid_methods}}"
    ))
  }
}

#' @rdname entrata_validation
#' @export
validate_entrata_request_method_params <- function(endpoint, method, method_params) {

  if (endpoint == "reports" && method == "getReportData") {
    cli::cli_alert_info(
      "No parameter validation is performed for the {.field {endpoint}/getReportData} method."
    )
    return(invisible())
  }

  expected_params <- entrata_api_request_parameters[[endpoint]][[method]]

  if (is.null(expected_params)) {
    cli::cli_alert_info("No parameters are expected for the {.field {method}} method.")
    return(invisible())
  }

  for (param_name in names(method_params)) {
    if (!param_name %in% names(expected_params)) {
      cli::cli_alert_warning("Unexpected parameter: {.field {param_name}}")
      next
    }

    param_info <- expected_params[[param_name]]
    param_value <- method_params[[param_name]]

    if (param_info$required && is.null(param_value)) {
      cli::cli_abort("Required parameter is missing: {.field {param_name}}")
    }

    if (!is.null(param_value)) {
      validate_param_type(param_name, param_value, param_info$type)

      if (!is.null(param_info$multiple) && param_info$multiple && length(param_value) > 1 && !is.vector(param_value)) {
        cli::cli_abort("Parameter {.field {param_name}} should be a vector for multiple values.")
      }
    }
  }
}

#' @rdname entrata_validation
#' @export
validate_entrata_request <- function(endpoint, method, method_params, ...) {
  validate_entrata_request_endpoint(endpoint)
  validate_entrata_request_endpoint_method(endpoint, method)
  validate_entrata_request_method_params(endpoint, method, method_params)
  TRUE
}

#' @rdname entrata_validation
#' @export
validate_entrata_report_name <- function(report_name, ...) {
  report_names <- get_entrata_reports_list(latest_only = TRUE) |>
    dplyr::pull("report_name") |>
    unique()

  if (!report_name %in% report_names) {
    cli::cli_abort(c(
      "Invalid report name: {.val {report_name}}",
      "i" = "Valid report names are: {.val {report_names}}",
      "i" = "Use `get_entrata_reports_list()` to see all available reports."
    ))
  }

  cli::cli_alert_info("The report name {.val {report_name}} is valid.")
}

# Helper functions ---------------------------------------------------------

validate_param_type <- function(param_name, param_value, expected_type) {

  switch(expected_type,
    "integer" = if (!is.integer(param_value) && !is_integer_string(param_value)) {
      cli::cli_abort("Parameter {.field {param_name}} should be an integer or integer string.")
    },
    "string" = if (!is.character(param_value)) {
      cli::cli_abort("Parameter {.field {param_name}} should be a string.")
    },
    "date" = if (!inherits(param_value, "Date") && !is.character(param_value)) {
      cli::cli_abort("Parameter {.field {param_name}} should be a Date object or date string.")
    },
    "boolean" = if (!is.logical(param_value) && !is_boolean_string(param_value)) {
      cli::cli_abort("Parameter {.field {param_name}} should be a logical value or boolean string.")
    },
    cli::cli_abort("Unknown parameter type: {.val {expected_type}}")
  )
}

#' Check if a string represents a boolean value
#'
#' @param str String to check
#' @return Logical indicating if the string represents a boolean value
#' @keywords internal
is_boolean_string <- function(str) {
  str %in% c("0", "1", "true", "false", "TRUE", "FALSE")
}

#' Check if a string represents an integer
#'
#' @param str String to check
#' @return Logical indicating if the string represents an integer
#' @keywords internal
is_integer_string <- function(str) {
  !is.na(suppressWarnings(as.integer(str)))
}

#' Check if a string represents multiple integers
#'
#' @param str String to check
#' @return Logical indicating if the string represents multiple integers
#' @keywords internal
is_integer_string_multi <- function(str) {
  if (grepl(",$", str)) return(FALSE)
  all(sapply(strsplit(str, ",")[[1]], is_integer_string))
}
