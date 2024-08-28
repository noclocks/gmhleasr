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

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}
