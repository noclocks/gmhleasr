
#  ------------------------------------------------------------------------
#
# Title : HTTP Utilities
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------


# user agent --------------------------------------------------------------

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
  overwrite = FALSE
) {

  if (is.na(url)) {
    url <- ""
  } else {
    url <- paste0(" (", url, ")")
  }

  glue::glue("{package}/{version}{url}")
}
