#' View List
#'
#' @description
#' View a list object in a JSON viewer via [listviewer::jsonedit()].
#'
#' @param listdata List or string data to view - Although designed for lists,
#'   `listdata` can be any data source that can be rendered into `JSON` through
#'   [jsonlite::toJSON()]. Alternately, `listdata` could be a character string
#'   of valid `JSON`. This might be helpful when dealing with an `API` response.
#' @inheritDotParams listviewer::jsonedit
#'
#' @return A JSON viewer of the list data.
#'
#' @export
#'
#' @importFrom listviewer jsonedit
#'
#' @examples
#' view_list(list(1, 2, 3))
view_list <- function(
    listdata = NULL,
    ...) {
  listviewer::jsonedit(listdata, ...)
}

#' @keywords internal
#' @noRd
is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

#' Is Boolean String
#'
#' @description
#' Checks if provided string represents a boolean (used by Entrata API).
#'
#' @param str Character string to check. Typically, with the Entrata API, "boolean"
#'   values are represented as quoted integers (`"0"` or `"1"`) representing
#'   `FALSE` and `TRUE`, respectively.
#'
#' @return `TRUE` if the string is a boolean string, `FALSE` otherwise.
#'
#' @export
#'
#' @examples
#' is_boolean_string("0")
is_boolean_string <- function(str) {
  str %in% c(as.character(as.integer(TRUE)), as.character(as.integer(FALSE)))
}
