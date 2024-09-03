
#  ------------------------------------------------------------------------
#
# Title : App Configuration
#    By : Jimmy Briggs
#  Date : 2024-08-30
#
#  ------------------------------------------------------------------------


#' Get App Config
#'
#' @description
#' Retrieve configuration values from a the app's `config.yml` `YAML` file.
#'
#' @details
#' The only difference in this function and [config::get()] is that this function
#' sets the default value of the `file` argument to the app's `config.yml` file
#' and attempts to set the `config` argument to the value of the `APP_CONFIG_ACTIVE`.
#'
#' @inheritParams config::get
#'
#' @return The value of the configuration key.
#'
#' @export
#'
#' @importFrom config get
get_app_config <- function(
    value,
    config = Sys.getenv(
      "APP_CONFIG_ACTIVE",
      Sys.getenv(
        "R_CONFIG_ACTIVE",
        "default"
      )
    ),
    use_parent = TRUE,
    file = Sys.getenv(
      "APP_CONFIG_FILE",
      Sys.getenv(
        "R_CONFIG_FILE",
        app_sys("config/config.yml")
      )
    )
) {

  config::get(
    value = value,
    config = config,
    file = file,
    use_parent = use_parent
  )

}

#' App System File
#'
#' @description
#' Get the path to a file in the package.
#'
#' @param ... Path components.
#'
#' @return Path to file in package.
#'
#' @keywords internal
app_sys <- function(...) {

  system.file(file.path("app/www/", ...), package = "gmhleasr", mustWork = FALSE)

}
