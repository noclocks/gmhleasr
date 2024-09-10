#  ------------------------------------------------------------------------
#
# Title : Entrata Base API Request
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------

#' Send a request to the Entrata API
#'
#' @description
#' This function sends an HTTP request to the Entrata API. It handles authentication,
#' request construction, caching, and error handling. Use this function as a base
#' for creating specific API calls or for direct interaction with the Entrata API.
#'
#' @param endpoint Character string specifying the Entrata API endpoint to send the request to.
#'   If NULL, the request will be sent to the base API URL.
#' @param method Character string specifying the Entrata API method to use in the request.
#'   If NULL, a default method will be determined based on the endpoint.
#' @param method_version Character string specifying the version of the API method to use.
#'   Default is "r1".
#' @param method_params List of parameters to include in the request body's "method" object.
#' @param config An APIConfig object or a list containing the Entrata API configuration.
#'   If not provided, a default configuration will be created using [create_entrata_config()].
#' @param perform Logical indicating whether to perform the request (TRUE) or just construct
#'   the request object (FALSE).
#' @param extract Logical indicating whether to extract the response body (TRUE) or return
#'   the full response object (FALSE).
#' @param cache Logical indicating whether to use caching for this request.
#' @param ... Additional arguments to pass to [httr2::req_perform()].
#'
#' @return Depending on the `perform` and `extract` parameters:
#'   - If `perform` is FALSE: Returns an [httr2::request] object.
#'   - If `perform` is TRUE and `extract` is FALSE: Returns an [httr2::response] object.
#'   - If `perform` is TRUE and `extract` is TRUE: Returns the extracted response body (usually a list).
#'
#' @export
#'
#' @importFrom httr2 req_body_json req_auth_basic req_headers req_method
#' @importFrom httr2 req_url_path_append request req_perform resp_body_json resp_status
#' @importFrom rlang abort inform
#' @importFrom purrr compact
#' @importFrom glue glue
#' @importFrom futile.logger flog.error
#'
#' @examples
#' \dontrun{
#' # Create a configuration object
#' config <- create_entrata_config(
#'   username = "your_username",
#'   password = "your_password",
#'   base_url = "https://your-subdomain.entrata.com"
#' )
#'
#' # Make a simple request to get properties
#' properties <- entrata(
#'   endpoint = "properties",
#'   method = "getProperties",
#'   config = config,
#'   perform = TRUE,
#'   extract = TRUE
#' )
#'
#' # Print the properties
#' print(properties)
#'
#' # Make a request with parameters to get leases
#' leases <- entrata(
#'   endpoint = "leases",
#'   method = "getLeases",
#'   method_params = list(propertyId = 12345),
#'   config = config,
#'   perform = TRUE,
#'   extract = TRUE
#' )
#'
#' # Print the leases
#' print(leases)
#'
#' # Construct a request without performing it
#' req <- entrata(
#'   endpoint = "reports",
#'   method = "getReportList",
#'   config = config,
#'   perform = FALSE
#' )
#'
#' # Inspect the request
#' print(req)
#' }
#'
#' @seealso
#' [create_entrata_config()] for creating an API configuration object.
#' [validate_entrata_request()] for request validation.
#' [APIConfig] for the configuration object structure.
entrata <- function(
    endpoint = NULL,
    method = NULL,
    method_version = "r1",
    method_params = list(),
    config = create_entrata_config(),
    perform = FALSE,
    extract = FALSE,
    cache = TRUE,
    ...
) {
  # Validate inputs
  config <- if (inherits(config, "APIConfig")) config else create_entrata_config(config)

  if (is.null(method)) {
    method <- get_default_method(endpoint)
  }

  validate_entrata_request(endpoint, method, method_params)

  # Check cache
  cache_key <- NULL
  if (cache && !is.null(config$cache_dir)) {
    cache_key <- digest::digest(list(endpoint, method, method_version, method_params))
    cached_response <- memoise::memoise(identity, cache = cachem::cache_disk(config$cache_dir))(cache_key)
    if (!is.null(cached_response)) {
      rlang::inform("Returning cached response")
      return(cached_response)
    }
  }

  # Prepare request body
  req_body <- derive_req_body(method, method_version, method_params)

  # Build request
  req <- httr2::request(config$base_url) |>
    httr2::req_url_path_append("api", "v1") |>
    httr2::req_method("POST") |>
    httr2::req_auth_basic(config$username, config$password) |>
    httr2::req_headers(`Content-Type` = "application/json; charset=UTF-8") |>
    httr2::req_user_agent(config$user_agent) |>
    httr2::req_body_json(req_body)

  if (!is.null(endpoint)) {
    req <- req |> httr2::req_url_path_append(endpoint)
  }

  # Add retry capability
  req <- req |>
    httr2::req_retry(
      max_tries = 3,
      backoff = ~ 2 ^ .x
    )

  # Set timeout
  if (!is.null(config$timeout)) {
    req <- req |> httr2::req_timeout(config$timeout)
  }

  # Perform request if needed
  if (perform) {
    tryCatch({
      resp <- httr2::req_perform(req, ...)

      # Basic API error checking
      if (httr2::resp_status(resp) >= 400) {
        error_body <- httr2::resp_body_json(resp)
        error_message <- glue::glue("API request failed with status {httr2::resp_status(resp)}: {error_body$message}")
        futile.logger::flog.error(error_message)
        rlang::abort(error_message)
      }

      # Cache response if caching is enabled
      if (cache && !is.null(config$cache_dir) && !is.null(cache_key)) {
        memoise::memoise(identity, cache = cachem::cache_disk(config$cache_dir))(cache_key, resp)
      }

      if (extract) {
        return(httr2::resp_body_json(resp))
      } else {
        return(resp)
      }
    }, error = function(e) {
      error_message <- glue::glue("API request failed: {e$message}\nEndpoint: {endpoint}\nMethod: {method}")
      futile.logger::flog.error(error_message)
      rlang::abort(error_message, parent = e)
    })
  } else {
    return(req)
  }
}

#' Derive Entrata API Request Body
#'
#' @description
#' Derives the request body for an Entrata API request. This function is used internally
#' by the [entrata()] function to construct the JSON body of the API request.
#'
#' @param method Character string specifying the Entrata API method to use.
#' @param method_version Character string specifying the version of the API method to use.
#' @param method_params A named list of parameters to include in the request body.
#'
#' @return A list representing the request body, ready to be converted to JSON.
#'
#' @keywords internal
#'
#' @importFrom purrr compact
derive_req_body <- function(method, method_version, method_params) {
  list(
    auth = list(type = "basic"),
    requestId = as.integer(Sys.time()),
    method = list(
      name = method,
      version = method_version,
      params = method_params
    )
  ) |>
    purrr::compact()
}
