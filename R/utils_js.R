
#  ------------------------------------------------------------------------
#
# Title : JavaScript Utilities
#    By : Jimmy Briggs
#  Date : 2024-08-19
#
#  ------------------------------------------------------------------------


# internal ----------------------------------------------------------------

.screen_size_js <- function() {
  readLines(
    system.file("assets/scripts/screen_size.js", package = "gmhleasr")
  ) |>
    paste(collapse = "\n")
}

.use_screen_size_js <- function() {
  htmltools::tags$head(
    htmltools::tags$script(
      type = "text/javascript",
      .screen_size_js()
    )
  )
}




# fetch_js ----------------------------------------------------------------

fetch_js <- function(url) {



}
