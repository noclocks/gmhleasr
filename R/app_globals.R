#  ------------------------------------------------------------------------
#
# Title : App Globals
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------


# environment -------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom utils packageVersion
.app_globals <- new.env()
.app_globals$running <- FALSE
.app_globals$version <- utils::packageVersion("gmhleasr")
.app_globals$app_resource_path <- system.file("app/www", package = "gmhleasr")

# helpers -----------------------------------------------------------------

#' App Global Variables
#'
#' @name app_globals
#'
#' @description
#' Set, get, and list global variables for the app.
#'
#' @param name A character string.
#' @param value A value.
#'
#' @return
#' - `set_app_global()`: Sets a global variable and invisibly returns the previous value,
#'   if any.
#' - `get_app_globals()`: Returns a list of all global variables.
#' - `get_app_global()`: Returns the value of a global variable by name.
NULL


#' @rdname app_globals
#' @export
set_app_global <- function(name, value) {
  before <- .app_globals[[name]]
  .app_globals[[name]] <- value
  return(invisible(before))
}

#' @rdname app_globals
#' @export
get_app_globals <- function() {
  .app_globals
}

#' @rdname app_globals
#' @export
get_app_global <- function(name) {
  .app_globals[[name]]
}
