#' GMH Leasing R Package - `gmhleasr`
#'
#' *R package housing a shiny application and data processing logic related to
#' the leasing activities at GMH Communities.*
#'
#' @description
#' The `gmhleasr` package provides a comprehensive set of tools for interacting with the Entrata API.
#' It includes functions for managing API configurations, making API requests, and parsing responses.
#' The package is designed to simplify the process of retrieving and analyzing data from Entrata,
#' particularly focusing on leasing and property management information.
#'
#' @section Main Features:
#' \itemize{
#'   \item API Configuration Management: Easy setup and management of Entrata API credentials and settings.
#'   \item Request Handling: Robust functions for making API requests with built-in error handling and retrying capabilities.
#'   \item Response Parsing: Tools for parsing and cleaning API responses into usable R data structures.
#'   \item Caching: Efficient caching mechanisms to improve performance and reduce API calls.
#'   \item Data Retrieval: Specialized functions for retrieving property, lease, and report data from Entrata.
#' }
#'
#' @section Key Functions:
#' \itemize{
#'   \item \code{\link{create_entrata_config}}: Create and manage Entrata API configurations.
#'   \item \code{\link{entrata}}: Make requests to the Entrata API.
#'   \item \code{\link{entrata_properties}}: Retrieve property information from Entrata.
#'   \item \code{\link{entrata_leases}}: Fetch lease data from Entrata.
#'   \item \code{\link{get_entrata_reports_list}}: Get a list of available reports from Entrata.
#'   \item \code{\link{get_entrata_report_info}}: Retrieve detailed information about specific Entrata reports.
#' }
"_PACKAGE"

# Package environment -----------------------------------------------------

#' #' Package Environment
#' #'
#' #' @description
#' #' This environment stores package-level variables and caches.
#' #'
#' #' @keywords internal
#' pkg_env <- rlang::new_environment()
#'
#' #' @describeIn pkg_env Throttle settings for API requests
#' pkg_env$throttle <- list()
#'
#' #' @describeIn pkg_env Cache for throttled API requests
#' pkg_env$cache_throttle <- list()
#'
#' #' @describeIn pkg_env General cache for API responses and configurations
#' pkg_env$cache <- rlang::new_environment()
#'
#' #' @describeIn pkg_env Cache for Entrata configurations
#' pkg_env$cache$entrata_config <- list()
#'
#' #' @describeIn pkg_env Cache for Entrata API requests
#' pkg_env$cache$entrata_requests <- list()
#'
#' #' @describeIn pkg_env Cache for Entrata API responses
#' pkg_env$cache$entrata_responses <- list()
#'
#' #' @describeIn pkg_env Stores the last API request made
#' pkg_env$last_request <- NULL
#'
#' #' @describeIn pkg_env Stores the last API response received
#' pkg_env$last_response <- NULL
#'
#' #' @describeIn pkg_env Stores the last error encountered
#' pkg_env$last_error <- NULL
#'
#' #' @describeIn pkg_env Stores the current queue ID for long-running operations
#' pkg_env$queue_id <- NULL
#'
#' #' @describeIn pkg_env Environment for storing poller functions
#' pkg_env$pollers <- rlang::new_environment()
