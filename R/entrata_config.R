
#  ------------------------------------------------------------------------
#
# Title : Entrata API Configuration
#    By : Jimmy Briggs
#  Date : 2024-08-27
#
#  ------------------------------------------------------------------------



# validate ----------------------------------------------------------------

#' Validate Entrata API Configuration
#'
#' @description
#' Validate proper configuration setup for Entrata API credentials and URLs.
#'
#' @param cfg Either a path to a YAML configuration file or a list object containing the configurations.
#'
#' @return Invisibly returns the original configuration object.
#'
#' @export
#'
#' @importFrom cli cli_abort
#' @importFrom yaml read_yaml
validate_entrata_config <- function(cfg) {

  cfg_orig <- cfg

  # check if cfg is a path and not the object
  if (!is.list(cfg) && file.exists(cfg)) {
    cfg <- yaml::read_yaml(cfg)
  }

  # validate cfg is a list
  if (!is.list(cfg)) {
    cli::cli_abort("Invalid {.var cfg}. Provided {.var cfg} is not a list.")
  }

  # check configurations and use default
  if (!("default" %in% names(cfg))) {
    cli::cli_abort("Invalid {.var cfg}. Provided {.var cfg} is missing required {.field default} configuration.")
  }

  cfg <- cfg$default

  # validate required `entrata` configuration
  if (!("entrata" %in% names(cfg))) {
    cli::cli_abort("Invalid {.var cfg}. Provided {.var cfg} is missing required field: {.field entrata}.")
  }

  # extract entrata config
  cfg <- cfg$entrata

  # validate required fields - username and password
  if (!all(c("username", "password") %in% names(cfg))) {
    cli::cli_abort("Invalid {.var cfg}. Provided {.var cfg} is missing required fields: {.field username} and {.field password}.")
  }

  # validate base_url OR domain OR api_url
  if (!any(c("base_url", "domain", "api_url") %in% names(cfg))) {
    cli::cli_abort("Invalid {.var cfg}. Provided {.var cfg} is missing required fields: {.field base_url}, {.field api_url}, or {.field domain}.")
  }

  return(invisible(cfg_orig))

}
