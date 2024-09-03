#  ------------------------------------------------------------------------
#
# Title : Shiny Utilities
#    By : Jimmy Briggs
#  Date : 2024-08-30
#
#  ------------------------------------------------------------------------



#' Fluid Column - Shiny fluidRow + Column
#'
#' @param ... elements to include within the flucol
#' @param width width
#' @param offset offset
#'
#' @return A column wrapped in fluidRow
#' @export
#'
#' @importFrom shiny fluidRow column
flucol <- function(..., width = 12, offset = 0) {
  if (!is.numeric(width) || (width < 1) || (width > 12)) {
    stop("column width must be between 1 and 12")
  }

  shiny::fluidRow(
    shiny::column(
      width = width,
      offset = offset,
      ...
    )
  )
}

#' Insert Logo
#'
#' @param file file
#' @param style style
#' @param width width
#' @param ref ref
#'
#' @return tag
#' @export
#' @importFrom shiny tags img
insert_logo <- function(
    file,
    style = "background-color: #FFF; width: 100%; height: 100%;",
    width = NULL,
    ref = "#") {
  shiny::tags$div(
    style = style,
    shiny::tags$a(
      shiny::img(
        src = file,
        width = width
      ),
      href = ref
    )
  )
}

#' Icon Text
#'
#' Creates an HTML div containing the icon and text.
#'
#' @param icon fontawesome icon
#' @param text text
#'
#' @return HTML div
#' @export
#'
#' @examples
#' icon_text("table", "Table")
#'
#' @importFrom htmltools tagList
#' @importFrom shiny icon
icon_text <- function(icon, text) {
  if (is.character(icon)) i <- shiny::icon(icon) else i <- icon
  t <- paste0(" ", text)
  htmltools::tagList(htmltools::tags$div(i, t))
}
