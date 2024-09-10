#  ------------------------------------------------------------------------
#
# Title : Entrata API Configuration
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------

#' Entrata API Configuration
#'
#' @description
#' Configure settings and options related to the Entrata API.
#'
#' @name entrata_config
#' @importFrom R6 R6Class
#' @importFrom cli cli_abort cli_warn
#' @importFrom yaml read_yaml write_yaml
APIConfig <- R6::R6Class(
  "APIConfig",
  public = list(
    #' @field username API username
    username = NULL,
    #' @field password API password
    password = NULL,
    #' @field base_url Base URL for API requests
    base_url = NULL,
    #' @field user_agent User agent string for API requests
    user_agent = NULL,
    #' @field rate_limit Rate limit for API requests
    rate_limit = NULL,
    #' @field cache_dir Directory for caching API responses
    cache_dir = NULL,
    #' @field cache_ttl Time-to-live for cached responses (in seconds)
    cache_ttl = 3600,

    #' @description
    #' Initialize a new APIConfig object
    #' @param username API username
    #' @param password API password
    #' @param base_url Base URL for API requests
    #' @param user_agent User agent string for API requests
    #' @param rate_limit Rate limit for API requests
    #' @param cache_dir Directory for caching API responses
    #' @param cache_ttl Time-to-live for cached responses (in seconds)
    initialize = function(
        username = NULL,
        password = NULL,
        base_url = NULL,
        user_agent = NULL,
        rate_limit = NULL,
        cache_dir = NULL,
        cache_ttl = 3600
    ) {
      self$username <- username
      self$password <- password
      self$base_url <- base_url
      self$user_agent <- user_agent %||% user_agent("gmhleasr")
      self$rate_limit <- rate_limit
      self$cache_dir <- cache_dir
      self$cache_ttl <- cache_ttl
      private$validate()
    },

    #' @description
    #' Print a summary of the configuration
    print = function() {
      cli::cli_text("Entrata API Configuration:")
      cli::cli_ul()
      cli::cli_li("Username: {self$username}")
      cli::cli_li("Base URL: {self$base_url}")
      cli::cli_li("User Agent: {self$user_agent}")
      cli::cli_li("Rate Limit: {self$rate_limit %||% 'Not set'}")
      cli::cli_li("Cache Directory: {self$cache_dir %||% 'Not set'}")
      cli::cli_li("Cache TTL: {self$cache_ttl} seconds")
      cli::cli_end()
      invisible(self)
    }
  ),

  private = list(
    validate = function() {
      if (is.null(self$username) || is.null(self$password)) {
        cli::cli_abort("Username and password must be provided.")
      }
      if (is.null(self$base_url)) {
        cli::cli_abort("Base URL must be provided.")
      }
      if (!is.null(self$cache_dir) && !dir.exists(self$cache_dir)) {
        dir.create(self$cache_dir, recursive = TRUE)
        cli::cli_warn("Created cache directory: {self$cache_dir}")
      }
    }
  )
)

#' Create Entrata API Configuration
#'
#' @description
#' Create a new Entrata API configuration object. By default, it looks for a config.yml file
#' in the current working directory. If found, it uses the configuration from this file.
#' Otherwise, it uses the provided arguments or falls back to default values.
#'
#' @param ... Named arguments to pass to APIConfig$new()
#' @param config_path Path to a YAML configuration file. Default is "config.yml" in the current directory.
#'
#' @return An APIConfig object
#'
#' @export
create_entrata_config <- function(..., config_path = "config.yml") {
  if (file.exists(config_path)) {
    cfg <- load_config(config_path)
    do.call(APIConfig$new, cfg)
  } else {
    args <- list(...)
    if (length(args) == 0) {
      cli::cli_warn("No configuration file found and no arguments provided. Using default values.")
    }
    do.call(APIConfig$new, args)
  }
}

#' Load Configuration from YAML
#'
#' @description
#' Load Entrata API configuration from a YAML file. It expects a structure with a "default"
#' section containing an "entrata" subsection with the configuration parameters.
#'
#' @param path Path to the YAML configuration file
#'
#' @return A list of configuration parameters
#'
#' @keywords internal
load_config <- function(path) {
  if (!file.exists(path)) {
    cli::cli_abort("Configuration file not found: {path}")
  }
  cfg <- yaml::read_yaml(path)
  if (!"default" %in% names(cfg) || !"entrata" %in% names(cfg$default)) {
    cli::cli_abort("Invalid configuration. Expected structure: default > entrata")
  }
  cfg$default$entrata
}

#' Save Configuration to YAML
#'
#' @description
#' Save Entrata API configuration to a YAML file.
#'
#' @param config An APIConfig object
#' @param path Path to save the YAML configuration file
#'
#' @return Invisible NULL
#'
#' @export
save_config <- function(config, path) {
  if (!inherits(config, "APIConfig")) {
    cli::cli_abort("config must be an APIConfig object")
  }
  cfg <- list(
    default = list(
      entrata = list(
        username = config$username,
        password = config$password,
        base_url = config$base_url,
        user_agent = config$user_agent,
        rate_limit = config$rate_limit,
        cache_dir = config$cache_dir,
        cache_ttl = config$cache_ttl
      )
    )
  )
  yaml::write_yaml(cfg, path)
  cli::cli_alert_success("Configuration saved to {path}")
  invisible(NULL)
}

#' Validate Entrata API Configuration
#'
#' @description
#' Validate proper configuration setup for Entrata API credentials and URLs.
#'
#' @param config An APIConfig object or a list containing the configurations.
#'
#' @return The original configuration object, invisibly.
#'
#' @export
validate_entrata_config <- function(config) {
  if (inherits(config, "APIConfig")) {
    return(invisible(config))
  }

  if (!is.list(config)) {
    cli::cli_abort("Invalid configuration. Provided configuration is not a list or APIConfig object.")
  }

  required_fields <- c("username", "password", "base_url")
  missing_fields <- setdiff(required_fields, names(config))

  if (length(missing_fields) > 0) {
    cli::cli_abort("Invalid configuration. Missing required fields: {paste(missing_fields, collapse = ', ')}")
  }

  APIConfig$new(
    username = config$username,
    password = config$password,
    base_url = config$base_url,
    user_agent = config$user_agent,
    rate_limit = config$rate_limit,
    cache_dir = config$cache_dir,
    cache_ttl = config$cache_ttl
  )
}
