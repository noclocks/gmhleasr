#' @title Entrata API Manager Client
#'
#' @description
#' This is a wrapper [R6::R6Class()] that provides a high-level interface for
#' interacting with the [Entrata API](https://api.entrata.com/v1/documentation/).
#'
#' It handles authentication, request parameter validation and construction,
#' and response parsing, making it easy for developers to work with the API.
#'
#' @details
#' This class ...
#'
#' @field config A list containing the Entrata API configuration, including
#'   the username, password, and API base URL.
#'
#' @field user_agent The user agent string to use for API requests.
#'
#' @export
#'
#' @importFrom httr2 req_auth_basic req_headers req_url_path_append request
#' @importFrom purrr compact
#' @importFrom glue glue
#' @importFrom rlang abort
#' @importFrom config get
EntrataAPI <- R6::R6Class(
  classname = "EntrataAPI",

  public = list(
    config = NULL,
    user_agent = NULL,

    #' @description
    #' Initializes the Entrata API manager with the provided configuration.
    #' If no configuration is provided, the default configuration will be used.
    #'
    #' @param config A list containing the Entrata API configuration.
    #'
    #' @return The initialized Entrata API manager.
    initialize = function(config = config::get("entrata")) {
      self$config <- validate_entrata_config(config)
      self$user_agent <- user_agent("gmhleasr", utils::packageVersion("gmhleasr"))
    },

    #' @description
    #' Sends a request to the Entrata API.
    #'
    #' @param endpoint The Entrata API endpoint to call.
    #' @param method The Entrata API method to use.
    #' @param method_version The version of the API method to use.
    #' @param method_params A named list of parameters to include in the API request.
    #' @param enable_retry Logical, should the request be retried on failure?
    #' @param timeout Numeric, the request timeout in seconds.
    #' @param progress Logical, should progress be shown for the request?
    #' @param ... Additional arguments to pass to the underlying `httr2::req_perform()` call.
    #'
    #' @return The response object from the API request.
    #' @export
    send_request = function(endpoint,
                            method,
                            method_version = "r1",
                            method_params = list(),
                            enable_retry = FALSE,
                            timeout = NULL,
                            progress = FALSE,
                            ...) {
      validate_entrata_endpoint_method(endpoint, method)
      validate_entrata_method_params(endpoint, method, method_params)

      req_body <- list(
        auth = list(type = "basic"),
        requestId = 15,
        method = list(
          name = method,
          version = method_version,
          params = method_params
        )
      ) |> purrr::compact()

      req <- httr2::request(self$config$base_url) |>
        httr2::req_url_path_append("api", "v1") |>
        httr2::req_method("POST") |>
        httr2::req_auth_basic(self$config$username, self$config$password) |>
        httr2::req_headers(`Content-Type` = "application/json; charset=UTF-8") |>
        httr2::req_user_agent(self$user_agent) |>
        httr2::req_error(is_error = res_is_err, body = res_err_body) |>
        httr2::req_body_json(req_body)

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
        req <- req |> httr2::req_timeout(seconds = timeout)
      }

      if (progress) {
        req <- req |> httr2::req_progress()
      }

      req |> httr2::req_perform(...)
    },

    #' @description
    #' Retrieves the list of available Entrata reports.
    #'
    #' @param latest_only Logical, should only the latest version of each report be returned?
    #'
    #' @return A tibble containing the report information.
    #' @export
    get_reports_list = function(latest_only = TRUE) {
      self$send_request(
        endpoint = "reports",
        method = "getReportList",
        method_params = list(),
        enable_retry = TRUE
      ) |>
        parse_entrata_reports_list(latest_only = latest_only)
    },

    #' @description
    #' Retrieves detailed information for a specific Entrata report.
    #'
    #' @param report_name The name of the report to retrieve information for.
    #' @param report_version The version of the report to retrieve information for.
    #'
    #' @return A list containing the report name, description, and filters.
    #' @export
    get_report_info = function(report_name, report_version = "latest") {
      self$send_request(
        endpoint = "reports",
        method = "getReportInfo",
        method_params = list(
          reportName = report_name,
          reportVersion = if (report_version == "latest") {
            self$get_latest_report_version(report_name)
          } else {
            report_version
          }
        ),
        enable_retry = TRUE
      ) |>
        parse_entrata_report_info()
    },

    #' @description
    #' Retrieves the latest version of a specific Entrata report.
    #'
    #' @param report_name The name of the report to retrieve the latest version for.
    #'
    #' @return The latest version of the report as a character string.
    #' @export
    get_latest_report_version = function(report_name) {
      reports_list <- self$get_reports_list(latest_only = TRUE)
      reports_list |>
        dplyr::filter(report_name == !!report_name) |>
        dplyr::pull(report_version)
    },

    #' @description
    #' Generates a pre-lease report in Entrata.
    #'
    #' @param property_ids A vector of property IDs to include in the report.
    #' @param period_start The start date of the reporting period.
    #' @param ... Additional parameters to pass to the report generation.
    #'
    #' @return A list containing the summary and details of the pre-lease report.
    #' @export
    generate_pre_lease_report = function(property_ids, period_start = "2024-09-01", ...) {
      report_params <- prep_pre_lease_report_params(
        latest_report_version = self$get_latest_report_version("pre_lease"),
        property_group_ids = self$get_property_ids(),
        period_start_date = period_start,
        ...
      )

      self$send_request(
        endpoint = "reports",
        method = "getReportData",
        method_version = "r3",
        method_params = report_params,
        enable_retry = TRUE,
        progress = TRUE
      ) |>
        parse_entrata_pre_lease_report()
    },

    #' @description
    #' Retrieves the list of property IDs from the Entrata API.
    #'
    #' @return A vector of property IDs.
    #' @export
    get_property_ids = function() {
      self$send_request(
        endpoint = "properties",
        method = "getProperties",
        method_params = list(),
        enable_retry = TRUE
      ) |>
        parse_entrata_property_ids()
    }
  ),


  private = NULL,
  active = NULL,
  inherit = NULL,
  lock_objects = TRUE,
  class = TRUE,
  portable = TRUE,
  lock_class = FALSE,
  cloneable = TRUE,
  parent_env = parent.frame()
  # lock

)
