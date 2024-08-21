
#  ------------------------------------------------------------------------
#
# Title : HTML Utilities
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------

# exported ----------------------------------------------------------------

#' HTML Utilities
#'
#' @name utils_html
#'
#' @description
#' - `centered()`: Centered HTML element
#' - `help_mark()`: Help icon with hover text
#' - `help_label()`: Label with help icon
#'
#' @param ... HTML elements
#' @param help_txt Help text
#' @param label_text Label text
#'
#' @return
#' - `centered()`: Centered HTML element
#' - `help_mark()`: Help icon with hover text
#' - `help_label()`: Label with help
NULL


#' @rdname utils_html
#' @export
#' @importFrom htmltools tags
centered <- function(...) {
  htmltools::tags$div(
    style = "text-align: center",
    ...
  )
}

#' @rdname utils_html
#' @export
#' @importFrom htmltools tags HTML
#' @importFrom shiny icon
help_mark <- function(help_txt) {

  htmltools::tagList(
    htmltools::tags$head(
      htmltools::tags$style(
        htmltools::HTML(
        ".helper {
          display: inline-block;
          position: relative;
          margin-left: 0.5em;
          margin-right: 0.5em;
          cursor: help;
        }
        .helper::after {
          content: attr(data-help);
          position: absolute;
          top: 100%;
          left: 50%;
          transform: translateX(-50%);
          display: none;
          z-index: 1000;
          padding: 0.5em;
          background-color: white;
          border: 1px solid #ccc;
          border-radius: 0.25em;
          box-shadow: 0 0.5em 1em rgba(0, 0, 0, 0.1);
          font-size: 0.75em;
          line-height: 1.5;
          text-align: left;
          white-space: normal;
          width: 20em;
        }
        .helper:hover::after {
          display: block;
        }"
      )
      )
    ),
    htmltools::tags$div(
      shiny::icon("question-circle"),
      class = "helper",
      `data-help` = help_txt
    )
  )

}

#' @rdname utils_html
#' @export
#' @importFrom htmltools tags
help_label <- function(label_text, help_text) {
  htmltools::tags$span(
    style = "display: inline-flex; align-items: center;",
    label_text,
    help_mark(help_text)
  )
}





