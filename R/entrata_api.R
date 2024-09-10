#' Entrata API Manager Client
#'
#' @description
#' This R6 class provides a high-level interface for interacting with the Entrata API.
#' It handles authentication, request parameter validation, request construction,
#' response parsing, caching, and error handling, making it easy for developers
#' to work with the API efficiently and reliably.
#'
#' @details
#' The EntrataAPI class encapsulates all the necessary logic for interacting with the Entrata API,
#' including request construction, authentication, error handling, and response parsing.
#' It also implements caching to improve performance for frequently accessed data.
#'
#' @export
#'
#' @importFrom R6 R6Class
#' @importFrom httr2 req_auth_basic req_headers req_url_path_append request req_perform
#' @importFrom purrr compact
#' @importFrom glue glue
#' @importFrom rlang abort inform
#' @importFrom memoise memoise
#' @importFrom cachem cache_disk
#'
#' @examples
#' \dontrun{
#' # Create an API client with default configuration
#' api <- EntrataAPI$new()
#'
#' # Create an API client with custom configuration
#' config <- create_entrata_config(
#'   username = "your_username",
#'   password = "your_password",
#'   base_url = "https://your-subdomain.entrata.com"
#' )
#' api <- EntrataAPI$new(config)
#'
#' # Get the list of available reports
#' reports <- api$get_reports_list()
#'
#' # Get information about a specific report
#' report_info <- api$get_report_info("pre_lease")
#'
#' # Generate a pre-lease report
#' pre_lease_report <- api$generate_pre_lease_report(property_ids = c(1234, 5678))
#'
#' # Get the list of property IDs
#' property_ids <- api$get_property_ids()
#' }
EntrataAPI <- R6::R6Class(
  classname = "EntrataAPI",
  public = list(
    #' @field config An APIConfig object containing the Entrata API configuration.
    config = NULL,

    #' @description
    #' Initialize a new EntrataAPI object.
    #'
    #' @param config An APIConfig object or a list containing the Entrata API configuration.
    #'   If not provided, a default configuration will be created using [create_entrata_config()].
    #'
    #' @return A new `EntrataAPI` object.
    initialize = function(config = create_entrata_config()) {
      self$config <- if (inherits(config, "APIConfig")) config else create_entrata_config(config)
      private$setup_caching()
      private$setup_logging()
    },

    #' @description
    #' Send a request to the Entrata API.
    #'
    #' @param endpoint Character string specifying the Entrata API endpoint to call.
    #' @param method Character string specifying the Entrata API method to use.
    #' @param method_version Character string specifying the version of the API method to use. Default is "r1".
    #' @param method_params A named list of parameters to include in the API request.
    #' @param enable_retry Logical indicating whether to enable request retrying on failure.
    #' @param timeout Numeric specifying the request timeout in seconds.
    #' @param progress Logical indicating whether to show a progress bar for the request.
    #' @param use_cache Logical indicating whether to use caching for this request.
    #' @param ... Additional arguments to pass to the underlying `httr2::req_perform()` call.
    #'
    #' @return The response object from the API request.
    #'
    #' @examples
    #' \dontrun{
    #' api <- EntrataAPI$new()
    #' response <- api$send_request(
    #'   endpoint = "properties",
    #'   method = "getProperties",
    #'   method_params = list(propertyId = 1234),
    #'   enable_retry = TRUE
    #' )
    #' }
    send_request = function(endpoint,
                            method,
                            method_version = "r1",
                            method_params = list(),
                            enable_retry = FALSE,
                            timeout = NULL,
                            progress = FALSE,
                            use_cache = TRUE,
                            ...) {
      validate_entrata_endpoint_method(endpoint, method)
      validate_entrata_method_params(endpoint, method, method_params)

      cache_key <- private$generate_cache_key(endpoint, method, method_params)

      if (use_cache && !is.null(private$cache)) {
        cached_response <- private$cache$get(cache_key)
        if (!is.null(cached_response)) {
          rlang::inform("Returning cached response")
          return(cached_response)
        }
      }

      req_body <- list(
        auth = list(type = "basic"),
        requestId = as.integer(Sys.time()),
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
        httr2::req_user_agent(self$config$user_agent) |>
        httr2::req_error(is_error = private$res_is_err, body = private$res_err_body) |>
        httr2::req_body_json(req_body)

      if (!is.null(endpoint)) {
        req <- req |> httr2::req_url_path_append(endpoint)
      }

      if (enable_retry) {
        req <- req |>
          httr2::req_retry(
            max_tries = 5,
            max_seconds = 60,
            is_transient = private$req_retry_is_transient,
            backoff = private$req_retry_backoff
          )
      }

      if (!is.null(timeout) && is.numeric(timeout)) {
        req <- req |> httr2::req_timeout(seconds = timeout)
      }

      if (progress) {
        req <- req |> httr2::req_progress()
      }

      response <- tryCatch({
        httr2::req_perform(req, ...)
      }, error = function(e) {
        private$log_error(glue::glue("API request failed: {e$message}"))
        rlang::abort(glue::glue("API request failed: {e$message}"))
      })

      if (use_cache && !is.null(private$cache)) {
        private$cache$set(cache_key, response)
      }

      response
    },

    #' @description
    #' Retrieve the list of available Entrata reports.
    #'
    #' @param latest_only Logical indicating whether to return only the latest version of each report.
    #'
    #' @return A tibble containing the report information.
    #'
    #' @examples
    #' \dontrun{
    #' api <- EntrataAPI$new()
    #' reports <- api$get_reports_list()
    #' print(reports)
    #' }
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
    #' Retrieve detailed information for a specific Entrata report.
    #'
    #' @param report_name Character string specifying the name of the report to retrieve information for.
    #' @param report_version Character string specifying the version of the report to retrieve information for.
    #'   Use "latest" to retrieve information for the latest version.
    #'
    #' @return A list containing the report name, description, and filters.
    #'
    #' @examples
    #' \dontrun{
    #' api <- EntrataAPI$new()
    #' report_info <- api$get_report_info("pre_lease")
    #' print(report_info)
    #' }
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
    #' Retrieve the latest version of a specific Entrata report.
    #'
    #' @param report_name Character string specifying the name of the report to retrieve the latest version for.
    #'
    #' @return The latest version of the report as a character string.
    #'
    #' @examples
    #' \dontrun{
    #' api <- EntrataAPI$new()
    #' latest_version <- api$get_latest_report_version("pre_lease")
    #' print(latest_version)
    #' }
    get_latest_report_version = function(report_name) {
      reports_list <- self$get_reports_list(latest_only = TRUE)
      reports_list |>
        dplyr::filter(report_name == !!report_name) |>
        dplyr::pull(report_version)
    },

    #' @description
    #' Generate a pre-lease report in Entrata.
    #'
    #' @param property_ids A vector of property IDs to include in the report.
    #' @param period_start The start date of the reporting period. Defaults to the current date.
    #' @param ... Additional parameters to pass to the report generation.
    #'
    #' @return A list containing the summary and details of the pre-lease report.
    #'
    #' @examples
    #' \dontrun{
    #' api <- EntrataAPI$new()
    #' pre_lease_report <- api$generate_pre_lease_report(
    #'   property_ids = c(1234, 5678),
    #'   period_start = as.Date("2023-01-01")
    #' )
    #' print(pre_lease_report)
    #' }
    generate_pre_lease_report = function(property_ids, period_start = Sys.Date(), ...) {
      report_params <- prep_pre_lease_report_params(
        latest_report_version = self$get_latest_report_version("pre_lease"),
        property_group_ids = property_ids,
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
    #' Retrieve the list of property IDs from the Entrata API.
    #'
    #' @return A vector of property IDs.
    #'
    #' @examples
    #' \dontrun{
    #' api <- EntrataAPI$new()
    #' property_ids <- api$get_property_ids()
    #' print(property_ids)
    #' }
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

  private = list(
    cache = NULL,
    logger = NULL,

    setup_caching = function() {
      if (!is.null(self$config$cache_dir)) {
        self$cache <- cachem::cache_disk(self$config$cache_dir)
      }
    },

    setup_logging = function() {
      # Implement logging setup here
    },

    generate_cache_key = function(endpoint, method, params) {
      # Generate a unique cache key based on the request details
      digest::digest(list(endpoint, method, params))
    },

    log_error = function(message) {
      # Implement error logging here
    },

    res_is_err = function(resp) {
      # Implement custom error detection logic here
      httr2::resp_status(resp) >= 400
    },

    res_err_body = function(resp) {
      # Implement custom error body extraction logic here
      httr2::resp_body_json(resp)
    },

    req_retry_is_transient = function(resp) {
      # Implement custom retry logic here
      httr2::resp_status(resp) %in% c(429, 500, 502, 503, 504)
    },

    req_retry_backoff = function(attempt) {
      # Implement custom backoff strategy here
      2 ^ attempt
    }
  )
)

#' Create an Entrata API client
#'
#' @description
#' Creates and initializes an EntrataAPI object with the provided configuration.
#'
#' @param config An APIConfig object or a list containing the Entrata API configuration.
#'   If not provided, a default configuration will be created using [create_entrata_config()].
#'
#' @return An initialized EntrataAPI object.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Create an API client with default configuration
#' api <- create_entrata_api()
#'
#' # Create an API client with custom configuration
#' config <- list(
#'   username = "your_username",
#'   password = "your_password",
#'   base_url = "https://your-subdomain.entrata.com"
#' )
#' api <- create_entrata_api(config)
#'
#' # Use the API client to get the list of reports
#' reports <- api$get_reports_list()
#' print(reports)
#' }
create_entrata_api <- function(config = NULL) {
  EntrataAPI$new(config)
}
