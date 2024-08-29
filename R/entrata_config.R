#' Validate Entrata API Configuration
#'
#' @description
#' Validate proper configuration setup for Entrata API credentials and URLs.
#'
#' @param cfg Either a path to a YAML configuration file or a list object containing the configurations.
#'
#' @return The original configuration object, invisibly.
#'
#' @export
#'
#' @importFrom cli cli_abort
#' @importFrom yaml read_yaml
validate_entrata_config <- function(cfg) {
  cfg_orig <- cfg

  if (!is.list(cfg) && file.exists(cfg)) {
    cfg <- yaml::read_yaml(cfg)

    if (!("default" %in% names(cfg))) {
      cli::cli_abort("Invalid configuration. Provided configuration is missing required {.field default} configuration.")
    }

    cfg <- cfg$default

    if (!("entrata" %in% names(cfg))) {
      cli::cli_abort("Invalid configuration. Provided configuration is missing required {.field entrata} field.")
    }

    cfg <- cfg$entrata

  }

  if (!is.list(cfg)) {
    cli::cli_abort("Invalid configuration. Provided configuration is not a list.")
  }

  if (!all(c("username", "password") %in% names(cfg))) {
    cli::cli_abort("Invalid configuration. Provided configuration is missing required {.field username} and {.field password} fields.")
  }

  if (!any(c("base_url", "domain", "api_url") %in% names(cfg))) {
    cli::cli_abort("Invalid configuration. Provided configuration is missing required 'base_url', 'api_url', or 'domain' fields.")
  }

  invisible(cfg_orig)
}
